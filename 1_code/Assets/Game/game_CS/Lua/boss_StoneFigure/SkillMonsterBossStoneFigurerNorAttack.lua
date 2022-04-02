--遗迹石像 普通攻击
local basefunc = require "Game/Common/basefunc"

SkillMonsterBossStoneFigurerNorAttack = basefunc.class(Skill)
local M = SkillMonsterBossStoneFigurerNorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:Init(data)
	M.super.Init( self )
	self.data = data or self.data
	self.attack_num = 0
	self._total_attack_num = 0
	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		self.super_skill_attack_num_1 = 1
		self.super_skill_attack_num_2 = 2
		self.super_skill_attack_num_3 = 3
	else
		self.super_skill_attack_num_1 = 2
		self.super_skill_attack_num_2 = 4
		self.super_skill_attack_num_3 = 5
	end
	self:CD()
	Event.Brocast("stageRefreshBossNorAttackValue",self._total_attack_num,self.super_skill_attack_num_3 + 2)
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

function M:Trigger()
	M.super.Trigger(self)	
	self.object.anim_pay:Play("attack1",0,0)
	self.trigger_seq = DoTweenSequence.Create()
	self.trigger_seq:AppendInterval(0.6)
	self.trigger_seq:AppendCallback(function()
		self:AttackTarget()
		self.trigger_seq = nil
	end)
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

function M:Finish()
	self.super.Finish(self)
	self.attack_num = self.attack_num + 1
	
	if self.attack_num == self.super_skill_attack_num_1 then
		self._total_attack_num = self._total_attack_num + 1
		Event.Brocast("monsterBossSuperAttack",{type = 1,attack_num = self._total_attack_num,max_attack_num = self.super_skill_attack_num_3 + 2})
	elseif self.attack_num == self.super_skill_attack_num_2 then
		self._total_attack_num = self._total_attack_num + 1
		Event.Brocast("monsterBossSuperAttack",{type = 2,attack_num = self._total_attack_num,max_attack_num = self.super_skill_attack_num_3 + 2})
	elseif self.attack_num >= self.super_skill_attack_num_3 then
		self._total_attack_num = self._total_attack_num + 1
		Event.Brocast("monsterBossSuperAttack",{type = 3,attack_num = self._total_attack_num,max_attack_num = self.super_skill_attack_num_3 + 2})
		self.attack_num = 0
		self._total_attack_num = 0
	end
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("attack", {skillObject = self}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("norAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

function M:AttackTarget()
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_juxiang_jiguang.audio_name)
	--随机从左往右或者从右往左移动
	self._total_attack_num = self._total_attack_num + 1
	Event.Brocast("stageRefreshBossNorAttackValue",self._total_attack_num,self.super_skill_attack_num_3 + 2)
	local l_or_r_rdn = math.random(1,2)
	local fx_pre_l = NewObject("BulletPrefab_StoneFigureLaser",MapManager.GetMapNode())
	fx_pre_l.transform.position = self.object.eyeL.transform.position
	-- local fx_pre_r = NewObject("BulletPrefab_StoneFigureLaser",MapManager.GetMapNode())
	-- fx_pre_r.transform.position = self.object.eyeR.transform.position
	if l_or_r_rdn == 2 then
		fx_pre_l.transform.localScale = Vector3.New(-1,1,1)
		-- fx_pre_r.transform.localScale = Vector3.New(-1,1,1)
	end
	
	local collider_l = fx_pre_l.transform:Find("node/@laser_node/@laser_sprite"):GetComponent("ColliderBehaviour")
	if IsEquals(collider_l) then
		collider_l:SetLuaTable(self)
		collider_l.luaTableName = "SkillMonsterBossStoneFigurerNorAttack"
	end

	-- local collider_r = fx_pre_r.transform:Find("node/@laser_node/@laser_sprite"):GetComponent("ColliderBehaviour")
	-- if IsEquals(collider_r) then
	-- 	collider_r:SetLuaTable(self)
	-- 	collider_r.luaTableName = "SkillMonsterBossStoneFigurerNorAttack"
	-- end
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function()
		fx_pre_l.transform:GetComponent("Animator").enabled = true
		-- fx_pre_r.transform:GetComponent("Animator").enabled = true
	end)
	seq:AppendInterval(3)
	seq:AppendCallback(function()
		Destroy(fx_pre_l)
		-- Destroy(fx_pre_r)
		self:Finish()
	end)
end

function M:OnTriggerEnter2D(collision)
	local collision_id = tonumber(collision.gameObject.name)
	local hero_head = GameInfoCenter.GetHeroHead()
	if hero_head.id == collision_id then
		if self.object and self.object.data then
			Event.Brocast("hit_hero",{damage =  GetSkillOneDamage( self , "damage_bei" , "damage_fix" ), id = collision_id,})
		end
	end
end
function M:Exit()
	if self.trigger_seq then
		self.trigger_seq:Kill()
		self.trigger_seq = nil
	end
	self.super.Exit(self)
end