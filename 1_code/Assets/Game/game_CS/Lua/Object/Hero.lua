local basefunc = require "Game/Common/basefunc"
local heroFsmTable = require "Game.game_CS.Lua.FsmConfig.heroFsmTable"

Hero = basefunc.class(Object)
local M = Hero

function M:Ctor(data)
	M.super.Ctor( self , data )

	self.data = data
	self.skill = {}	

	self.modifier = {}

	self:InitBaseData()

	self.fsmLogic = FsmLogic.New( self , heroFsmTable )
end

function M:InitBaseData()
	-------------------------- 基础数据 ↓
	self.hp = self.config.hp
	self.maxHp = self.hp
	self.speed = self.config.speed
	--- 攻击间隔
	self.hit_space = self.config.hit_space or 0.5
	--- 攻击距离
	self.damage = self.config.damage
	--print("xxx-----------hero__initData , ", self.damage , self.config.type)
	self.attack_range = self.config.attack_range or 10
	-------------------------- 基础数据 ↑
	self:InitTechnologyUp()
	self:InitMasterUp()
end
--附带炮台大师的增益效果
function M:InitMasterUp()
	local data = GameConfigCenter.GetMasterBuffByHeroType( self.config.type )

	for k , v in pairs(data) do
		if k == "damage_up" then
			self.damage = self.damage * (1 + v / 100)
		elseif k == "hitSpeed_up" then
			self.hit_space = self.hit_space * (1 - v / 100)
		end
	end
end

function M:InitTechnologyUp()
	local data = TechnologyManager.GetHeroGain( self.config.type )

	for k , v in pairs(data) do
		if k == "attack" then
			self.damage = self.damage + v
		elseif k == "gunshot" then
			self.attack_range = self.attack_range + v
		elseif k == "hitspace" then
			local one_p = 1 / self.hit_space
			one_p = one_p + v
			self.hit_space = 1 / one_p
		end
	end
end


function M:CreateUI()
	local base_name = CSModel.GetAssetName(self.config.base_name)
	--self.prefab = CachePrefabManager.Take(base_name, CSPanel.hero_node, 20)
	self.gameObject =  NewObject(base_name,CSPanel.hero_node) --self.prefab.prefab.prefabObj
	self.transform = self.gameObject.transform

	self.transform.parent = CSPanel.hero_node
	self.gameObject:SetActive(true)
	self.gameObject.name = self.id
	self.transform.localScale = Vector3.one * (self.config.size or 1)

	LuaHelper.GeneratingVar(self.transform, self)
	SetLayer(self.gameObject,"Hero")
	dump(self.config.prefab_name,"<color=red>XXXXXXXXXXXXXXXXXXXXXX</color>")
	--self.canno_prefab = CachePrefabManager.Take(CSModel.GetAssetName(self.config.prefab_name),self.cannon_parent.transform,20)
	self.canno_pre =  NewObject(self.config.prefab_name, self.cannon_parent.transform) --self.canno_prefab.prefab.prefabObj
	self.canno_pre.transform.parent = self.cannon_parent.transform
	self.canno_pre.transform.rotation = Vector3.zero
	self.canno_pre.transform.localPosition = Vector3.zero
	LuaHelper.GeneratingVar(self.canno_pre.transform, self)
	self.canno_pre:SetActive(true)
	self.cannon_animator = self.canno_pre.transform:GetComponent("Animator")

	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "Hero"
	end

	ChangeLayer(self.transform, 10000 - self.data.location * 100 , true)

	local cmt = {"nearest","random"}
	local cr = math.random(2)
	--在符合取怪的范围内随机获取一个
	self.checkMonsterType = cmt[2]

end

function M:Init()
	M.super.Init( self )

	self:CreateUI()

	self:MakeLister()
	self:AddMsgListener()
	self.fsmLogic:addWaitStatusForUser( "idel" ) 

end

function M:Refresh(data)
	M.super.Refresh( self )
end

function M:Exit()
	M.super.Exit( self )
	self:RemoveListener()
	-- CachePrefabManager.Back(self.canno_prefab)
	-- CachePrefabManager.Back(self.prefab)
	Destroy(self.gameObject)
	self.fsmLogic:Delete()

	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
		end
	end
	
	ClearTable(self)
end

function M:FrameUpdate(dt)
	M.super.FrameUpdate( self , dt )
	--print("xxxx-------------hero update")

	self.fsmLogic:Update(dt)
	local c = 0
	if not CSPanel.is_head then
		for id,skill in pairs(self.skill) do
			c = c + 1
			if skill.isLive then
				skill:FrameUpdate(dt)
			else
				self.skill[id]:Exit()
				self.skill[id] = nil
			end
		end
	end
	if IsEquals(self.starTX)  then
		self.starTX.transform.eulerAngles = Vector3.New(0,0,0)
	end
	self:RefreshBaseModelRotation()
end


function M:RefreshBaseModelRotation()
	self.model.transform.rotation = Quaternion.Euler(0,0,0)
end

function M:MakeLister()
	M.super.MakeLister( self )
	self.lister = {}
	--self.lister["HeroTypeChange"] = basefunc.handler(self,self.RefreshAll)

	self.lister["hero_link_change"] = basefunc.handler(self,self.RefreshAll)
	
end

function M:AddMsgListener()
	M.super.AddMsgListener( self )
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end

end

function M:RemoveListener()
	M.super.RemoveListener( self )
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}

end

-- function M:OnHit(data)
-- 	-- dump(data,"英雄受伤")
-- 	GameInfoCenter.AddPlayerHp(-data.damage)
-- end


function M:SetLocation(location)
	self.data.location = location
end


function M:CreatForzenPrefab()

	local forzenPrefab = CachePrefabManager.Take("forzen", self.forzenNode, 10)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero

	return forzenPrefab

end

function M:RefreshAll(data)
	--local _cfg = GameConfigCenter.GetHeroConfig(data.type,data.star)
	--local hero_color = _cfg.hero_color
	--if hero_color == self.config.hero_color then
	if data.id == self.id then
		local flag = false
		if data.star > 1 and data.star ~= self.config.star then
			flag = true
		end
		
		--Destroy(self.gameObject)
		--self:CreateUI()
		local level = HeroDataManager.GetHeroLevelByType( self.config.type )
		self.config = GameConfigCenter.GetHeroConfig( self.config.type, data.star , level )
		self:InitBaseData()
		--self.data.level = data.level
		--dump( self.config , "xxx----------------hero_refresh_all  self.config::" )

		---- 刷新技能，不能先删除再创建
		if self.config.skill and type(self.config.skill) == "table" then
			for skill_id,_c_data in pairs(self.config.skill) do

				local skillObj = GameInfoCenter.GetObjSkillByTypeValue( self , "skill_id" , skill_id )

				if skillObj then
					local skill_config = GameConfigCenter.GetSkillConfig( skill_id , ( type(_c_data) == "table") and _c_data or nil )
					skillObj:Refresh( skill_config )
				end
			end
		end
		
		if flag then
			if IsEquals(self.starTX) then
				Destroy(self.starTX)
			end

			self.starTX = NewObject("C_bao_tubiao",self.transform)
			local temp_ui = {}
			GeneratingVar(self.starTX.transform,temp_ui)
			temp_ui["index_txt"].text = data.star
			self.starTX.transform.localPosition = Vector3.zero
			GameObject.Destroy(self.starTX,3)
		end
		
		--[[for k,v in pairs(self.skill) do
			v:Exit()
		end--]]
		--self:InitSkill()
	end
end