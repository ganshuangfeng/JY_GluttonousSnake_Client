local basefunc = require "Game/Common/basefunc"

SkillMonsterBossCrabSuperBombAttack = basefunc.class(Skill)
local M = SkillMonsterBossCrabSuperBombAttack

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
    self.attackTargetId = self:GetAttackTarget()
	self.attackTargetPos1 = ObjectCenter.GetObj(self.attackTargetId).transform.position
	self.attackTargetPos2 = self.attackTargetPos1 + Vector3.New(math.random(-9,9),math.random(-9,9),0)
	self.attackTargetPos3 = self.attackTargetPos1 + Vector3.New(math.random(-6,6),math.random(-6,6),0)
	self.attackTargetPos4 = self.attackTargetPos1 + Vector3.New(math.random(-9,9),math.random(-9,9),0)
	self.attackTargetPos5 = self.attackTargetPos1 + Vector3.New(math.random(-6,6),math.random(-6,6),0)
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
	if t == 2 then
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
		return _obj.id
	end
	return nil
end

function M:AttackTarget()
	Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6, delta_t=0.1})
	local hit_data = {}
	--- 从子弹配置中
	local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
	for k, v in pairs(bullet_config) do
		hit_data[k] = v
	end

	local damage = {}
	hit_data.attackFrom = "monster"
	local start_pos_1 = self.object.attack_node_zuo.transform.position
	local start_pos_2 = self.object.attack_node_you.transform.position
	hit_data.hitTarget = {angel = 0}
	hit_data.damage = { GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	end

	local seq = DoTweenSequence.Create()
	for i = 1,5 do
		
		seq:AppendInterval((i - 1) * 0.1)
		seq:AppendCallback(
			function()
				local start_pos = start_pos_1
				if math.random() > 0.5 then
					start_pos = start_pos_2
				end
				hit_data.hitOrgin = { pos = start_pos }
				if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
					hit_data.hitTarget = {pos = self["attackTargetPos"..i]}
				else
					hit_data.hitTarget = {angel = math.random(0,360)}
				end
		
				Event.Brocast("monster_attack_hero", hit_data)
			end
		)
	end


	--攻击完成
    self:Finish()
end