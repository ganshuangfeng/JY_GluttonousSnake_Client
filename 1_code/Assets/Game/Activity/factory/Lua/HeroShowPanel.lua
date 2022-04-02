local basefunc = require "Game/Common/basefunc"

HeroShowPanel = basefunc.class()
local M = HeroShowPanel
M.name = "HeroShowPanel"

function M.Create(hero_type)
	return M.New(hero_type)
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
	self.lister["hero_level_changed"] = basefunc.handler(self,self.MyRefresh)
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

function M:Ctor(hero_type)
	ExtPanel.ExtMsg(self)
	self.panelSelf = panelSelf
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.cur_hero_type = hero_type
	self.attack_type = GameConfigCenter.GetHeroAttackType(self.cur_hero_type)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.hero_show_close_btn.onClick:AddListener(
		function()

			self:Exit()
		end
	)
	self.level_up_btn.onClick:AddListener(function()
		local _turret = self.turret_items[self.cur_hero_type]
		local need = HeroDataManager.GetUnlockNeed(_turret.hero_type,_turret.level)
		local fragment_num = HeroDataManager.GetHeroFragmentNumByType(_turret.hero_type)
		local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
		self.up_tx.gameObject:SetActive(false)
		self.up_tx.gameObject:SetActive(true)

		Timer.New(function()
			if IsEquals(self.gameObject) then
				self.up_tx.gameObject:SetActive(false)
			end
		end,1,1):Start()
		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
			HeroDataManager.UpHeroLevelByType(_turret.hero_type)
		else
			LittleTips.Create("材料不足！")
		end
	end)
	self.level_up_gray_btn.onClick:AddListener(function()
		LittleTips.Create("材料不足！")
	end)
	self.unlock_btn.onClick:AddListener(function()
		local _turret = self.turret_items[self.cur_hero_type]
		local need = HeroDataManager.GetUnlockNeed(_turret.hero_type,_turret.level)
		local fragment_num = HeroDataManager.GetHeroFragmentNumByType(_turret.hero_type)
		local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
			HeroDataManager.UpHeroLevelByType(_turret.hero_type)
		else
			LittleTips.Create("材料不足！")
		end
		
	end)

	self.unlock_gray_btn.onClick:AddListener(function()
		LittleTips.Create("材料不足")
	end)

	self.battle_btn.onClick:AddListener(
		function()
			if  HeroDataManager.IsHeroUnlock(self.cur_hero_type) then
				HeroDataManager.SetGoIntoBattle(self.cur_hero_type)
				LittleTips.Create("已上阵")
				self.ysz_btn.gameObject:SetActive(true)
				self:Exit()
			else
				LittleTips.Create("英雄还没有解锁")
			end
		end
	)
	if AppDefine.IsEDITOR() then
		self.test_btn.onClick:AddListener(function()
			--HeroDataManager.ChangeHeroFragmentNumByType(self.cur_hero_type,10)
			MainModel.TestAddAsset(
				{
					[1] = {
						asset_type = "prop_hero_fragment_"..self.cur_hero_type,
						asset_value = 10
					},
					[2] = {
						asset_type = "prop_jin_bi",
						asset_value = 10000
					},
				}
			)
			self:RefreshTurretInfo(self.cur_hero_type)
			self:RefreshTurretItem(self.cur_hero_type)
			-- --ClientAndSystemManager.SendRequest("cs_add_gold",{jb = 10000})
		end)
	end
	self.ysz_btn.onClick:AddListener(
		function()
			LittleTips.Create("已上阵")
		end
	)
	self:RefreshCompanyInfo(self.cur_hero_type)
	self:AddRedPointEvent()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.cfg = HeroDataManager.GetUnlockConfig()
	local hero_base_config = HeroDataManager.GetHeroBaseConfig()

	self.turret_items = {}
	for i = 1,#hero_base_config.base do
		local k = "hero_" .. i
		local v = self.cfg[k]
		if v then
			local _turret = {}
			local hero_type = tonumber(string.sub(k,6))
			local base_cfg = hero_base_config.base[hero_type]
			local level = HeroDataManager.GetHeroLevelByType(hero_type)
			-- _turret.tbl = tbl
			_turret.hero_type = hero_type
			_turret.cfg = v
			_turret.base_cfg = base_cfg
			_turret.level = level
			self.turret_items[_turret.hero_type] = _turret
		end
	end
	self:MyRefresh()
end

local turret_cfg = {
	[1] = {
		asset_type = "prop_hero_fragment_1",
		damage_level = 2,
		attack_speed_level = 2,
		attack_range_level = 3,
	},
	[2] = {
		asset_type = "prop_hero_fragment_2",
		damage_level = 1,
		attack_speed_level = 4,
		attack_range_level = 2,
	},
	[3] = {
		asset_type = "prop_hero_fragment_3",
		damage_level = 3,
		attack_speed_level = 2,
		attack_range_level = 4,
	},
	[4] = {
		asset_type = "prop_hero_fragment_4",
		damage_level = 2,
		attack_speed_level = 3,
		attack_range_level = 2,
	},
	[7] = {
		asset_type = "prop_hero_fragment_7",
		damage_level = 2,
		attack_speed_level = 1,
		attack_range_level = 4,
	},
	[9] = {
		asset_type = "prop_hero_fragment_9",
		damage_level = 1,
		attack_speed_level = 4,
		attack_range_level = 2,
	},
	[13] = {
		damage_level = 4,
		attack_speed_level = 1,
		attack_range_level = 4,
	},
	[14] = {
		asset_type = "prop_hero_fragment_14",
		damage_level = 3,
		attack_speed_level = 2,
		attack_range_level = 1,
	},
	[15] = {
		asset_type = "prop_hero_fragment_15",
		damage_level = 4,
		attack_speed_level = 2,
		attack_range_level = 2,
	},
	[16] = {
		asset_type = "prop_hero_fragment_16",
		damage_level = 2,
		attack_speed_level = 2,
		attack_range_level = 1,
	},
	[17] = {
		asset_type = "prop_hero_fragment_17",
		damage_level = 4,
		attack_speed_level = 2,
		attack_range_level = 1,
	},
	[18] = {
		asset_type = "prop_hero_fragment_18",
		damage_level = 3,
		attack_speed_level = 3,
		attack_range_level = 3,
	},
	[19] = {
		asset_type = "prop_hero_fragment_19",
		damage_level = 1,
		attack_speed_level = 2,
		attack_range_level = 3,
	},
	[20] = {
		asset_type = "prop_hero_fragment_20",
		damage_level = 3,
		attack_speed_level = 2,
		attack_range_level = 2,
	},
	[21] = {
		asset_type = "prop_hero_fragment_21",
		damage_level = 2,
		attack_speed_level = 3,
		attack_range_level = 2,
	},
}

function M:RefreshTurretInfo(hero_type)
	dump(hero_type,"<color=yellow>hero_type</color>")
	self.cur_hero_type = hero_type
	local hero_base_config = HeroDataManager.GetHeroBaseConfig()
	local base_config = hero_base_config.base[hero_type]

	local _turret = self.turret_items[hero_type]
	_turret.level = HeroDataManager.GetHeroLevelByType(hero_type)
	self.turret_img.sprite = GetTexture(base_config.icon_img)
	self.turret_name_txt.text = base_config.remark
	self.turret_level_txt.text = "LV." .. _turret.level
	local _level_hero_config = GameConfigCenter.GetHeroConfig(hero_type,1,_turret.level)

	self.attack_speed_value_txt.text = "(" .. base_config.hit_space .. ")"
	self.attack_range_value_txt.text = "(" .. base_config.attack_range .. ")"
	local need = HeroDataManager.GetUnlockNeed(hero_type,_turret.level)
	local fragment_num = HeroDataManager.GetHeroFragmentNumByType(hero_type)
	local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
	
	self.fragment_txt.text = fragment_num .. "/" .. need.fragment_need
	if fragment_num >= need.fragment_need then
		self.fragment_txt.color = Color.New(1,1,1)
	else
		self.fragment_txt.color = Color.New(1,0,0)
	end
	self.jb_txt.text = need.gold_need
	self.jb_btn = self.jb_img.transform:GetComponent("Button")
	self.jb_btn.onClick:AddListener(function ()
		ItemShowPanel.Create("prop_jin_bi")
	end)
	local set_level_func = function(desc,level)
		if type(level) ~= "number" then return end
		local _desc
		if level == 1 then
			_desc = "低"
		elseif level == 2 or level == 3 then
			_desc = "中"
		elseif level == 4 then
			_desc = "高"
		end
		self[desc .. "_desc_txt"].text = _desc
		for i = 1,4 do
			if i > level then
				self[desc .. "_" .. i].gameObject:SetActive(false)
			else
				self[desc .. "_" .. i].gameObject:SetActive(true)
			end
		end
	end
	local _turret_cfg = turret_cfg[hero_type]
	for k,v in pairs(_turret_cfg) do
		set_level_func(k,v)
	end
	local assetCfg = GameConfigCenter.GetAssetConfigByType(_turret_cfg.asset_type)
	self.fragment_img.sprite = GetTexture(GameConfigCenter.GetHeroFragmentIcon(self.cur_hero_type))
	self.fragment_btn = self.fragment_img.transform:GetComponent("Button")
	local ac = _turret_cfg.asset_type
	self.fragment_btn.onClick:AddListener(function ()
		ItemShowPanel.Create(ac)
	end)
	if _turret.level <= 0 then
		self.level_up_btn.gameObject:SetActive(false)
		self.level_up_gray_btn.gameObject:SetActive(false)
		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
			self.unlock_btn.gameObject:SetActive(true)
			self.unlock_gray_btn.gameObject:SetActive(false)
		else
			self.unlock_btn.gameObject:SetActive(false)
			self.unlock_gray_btn.gameObject:SetActive(true)
		end
		self.can_up_notice.gameObject:SetActive(false)
		self.damage_value_txt.text = "(" .. base_config.damage .. ")"
	else
		self.unlock_btn.gameObject:SetActive(false)
		self.unlock_gray_btn.gameObject:SetActive(false)
		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
			self.level_up_btn.gameObject:SetActive(true)
			self.level_up_gray_btn.gameObject:SetActive(false)
			local next = GameConfigCenter.GetHeroConfig(hero_type,1,_turret.level + 1)


			if _turret.level < 20 then
				self.damage_value_txt.text = "(" .. _level_hero_config.damage .."<color=green>+"..next.damage - _level_hero_config.damage.. "</color>)" 
			else
				self.damage_value_txt.text = "(" .. _level_hero_config.damage .. ")"
			end
			self.can_up_notice.gameObject:SetActive(_turret.level < 20 and _turret.level > 0)
		else
			self.level_up_btn.gameObject:SetActive(false)
			self.level_up_gray_btn.gameObject:SetActive(true)
			self.can_up_notice.gameObject:SetActive(false)

			self.damage_value_txt.text = "(" .. _level_hero_config.damage .. ")"
		end
	end
	self.level_max_txt.gameObject:SetActive(false)
	if _turret.level == 20 then
		self.unlock_btn.gameObject:SetActive(false)
		self.unlock_gray_btn.gameObject:SetActive(false)
		self.level_up_btn.gameObject:SetActive(false)
		self.level_up_gray_btn.gameObject:SetActive(false)
		self.level_max_txt.gameObject:SetActive(true)
		self.fragment_node.gameObject:SetActive(false)
		self.jb_node.gameObject:SetActive(false)
	end

	if jin_bi >= need.gold_need then
		self.jb_txt.color = Color.New(1,1,1)
	else
		self.jb_txt.color = Color.New(1,0,0)
	end
end

function M:RefreshTurretItem(hero_type)
	
	-- for k , v in pairs(self.turret_items) do
	-- 	local _turret = v
	-- 	if _turret then
	-- 		local hero_type = _turret.hero_type
	-- 		local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
	-- 		_turret.tbl.turret_item_level_txt.text = "LV." .. _turret.level
	-- 		_turret.tbl.turret_item_img.sprite = GetTexture(_turret.base_cfg.icon_img)
	-- 		local need = HeroDataManager.GetUnlockNeed(hero_type,_turret.level)
	-- 		local fragment_num = HeroDataManager.GetHeroFragmentNumByType(hero_type)
	-- 		_turret.tbl.exp_progress_img.fillAmount = fragment_num / need.fragment_need
	-- 		_turret.tbl.exp_progress_txt.text = fragment_num .. "/" .. need.fragment_need
	-- 		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
	-- 			_turret.tbl.exp_icon_tx.gameObject:SetActive(true)
	-- 			_turret.tbl.exp_not_icon_tx.gameObject:SetActive(false)
	-- 			_turret.tbl.exp_progress_img.sprite = GetTexture("wf4_jdt_02")
	-- 		else
	-- 			_turret.tbl.exp_icon_tx.gameObject:SetActive(false)
	-- 			_turret.tbl.exp_progress_img.sprite = GetTexture("wf4_jdth_02")
	-- 			_turret.tbl.exp_not_icon_tx.gameObject:SetActive(true)
	-- 		end
	-- 		if _turret.level > 0 then
	-- 			_turret.tbl.lock_img.gameObject:SetActive(false)
	-- 			_turret.tbl.turret_item_level_txt.gameObject:SetActive(true)
	-- 			_turret.transform:SetSiblingIndex(_turret.hero_type)
	-- 		else
	-- 			_turret.tbl.lock_img.gameObject:SetActive(true)
	-- 			_turret.tbl.turret_item_level_txt.gameObject:SetActive(false)
	-- 			_turret.transform:SetAsLastSibling()
	-- 		end
	-- 	end

	-- end
	
end

function M:MyRefresh()
	self:RefreshTurretInfo(self.cur_hero_type)
	self.ysz_btn.gameObject:SetActive(HeroDataManager.IsHeroGoBattle(self.cur_hero_type))
end

function M:AddRedPointEvent()
	self.OnRedPointNumChange = function (redPointNode)
		if redPointNode.num > 0 then
			self.red_point.gameObject:SetActive(true)
		else
			self.red_point.gameObject:SetActive(false)
		end
	end
	RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryHero .. "." .. self.attack_type .. "." .. self.cur_hero_type,self.OnRedPointNumChange)
end

function M:CallRedPointEvent()
	RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryHero .. "." .. self.attack_type .. "." .. self.cur_hero_type,self.OnRedPointNumChange)
end

function M:RemoveRedPointEvent()
	RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryHero .. "." .. self.attack_type .. "." .. self.cur_hero_type,self.OnRedPointNumChange)
end

function M:RefreshCompanyInfo(hero_type)
	local hero_base_config = HeroDataManager.GetHeroBaseConfig()
	local base_config = hero_base_config.base[hero_type]
	for k,v in ipairs(hero_base_config.base_change) do
		if v.id == hero_type and v.link_desc and self["turret_company_item_" .. (v.star - 1)] then
			local tbl = LuaHelper.GeneratingVar(self["turret_company_item_" .. (v.star - 1)])
			tbl.huoban_count_desc_txt.text = base_config.remark .. "x" .. v.star
			tbl.huoban_desc_txt.text = v.link_desc
		end
	end
	local str  = "·相同的炮台同时上场会获得额外效果"
	str = str .. "\n".."·"..base_config.desc
	self.texing_txt.text = str
end
