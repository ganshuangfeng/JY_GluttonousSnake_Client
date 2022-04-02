local basefunc = require "Game/Common/basefunc"

SkillMonsterBossBaWangFlowerNorAttack = basefunc.class(Skill)
local M = SkillMonsterBossBaWangFlowerNorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data
	self.attack_num = 0
	self.super_skill_attack_num = 5
	Event.Brocast("stageRefreshBossNorAttackValue",self.attack_num,self.super_skill_attack_num)
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

function M:Before()
	if self.data.beforeCd then
        self.cd = self.data.beforeCd
        self.skillState = SkillState.before
		self.attack_num = self.attack_num + 1
		if self.attack_num > self.super_skill_attack_num then
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.5)
			seq:AppendCallback(function()
				if IsEquals(self.object.transform) then
					CSEffectManager.PlayShowAndHideAndCall(MapManager.GetMapNode(),"kuosan_daduan_quan",nil,self.object.transform.position,2)
				end
			end)
		elseif self.attack_num == 3 then
			Event.Brocast("BawangFlowerSuperAttack",{attack_num = self.attack_num,super_skill_attack_num = self.super_skill_attack_num})
			self:Finish()
			return
		elseif self.attack_num >= 3 then
			local rdn = math.random(1,2)
			if rdn == 2 then
				Event.Brocast("BawangFlowerSuperAttack",{attack_num = self.attack_num,super_skill_attack_num = self.super_skill_attack_num})
				self:Finish()
				return
			end
		end
		self.cd = self.data.beforeCd
		self.object.anim_pay.speed = 0
		local parent = self.object
		if self.object.com_attack_warning_node then  parent = self.object.com_attack_warning_node end
		self.attackWarningPre = MonsterComAttackWarningPrefab.Create(parent,self.cd,function()
			--在cd里面触发过了这里就不需要写了
			-- self:Trigger()
		end,
		function()
			self.object.anim_pay.speed = 1
			self.attackWarningPre = nil    
		end,self.attack_num >= self.super_skill_attack_num and 0.3 or nil)
	else
        self:Trigger()
	end
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
    self:Finish()
end

function M:Finish()
	self.super.Finish(self)
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
	Event.Brocast("stageRefreshBossNorAttackValue",self.attack_num,self.super_skill_attack_num)
	local hit_data = self.object.data
	for k,v in pairs(self.object.config) do
		hit_data[k] = v
	end
	
	if self.attack_num > self.super_skill_attack_num then
		Event.Brocast("BawangFlowerSuperChargeAttack",{attack_num = self.attack_num,super_skill_attack_num = self.super_skill_attack_num})
		self.attack_num = 0
		return
	end

	local damage = {}
	hit_data.hitOrgin = {id = self.object.id}
	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end

	hit_data.damage = { self.object.data.damage }

	ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	
	hit_data.bulletPrefabName = { "GW_srh_zidan_boss" }

	hit_data.attackFrom = "monster"
	hit_data.moveWay = {"LineMove",}
	hit_data.hitEffect = {"SampleHit",} 
	hit_data.hitStartWay = {"IsHitSomeOne"}
	hit_data.hitType = {"SectorShoot#150"}
	hit_data.bulletLifeTime = 6
	hit_data.speed = {10}
	hit_data.bulletNumDatas = {5}
	hit_data.attr = {}
	hit_data.angle = 150
	hit_data.shouji_pre = "GW_srh_baoza"
	hit_data.hitOrgin = {pos = self.object.attack_node.transform.position}

	Event.Brocast("monster_attack_hero", hit_data)
end