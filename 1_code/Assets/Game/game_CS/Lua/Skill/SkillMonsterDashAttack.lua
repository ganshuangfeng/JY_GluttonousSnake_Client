local basefunc = require "Game/Common/basefunc"

SkillMonsterDashAttack = basefunc.class(Skill)
local M = SkillMonsterDashAttack

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

function M:Exit(data)
    M.super.Exit(self)

    self:ClearResources()
end

function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

---- 清理资源
function M:ClearResources()
    if self.warningEffectSeq then
        self.warningEffectSeq:Kill()
        self.warningEffectSeq = nil
    end

    if self.attackWarningPre then
        self.attackWarningPre:Exit()
        self.attackWarningPre = nil
    end

end

function M:Finish(data)
    self.sprinting = false
    self.object.enableRot = true
    M.super.Finish(self)
    --print("<color=yellow>xxx------------- 小蛇 攻击技能 finish </color>")
    --print("<color=yellow>xxx----------self.skillState:</color>" , self.skillState )
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
    --print("xxx-------------SendStateData:")
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
        --dump( { p1,p2,dis , i , n2 , p } , "xxx--------FindPathPoint")
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
            local ok,p = self:FindPathPoint(self.object.transform.position,_obj.transform.position,self.object.attack_range)
            if ok then
                self.attackTargetId = _obj.id
                self.attackTargetPos = _obj.transform.position
                self.targetPos = p
                --print( "<color=red>xxx------------GetAttackTarget true </color>" )
    			return true
            end
        end
	end
    --print( "<color=red>xxx------------GetAttackTarget false </color>" )
	return nil
end


function M:Before()
    --print("<color=blue>xxxx----------begore</color>" , debug.traceback() )
    M.super.Before(self)

    if self.skillState == SkillState.before then

        self.object:UpdateRot()
        self.object.enableRot = false

        --local gsz = MapManager.GetGridSize()
        local gsz = GetGridSize(self.object)

        local dis = tls.pGetDistance(self.targetPos , self.object.transform.position)
        local sy = dis / gsz

        local angel = Vec2DAngle( (self.targetPos - self.object.transform.position).normalized )
        angel = angel % 360
        
        self.warningEffectSeq = CSEffectManager.PlayBossWarning(
                        "RectWarning_1",
                        self.object.warnNode.transform.position,
                        self.cd,
                        0,
                        function (obj)
                            obj.transform.rotation = Quaternion.Euler(0, 0, angel)
                        end,
                        nil,
                        Vector3.New(1,1,1))

    end

end


-- 冲刺
function M:Sprint()
    --print("<color=yellow>xxx--------------sprint 11</color>")
    if self.sprinting then
        return
    end
    --print("<color=yellow>xxx--------------sprint 22</color>")
    self.sprinting = true

	--播放攻击动画
	if self.object.curDir and self.object.anim_pay then
		self.object.anim_pay:Play("attack" .. self.object.curDir,0,0)
	end
    local seq = DoTweenSequence.Create()
    seq:Append(self.object.transform:DOMove(self.targetPos, 0.5))
    seq:OnKill(function ()
        if self.object and self.object.isLive then 
            self.object.vehicle:SetPos(self.targetPos)
            --- 朝向目标
            local tarVector = { x = self.attackTargetPos.x - self.targetPos.x , y = self.attackTargetPos.y - self.targetPos.y }
            self.object.vehicle:SetRot(Vec2DAngle(tarVector) ) 
            --dump( self.targetPos , "<color=yellow>xxxx---------冲刺结束：</color>" )
            self:AttackTarget()
        end
    end)

end

function M:AttackTarget()

    -- 冲撞即攻击

    --攻击完成
    self:After()
end
