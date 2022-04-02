local basefunc = require "Game/Common/basefunc"

SkillMonsterBossCrabNorAttack = basefunc.class(Skill)
local M = SkillMonsterBossCrabNorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.attackNum = 0
	self.bigAttackNum = 3

	self.attackTargetId = nil

	self.at_range = self.object.config.attack_range
    self.at_range_squ = self.at_range * self.at_range

    ---- 处理多个子弹
    if type(self.data.bullet_id) ~= "table" then
    	self.data.bullet_id = { self.data.bullet_id }
    end
	
	Event.Brocast("stageRefreshBossNorAttackValue",0,5)
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:CD()
end

function M:Before()
	self.attackNum = self.attackNum or 0
	self.attackNum = self.attackNum + 1
	if self.attackNum == 1 then
		Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,5)
	elseif self.attackNum == 2 then
		Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,5)
		self:Finish()
		Event.Brocast("monsterBossSuperAttack",1)
		return
	elseif self.attackNum == 3 then
		Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,5)
		self:Finish()
		Event.Brocast("monsterBossSuperAttack",2)
		return
	elseif self.attackNum == 4 then
		Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,5)
	elseif self.attackNum == 5 then
		Event.Brocast("stageRefreshBossNorAttackValue",5,5)
		self:Finish()
		Event.Brocast("monsterBossSuperAttack",math.random(1,2))
		return
	elseif self.attackNum == 6 then
		self.attackNum = 0
		self:Finish()
		Event.Brocast("monsterBossSuperAttack",3,self)
		return
	end
	M.super.Before(self)
end

function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end


function M:Finish(data)
	M.super.Finish(self)
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

function M:Trigger()
	self.super.Trigger(self)
	local my_pos = self.object.transform.position
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	local anim_id = 1
	if target.transform.position.x > self.object.transform.position.x then
		anim_id = 4
		self.object.anim_pay:Play("attack_4",0,0)
	else
		anim_id = 1
		self.object.anim_pay:Play("attack_1",0,0)
	end
	
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	--- 瞄准目标
	if target then
		local _target_pos = target.transform.position
		self.attackTargetId = target.id
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.73)
	seq:AppendCallback(function()
		self:AttackTarget(anim_id)
	end)
	
end 

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossNorAttack"] = basefunc.handler(self, self.onMonsterBossNorAttack)
end

--- 主动触发
function M:onMonsterBossNorAttack( data )
	if data.object_id ~= self.object.id then
		return
	end

	self:OnActive()
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
	if _obj then
		local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.range2 then
			return _obj.id
        end
	end
	return nil
end

function M:GetHitByBulletData( _bulletIndex , _damage )
	local bullet_id = self.data.bullet_id[_bulletIndex]
	if not bullet_id then
		return nil
	end

	local hit_data = {}
    --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(bullet_id)
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
	hit_data.damage = { _damage }

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[bullet_config.audio_name].audio_name)
	end
	
	hit_data.attackFrom = "monster"

	--普通子弹
	--Event.Brocast("monster_attack_hero", hit_data)

	return hit_data
end

function M:AttackTarget(anim_id)
	local hit_data = self:GetHitByBulletData( 1 , 30 )
	if hit_data and next(hit_data) then
		hit_data.angle = 30
		if anim_id == 1 then
			hit_data.hitOrgin = {pos = self.object.attack_node_you.transform.position}
		elseif anim_id == 4 then
			hit_data.hitOrgin = {pos = self.object.attack_node_zuo.transform.position}
		end
		Event.Brocast("monster_attack_hero", hit_data)
	end

	local hit_data = self:GetHitByBulletData( 2 , 100 )
	if hit_data and next(hit_data) then
		hit_data.angle = 0
		hit_data.hit_range = 4
		if anim_id == 1 then
			hit_data.hitOrgin = {pos = self.object.attack_node_you.transform.position}
		elseif anim_id == 4 then
			hit_data.hitOrgin = {pos = self.object.attack_node_zuo.transform.position}
		end
		Event.Brocast("monster_attack_hero", hit_data)
	end

    self:Finish()
end