local basefunc = require "Game/Common/basefunc"

SkillMonsterBossSuperAttack = basefunc.class(Skill)
local M = SkillMonsterBossSuperAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.at_range = self.object.config.attack_range
    self.at_range_squ = self.at_range * self.at_range
    self.targetV = nil
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:CD()
end

function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

function M:Trigger(data)
	M.super.Trigger(self)
	self.object.anim_pay.speed = 0
	self.isLock = false

	if self.object and IsEquals(self.object.transform) then
		self.object.anim_pay.speed = 1
		self.object.anim_pay:Play("attack2", 0, 0)
	end
end

function M:Finish(data)
	M.super.Finish(self)
	Event.Brocast("stageRefreshBossNorAttackValue",0,4)
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --攻击
    self:AttackTarget()
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
	self.lister["monsterBossAttack2AnimFinish"] = basefunc.handler(self, self.on_monsterBossAttackAnimFinish)
end

--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t == 1 then
	    if self.skillState ~= SkillState.active then
	        return
	    end
	    self:Ready()
	end
end

function M:on_monsterBossAttackAnimFinish(  )
	--- 寻找最近的目标
	local my_pos = self.object.transform.position

	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target then
		local target_pos = target.transform.position
		
		if CSModel.Is2D then
			if self.object.transform.position.x > target_pos.x then
				self.object.node.localScale = Vector3.New(-1,1,1)
			else
				self.object.node.localScale = Vector3.New(1,1,1)
			end
		else
			AxisLookAt(self.object.transform , target_pos , Vector3.up)
		end
	end

	--- 发消息给普通攻击技能，有无目标都要发
	self.targetV = true
end


--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self , }, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end


--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
    self.targetV = nil
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
	if self.isLock then
		return
	end
	if not self.targetV then
		return
	end

	--[[local hit_data = self.object.data
	for k,v in pairs(self.object.config) do
		hit_data[k] = v
	end--]]
	
	local hit_data = {}
    --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

	
	hit_data.hitOrgin = { pos = self.object.superAttackNode.transform.position }

	local my_pos = self.object.transform.position

	local my_pos = self.object.transform.position
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	local angel = nil
	if target then
		local target_pos = target.transform.position
		angel = Vec2DAngle( (target_pos - my_pos).normalized )

		local dis = tls.pGetDistanceSqu( my_pos , target_pos )
		if dis > self.at_range_squ then
			target = nil
		end
	end

	hit_data.hitTarget = {angel = angel or math.random(0,360)}

	--local damage = {}
	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }  -- {self.object.config.damage}
	
	--ExtendSoundManager.PlaySound( audio_config.cs.boss_attack1.audio_name )
	if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end

	hit_data.attackFrom = "monster"

	Event.Brocast("monster_attack_hero", hit_data)

	Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6, delta_t=0.1})

	if target then
		SkillManager.SkillCreate({type="dizziness"})
	end

	--攻击完成
    self:After()

end