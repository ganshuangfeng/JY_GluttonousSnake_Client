--沙虫boss 追踪攻击
local basefunc = require "Game/Common/basefunc"

SkillMonsterBossSandWormChaseAttack = basefunc.class(Skill)
local M = SkillMonsterBossSandWormChaseAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.boss_skill_id = 3
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:Active()
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
    self.attackTargetId = self:GetAttackTarget()
	local seq = DoTweenSequence.Create()
	for i = 1,2 do
		seq:AppendCallback(function()
			self:AttackTarget()
		end)
		seq:AppendInterval(1)
	end
	seq:AppendCallback(function()
		--攻击完成
		self:After()
	end)
end

function M:OnTrigger()
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["SandwormBossDiliverAttack"] = basefunc.handler(self, self.OnSandwormBossDiliverAttack)
end

function M:OnSandwormBossDiliverAttack(data)
	if data.boss_skill_id == self.boss_skill_id then
		for k,v in ipairs(data.attack_obj) do
			if v == self.object.bossId then
				self:Ready()
				break
			end
		end
	end
end

function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		return _obj.id
	end
	return nil
end


--------消息 函数调用方式--------------------
function M:SendStateData()
	--print("xxxx------------ SendStateData")
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
	self.object.anim_pay:Play("attack_1",0,0)
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
	hit_data.hitOrgin = {id = self.object.id}

	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end

	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) } --{self.object.config.damage}
	--dump(hit_data.damage , "xxxx--------------hit_data.damage:")
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name ].audio_name)
	end
	
	--[[if self.data.bullet_id then
		local config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
		for k ,v in pairs(config) do
			hit_data[k] = v
		end
	end--]]
	self.create_bullet_id = nil
	hit_data.startCall = function(bullet_data)
		self.create_bullet_id = bullet_data.bullet_id
	end
	Event.Brocast("monster_attack_hero", hit_data)
end