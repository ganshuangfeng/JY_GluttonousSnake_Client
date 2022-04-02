local basefunc = require "Game/Common/basefunc"

FactoryGongjuPanel = basefunc.class()
local M = FactoryGongjuPanel
M.name = "FactoryGongjuPanel"

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
	self.lister["model_asset_change_msg"] = basefunc.handler(self,self.Refresh)
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

function M:Ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	self.gameObjec = NewObject(M.name, parent)
	self.transform = self.gameObjec.transform
	self.config = GameConfigCenter.GetGongjuCfg()
	GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self:AddRedPointEvent()
	self:CallRedPointEvent()
	self:Refresh()
end

function M:InitUI()
	self.item_list = {}
	for k, v in pairs(self.config) do
		local temp_ui = {}
		temp_ui.gameObject = GameObject.Instantiate(self.item,self.show_node).gameObject
		temp_ui.gameObject:SetActive(true)
		GeneratingVar(temp_ui.gameObject.transform,temp_ui)
		temp_ui.slider = temp_ui.slider:GetComponent("Slider")
		temp_ui.name_txt.text = v.name
		temp_ui.icon_img.sprite = GetTexture(v.icon)
		temp_ui.click_btn.onClick:AddListener(
			function()
				GongjuShowPanel.Create(v.id)
			end
		)
		self.item_list[k] = temp_ui
	end

	self.nodeLayoutGroup = self.show_node:GetComponent("HorizontalLayoutGroup")
end

function M:Refresh()
	local num = 0
	for k, v in pairs(self.config) do
		num = num + 1
		local data
		local lv
		if k == "team" then
			lv = MainModel.QueryTeamLevel()
			data = GameConfigCenter.GetTeamLevelDataConfig()
		elseif k == "health" then
			lv = MainModel.QueryHealthLevel()
			data = GameConfigCenter.GetHealthLevelDataConfig()
		end
		local obj = self.item_list[k]
		obj.level_txt.text = "LV." .. lv

		if lv >= #data then
			obj.progress_txt.text = "Max"
			obj.slider.value = 1
		else
			local curNum = 0
			local needNum = 0
			for k1, v1 in pairs(data[lv + 1].upgrade_asset) do
				if v1.asset_type ~= "prop_jin_bi" then
					curNum = curNum + MainModel.GetAssetValueByKey(v1.asset_type)
					needNum = needNum + v1.asset_value
				end
			end
			if curNum == 0 then
				obj.progress_txt.text = "<color=red>" .. curNum .. "/" .. needNum .. "</color>"
			else
				obj.progress_txt.text = curNum .. "/" .. needNum
			end
			obj.slider.value = curNum / needNum
		end
	end

	if num > 2 then
		self.nodeLayoutGroup.spacing = 300
	else
		self.nodeLayoutGroup.spacing = 350
	end
end

function M:AddRedPointEvent()
	for k, data in pairs(self.item_list) do
		data.OnRedPointNumChange = function (redPointNode)
			if redPointNode.num > 0 then
				data.red_point.gameObject:SetActive(true)
				data.gray_point.gameObject:SetActive(false)
			else
				local _data
				local lv
				if k == "team" then
					lv = MainModel.QueryTeamLevel()
					_data = GameConfigCenter.GetTeamLevelDataConfig()
				elseif k == "health" then
					lv = MainModel.QueryHealthLevel()
					_data = GameConfigCenter.GetHealthLevelDataConfig()
				end

				if lv >= #_data then
					data.red_point.gameObject:SetActive(false)
					data.gray_point.gameObject:SetActive(false)
				else
					data.red_point.gameObject:SetActive(false)
					data.gray_point.gameObject:SetActive(true)
				end
			end
		end
		RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryGongju .. "." .. k,data.OnRedPointNumChange)
	end
end

function M:CallRedPointEvent()
	for k, data in pairs(self.item_list) do
		RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryGongju .. "." .. k,data.OnRedPointNumChange)
	end
end

function M:RemoveRedPointEvent()
	for k, data in pairs(self.item_list) do
		RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryGongju .. "." .. k,data.OnRedPointNumChange)
	end
end