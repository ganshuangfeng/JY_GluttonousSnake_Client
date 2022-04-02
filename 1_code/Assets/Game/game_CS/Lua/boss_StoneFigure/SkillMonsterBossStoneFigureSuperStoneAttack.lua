local basefunc = require "Game/Common/basefunc"

SkillMonsterBossStoneFigureSuperStoneAttack = basefunc.class(Skill)
local M = SkillMonsterBossStoneFigureSuperStoneAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.at_range = self.object.config.attack_range
    self.at_range_squ = self.at_range * self.at_range
    self.targetV = nil
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
function M:Before()
	self.super.Before(self)

	--在场地中随机选择几个位置
	local x_range = {-11.3,11.3}
	local y_range = {-9.17,2.44}
	local create_count = 4
	self.effect_positions = {}
	if self.type == 2 then
		for i = 1,create_count do
			local pos_x = math.random(x_range[1],x_range[2])
			local pos_y = math.random(y_range[1],y_range[2])
			--self.effect_positions[i] = get_grid_pos(Vector3.New(pos_x,pos_y,0))
			self.effect_positions[i] = MapManager.GetMapGameObject().transform.position + Vector3.New(pos_x,pos_y)
		end
	else
		local head = GameInfoCenter.GetHeroHead()
		local room_pos = MapManager.GetMapGameObject().transform.position
		local target_position = head.transform.position - room_pos
		local effect_position = Vector3.New(target_position.x,target_position.y,target_position.z)
		if effect_position.x > 0 then effect_position.x = math.min(x_range[2],effect_position.x) end
		if effect_position.y > 0 then effect_position.y = math.min(y_range[2],effect_position.y) end
		if effect_position.x < 0 then effect_position.x = math.max(x_range[1],effect_position.x) end
		if effect_position.y < 0 then effect_position.y = math.max(y_range[1],effect_position.y) end
		self.effect_positions[#self.effect_positions + 1] = room_pos + effect_position
	end
	for k,v in ipairs(self.effect_positions) do
		CSEffectManager.PlayBossWarning(
									"BossWarning6",
									v,
									self.data.beforeCd,
									0.3,
									function ()
									end)
	end
	self.trigger_seq = DoTweenSequence.Create()
	self.trigger_seq:AppendInterval(self.data.beforeCd)
	self.trigger_seq:AppendCallback(function()
		self.object.anim_pay:Play("attack1",0,0)
	end)
	self.trigger_seq:AppendInterval(0.5)
	self.trigger_seq:AppendCallback(function()
		self:AttackTarget()
		self.trigger_seq = nil
	end)
end


function M:Finish(data)
	M.super.Finish(self)
end

function M:OnCD()

end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

--消息
function M:MakeLister()
	M.super.MakeLister(self)
	self.lister["monsterBossSuperAttack"] = basefunc.handler(self, self.onMonsterBossSuperAttack)
end

--- 主动触发
function M:onMonsterBossSuperAttack( t )
	if t.type == 1 or t.type == 2 then
		self.type = t.type
		self.attack_num = t.attack_num
		self.max_attack_num = t.max_attack_num
		self:Active()
	end

end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self }, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

function M:AttackTarget()
	local _roar = NewObject("BOOS_csb_quangquan",MapManager.GetMapNode())
	Event.Brocast("stageRefreshBossNorAttackValue",self.attack_num,self.max_attack_num)
	_roar.transform.position = self.object.transform.position + Vector3.New(0,0,-10)
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_juxiang_paoxiao.audio_name)
	for k,v in ipairs(self.effect_positions) do
		local data = {pos = v,damage =  GetSkillOneDamage( self , "damage_bei" , "damage_fix" )}
		self.object.stones[#self.object.stones + 1] = GoodsBossStone.New(data)
	end
	Event.Brocast("ui_shake_screen_msg", {t=1, range=1.2,})
	self.attack_seq = DoTweenSequence.Create()
	self.attack_seq:AppendInterval(1)
	self.attack_seq:AppendCallback(function()
		--攻击完成
		self:Finish()
		self.attack_seq = nil
	end)
	self.attack_seq:OnForceKill(function()
		if IsEquals(_roar) then
			Destroy(_roar)
		end
	end)

end

function M:Exit()
	if self.trigger_seq then
		self.trigger_seq:Kill()
		self.trigger_seq = nil
	end
	if self.attack_seq then
		self.attack_seq:Kill()
		self.attack_seq = nil
	end
	self.super.Exit(self)
end