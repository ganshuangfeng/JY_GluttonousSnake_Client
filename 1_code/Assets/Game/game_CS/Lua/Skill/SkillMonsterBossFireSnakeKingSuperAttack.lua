local basefunc = require "Game/Common/basefunc"

SkillMonsterBossFireSnakeKingSuperAttack = basefunc.class(Skill)
local M = SkillMonsterBossFireSnakeKingSuperAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:MakeLister()
    self.lister = {}
	self.lister["FireSnakeKingSuperAttack"] = basefunc.handler(self,self.Ready)
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data
	self:CD()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 0
    self.cd = self.data.cd
end

function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	return _obj
end

function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

function M:Finish()
	M.super.Finish(self)
	Event.Brocast("stageRefreshBossNorAttackValue",0,3)
end

--触发
function M:Trigger()
	M.super.Trigger(self)
	self.object.anim_pay:Play("attack",0,0)
	local target = self:GetAttackTarget()
	local my_pos = self.object.transform.position
	local target_pos = target.transform.position

	self.angel = Vec2DAngle( (target_pos - my_pos).normalized )
	self.angel = self.angel % 360
	
	if self.object and IsEquals(self.object.transform) then
		self.object.anim_pay.speed = 1
	end

	local hit_data = {}
	--- 从子弹配置中
	local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    basefunc.merge( bullet_config , hit_data )

	hit_data.hitOrgin = { pos = my_pos }
	hit_data.hitTarget = {angel = self.angel}
	hit_data.damage = {self.object.config.damage,self.object.config.damage}
	hit_data.attackFrom = "monster"


	self.object.vehicle:Stop()
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)

	for i = 1,3 do
		seq:AppendCallback(
			function()
				Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})
				ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
				
				hit_data.hitTarget = {angel = i * 9}
				Event.Brocast("monster_attack_hero",hit_data)
			end
		)

		seq:AppendInterval(1)
	end
	seq:AppendCallback(function()
		self:After()
	end)
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self , animName="attack2"}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end