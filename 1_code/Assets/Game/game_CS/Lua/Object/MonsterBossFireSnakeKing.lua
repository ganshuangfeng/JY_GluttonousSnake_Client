---- 寄居蟹怪物

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossSKFsmTable"

MonsterBossFireSnakeKing = basefunc.class(Monster)
local M = MonsterBossFireSnakeKing

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable
	M.super.Ctor( self , data )
	-------------------------- 基础数据 ↓
	self.minSpeed = self.config.move_speed[1]
	self.maxSpeed = self.config.move_speed[2]
	-------------------------- 基础数据 ↑
end

--重写
function M:CreateUI()
	M.super.CreateUI( self , {luaTableName="MonsterBoss",})
	self.transform.position = self.data.pos--Vector3.New(0,0,0)
	
	-- self.vehicle = VehicleManager.CreateMonster(
	-- 						{
	-- 							m_vPos={
	-- 								x=self.transform.position.x, 
	-- 								y=self.transform.position.y,
	-- 							},
	-- 							m_dMinSpeed = self.minSpeed,
	-- 							m_dMaxSpeed = self.maxSpeed,
	-- 							m_dMaxTurnRate = 360,
	-- 						}, self)
	-- self.vehicle:Start()
	-- self.vehicle:Stop()
	
	--self.anim_event = self.node:GetComponent("ComAnimatorEvent")
end

function M:PlayHitBackAnim()
	
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
	self.sprites = {}
	self.sprites[#self.sprites + 1] = self.node:Find("shenti"):GetComponent("SpriteRenderer")
	self.sprites[#self.sprites + 1] = self.node:Find("shetou"):GetComponent("SpriteRenderer")
	self.sprites[#self.sprites + 1] = self.node:Find("GameObject/weiba"):GetComponent("SpriteRenderer")
	self.sprites[#self.sprites + 1] = self.node:Find("GameObject/1/weiba (1)"):GetComponent("SpriteRenderer")
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

function M:FrameUpdate(dt)
	M.super.FrameUpdate( self , dt )
end

function M:PlayMonserApearAnim()
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
			v.color = Color.New(253/255,105/255,105/255)
		end
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.2)
		seq:OnKill(function ()
			for k,v in ipairs(self.sprites) do
				v.color = Color.white
			end
		end)
	end
end

function M:UpdateTransform()

end