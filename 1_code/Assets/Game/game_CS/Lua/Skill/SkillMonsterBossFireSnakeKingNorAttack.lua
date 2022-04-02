local basefunc = require "Game/Common/basefunc"

SkillMonsterBossFireSnakeKingNorAttack = basefunc.class(Skill)
local M = SkillMonsterBossFireSnakeKingNorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:Init(data)
	M.super.Init( self )
	self.data = data or self.data
	self.attack_num = 0
	self.super_skill_attack_num = 3
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

function M:Before()
	if self.data.beforeCd then
        self.cd = self.data.beforeCd
        self.skillState = SkillState.before
		self.attack_num = self.attack_num + 1
		local _cur = self.attack_num > self.super_skill_attack_num and self.super_skill_attack_num or self.attack_num 
		if self.attack_num > self.super_skill_attack_num then
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.5)
			seq:AppendCallback(function()
				if self.object and IsEquals(self.object.transform) then
					CSEffectManager.PlayShowAndHideAndCall(MapManager.GetMapNode(),"kuosan_daduan_quan",nil,self.object.transform.position,2)
				end
			end)
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
		end,self.attack_num > self.super_skill_attack_num and self.data.flashTime or nil)
	else
        self:Trigger()
	end
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

function M:Finish()
	self.super.Finish(self)
	self:CD()
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
	if self.attack_num > self.super_skill_attack_num then
		Event.Brocast("FireSnakeKingSuperAttack")
		self.attack_num = 0
		return
	end

	local hit_data = {}
	--- 从子弹配置中
	local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    basefunc.merge( bullet_config , hit_data )

	local damage = {}
	hit_data.hitOrgin = {id = self.object.id}
	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end

	hit_data.attackFrom = "monster"
	hit_data.damage = { self.object.config.damage,self.object.config.damage }
	hit_data.angle = 30

	if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end
	

	Event.Brocast("monster_attack_hero", hit_data)
end