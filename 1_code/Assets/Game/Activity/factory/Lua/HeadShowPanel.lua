-- 创建时间:2021-10-13
-- Panel:HeadShowPanel
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

HeadShowPanel = basefunc.class()
local M = HeadShowPanel
M.name = "HeadShowPanel"

function M.Create(head_type,parent)
	return M.New(head_type,parent)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["FactoryMainUIPanelExit"] = basefunc.handler(self,self.Exit)
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

function M:Ctor(head_type,parent)
	self.head_type = head_type
	self.config = GameConfigCenter.GetHeroHeadConfig(self.head_type)
	self.data = GameConfigCenter.GetHeroHeadDataConfig(self.head_type)
	--如果curLevel == 0 表示没有解锁
	self.curLevel = MainModel.GetHeadLevel(self.head_type)
	self.nextLevel = self.curLevel + 1
	self.maxLevel = #self.data

	dump({self.config,self.data,self.curLevel},"<color=yellow>当前蛇头数据？？？？？？</color>")

	parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	self.gameObject = NewObject(M.name, parent)
	self.transform = self.gameObject.transform
	GeneratingVar(self.transform, self)

	self:InitUI()

	self:MakeLister()
	self:AddMsgListener()
	self:AddRedPointEvent()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.name_txt.text = self.config.name
	self.head_img.sprite = GetTexture(self.config.headIcon)
	self.skill_name_txt.text = self.config.skillName
	self.skill_desc_txt.text = self.config.skillDesc
	self.skill_icon_img.sprite = GetTexture(self.config.skillIcon)

	self.hero_show_close_btn.onClick:AddListener(function ()
        self:Exit()
    end)

	self.use_btn.onClick:AddListener(function ()
		self:Use()
    end)

	self.up_btn.onClick:AddListener(function ()
		self:Up()
    end)
	if AppDefine.IsEDITOR() then
		self.test_btn.onClick:AddListener(function()
			--HeroDataManager.ChangeHeroFragmentNumByType(self.cur_hero_type,10)
			MainModel.TestAddAsset(
				{
					[1] = {
						asset_type = "prop_head_fragment_"..self.head_type,
						asset_value = 10
					},
				}
			)
			self:MyRefresh()
		end)
	end

	self.up_btn_img = self.up_btn.transform:GetComponent("Image")

	--解锁
	self.unlockItems = {}
	for i = 1, #self.data do
		local obj = {}
		obj.gameObject = GameObject.Instantiate(self.unlock_item,self.unlock_content).gameObject
		obj.gameObject:SetActive(true)
		GeneratingVar(obj.gameObject.transform, obj)
		
		self.unlockItems[i] = obj
		if i == 1 then
			obj.gameObject:SetActive(false)
		end
	end

	--属性
	self.attributeItems = {}
	for i = 1, 2 do
		local obj = {}
		obj.gameObject = GameObject.Instantiate(self.attribute_item,self.attribute_content).gameObject
		obj.gameObject:SetActive(true)
		GeneratingVar(obj.gameObject.transform, obj)

		local bs_skill_str = self.config["skill_" .. self.data[1]["bd_skill_" .. i]]
		obj.attribute_name_txt.text = bs_skill_str
		self.attributeItems[i] = obj
	end

	self.use_btn_img = self.use_btn.transform:GetComponent("Image")
	
	self.use_txt_outline = self.use_txt.transform:GetComponent("Outline")
	self:MyRefresh()
end

function M:MyRefresh()
	self.level_txt.text = "LV." .. self.curLevel
	if MainModel.UserInfo.GameInfo.head_type == self.head_type then
		self.use_txt.color = Color.New(75/255,84/255,97/255,255/255)
		self.use_txt_outline.effectColor = Color.white
		self.use_txt.text = "已上阵"
		self.use_btn_img.sprite = GetTexture("tc_btn_hui")
	else
		self.use_txt_outline.effectColor = Color.black
		self.use_txt.color = Color.white
		self.use_txt.text = "上阵"
		self.use_btn_img.sprite = GetTexture("tc_btn_huang")
	end

	if self.nextLevel > self.maxLevel then
		self.up_btn.gameObject:SetActive(false)
		self.up_btn_txt.text = "已满级"
		self.red_point.gameObject:SetActive(false)
	else
		self.up_btn.gameObject:SetActive(true)
		if self.curLevel == 0 then
			self.up_btn_txt.text = "解锁"
		else
			self.up_btn_txt.text = "升级"
		end
	end

	for i = 1, #self.unlockItems do
		if i <= self.curLevel then
			self.unlockItems[i].unlock_level_txt.text = ""
			self.unlockItems[i].unlock_icon_img.material = nil
		else
			self.unlockItems[i].unlock_level_txt.text = "LV." .. i .. "解锁"
			self.unlockItems[i].unlock_icon_img.material = GetMaterial("ImageGray")
		end

		if i == 1 then
			local bs_skill_str_1 = self.config["skill_" .. self.data[i].bd_skill_1]
			local bd_skill_data_1 = self.data[i].bd_skill_data_1
			local bs_skill_str_2 = self.config["skill_" .. self.data[i].bd_skill_2]
			local bd_skill_data_2 = self.data[i].bd_skill_data_2
			if i <= self.curLevel then
				bs_skill_str_1 = "<color=#c96149ff>".. bs_skill_str_1 .. "</color>"
				bs_skill_str_2 = "<color=#c96149ff>".. bs_skill_str_2 .. "</color>"
			end
			self.unlockItems[i].unlock_info_txt.text = string.format("%s<color=green>%s</color> %s<color=green>%s</color>",bs_skill_str_1,bd_skill_data_1,bs_skill_str_2,bd_skill_data_2 )
			-- self.unlockItems[i].unlock_info_txt.text = ""
		else
			local bs_skill_str_1 = self.config["skill_" .. self.data[i].bd_skill_1]
			if i <= self.curLevel then
				bs_skill_str_1 = "<color=#c96149ff>".. bs_skill_str_1 .. "</color>"
			end
			local bd_skill_data_1 = self.data[i].bd_skill_data_1 - self.data[1].bd_skill_data_1
			local bs_skill_str_2 = self.config["skill_" .. self.data[i].bd_skill_2]
			local bd_skill_data_2 = self.data[i].bd_skill_data_2 - self.data[1].bd_skill_data_2
			self.unlockItems[i].unlock_info_txt.text = ""
			if i <= self.curLevel then
				bs_skill_str_1 = "<color=#c96149ff>".. bs_skill_str_1 .. "</color>"
				bs_skill_str_2 = "<color=#c96149ff>".. bs_skill_str_2 .. "</color>"
			end
			if bd_skill_data_1 ~= 0 then
				self.unlockItems[i].unlock_info_txt.text = string.format("%s<color=green>+%s</color>",bs_skill_str_1,bd_skill_data_1)
			end
			if bd_skill_data_2 ~= 0 then
				self.unlockItems[i].unlock_info_txt.text = self.unlockItems[i].unlock_info_txt.text .. string.format(" %s<color=green>+%s</color>",bs_skill_str_2,bd_skill_data_2 )
			end
		end

	end

	for i = 1, #self.attributeItems do
		if self.nextLevel > self.maxLevel then
			self.attributeItems[i].attribute_num_txt.text = self.data[self.curLevel]["bd_skill_data_" .. i]
		else
			local bd_skill_data
			if self.curLevel == 0 then
				bd_skill_data = self.data[self.nextLevel]["bd_skill_data_" .. i]
				self.attributeItems[i].attribute_num_txt.text = "<color=green>" .. bd_skill_data .. "</color>"
			else
				bd_skill_data = self.data[self.nextLevel]["bd_skill_data_" .. i] - self.data[self.curLevel]["bd_skill_data_" .. i]
				if bd_skill_data ~= 0 then
					self.attributeItems[i].attribute_num_txt.text = self.data[self.curLevel]["bd_skill_data_" .. i] .. " +" .. "<color=#3bcf69ff>" .. bd_skill_data .. "</color>"
				else
					self.attributeItems[i].attribute_num_txt.text = self.data[self.curLevel]["bd_skill_data_" .. i]
				end
			end
		end
	end

	DestroyChildren(self.up_content)
	self.upAssetItems = {}
	if self.nextLevel <= self.maxLevel then
		for i, v in ipairs(self.data[self.nextLevel].upgrade_asset) do
			local obj = {}
			obj.gameObject = GameObject.Instantiate(self.up_asset_item,self.up_content).gameObject
			obj.gameObject:SetActive(true)
			GeneratingVar(obj.gameObject.transform, obj)
			self.upAssetItems[i] = obj
			local asset_cfg = GameConfigCenter.GetAssetConfigByType(v.asset_type)
			obj.up_icon_img.sprite = GetTexture(asset_cfg.icon)
			obj.up_icon_btn = obj.up_icon_img.transform:GetComponent("Button")
			local ac = v.asset_type
			obj.up_icon_btn.onClick:AddListener(function ()
				ItemShowPanel.Create(ac)
			end)
			local curNum = MainModel.GetAssetValueByKey(v.asset_type)
			local needNum = v.asset_value
			if v.asset_type == "prop_jin_bi" then				
				obj.up_asset_num_txt.text = StringHelper.ToAbbrNum(needNum)
				if needNum > curNum then
					obj.up_asset_num_txt.color = Color.red
				else
					obj.up_asset_num_txt.color = Color.white
				end
			else
				if curNum == 0 then
					obj.up_asset_num_txt.color = Color.red
				else
					obj.up_asset_num_txt.color = Color.white
				end
				obj.up_asset_num_txt.text = curNum .. "/" .. needNum
			end
		end
	end
end

function M:Up()
	dump(self.config,"<color=yellow>升级</color>")
	if self.nextLevel > self.maxLevel then
		LittleTips.Create("已经升级到最高等级")
		return
	end

	for i, v in ipairs(self.data[self.nextLevel].upgrade_asset) do
		local curNum = MainModel.GetAssetValueByKey(v.asset_type)
		local needNum = v.asset_value
		if curNum < needNum then
			LittleTips.Create("材料不足")
			return
		end
	end

	local asset = self.data[self.nextLevel].upgrade_asset
	MainModel.UpgradeHead(self.head_type,asset,function (data)
		if data.result == 0 then
			LittleTips.Create("升级成功")
			self.curLevel = self.curLevel + 1
			self.nextLevel = self.nextLevel + 1
			self.up_tx.gameObject:SetActive(false)
			self.up_tx.gameObject:SetActive(true)
			self:MyRefresh()
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function M:Use()
	dump(self.config,"<color=yellow>上阵</color>")
	if MainModel.UserInfo.GameInfo.head_type == self.head_type then
		LittleTips.Create("已上阵")
		return
	end
	if self.curLevel <= 0 then
		LittleTips.Create("头部还没有解锁")
		return
	end
	MainModel.SelectHeadType(self.head_type)
	self:Exit()
	self:MyRefresh()
end

function M:CheckUpAsset(upgrade_asset)
	for ai,ass in ipairs(upgrade_asset) do
		if type(ass.asset_type) == "string" and tonumber(ass.asset_value) then
			if MainModel.GetAssetValueByKey(ass.asset_type) < tonumber(ass.asset_value) then
		  		return {result = 1002}
			end
	  	else
			return {result = 1001}
	  	end
	end
end

function M:AddRedPointEvent()
	self.onRedPointNumChange = function (redPointNode)
		if redPointNode.num > 0 and self.curLevel < self.maxLevel then
			self.up_btn_img.sprite = GetTexture("tc_btn_huang")
			self.red_point.gameObject:SetActive(true)
			self.can_up_notice.gameObject:SetActive(true)
		else
			self.up_btn_img.sprite = GetTexture("tc_btn_hui")
			self.red_point.gameObject:SetActive(false)
			self.can_up_notice.gameObject:SetActive(false)
		end
	end
	RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryHead .. "." .. self.config.id,self.onRedPointNumChange)
end

function M:CallRedPointEvent()
	RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryHead .. "." .. self.config.id,self.onRedPointNumChange)
end

function M:RemoveRedPointEvent()
	RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryHead .. "." .. self.config.id,self.onRedPointNumChange)
end