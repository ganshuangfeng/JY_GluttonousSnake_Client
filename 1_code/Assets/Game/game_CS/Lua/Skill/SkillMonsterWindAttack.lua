local basefunc = require "Game/Common/basefunc"

SkillMonsterWindAttack = basefunc.class(Skill)
local M = SkillMonsterWindAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range2 = self.object.attack_range * self.object.attack_range

    self.data.shouji_pre = self.data.shouji_pre or "xx_shouji"
    self.sprint_time = 3
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:CD(1)
end


function M:CD(_temp_cd)
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 1
    self.cd = _temp_cd or self.data.cd
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
    if self.fx_pre then
        Destroy(self.fx_pre)
    end
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
function M:Trigger()
    self.super.Trigger(self)
    if self.object.config.classname == "MonsterWind" then 
        self.fx_pre = NewObject("GW_skill_feng_g",self.object.transform)
    elseif self.object.config.classname == "MonsterXianrenzhang" then
        self.fx_pre = NewObject("GW_YAN_tw",self.object.tuowei_node.transform)
    end
    self.object.anim_pay:Play("attack",0,0)
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end

    --冲刺
    self:Sprint(dt)

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
-- 冲刺
function M:Sprint(dt)
    self.sprint_time = self.sprint_time - dt
    if self.attackTargetId then
        local target = ObjectCenter.GetObj(self.attackTargetId)
        self.object.enableMove = true
        self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, target.transform.position )
        self.object.vehicle:Start()
        local range = 3
		local dis = tls.pGetDistanceSqu(self.object.transform.position, target.transform.position)
        if dis <= range then
            Event.Brocast("hit_hero",{damage = self.object.data.damage, id = target.id,})
        end
        if self.sprint_time < 0 then
            if self.fx_pre then
                Destroy(self.fx_pre)
                self.fx_pre = nil
            end
            self.object.anim_pay:Play("idle",0,0)
            self.object.enableMove = false
            self.sprint_time = 3
            self:After()
        end
    end
end
