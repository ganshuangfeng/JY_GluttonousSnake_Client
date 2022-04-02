local basefunc = require "Game/Common/basefunc"

SkillMonsterBossStoneFigureSuperStoneBoomAttack = basefunc.class(Skill)
local M = SkillMonsterBossStoneFigureSuperStoneBoomAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
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

function M:Before()
	self.super.Before(self)
	Event.Brocast("BossStoneSuperBoomCharge")
	self.trigger_seq = DoTweenSequence.Create()
	self.trigger_seq:AppendInterval(self.data.beforeCd)
	self.trigger_seq:AppendCallback(function()
		self.object.anim_pay:Play("attack2",0,0)
	end)
	self.trigger_seq:AppendInterval(0.6)
	self.trigger_seq:AppendCallback(function()
		self:AttackTarget()
		self.trigger_seq = nil
	end)
end

function M:Trigger(data)
	M.super.Trigger(self)

end


function M:Finish(data)
	M.super.Finish(self)
	if self.trigger_seq then
		self.trigger_seq:Kill()
		self.trigger_seq = nil
		for k,v in pairs(self.object.stones) do
			v:OnBoom({damage = 0})
		end
	end
	self.object.anim_pay:Play("idle",0,0)
	Event.Brocast("stageRefreshBossNorAttackValue",0,self.max_attack_num)
end

function M:OnCD()

end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
end

--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t.type == 3 then
		self.attack_num = t.attack_num
		self.max_attack_num = t.max_attack_num
		self:Active()
	end

end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self }, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

function M:AttackTarget()
	Event.Brocast("ui_shake_screen_msg", {t=0.4, range=1.5,})
	ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	Event.Brocast("stageRefreshBossNorAttackValue",0,self.max_attack_num)
	for k,v in pairs(self.object.stones) do
		v:OnBoom({damage =  0})
	end
	Event.Brocast("hit_hero",{damage =  GetSkillOneDamage( self , "damage_bei" , "damage_fix" ),attr = "IgnoreInvicble", id = GameInfoCenter.GetHeroHead().id,})
	SkillManager.SkillCreate({type="dizziness"})
	local _r_fx = NewObject("BOOS_shixiang_kuosan",MapManager.GetMapNode())
	_r_fx.transform.position = self.object.hand_right.transform.position
	local _l_fx = NewObject("BOOS_shixiang_kuosan",MapManager.GetMapNode())
	_l_fx.transform.position = self.object.hand_left.transform.position
	self.attack_seq = DoTweenSequence.Create()
	self.attack_seq:AppendInterval(0.5)
	self.attack_seq:AppendCallback(function()
		Event.Brocast("ui_shake_screen_msg", {t=0.4, range=1.5,})
	end)
	self.attack_seq:AppendInterval(0.5)
	self.attack_seq:AppendCallback(function()
		--攻击完成
		self:Finish()
		self.attack_seq = nil
	end)
end
function M:Exit()
	if self.trigger_seq then
		self.trigger_seq:Kill()
		self.trigger_seq = nil
	end
	if self.attack_seq then
		self.attack_seq:Kill()
		self.attack_seq = nil
	end
	self.super.Exit(self)
end