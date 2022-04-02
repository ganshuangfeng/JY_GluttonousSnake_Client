local basefunc = require "Game/Common/basefunc"

SkillMonsterSprintInfightAttack = basefunc.class(Skill)
local M = SkillMonsterSprintInfightAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range2 = self.object.attack_range * self.object.attack_range

    self.data.shouji_pre = self.data.shouji_pre or "xx_shouji"
    self.speed = 20
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:Active()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 3
    self.cd = self:GetRandomCD(self.data.cd)
end


function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end



function M:Finish(data)
    self.sprinting = false

    M.super.Finish(self)
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
    -- 一直找目标，找到后切换到ready状态
    if not self:GetAttackTarget() then
        return
    end

    self:Ready()
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --冲刺
    self:Sprint()

end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("attack", {skillObject = self}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("norAttack", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end




-- 判断两点间直线上的格子是否都可通过
local function CheckPathOk(p1,p2)
    --local npg = GameInfoCenter.GetMapNotPassGridData()
    local npg = GetMapNotPassGridData(self.object)

    if not npg then
        return true
    end

    p1,p2 = get_grid_pos( self.object , p1 , true ),get_grid_pos( self.object , p2 , true )

    --local gsz = MapManager.GetGridSize()
    local gsz = GetGridSize(self.object)

    local dis = tls.pGetDistance(p1,p2)

    local n = math.ceil(dis/gsz)-1

    local vd = tls.pSub(p2,p1)
    vd = tls.pNormalize(vd)

    local dl = {}
    for i=1,n do
        local d = tls.pMul(vd,i*gsz)
        local p = Vector3.New(p1.x+d.x,p1.y+d.y,0)
        local k = GetMapNoByPos( self.object , p ) --GetPosTagKeyStr( get_grid_pos( p ) )
        if npg[k] then
            return false
        end
    end
    
    return true
end

function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.range2 and CheckPathOk(self.object.transform.position,_obj.transform.position) then

            self.attackTargetId = _obj.id
            self.targetPos = _obj.transform.position
			return true

        end
	end
	return nil
end


-- 冲刺
function M:Sprint()
    if self.sprinting then
        return
    end
    self.sprinting = true

    local pp = {x=self.targetPos.x,y=self.targetPos.y,z=0}
    local seq = DoTweenSequence.Create()
    seq:Append(self.object.transform:DOMove(pp, 0.2))
    seq:OnKill(function ()
        self.object.vehicle:SetPos(pp)
        self:AttackTarget()
    end)

end

function M:AttackTarget()

	local pos = ObjectCenter.GetObj(self.attackTargetId).transform.position

	CSEffectManager.PlayBulletBoom({position = pos},self.data.shouji_pre)
	
	Event.Brocast("hit_hero",{damage = self.object.damage, id = self.attackTargetId})

    --攻击完成
    self:After()
end