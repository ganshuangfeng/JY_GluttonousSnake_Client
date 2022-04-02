--沙虫boss 火焰攻击
local basefunc = require "Game/Common/basefunc"

SkillMonsterBossSandWormDropAttack = basefunc.class(Skill)
local M = SkillMonsterBossSandWormDropAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.boss_skill_id = 2
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


--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --攻击

    self.attackTargetId = self:GetAttackTarget()
    if not self.attackTargetId then
        return
    end
    self:AttackTarget()

    --攻击完成
    self:After()
end

function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		return _obj.id
	end
	return nil
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

    
	hit_data.hitOrgin = {id = self.object.id}

	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end

    --local damage = {}
	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }  --{self.object.config.damage}
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	end
	
	--[[if self.data.bullet_id then
		local config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
		for k ,v in pairs(config) do
			hit_data[k] = v
		end
	end--]]
	self.create_bullet_id = nil

	hit_data.startCall = function(bullet_data)
        --print("<color=yellow>xxx-------------call_startCall</color>")
		self.create_bullet_id = bullet_data.bullet_id
	end
	Event.Brocast("monster_attack_hero", hit_data)
end