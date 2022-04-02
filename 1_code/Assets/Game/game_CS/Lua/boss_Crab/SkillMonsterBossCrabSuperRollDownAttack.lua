local basefunc = require "Game/Common/basefunc"

SkillMonsterBossCrabSuperRollDownAttack = basefunc.class(Skill)
local M = SkillMonsterBossCrabSuperRollDownAttack


function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.attackTargetId = nil

end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data
	
	self.attackMaxCount = 5
	self.attackCount = self.attackMaxCount

	self.isLock = true
	self.isPlayAnim = false
	self.isPlayAnimOver = false

	self:CD()
end


function M:CD()
	self.skillState = SkillState.cd
	self.data.cd = self.data.cd or 0
	self.cd = 999999
end

function M:Ready(data)
	M.super.Ready(self)
	self.skillState = SkillState.ready
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.1)
	seq:AppendCallback(function()
		-- 发送攻击状态数据包
		self:SendStateData()
	end)
end

function M:Trigger(data)
	M.super.Trigger(self)

	local my_pos = self.object.transform.position
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target then
		local target_pos = target.transform.position
		local dis_x = math.abs(target_pos.x - my_pos.x)
		local dis_y = math.abs(target_pos.y - my_pos.y)
		--如果x小则在y轴创建子弹
		--否则在x轴创建子弹
		self.effect_positions = {}
		x_axis = 0
		y_axis = 0
		if dis_x < dis_y then
			y_axis = dis_y
			if y_axis > 20 then y_axis = 20 end
			self.angle = 0
		else
			x_axis = dis_x
			if x_axis > 20 then x_axis = 20 end
			self.angle = 90
		end
		
		self.effect_positions[1] = my_pos + Vector3.New(x_axis,y_axis,0)
		self.effect_positions[2] = my_pos + Vector3.New(-x_axis,-y_axis,0)
	end

	self.object.anim_pay.speed = 0
	for k,pos in ipairs(self.effect_positions) do 
		CSEffectManager.PlayBossWarning(
									"BossWarning4",
									pos,
									2,
									0.5,
									function (obj)
										obj.transform.rotation = Quaternion.Euler(0, 0, self.angle)
									end)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2.5)
	seq:AppendCallback(function()
		self.object.anim_pay.speed = 1
		self.object.anim_pay:Play("attack_3",0,0)
	end)
end


function M:Finish(data)
	M.super.Finish(self)

	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target.transform.position.x > self.object.transform.position.x then
		self.object.anim_pay:Play("attack4",0,0)
	else
		self.object.anim_pay:Play("attack1",0,0)
	end
    if self.stateVec then
        for key, obj in pairs(self.stateVec) do
            obj:Stop()
        end
    end

    self.attackTargetId = nil

    self:ResetData()
	---- 状态重新回到 cd状态
    self:CD()

    self.object.anim_pay:Play("attack1", 0, 0)
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end

    --攻击
    self:AttackTarget()
    
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	-- self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
	-- self.lister["monsterBossAttack3AnimFinish"] = basefunc.handler(self, self.on_monsterBossAttackAnimFinish)
end

--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t == 2 then
		self:Trigger(dt)
	end	

end

function M:on_monsterBossAttackAnimFinish(  )
	--- 寻找最近的目标
	local my_pos = self.object.transform.position

	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	--- 瞄准目标
	if target then
		local _target_pos = target.transform.position
		if CSModel.Is2D then
			if self.object.transform.position.x > _target_pos.x then
				self.object.node.localScale = Vector3.New(-1,1,1)
			else
				self.object.node.localScale = Vector3.New(1,1,1)
			end
		else
			AxisLookAt(self.object.transform , _target_pos , Vector3.up)
		end

		--- 发消息给普通攻击技能，有无目标都要发
		self.attackTargetId = target.id
		
	else

	end

	self.isPlayAnimOver = true

end


--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self, animName = "attack3"}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
    self.attackCount = self.attackMaxCount
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

function M:AttackTarget()
	if self.skillState ~= SkillState.trigger then return end
	if not self.isPlayAnim then
		self.object.anim_pay:Play("attack_3", 0, 0)
		self.isPlayAnim = true
		
	end

	if not self.isPlayAnimOver then
		return
	end

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

	--local damage = {}
	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }  -- { 50 }

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack2.audio_name)
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	end

	hit_data.attackFrom = "monster"

	--[[hit_data.bulletPrefabName = { "BulletCrabBoss" }
	hit_data.moveWay = {"LineMove",}
	hit_data.hitEffect = {"RocketBombHit",} 
	hit_data.hitStartWay = {"IsHitPlane"}
	hit_data.hitType = {"SkillCrabRollDownShoot"}
	hit_data.bulletLifeTime = 6
	hit_data.speed = {20}
	hit_data.bulletNumDatas = {20}
	hit_data.attr = {}
	hit_data.shouji_pre = "BOOS_shouji_H"--]]

	for k,v in ipairs(self.effect_positions) do
		hit_data.hitOrgin= {pos = v}
		hit_data.hitTarget= {pos = v}
		Event.Brocast("monster_attack_hero", hit_data)
	end

	self.isPlayAnimOver = false
	self.isPlayAnim = false

	self.attackCount = self.attackCount - 1
	if self.attackCount < 1 then
		self:Finish()
	end
end
