local basefunc = require "Game/Common/basefunc"

ItemThreeChooseOnePanel = basefunc.class()
local M = ItemThreeChooseOnePanel
M.name = "ItemThreeChooseOnePanel"

local config = {
	hero_1 = 1,
	hero_2 = 1,
	hero_3 = 1,
	hero_4 = 1,
	hero_7 = 1,
	hero_13 = 1,
	hero_14 = 1,
	--hero_15 = 1000,
	heal = 999999999,--固定存在
}

function M.Create(_config,from)
	return M.New(_config,from)
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
	CSPanel:SetStopUpdate(false)

	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(_config,from)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	CSPanel:SetStopUpdate(true)
	local obj
	if from == "diaoxiang" then
		obj = NewObject("ItemThreeChooseOnePanel", parent)
	else
		obj = NewObject("HeroThreeChooseOnePanel",parent)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.config = basefunc.deepcopy(_config or config)
	self.from = from
	--剔除没有解锁和没有上证的英雄
	for k, v in pairs(self.config) do
		if string.sub(k, 1,5) == "hero_" then
			local hero_type = tonumber(string.sub(k, 6))
			if not HeroDataManager.IsHeroGoBattle(hero_type)  or not HeroDataManager.IsHeroUnlock(hero_type) then
				self.config[k] = nil
			end
		end
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	GuideLogic.CheckRunGuide("three", function ()
		    DOTweenManager.OpenPopupUIAnim(self.root.transform)	
	end)
end

function M:InitUI()
	local data = self:GetData(2)
	if not data then return Timer.New(function() self:Exit() end,1,1):Start() end
	--来自雕像
	local max = 3
	if self.from == "diaoxiang" then
		max = ItemThreeChooseOneManager.max_item
	end
	for i = 1,max do
		local type = data[i]
		if type then
			if string.sub(type, 1, 5) == "hero_" then
				local hero_type = tonumber(string.sub(type, 6))
				self:InitHeroUI(hero_type)
			elseif type == "heal" then
				self:InitHeal()
			elseif type == "hpMaxUp" then
				self:InitHpMaxUp()
			elseif type == "Invincible" then
				self:InitInvincibleUI()
			elseif type == "attackSpeedUp" then
				self:InitAttackSpeedUpUI()
			elseif type == "attackDamageUp" then
				self:InitAttackDamageUpUI()
			elseif type == "notHero" then
				self:InitNotHeroUI()
			elseif type == "only2" then
				self:InitOnly2UI()
			elseif type == "addSkillUseTime" then
				self:InitAddSkill()
			end
		end
	end
	
end

function M:GetData(func_type)
	local data = {}
	if func_type == 1 or func_type == 2 then
		for i = 1,3 do
			local type
			if func_type == 1 then
				type = self:RandomGetItem()
			else
				type = self:RandomGetItemNoRepet()
			end
			data[#data + 1] = type
		end
	elseif func_type == 3 then
		data = self:RandomGetItemWithHeroLink()
	end 
	return data
end

--完全随机
function M:RandomGetItem()
	local total = 0
	local part_list = {}
	for k , v in pairs(self.config) do
		part_list[k] = {min = total,max = total + v}
		total = total + v
	end

	local random = math.random(0,total)
	local type = nil
	for k , v in pairs(part_list) do
		if random >= v.min and random <= v.max then
			type = k
			break
		end
	end
	return type
end
--随机并且不重复
function M:RandomGetItemNoRepet()
	local total = 0
	local part_list = {}
	for k , v in pairs(self.config) do
		part_list[k] = {min = total,max = total + v}
		total = total + v
	end

	local random = math.random(0,total)
	local type = nil
	for k , v in pairs(part_list) do
		if random >= v.min and random <= v.max then
			type = k
			self.config[type] = nil
			break
		end
	end
	return type
end

--如果有英雄，某一个随机项必定是已有的英雄（不重复）
function M:RandomGetItemWithHeroLink()
	local the_special_index = math.random(1,3)
	local hero_data = GameInfoCenter.GetAllHero()
	local max = GameInfoCenter.GetHeroNum()
	if max < 1 then
		local data = {}
		for i = 1,3 do
			local d = self:RandomGetItemNoRepet()
			data[#data + 1] = d
		end
		return data
	end

	local find_random_type_and_unlocked = function()

		local unlocked = {}
		for i = 1,max do
			local location = i
			local hero = GameInfoCenter.GetHeroByLocation(location)
			local hero_type = hero.data.type

			if HeroDataManager.IsHeroUnlock(hero_type) then
				unlocked[#unlocked + 1] = hero_type
			end
		end

		return unlocked[math.random(1,#unlocked)]
	end
	
	local hero_type = find_random_type_and_unlocked()

	if not hero_type then return end
	for k , v in pairs(self.config) do
		if k == "hero_"..hero_type then
			self.config[k] = nil
		end
	end

	local data = {}
	for i = 1,3 do
		if the_special_index == i then
			if ItemThreeChooseOneManager.isNotHeroOn and self.from == "diaoxiang" then

			else
				data[#data + 1] = "hero_"..hero_type
			end
		else	
			local type = self:RandomGetItemNoRepet()
			data[#data + 1] = type
		end
	end
	return data
end

function M:InitHeroUI(_type)
	local obj = NewObject("hero_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	local link_times = HeroLinkCheck.CheckLinkTimes(_type)
	local turret_data = {level = GameInfoCenter.GetTurretLevel(_type),star = GameInfoCenter.GetTurretStar(_type)}
	local cfg = GameConfigCenter.GetHeroConfig(_type,link_times + 1,turret_data.level)
	tbl.hero_name_txt.text = cfg.remark
	obj.transform:GetComponent("Button").onClick:AddListener(function()
		--ClientAndSystemManager.SendRequest("cs_buy_turret",{type=cfg.type})
		GameInfoCenter.BuyHero({type=cfg.type})
		print("<color=red>xxxx----------- select_hero_msg </color>" , cfg.type )
		task_mgr.TriggerMsg( "select_hero_msg" , cfg.type )
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
	obj.gameObject.name = "hero_threechose_one_".._type
	tbl.hero_lv_txt.text = HeroDataManager.GetHeroLevelByType(_type)
	tbl.hero_name_txt.text = cfg.remark
	tbl.hero_desc_txt.text = cfg.desc
	local next_link_count = 9999
	local next_link_desc
	for k,v in ipairs(cfg.base_change) do
		--从base_change种读取下一次连接的配置
		if v.link_desc and v.id == _type and v.star > link_times and v.star < next_link_count then
			next_link_desc = v.link_desc
			next_link_count = v.star
		end
	end
	if cfg.icon_img then
		tbl.hero_img.sprite = GetTexture(cfg.icon_img)
		tbl.hero_img:SetNativeSize()
		tbl.hero_img.gameObject.transform.localScale = Vector3.New(0.9,0.9,0.9)
	end
	if next_link_count - link_times <= 1 then
		tbl.hero_can_link_node.gameObject:SetActive(true)
		tbl.hero_not_link_node.gameObject:SetActive(false)
		tbl.hero_can_link_txt.text = next_link_count
		tbl.hero_can_link_desc_txt.text = next_link_desc
	else
		tbl.hero_can_link_node.gameObject:SetActive(false)
		tbl.hero_not_link_node.gameObject:SetActive(true)
		tbl.hero_not_link_txt.text = next_link_count
		tbl.hero_not_link_desc_txt.text = next_link_desc
	end
	if not next_link_desc then
		next_link_count = 0
		--没有下一等级的提示时 显示最大等级提示
		tbl.hero_can_link_node.gameObject:SetActive(false)
		tbl.hero_not_link_node.gameObject:SetActive(false)
		tbl.hero_link_max_node.gameObject:SetActive(true)
		
		for k,v in ipairs(cfg.base_change) do
			
			if v.link_desc and v.id == _type and v.star >= next_link_count then
				next_link_desc = v.link_desc
				next_link_count = v.star
			end
		end
		tbl.hero_link_max_txt.text = next_link_count
		tbl.hero_link_max_desc_txt.text = next_link_desc
	end
	obj.gameObject:SetActive(true)
end

function M:InitHeal()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("2D_map_diaoluodaoju _jiaxue")
	tbl.item_name_txt.text = "生命恢复"
	tbl.item_desc_txt.text = "恢复300点生命值"
	tbl.item_img.gameObject.transform.localScale = Vector3.New(1.2,1.2,1.2)
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		CreateFactory.CreateSkill({
			type = "SkillItemHeal",
			object = GameInfoCenter.GetHeroHead()
		})
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitHpMaxUp()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("xfg_tb_smsx")
	tbl.item_name_txt.text = "生命上限提升"
	tbl.item_desc_txt.text = "增加200点生命值上限"
	tbl.item_img.gameObject.transform.localScale = Vector3.New(1.6,1.6,1.6)
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		CreateFactory.CreateSkill({
			type = "SkillItemHpMaxUp",
			object = GameInfoCenter.GetHeroHead()
		})
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitInvincibleUI()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("xfg_tb_hd")
	tbl.item_name_txt.text = "无敌护盾"
	tbl.item_desc_txt.text = "周期性获得无敌护盾"
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		CreateFactory.CreateSkill({
			type = "SkillInvincible",
			object = GameInfoCenter.GetHeroHead()
		})
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitAttackSpeedUpUI()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("xfg_tb_gs")
	tbl.item_name_txt.text = "攻速提升"
	tbl.item_desc_txt.text = "增加所有炮台的攻击速度"
	tbl.item_img.gameObject.transform.localScale = Vector3.New(1.6,1.6,1.6)
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		CreateFactory.CreateSkill({
			type = "SkillItemAddAttackSpeed2",
			object = GameInfoCenter.GetHeroHead()
		})
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitAttackDamageUpUI()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("xfg_tb_gj")
	tbl.item_name_txt.text = "攻击提升"
	tbl.item_desc_txt.text = "增加所有炮台的攻击力"
	tbl.item_img.gameObject.transform.localScale = Vector3.New(1.6,1.6,1.6)
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		CreateFactory.CreateSkill({
			type = "SkillItemAddAttackDamage2",
			object = GameInfoCenter.GetHeroHead()
		})
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitNotHeroUI()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("2d_zd_h")
	tbl.item_name_txt.text = "不再出现炮台选项"
	tbl.item_desc_txt.text = "不再出现炮台选项"
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		ItemThreeChooseOneManager.SetOnOffNotHero(true)
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitOnly2UI()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	tbl.item_img.sprite = GetTexture("2d_zd_h")
	tbl.item_name_txt.text = "只有两个选项"
	tbl.item_desc_txt.text = "只有两个选项"
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		ItemThreeChooseOneManager.SetMaxItem(2)
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end

function M:InitAddSkill()
	local obj = NewObject("item_threechose_one",self.parent)
	local tbl = LuaHelper.GeneratingVar(obj.transform)
	local h_type = MainModel.GetHeadType()
	local cur_head_cfg = GameConfigCenter.GetHeroHeadConfig(h_type)

	tbl.item_img.sprite = GetTexture(cur_head_cfg.skillIcon)
	tbl.item_img.gameObject.transform.localScale = Vector3.New(1.6,1.6,1.6)
	tbl.item_name_txt.text = "技能次数增加"
	tbl.item_desc_txt.text = "技能次数 +3"
	obj.gameObject:SetActive(true)

	obj.transform:GetComponent("Button").onClick:AddListener(function()
		HeadSkillManager.AddSkillUseTimes(3)
		ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		self:Exit()
	end)
end