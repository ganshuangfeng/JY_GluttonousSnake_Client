---- 霸王花怪物

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossSKFsmTable"

MonsterBossBaWangFlower = basefunc.class(Monster)
local M = MonsterBossBaWangFlower

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
	self.transform.position = self.data.pos
end

function M:PlayMonserApearAnim()
end

function M:Init()

	self:CreateUI()

	self:MakeLister()
	self:AddMsgListener()

	-- self.fsmLogic:addWaitStatusForUser( "create"  )

	---- 加一个免疫 冰冻，驱散冰冻的 标签
	AddTag( self , "immune_stationary" )
	self:InitSkill()
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

	CSEffectManager.PlayBossOnDead(self.transform.position, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)
	
	ExtendSoundManager.PauseSceneBGM()
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