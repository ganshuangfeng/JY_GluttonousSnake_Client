-- 创建时间:2021-10-13
-- Panel:TurretShowPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

TurretShowPanel = basefunc.class()
local M = TurretShowPanel
M.name = "TurretShowPanel"

function M.Create(panelSelf)
	return M.New(panelSelf)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(panelSelf)
	ExtPanel.ExtMsg(self)
	self.panelSelf = panelSelf
	local parent = panelSelf.turret_show_node
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
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
	self.star_btn.onClick:AddListener(function()
		if not self.TurretCompanyPanel then
			self.TurretCompanyPanel = TurretCompanyPanel.Create(self.turret_company_node)
			self.TurretCompanyPanel:RefreshCompanyInfo(self.cur_hero_type)
		end
		self.data_img.gameObject:SetActive(false)
		self.data_btn.gameObject:SetActive(true)
		self.star_img.gameObject:SetActive(true)
		self.star_btn.gameObject:SetActive(false)
		self.turret_data_node.gameObject:SetActive(false)
		self.turret_company_node.gameObject:SetActive(true)
	end)
	self.data_btn.onClick:AddListener(function()
		self.data_img.gameObject:SetActive(true)
		self.data_btn.gameObject:SetActive(false)
		self.star_img.gameObject:SetActive(false)
		self.star_btn.gameObject:SetActive(true)
		self.turret_data_node.gameObject:SetActive(true)
		self.turret_company_node.gameObject:SetActive(false)
	end)
	self.unlock_gray_btn.onClick:AddListener(function()
		LittleTips.Create("材料不足")
	end)
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
			local obj = GameObject.Instantiate(self.turret_item,self.turret_item_node)
			local tbl = LuaHelper.GeneratingVar(obj.transform)
			local hero_type = tonumber(string.sub(k,6))
			local base_cfg = hero_base_config.base[hero_type]
			local level = HeroDataManager.GetHeroLevelByType(hero_type)
			obj.gameObject:SetActive(true)
			obj.gameObject.name = "turret_item_" .. hero_type
			obj.transform:GetComponent("Button").onClick:AddListener(function()
				for k,v in pairs(self.turret_items) do
					v.tbl.curr_choose.gameObject:SetActive(false)
				end
				_turret.tbl.curr_choose.gameObject:SetActive(true)
				self:RefreshTurretInfo(hero_type)
				----ClientAndSystemManager.SendRequest("cs_add_gold",{jb = 100})
				--MainModel.AddAsset("prop_jin_bi",100)

			end)
			_turret.gameObject = obj.gameObject
			_turret.transform = obj.gameObject.transform
			_turret.tbl = tbl
			_turret.hero_type = hero_type
			_turret.cfg = v
			_turret.base_cfg = base_cfg
			_turret.level = level
			self.turret_items[_turret.hero_type] = _turret
			self:RefreshTurretItem(hero_type)
		end
	end
	self.turret_items[1].tbl.curr_choose.gameObject:SetActive(true)
	self:MyRefresh()
end

local turret_cfg = {
	[1] = {
		damage_level = 2,
		attack_speed_level = 2,
		attack_range_level = 3,
		fragment_img = "wf4_sp_3"
	},
	[2] = {
		damage_level = 1,
		attack_speed_level = 4,
		attack_range_level = 2,
		fragment_img = "wf4_sp_4"
	},
	[3] = {
		damage_level = 3,
		attack_speed_level = 2,
		attack_range_level = 4,
		fragment_img = "wf4_sp_1"
	},
	[4] = {
		damage_level = 2,
		attack_speed_level = 3,
		attack_range_level = 2,
		fragment_img = "wf4_sp_2"
	},
	[7] = {
		damage_level = 2,
		attack_speed_level = 1,
		attack_range_level = 4,
		fragment_img = "wf4_sp_7"
	},
	[13] = {
		damage_level = 4,
		attack_speed_level = 1,
		attack_range_level = 4,
		fragment_img = "wf4_sp_5"
	},
	[14] = {
		damage_level = 2,
		attack_speed_level = 2,
		attack_range_level = 2,
		fragment_img = "wf4_sp_6"
	},
}

function M:RefreshTurretInfo(hero_type)
	self.cur_hero_type = hero_type
	local hero_base_config = HeroDataManager.GetHeroBaseConfig()
	local base_config = hero_base_config.base[hero_type]
	local _turret = self.turret_items[hero_type]
	self.turret_img.sprite = GetTexture(base_config.icon_img)
	self.turret_name_txt.text = base_config.remark
	self.turret_level_txt.text = "LV." .. _turret.level .. "/" .. #_turret.cfg
	local _level_hero_config = GameConfigCenter.GetHeroConfig(hero_type,1,_turret.level)

	self.attack_speed_value_txt.text = "（" .. base_config.hit_space .. "）"
	self.attack_range_value_txt.text = "（" .. base_config.attack_range .. "）"
	local need = HeroDataManager.GetUnlockNeed(hero_type,_turret.level)
	local fragment_num = HeroDataManager.GetHeroFragmentNumByType(hero_type)
	local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
	
	self.fragment_txt.text = fragment_num .. "/" .. need.fragment_need
	self.jb_txt.text = need.gold_need
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
	self.fragment_img.sprite = GetTexture(_turret_cfg.fragment_img)
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
		self.damage_value_txt.text = "（" .. base_config.damage .. "）"
	else
		self.unlock_btn.gameObject:SetActive(false)
		self.unlock_gray_btn.gameObject:SetActive(false)
		if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
			self.level_up_btn.gameObject:SetActive(true)
			self.level_up_gray_btn.gameObject:SetActive(false)
			local next = GameConfigCenter.GetHeroConfig(hero_type,1,_turret.level + 1)


			if _turret.level < 20 then
				self.damage_value_txt.text = "（" .. _level_hero_config.damage .."<color=green>+</color>"..next.damage - _level_hero_config.damage.. "）" 
			else
				self.damage_value_txt.text = "（" .. _level_hero_config.damage .. "）"
			end

			self.can_up_notice.gameObject:SetActive(true)

		else
			self.level_up_btn.gameObject:SetActive(false)
			self.level_up_gray_btn.gameObject:SetActive(true)
			self.can_up_notice.gameObject:SetActive(false)

			self.damage_value_txt.text = "（" .. _level_hero_config.damage .. "）"
		end
	end
	self.level_max_txt.gameObject:SetActive(false)
	if _turret.level == 20 then
		self.unlock_btn.gameObject:SetActive(false)
		self.unlock_gray_btn.gameObject:SetActive(false)
		self.level_up_btn.gameObject:SetActive(false)
		self.level_up_gray_btn.gameObject:SetActive(false)
		self.level_max_txt.gameObject:SetActive(true)
	end
	if self.TurretCompanyPanel then
		self.TurretCompanyPanel:RefreshCompanyInfo(hero_type)
	end
end

function M:RefreshTurretItem(hero_type)
	
	for k , v in pairs(self.turret_items) do
		local _turret = v
		if _turret then
			local hero_type = _turret.hero_type
			local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
			_turret.tbl.turret_item_level_txt.text = "LV." .. _turret.level
			_turret.tbl.turret_item_img.sprite = GetTexture(_turret.base_cfg.icon_img)
			local need = HeroDataManager.GetUnlockNeed(hero_type,_turret.level)
			local fragment_num = HeroDataManager.GetHeroFragmentNumByType(hero_type)
			_turret.tbl.exp_progress_img.fillAmount = fragment_num / need.fragment_need
			_turret.tbl.exp_progress_txt.text = fragment_num .. "/" .. need.fragment_need
			if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
				_turret.tbl.exp_icon_tx.gameObject:SetActive(true)
				_turret.tbl.exp_not_icon_tx.gameObject:SetActive(false)
				_turret.tbl.exp_progress_img.sprite = GetTexture("wf4_jdt_02")
			else
				_turret.tbl.exp_icon_tx.gameObject:SetActive(false)
				_turret.tbl.exp_progress_img.sprite = GetTexture("wf4_jdth_02")
				_turret.tbl.exp_not_icon_tx.gameObject:SetActive(true)
			end
			if _turret.level > 0 then
				_turret.tbl.lock_img.gameObject:SetActive(false)
				_turret.tbl.turret_item_level_txt.gameObject:SetActive(true)
				_turret.transform:SetSiblingIndex(_turret.hero_type)
			else
				_turret.tbl.lock_img.gameObject:SetActive(true)
				_turret.tbl.turret_item_level_txt.gameObject:SetActive(false)
				_turret.transform:SetAsLastSibling()
			end
		end

	end
	
end

function M:MyRefresh()
	self:RefreshTurretInfo(1)
end
