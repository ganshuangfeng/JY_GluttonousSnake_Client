---- 仙人掌怪物

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"

MonsterBoss = basefunc.class(Monster)
local M = MonsterBoss

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable

	M.super.Ctor( self , data )
end

function M:PlayMonserApearAnim()
end

function M:CreateUI()
	M.super.CreateUI( self , {luaTableName="MonsterBoss",})

	self.vehicle:SetSteeringValue(Vehicle.SteerType.Flee, "safeDistacne", self.config.attack_range * 0.4)
	self.vehicle:SetSteeringValue(Vehicle.SteerType.Disperse, "minApartDistance", self.config.size * 0.98)


	--self.anim_pay:Play("cx")
	self.anim_pay.speed = 1
	self.anim_event = self.transform:GetComponent("ComAnimatorEvent")
	if self.anim_event then
		self.anim_event.onCall = function (no, event)
			if event == "attack1" then
				Event.Brocast( "monsterBossAttack1AnimFinish",{object_id = self.id} )
			elseif event == "attack2" then
				Event.Brocast( "monsterBossAttack2AnimFinish",{object_id = self.id} )
			elseif event == "attack3" then
				Event.Brocast( "monsterBossAttack3AnimFinish",{object_id = self.id} )
			elseif event == "boss_cx" then
				ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS1.audio_name)
				Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})
			else
				dump(event, "<color=red>EEEEEEEEE event 没有处理的事件 </color>")
			end
		end

		self.gameObject:SetActive(false)
	end

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