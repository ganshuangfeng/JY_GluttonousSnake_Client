local basefunc = require "Game/Common/basefunc"
local monsterPreciousFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterPreciousFsmTable"

MonsterPrecious = basefunc.class(Monster)
local M = MonsterPrecious

function M:Ctor(data)
	data.fsmTable  = monsterPreciousFsmTable
	M.super.Ctor( self , data )

	-------------------------- 基础数据 ↓
	self.minSpeed = self.config.move_speed[1]
	self.maxSpeed = self.config.move_speed[2]
	-------------------------- 基础数据 ↑
end


function M:Init(data)
	self:CreateUI({luaTableName="MonsterPrecious"})

	self:MakeLister()
	self:AddMsgListener()

	---- 职业代码
	MonsterProfessionManager.InitProfession( self , self.config.professionType ) 
	--self.fsmLogic:addWaitStatusForUser( "runaway" )

	self.state = "normal"

	self.gemData = {
		cfg = self.data.gem_data or { 0.3 , 0.6 , 0.9 } ,
		dropNum = 0,
	}

	self:EatGemAni()
	Event.Brocast("stageRefreshStageValue", 0, #self.gemData.cfg)
	self:InitSkill()
end

function M:OnDie()

	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
			self.skill[key] = nil
		end
	end
	
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_death_2.audio_name)
	self.gameObject:SetActive(false)
	CSEffectManager.PlayMonsterOnDead(self.transform.position, nil, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)
	
end

function M:OnHit(data)

	M.super.OnHit( self , data )

	self:CheakHitTriggerRage(self.hp,data.damage)
	self:CheakHitTriggerMoney(self.hp,data.damage)
	self:DropGem()

end

function M:CheakHitTriggerRage(hp,damage)
	local trigger_table = {70,40,10}
	local num = 0
	for i = 1,#trigger_table do
		local t_hp = trigger_table[i] * self.maxHp/100
		if hp >= t_hp then
			if hp - damage < t_hp then
				num = num + 1
			end
		end
	end
	--狂暴状态不叠加
	if num > 0 then
		--狂暴状态下加速
		local skill = GameInfoCenter.GetObjSkillByType(self,"SkillMonsterPreciousAttack")
		if skill then
			skill:Trigger()
		end
	end
end

function M:CheakHitTriggerMoney(hp,damage)
	local trigger_table = {90,80,70,60,50,40,30,20,10}
	local num = 0
	for i = 1,#trigger_table do
		local t_hp = trigger_table[i] * self.maxHp/100
		if hp >= t_hp then
			if hp - damage < t_hp then
				num = num + 1
			end
		end
	end

	--一次击杀超大血条，叠加掉落的金币数量
	for i = 1,num do
		self:DropGold(9999)
	end
end

function M:DropGold(jb)
	local pos = self.transform.position
	--ClientAndSystemManager.SendRequest("cs_add_gold",{jb = jb})
	MainModel.AddAsset("prop_jin_bi",jb)
	if jb and jb > 0 then	
		CSEffectManager.CreateGold(CSPanel.anim_node,
			CSModel.Get3DToUIPoint(pos),
			CSPanel:GetJBNode(),
			nil,
			function()
				Event.Brocast("ui_game_get_jin_bi_msg", jb)
			end
		)
	end
end

function M:DropGem()

	local dhp = (1-self.hp/self.maxHp)*100

	local n = self.gemData.dropNum + 1
	local gp = self.gemData.cfg[n]
	if gp and dhp >= gp then
		self.gemData.dropNum = n
		
		local gc = {
			type=1,
			jb=100,
			autoMove = true,
			pos=self.transform.position,
		}

        gc.collisionCallback = function (obj)
        	Event.Brocast("stageRefreshStageValue", n, #self.gemData.cfg)
            obj:Over()
        end

	    CreateFactory.CreateGoods(gc)

	end
end

function M:EatGemAni()
	
	local pd = {
		x = {
				{l=-10,r=-6},
				{l=4,r=6},
				{l=-6,r=-4},
				{l=6.5,r=10},
			},
		y = {
				{l=-16,r=-12},
				{l=9,r=12},
				{l=-12,r=-9},
				{l=12,r=16},
			},
	}

	local pl = {
		{1,1,}, {1,2,}, {2,1,}, {2,2,},
		{1,3,}, {1,4,}, {2,3,}, {2,4,},
		{3,1,}, {3,2,}, {4,1,}, {4,2,},
		{3,3,}, {3,4,}, {4,3,}, {4,4,},
	}
	
	local dx = self.node.localScale.x

	local py = Vector3.New(1.17, -0.74, 0)
	if dx < 0 then
		py.x = -py.x
	end

	local si = math.random(#pl)
	for i=1,#self.gemData.cfg do
		local t = si + i
		local xd = pd.x[pl[t%#pl+1][1]]
		local yd = pd.y[pl[t%#pl+1][2]]

		local x = math.random(xd.l*100,xd.r*100) * 0.01
		local y = math.random(yd.l*100,yd.r*100) * 0.01

		CSEffectManager.PlayMoveAndHideFX(CSPanel.map_node,
		 									"BS_baoshi",
		 									{x=x,y=y},
		 									self.transform.position+py, 
		 									0.5,
		 									2.5)

	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.5)
	seq:OnKill(function ()
		CSEffectManager.PlayShowAndHideAndCall(CSPanel.map_node,
			 									"dbg_xishou_2d",
			 									nil,
			 									self.transform.position+py, 
			 									2.7)
	end)

end


function M:CreatForzenPrefab()
 
	local forzenPrefab = CachePrefabManager.Take("forzen_boss", self.forzenNode, 2)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero

	return forzenPrefab

end

