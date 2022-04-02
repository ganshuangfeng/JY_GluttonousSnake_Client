--boss 遗迹石像

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossSKFsmTable"

MonsterBossStoneFigure = basefunc.class(Monster)
local M = MonsterBossStoneFigure

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable

	M.super.Ctor( self , data )
end

--重写
function M:CreateUI(data)
	
	ExtendSoundManager.PauseSceneBGM()
	data.luaTableName = "MonsterBoss"
	local prefab_name = CSModel.GetAssetName(self.config.prefab_name)
	self.prefab = CachePrefabManager.Take(prefab_name, CSPanel.monster_node, 20)
	self.gameObject = self.prefab.prefab.prefabObj
	self.transform = self.gameObject.transform
	self.transform.position = self.data.pos
	self.transform.parent = CSPanel.monster_node
	self.gameObject:SetActive(true)
	self.gameObject.name = self.id
	self.transform.localScale = Vector3.one * (self.config.size or 1)

	ChangeLayer(self.gameObject, 11000 + self.data.config.type * 20, true)
	
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = data.luaTableName
	end

	LuaHelper.GeneratingVar(self.transform, self)
	self.anim_pay = self.transform:GetComponent("Animator")
	if self.stone_boss_3d then
		self.anim_pay = self.stone_boss_3d.transform:GetComponent("Animator")
	end

	if self.eyeNode then
		self.animEye = self.eyeNode:GetComponent("Animator")
	end
	if self.sprite then
		self.spriteRenderer = self.sprite:GetComponent("SpriteRenderer")
		self.spriteRenderer.color = Color.New(1, 1, 1, 1)
	end
	SetLayer(self.gameObject,"Monster")
	self.transform.position = Vector3.New(self.data.pos.x,self.data.pos.y,0)

	local MinSpeed,MaxSpeed = self.config.move_speed[1],self.config.move_speed[2]

	self.vehicle = VehicleManager.CreateMonster(
							{
								m_vPos={
									x=self.transform.position.x, 
									y=self.transform.position.y,
								},
								m_dMinSpeed = MinSpeed,
								m_dMaxSpeed = MaxSpeed,
								m_dMaxTurnRate = 360,
							}, self)
	self.vehicle:Start()
	self:UpdateHp()
	if self.elite then
		self.elite_tx = NewObject("gw_fazhen",self.transform)
	end
	self.stones = {}
	self.transform.position = self.transform.position + Vector3.New(0,0,-1)
end

function M:PlayMonserApearAnim()
	ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_BOSS_BGM.audio_name)
	self.create = true
	self.is_stop = true
	self.anim_pay:Play("start",0,0)
	self.anim_pay.speed = 1
	local _r_fx
	local _l_fx
	self.start_seq = DoTweenSequence.Create()
	self.start_seq:AppendInterval(3.08)
	self.start_seq:AppendCallback(function()
		_r_fx = NewObject("BOOS_shixiang_kuosan",MapManager.GetMapNode())
		_r_fx.transform.position = self.hand_right.transform.position
		_l_fx = NewObject("BOOS_shixiang_kuosan",MapManager.GetMapNode())
		_l_fx.transform.position = self.hand_left.transform.position
		-- Event.Brocast("stage_state_change","boss_coming")
		ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
		Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})
	end)
	self.start_seq:AppendInterval(1.75)
	self.start_seq:AppendCallback(function()
		if IsEquals(_r_fx) then
			Destroy(_r_fx)
		end
		if IsEquals(_l_fx) then
			Destroy(_l_fx)
		end
		self.is_stop = false
		self.anim_pay:Play("idle",0,0)
	end)
end

function M:Init()

	self:CreateUI({})

	self:MakeLister()
	self:AddMsgListener()

	self.fsmLogic:addWaitStatusForUser( "create"  )

	---- 加一个免疫 冰冻，驱散冰冻的 标签
	AddTag( self , "immune_stationary" )
	AddTag( self , "break_stationary" )

	self:InitSkill()
end

function M:FrameUpdate(dt)
	if not self.create then
		self.anim_pay:Play("start",0,0)
		self.anim_pay.speed = 0
		local heroHead = GameInfoCenter.GetHeroHead()
        local range = 10
		local dis = tls.pGetDistanceSqu(self.transform.position, heroHead.transform.position)
		if dis <= range * range then
			self:PlayMonserApearAnim()
		else
			return
		end
	end
	if self.stones and next(self.stones) then
		for k,v in pairs(self.stones) do
			v:FrameUpdate()
			if not v.isLive then
				self.stones[k] = nil
			end
		end
	end
	if self.state == "die" then
		return
	end
	M.super.FrameUpdate( self , dt )
end

function M:UpdateRot()
end
function M:OnDie()
	-- M.super.OnDie( self )

	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
			self.skill[key] = nil
		end
	end
	
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_death_2.audio_name)
	ExtendSoundManager.PauseSceneBGM()

	CSEffectManager.PlayBossOnDead(self.transform.position, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)

	CSEffectManager.PlayBSFlicker(self.transform.position, 10, 100)
	
end

function M:CreatForzenPrefab()

	local forzenPrefab = CachePrefabManager.Take("forzen_boss", self.forzenNode, 2)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero
	
	return forzenPrefab

end

function M:OnHit(data)
	local damage = data.damage
	self.hp = self.hp - damage
	if self.state == "die" then
		return
	end

	if not data.extra then
		self.damageSum = self.damageSum + damage
	end

	self:UpdateHp()

	if self.hp <= 0 then
		self.state = "die"
		self:OnDie()
		self:DamageTxt(self.damageSum)
		self.damageCt = self.damageCd
		return
	end
	
	if self.damageCt<0 then
		if self.damageSum > 0 and self.hp > 0 then
			self:DamageTxt(self.damageSum)
			self.damageSum = 0
			self.damageCt = self.damageCd
		end
	end
	
	if self.sprites then
		for k,v in ipairs(self.sprites) do
			v.color = Color.New(253/255,218/255,218/255)
		end
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.1)
		seq:OnKill(function ()
			for k,v in ipairs(self.sprites) do
				v.color = Color.white
			end
		end)
	end
end

function M:UpdateTransform()
	
end

function M:DamageTxt(d,prefab,desc)
	if d == 0 then return end
	desc = desc or ""
	local pos = CSModel.Get3DToUIPoint(self.node.position)

	if self.reset_timer then
		self.reset_timer:Stop()
	end
	self.curr_index = self.curr_index or 0 
	self.reset_timer = Timer.New(
		function()
			self.curr_index = 0
		end
	,0.8,1)
	self.reset_timer:Start()
	local offsetPos = {
		Vector3.New(0, 2, 0),
		Vector3.New(1.5, 2, 0),
		Vector3.New(-1.3, 2, 0),
		Vector3.New(-1.2, 2, 0),
		Vector3.New(1.9, 2, 0),
		Vector3.New(-1.9, 3, 0),
		Vector3.New(2, 3, 0),
		Vector3.New(-2, 3, 0),
		Vector3.New(-3, 3, 0),
	}
	self.curr_index = self.curr_index + 1
	if self.curr_index > #offsetPos then
		self.curr_index = 1
	end

    CSEffectManager.PlayShowAndHideAndCall(
                                            MapManager.GetMapNode(),
											prefab or "Damage",
                                            20,
                                            Vector3.New(0, 2, 0),
                                            1,
                                            nil,
                                            nil,
                                            function (obj)
                                            	obj.position = self.transform.position + offsetPos[self.curr_index] + Vector3.New(0,0,-10)
                                            	local anim = obj.transform:GetComponent("Animator")
                                            	anim:Play("damage_anim", 0, 0)
                                            	obj.transform:Find("txt"):GetComponent("TMP_Text").text = 
												desc.."-"..StringHelper.ToAbbrNum( d )
												obj.transform.parent = CSPanel.attack_node
                                        	end)

end