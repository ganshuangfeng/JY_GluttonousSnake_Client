---- 寄居蟹怪物

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"

MonsterBossCrab = basefunc.class(Monster)
local M = MonsterBossCrab

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable

	M.super.Ctor( self , data )
end

--重写
function M:CreateUI()
	M.super.CreateUI( self , {luaTableName="MonsterBoss",})

	self.vehicle:SetSteeringValue(Vehicle.SteerType.Flee, "safeDistacne", self.config.attack_range * 0.4)
	self.vehicle:SetSteeringValue(Vehicle.SteerType.Disperse, "minApartDistance", self.config.size * 0.98)

	self.anim_pay = self.node:GetComponent("Animator")
	self.gameObject:SetActive(false)
	self.sprites = {}
	self.sprites[1] = self.node:Find("shenti").transform:GetComponent("SpriteRenderer")
	self.sprites[2] = self.node:Find("shenti/zuo").transform:GetComponent("SpriteRenderer")
	self.sprites[3] = self.node:Find("shenti/you").transform:GetComponent("SpriteRenderer")
end

function M:Init()

	self:CreateUI()

	self:MakeLister()
	self:AddMsgListener()

	self.fsmLogic:addWaitStatusForUser( "create"  )

	---- 加一个免疫 冰冻，驱散冰冻的 标签
	AddTag( self , "immune_stationary" )
	AddTag( self , "break_stationary" )

	self:InitSkill()
end
function M:PlayMonsterApearAnim()
end

function M:FrameUpdate(dt)
	if self.state == "die" then
		return
	end
	M.super.FrameUpdate( self , dt )
end


function M:OnDie()
	-- M.super.OnDie( self )

	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
			self.skill[key] = nil
		end
	end
	self.anim_pay:Play("dead",0,0)

	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_death_2.audio_name)
	ExtendSoundManager.PauseSceneBGM()
	
	CSEffectManager.PlayBossOnDead(self.transform.position, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)

end

function M:CreatForzenPrefab()

	local forzenPrefab = CachePrefabManager.Take("forzen_boss", self.forzenNode, 2)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero
	
	return forzenPrefab

end

function M:UpdateRot()
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

function M:UpdateTransform()
	
end

function M:OnTriggerStay2D(collision)

end