local basefunc = require "Game/Common/basefunc"

SkillMonsterBossCrabSuperSandAttack = basefunc.class(Skill)
local M = SkillMonsterBossCrabSuperSandAttack

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

function M:Before(data)
	M.super.Before(self)

	--以自身为中心创建多个圆圈
	local max_radius = 16
	local min_radius = 8
	local circle_count = math.random(4,6)
	self.effect_positions = {}
	for i = 1,circle_count do
		local angle = i / circle_count * 2 * math.pi
		local radius = math.random() * (max_radius - min_radius) + min_radius
		local vec = Vector3.New(math.cos(angle),math.sin(angle),0) * radius
		self.effect_positions[i] = vec + self.object.transform.position
	end
	local show_interval = 2
	self.isLock = true
	self.object.anim_pay.speed = 0
	for k,v in ipairs(self.effect_positions) do
		CSEffectManager.PlayBossWarning(
									"BossWarning3",
									v,
									2.3,
									0.6,
									function ()
									end)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2.3)
	seq:AppendCallback(function()
		self.isLock = false
		self.object.anim_pay.speed = 1
		self.object.anim_pay:Play("attack_2", 0, 0)
	end)
end


function M:Finish(data)
	M.super.Finish(self)
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

end

function M:Trigger()
	M.super.Trigger(self)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.75)
	seq:AppendCallback(function()
		self:AttackTarget()
	end)
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
end

--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t == 1 then
		self:Ready()
	end

end

function M:on_monsterBossAttackAnimFinish(  )
	--- 寻找最近的目标
	local my_pos = self.object.transform.position

	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target then
		local target_pos = target.transform.position
	end
	self:AttackTarget()
end


--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self ,}, nil, self)
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
	Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6, delta_t=0.1})
	for k,v in ipairs(self.effect_positions) do
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

		local damage = {}
		hit_data.attackFrom = "monster"
		hit_data.hitOrgin = { pos = v }
		hit_data.hitTarget = {angel = 0}
		hit_data.damage = { GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }

		--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
		if bullet_config.audio_name then
	        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	    end
	
		Event.Brocast("monster_attack_hero", hit_data)
	
		
	end

	--攻击完成
    self:Finish()
end