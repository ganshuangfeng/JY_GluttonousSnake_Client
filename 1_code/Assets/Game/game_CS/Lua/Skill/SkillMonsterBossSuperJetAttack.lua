local basefunc = require "Game/Common/basefunc"

SkillMonsterBossSuperJetAttack = basefunc.class(Skill)
local M = SkillMonsterBossSuperJetAttack

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


function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

function M:Before()
	M.super.Before(self)

	self.angel = -90

	local my_pos = self.object.transform.position
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target then
		local target_pos = target.transform.position
		self.angel = Vec2DAngle( (target_pos - my_pos).normalized )
		self.angel = self.angel % 360

		-- dump(self.angel, "<color=red>self.angel ================== </color>")
	end
	self.object.anim_pay:Play("attack3",0,0)
	self.object.anim_pay.speed = 0
	self.isLock = true
								
	CSEffectManager.PlayBossWarning(
		"BossWarning2",
		self.object.transform.position+Vector3.New(0, -2, 0),
		2,
		0,
		function (obj)
			obj.transform.rotation = Quaternion.Euler(0, 0, self.angel)
		end,
		function ()
		self.isLock = false
		if self.object and IsEquals(self.object.transform) then
					self.object.anim_pay.speed = 1
		end
		end)

end

function M:Finish(data)
	M.super.Finish(self)
    self.object.anim_pay:Play("attack1", 0, 0)
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
	self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
	self.lister["monsterBossAttack3AnimFinish"] = basefunc.handler(self, self.on_monsterBossAttackAnimFinish)
end


--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t == 2 then
	    if self.skillState ~= SkillState.active then
        	return
    	end

    	self:Ready()
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
	self.isLock = true
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self,}, nil, self)
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
	if not self.isPlayAnim then
		self.object.anim_pay:Play("attack3", 0, 0)
		self.isPlayAnim = true
		
	end

	if not self.isPlayAnimOver then
		return
	end
	if self.isLock then 
		return
	end
	Event.Brocast("stageRefreshBossNorAttackValue",2,4)
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
	hit_data.hitTarget = {angel = self.angel}
	hit_data.damage = {self.object.config.damage}

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack2.audio_name)
	if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end

	hit_data.attackFrom = "monster"

	local _p = self.object.transform.position

	hit_data.hitOrgin = {pos=Vector3.New(_p.x + 3*MathExtend.Cos(self.angel+90), _p.y+3*MathExtend.Sin(self.angel+90), 0)}
	Event.Brocast("monster_attack_hero", hit_data)

	hit_data.hitOrgin = {pos=Vector3.New(_p.x, _p.y, 0)}
	Event.Brocast("monster_attack_hero", hit_data)

	hit_data.hitOrgin = {pos=Vector3.New(_p.x - 3*MathExtend.Cos(self.angel+90), _p.y - 3*MathExtend.Sin(self.angel+90), 0)}
	Event.Brocast("monster_attack_hero", hit_data)

	self.isPlayAnimOver = false
	self.isPlayAnim = false

	self.attackCount = self.attackCount - 1
	if self.attackCount < 1 then
		self:After()
	end
end