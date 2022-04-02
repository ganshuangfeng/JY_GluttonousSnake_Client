local basefunc = require "Game/Common/basefunc"

FactoryHeroPanel = basefunc.class()
local M = FactoryHeroPanel
M.name = "FactoryHeroPanel"

function M.Create(parent,config)
	return M.New(parent,config)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["FactoryMainUIPanelExit"] = basefunc.handler(self,self.Exit)
	self.lister["battle_data_changed"] = basefunc.handler(self,self.Refresh)
	self.lister["hero_level_changed"] = basefunc.handler(self,self.Refresh)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	self:RemoveRedPointEvent()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent,config)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	GeneratingVar(self.transform, self)
	self.config = config
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self:AddRedPointEvent()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.titile_txt.text = self.config.type_name
	local this_type_all_level = 0
	local hero_list_ui = GameConfigCenter.GetHeroListUIByAttackType(self.config.attack_type)
	self.item_list = {}
	self.other_num = 0
	for i = 1,3 do
		if hero_list_ui[i] ~= 999 then
			local level = HeroDataManager.GetHeroLevelByType(hero_list_ui[i])
			this_type_all_level = this_type_all_level + level
			local obj = GameObject.Instantiate(self.hero_item,self.hero_node)
			obj.gameObject:SetActive(true)
			local temp_ui = {}
			local hero_base_config = HeroDataManager.GetHeroBaseConfig()
			local base_config = hero_base_config.base[hero_list_ui[i]]
			obj.name = "turret_item_"..base_config.type

			GeneratingVar(obj.transform,temp_ui)
			temp_ui.slider = temp_ui.slider:GetComponent("Slider")
			temp_ui.hero_lock.gameObject:SetActive(level == 0)
			temp_ui.hero_level_txt.gameObject:SetActive(level > 0)
			temp_ui.hero_level_txt.text = "LV."..level
			temp_ui.hero_icon_img.sprite = GetTexture(base_config.icon_img)
			temp_ui.hero_icon_img:SetNativeSize()
			temp_ui.hero_icon_img.gameObject.transform.localScale = Vector3.New(0.8,0.8,0.8)
			temp_ui.ysz.gameObject:SetActive( HeroDataManager.IsHeroGoBattle(hero_list_ui[i]))
			temp_ui.hero_btn.onClick:AddListener(
				function()
					HeroShowPanel.Create(hero_list_ui[i])
				end
			)

			local data = {}
			data.obj = obj
			data.hero_type = hero_list_ui[i]
			data.temp_ui = temp_ui
			self.item_list[#self.item_list + 1] = data

			local fragment_num = HeroDataManager.GetHeroFragmentNumByType(data.hero_type)
			local level = HeroDataManager.GetHeroLevelByType(data.hero_type)
			local need = HeroDataManager.GetUnlockNeed(data.hero_type,level)
			if fragment_num == 0 then
				data.temp_ui.progress_txt.text = "<color=red>" .. fragment_num .. "/" .. need.fragment_need .. "</color>"
			else
				data.temp_ui.progress_txt.text = fragment_num .. "/" .. need.fragment_need
			end
			temp_ui.slider.value = fragment_num / need.fragment_need
			if level >= 20 then
				data.temp_ui.progress_txt.text = "MAX"
			end
		else
			local obj = GameObject.Instantiate(self.zanwei,self.hero_node)
			obj.gameObject:SetActive(true)
			self.other_num = self.other_num + 1
		end
	end

	local hero_list = GameConfigCenter.GetHeroListByAttackType(self.config.attack_type)
	local first_hero_type = hero_list[1]
	local data = GameConfigCenter.GetMasterBuffByHeroType(first_hero_type)

	self.lv_txt.text = "总等级:"..this_type_all_level

	self.master_btn.onClick:AddListener(
		function()
			HeroShowMasterPanel.Create(self.config.attack_type,self.config)
		end
	)

	self.nodeLayoutGroup = self.hero_node:GetComponent("HorizontalLayoutGroup")
	if #self.item_list + self.other_num > 2 then
		self.nodeLayoutGroup.spacing = 300
	else
		self.nodeLayoutGroup.spacing = 350
	end
end

function M:Refresh()
	for i = 1,#self.item_list do
		local data = self.item_list[i]
		local level = HeroDataManager.GetHeroLevelByType(data.hero_type)
		data.temp_ui.hero_lock.gameObject:SetActive(level == 0)
		data.temp_ui.hero_level_txt.gameObject:SetActive(level > 0)
		data.temp_ui.hero_level_txt.text = "LV."..level
		if not data.temp_ui.ysz.gameObject.activeSelf then
			data.temp_ui.ysz_tx.gameObject:SetActive(false)
			data.temp_ui.ysz_tx.gameObject:SetActive(HeroDataManager.IsHeroGoBattle(data.hero_type))
		end
		data.temp_ui.ysz.gameObject:SetActive( HeroDataManager.IsHeroGoBattle(data.hero_type))
		
		local fragment_num = HeroDataManager.GetHeroFragmentNumByType(data.hero_type)
		local level = HeroDataManager.GetHeroLevelByType(data.hero_type)
		local need = HeroDataManager.GetUnlockNeed(data.hero_type,level)
		if fragment_num == 0 then
			data.temp_ui.progress_txt.text = "<color=red>" .. fragment_num .. "/" .. need.fragment_need .. "</color>"
		else
			data.temp_ui.progress_txt.text = fragment_num .. "/" .. need.fragment_need
		end
		data.temp_ui.slider.value = fragment_num / need.fragment_need
		if level >= 20 then
			data.temp_ui.progress_txt.text = "MAX"
		end
	end

	local hero_list = GameConfigCenter.GetHeroListByAttackType(self.config.attack_type)
	local this_type_all_level = 0
	for i = 1,#hero_list do
		local level = HeroDataManager.GetHeroLevelByType(hero_list[i])
		this_type_all_level = this_type_all_level + level
	end
	self.lv_txt.text = "总等级:"..this_type_all_level

	if not self.nodeLayoutGroup then
		self.nodeLayoutGroup = self.hero_node:GetComponent("HorizontalLayoutGroup")
	end
	if #self.item_list + self.other_num > 2 then
		self.nodeLayoutGroup.spacing = 300
	else
		self.nodeLayoutGroup.spacing = 350
	end
end

function M:AddRedPointEvent()
	for i = 1,#self.item_list do
		local data = self.item_list[i]
		data.OnRedPointNumChange = function (redPointNode)
			if redPointNode.num > 0 then
				data.temp_ui.red_point.gameObject:SetActive(true)
				data.temp_ui.gray_point.gameObject:SetActive(false)
			else
				data.temp_ui.red_point.gameObject:SetActive(false)
				local level = HeroDataManager.GetHeroLevelByType(data.hero_type)
				data.temp_ui.gray_point.gameObject:SetActive(level < 20)
			end
		end
		RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryHero .. "." .. self.config.attack_type .. "." .. data.hero_type,data.OnRedPointNumChange)
	end
end

function M:CallRedPointEvent()
	for i = 1,#self.item_list do
		local data = self.item_list[i]
		RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryHero .. "." .. self.config.attack_type .. "." .. data.hero_type,data.OnRedPointNumChange)
	end
end

function M:RemoveRedPointEvent()
	for i = 1,#self.item_list do
		local data = self.item_list[i]
		RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryHero .. "." .. self.config.attack_type .. "." .. data.hero_type,data.OnRedPointNumChange)
	end
end