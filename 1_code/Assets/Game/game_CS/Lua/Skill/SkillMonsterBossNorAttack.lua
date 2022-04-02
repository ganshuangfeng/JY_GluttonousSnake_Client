local basefunc = require "Game/Common/basefunc"

SkillMonsterBossNorAttack = basefunc.class(Skill)
local M = SkillMonsterBossNorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.attackNum = 0
	self.bigAttackNum = 4

	self.attackTargetId = nil

	self.at_range = self.object.config.attack_range
    self.at_range_squ = self.at_range * self.at_range
	Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,self.bigAttackNum)

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


function M:Finish(data)
	M.super.Finish(self)

    self.attackTargetId = nil
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
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
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossNorAttack"] = basefunc.handler(self, self.onMonsterBossNorAttack)
	self.lister["monsterBossAttack1AnimFinish"] = basefunc.handler(self, self.on_monsterBossAttack1AnimFinish)
end

--- 主动触发
function M:onMonsterBossNorAttack( data )
	if data.object_id ~= self.object.id then
		return
	end

	self:OnActive()
end

--- 动画到了要攻击的消息
function M:on_monsterBossAttack1AnimFinish( data )
	
	if data.object_id ~= self.object.id then
		return
	end
	--- 寻找最近的目标
	local my_pos = self.object.transform.position

	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	--print("xxxx-------------------- on_monsterBossAttack1AnimFinish 00" , target)

	if target then
		local target_pos = target.transform.position
		local dis = tls.pGetDistanceSqu( my_pos , target_pos )

		--print("xxxx-------------------- on_monsterBossAttack1AnimFinish 01" , dis )

		if true then
			
		else
			target = nil
		end
	end
	--print("xxxx-------------------- on_monsterBossAttack1AnimFinish 1")
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

		--print("xxxx-------------------- on_monsterBossAttack1AnimFinish 2" , self.skillState )

		self.attackTargetId = target.id
		self:Before()
	else
		--- 没有目标就完咯
		self:Finish()

		--print("xxxx-------------------- on_monsterBossAttack1AnimFinish 3")

		self.attackNum = 0
	end
		
	
end


--------消息 函数调用方式--------------------
function M:AcceptMes()

end

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

function M:AttackTarget()
	if not self.attackTargetId then
		return
	end
	
	---- 攻击次数加1
	self.attackNum = self.attackNum + 1
	if self.attackNum == 1 or self.attackNum == 3 then

	elseif self.attackNum == 2 then
		local rdn = math.random(1,2)
		if rdn == 2 then
			Event.Brocast( "monsterBossSuperAttack" , 2)
			self:After()
			return
		end
	elseif self.attackNum > self.bigAttackNum then
		self.attackNum = 0
		---- 发送消息
		-- print("xxxx--------------------monsterBossSuperAttack")
		Event.Brocast( "monsterBossSuperAttack" , 1)
		self:After()
		return
	end
	

	--[[local hit_data = self.object.data
	for k,v in pairs(self.object.config) do
		hit_data[k] = v
	end--]]
	
	Event.Brocast("stageRefreshBossNorAttackValue",self.attackNum,self.bigAttackNum)
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
	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) } --{ self.object.config.damage }

	if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end
	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	
	hit_data.attackFrom = "monster"
	hit_data.angle = 30

	Event.Brocast("monster_attack_hero", hit_data)

	--print("xxxx--------------------BossNorattack")
	--攻击完成
    self:After()


end