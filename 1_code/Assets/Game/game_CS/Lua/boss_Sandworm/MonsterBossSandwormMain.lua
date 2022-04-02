-- 创建时间:2021-10-19
---- 沙虫boss （三个boss共享血量）
--这是主体（中间的那只）

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"

MonsterBossSandwormMain = basefunc.class(Monster)
local M = MonsterBossSandwormMain

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable

	M.super.Ctor( self , data )
end

--重写
function M:CreateUI()
	M.super.CreateUI( self , {luaTableName="MonsterBoss",})
	self.anim_pay = self.node.transform:Find("MonsterBossSandWorm"):GetComponent("Animator")
	self.anim_pay.speed = 0
	self.start_anim_pay = self.node:Find("MonsterBossSandWorm/desert_boss@start"):GetComponent("Animator")
	self.start_anim_pay.speed = 0
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

function M:FrameUpdate(dt)
	if self.state == "die" then
		return
	end
	if not (self.others and next(self.others)) then
		self:GetOther()
	end
	M.super.FrameUpdate( self , dt )
end

function M:PlayMonsterApearAnim()
	local interval = 1
	if self.bossId == 2 then
		interval = 0.5
	elseif self.bossId == 1 then
		interval = 2
	elseif self.bossId == 3 then
		interval = 1.5
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(interval)
	seq:AppendCallback(function()
		self.anim_pay.speed = 1
		self.start_anim_pay.speed = 1
	end)
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
	self.anim_pay.speed = 0.1
	CSEffectManager.PlayBossOnDead(self.transform.position, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)
	CSEffectManager.PlayBSFlicker(self.transform.position, 10, 100)

end

function M:CreatForzenPrefab()
end

function M:UpdateRot()
end

function M:OnHit(data)
	local damage = data.damage
	self.hp = self.hp - damage
	for k,v in pairs(self.others) do
		v.hp = self.hp
	end
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
		for k,v in pairs(self.others) do
			v.state = "die"
			v:OnDie()
		end
		self:DamageTxt(self.damageSum)
		self.damageCt = self.damageCd
		return
	end
	
end

function M:UpdateTransform()
	
end

function M:OnTriggerStay2D(collision)

end

function M:GetOther()
	if not (self.others and next(self.others)) then
		self.others = {}
		local other_1 
		local other_2
		for k,v in pairs(GameInfoCenter.GetAllMonsters()) do
			if v.config.classname == "MonsterBossSandworm" then
				if not other_1 then 
					other_1 = v
				elseif not other_2 then 
					other_2 = v
				end
			end
		end
		if other_1.transform.localPosition.x < other_2.transform.localPosition.x then
			self.others[1] = other_1
			self.others[2] = other_2
		else
			self.others[1] = other_2
			self.others[2] = other_1
		end
		self.transform.localScale = self.transform.localScale + Vector3.New(0.5,0.5,0.5)
		self:PlayMonsterApearAnim()
		for i =1,2 do
			self.others[i]:SetBossId(i == 1 and 1 or 3)
			self.others[i]:PlayMonsterApearAnim()
			if i == 1 then
				local localScale = self.others[i].transform.localScale
				self.others[i].transform.localScale = Vector3.New(-localScale.x,localScale.y,localScale.z)
			end
		end
		self:SetBossId(2)
	end
end

function M:SetBossId(bossId)
	self.bossId = bossId
end