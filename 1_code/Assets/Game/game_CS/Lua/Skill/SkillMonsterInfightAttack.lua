local basefunc = require "Game/Common/basefunc"

SkillMonsterInfightAttack = basefunc.class(Skill)
local M = SkillMonsterInfightAttack
M.name = "SkillMonsterInfightAttack"

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range2 = self.object.attack_range * self.object.attack_range

    self.data.shouji_pre = self.data.shouji_pre or "xx_shouji"
    
    --self.speed = 25
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:Active()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 3
    self.cd = self.data.cd
end


function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end


function M:Finish(data)
    self.sprinting = false
    self.object.enableRot = true
    M.super.Finish(self)

	print("<color=yellow>xxxx----------海螺 技能 结束</color>")
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

	self:AttackTarget()
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
function M:FindPathPoint(p1,p2,dis)
    --local npg = GameInfoCenter.GetMapNotPassGridData()
    local npg = GetMapNotPassGridData(self.object)
    local pos = p2
    if not npg then
        return true
    end

    p1 = ConvertToGrid( self.object , p1 )
    p2 = ConvertToGrid( self.object , p2 )

    --local gsz = MapManager.GetGridSize()
    --local sceen_size = MapManager.GetMapSize()
    local gsz = GetGridSize( self.object )
    local sceen_size = GetSceenSize( self.object )

    local n = math.ceil(dis/gsz)-1
    local n2 = n + 2

    local vd = tls.pSub(p2,p1)
    vd = tls.pNormalize(vd)

    local dl = {}
    for i=1,n2 do
        local d = tls.pMul(vd,i*gsz)
        local p = Vector3.New(p1.x+d.x,p1.y+d.y,0)

        local out = false
        if p.x < -sceen_size.width/2 or p.x > sceen_size.width/2 
            or p.y < -sceen_size.height/2 or p.y > sceen_size.height/2 then
                out = true
        end
        p = ConvertToPos( self.object , p)
        local k = GetMapNoByPos( self.object , p  )  --GetPosTagKeyStr( get_grid_pos( p ) )
        if npg[k] or out then

            if i <= n then

                return false

            else
                return true, pos

            end

        end

        pos = p

    end
    
    return true, pos
end

function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.range2 then
			self.attackTargetId = _obj.id
			self.targetPos = p
			return true
        end
	end
	return nil
end


function M:Before()
	print("<color>后摇~！3333333333333333333333333333333333333</color>")
    M.super.Before(self)
end

function M:AttackTarget()
	print("<color>开始攻击~！3333333333333333333333333333333333333</color>")

	--self:AttackStart()
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.5)
    seq:AppendCallback(function()
		if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) and self.object then
			local dis = tls.pGetDistanceSqu(self.object.transform.position, ObjectCenter.GetObj(self.attackTargetId).transform.position)
			if dis <= self.range2 then
				print("<color=red>近战集中了！！！！！！！！！！！！！！！</color>")
			end
		end
    end)
	seq:AppendInterval(3)
	seq:AppendCallback(
		function()
			--self:AttackOver()
		end
	)
    self:After()
end

function M:AttackStart()
	self.SpModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
	object = self.object , skill = self , 
	modify_key_name = "speed" , 
	modify_type = 3 , 
	modify_value = 0 , 
	} )

	local now_speed = ModifierSystem.GetObjProp( self.object , "speed" ) 
	self.object.vehicle:SetMinSpeed( now_speed  )
	self.object.vehicle:SetMaxSpeed( now_speed  )
end

function M:AttackOver()
	self.SpModifier:Exit()
	local now_speed = ModifierSystem.GetObjProp( self.object , "speed" ) 
	self.object.vehicle:SetMinSpeed( now_speed  )
	self.object.vehicle:SetMaxSpeed( now_speed  )
end