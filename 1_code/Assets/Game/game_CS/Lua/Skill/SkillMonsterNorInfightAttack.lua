local basefunc = require "Game/Common/basefunc"

SkillMonsterNorInfightAttack = basefunc.class(Skill)
local M = SkillMonsterNorInfightAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range = 3
    self.range2 = self.range * self.range

    self.data.shouji_pre = self.data.shouji_pre or "xx_shouji"

end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:CD()
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

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
    -- 一直找目标，找到后切换到ready状态
    self.attackTargetId = self:GetAttackTarget()
    if not self.attackTargetId then
        return
    end

    self:Ready()
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --攻击
    self:AttackTarget()

    --攻击完成
    self:After()
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


function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.range2 then
			return _obj.id
        end
	end
	return nil
end

function M:AttackTarget()

	local pos = ObjectCenter.GetObj(self.attackTargetId).transform.position

	CSEffectManager.PlayBulletBoom({position = pos},self.data.shouji_pre)
	
	Event.Brocast("hit_hero",{damage = self.object.damage, id = self.attackTargetId})

end