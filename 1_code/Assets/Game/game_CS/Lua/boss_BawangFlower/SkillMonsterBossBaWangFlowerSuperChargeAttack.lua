local basefunc = require "Game/Common/basefunc"

SkillMonsterBossBaWangFlowerSuperChargeAttack = basefunc.class(Skill)
local M = SkillMonsterBossBaWangFlowerSuperChargeAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:MakeLister()
    self.lister = {}
	self.lister["BawangFlowerSuperChargeAttack"] = basefunc.handler(self,self.Ready)
end


function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data
	self.attack_num = 0
	self.super_skill_attack_num = 3
	self:CD()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = 0
    self.cd = 0
end


function M:Ready(data)
	M.super.Ready(self)
	if data then
		self.attack_num = data.attack_num
		self.super_skill_attack_num = data.super_skill_attack_num
	end
    -- 发送攻击状态数据包
    self:SendStateData()
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --攻击
	self:AttackTarget()

    

    --攻击完成
    self:Finish()
end

function M:Finish()
	self.super.Finish(self)
	Event.Brocast("stageRefreshBossNorAttackValue",0,self.super_skill_attack_num)
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


function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	return _obj.id
end

function M:AttackTarget()
	self.object.anim_pay:Play("attack",0,0)
	if self.attack_num and self.super_skill_attack_num then
		Event.Brocast("stageRefreshBossNorAttackValue",0,self.super_skill_attack_num)
	end
	local hit_data = self.object.data
	for k,v in pairs(self.object.config) do
		hit_data[k] = v
	end
	local damage = {}
	hit_data.hitOrgin = {id = self.object.id}
	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end


	ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	
	hit_data.bulletPrefabName = { "dufenhua_dufen_boss" }
	local _damage = basefunc.deepcopy(self.object.data.damage)
	hit_data.damage = { _damage }
	hit_data.attackFrom = "monster"
	hit_data.moveWay = {"BossWaveMove",}
	hit_data.hitEffect = {"ExtraPenetrateHit",} 
	hit_data.hitStartWay = {"IsHitSome"}
	hit_data.hitType = {"SectorShoot"}
	hit_data.bulletLifeTime = 3
	hit_data.speed = {10}
	hit_data.bulletNumDatas = {1}
	hit_data.attr = {"Poisoning#100"}
	hit_data.shouji_pre = {}
	hit_data.hitOrgin = {pos = self.object.attack_node.transform.position}

	Event.Brocast("monster_attack_hero", hit_data)
	
	hit_data.bulletPrefabName = { "GW_srh_zidan_boss" }

	hit_data.damage = { _damage }
	hit_data.attackFrom = "monster"
	hit_data.moveWay = {"LineMove",}
	hit_data.hitEffect = {"SampleHit",} 
	hit_data.hitStartWay = {"IsHitSomeOne"}
	hit_data.hitType = {"CircleShoot"}
	hit_data.bulletLifeTime = 6
	hit_data.speed = {10}
	hit_data.bulletNumDatas = {16}
	hit_data.attr = {}
	hit_data.shouji_pre = "GW_srh_baoza"
	hit_data.hitOrgin = {pos = self.object.attack_node.transform.position}
	Event.Brocast("monster_attack_hero",hit_data)
end