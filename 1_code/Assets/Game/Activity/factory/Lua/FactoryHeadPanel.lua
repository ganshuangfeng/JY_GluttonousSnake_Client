-- 创建时间:2021-10-14
-- Panel:FactoryHeadPanel
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

local max_id = 3
FactoryHeadPanel = basefunc.class()
local M = FactoryHeadPanel
M.name = "FactoryHeadPanel"

function M.Create(parent)
	return M.New(parent)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["FactoryMainUIPanelExit"] = basefunc.handler(self,self.Exit)
	self.lister["UpgradeHead"] = basefunc.handler(self,self.MyRefresh)
	self.lister["SelectHead"] = basefunc.handler(self,self.MyRefresh)
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
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	-- HeadShowPanel.Create(MainModel.UserInfo.GameInfo.head_type)
end

function M:InitUI()

	self.items = {}
	for i = 1,max_id do
		local config = GameConfigCenter.GetHeroHeadDataConfig(i)
		local ui_config = GameConfigCenter.GetHeroHeadConfig(i)
		local level = MainModel.GetHeadLevel(i)
		local obj = GameObject.Instantiate(self.head_item,self.node)
		obj.gameObject:SetActive(true)
		local temp_ui = {}
		GeneratingVar(obj.transform,temp_ui)
		temp_ui.icon_img.sprite = GetTexture(ui_config.headIcon)
		temp_ui.slider = temp_ui.slider:GetComponent("Slider")
		temp_ui.item_btn.onClick:AddListener(
			function()
				HeadShowPanel.Create(i)
			end
		)
		
		local data = {}
		data.temp_ui = temp_ui
		data.head_type = i
		data.id = ui_config.id
		self.items[#self.items + 1] = data
	end

	self.nodeLayoutGroup = self.node:GetComponent("HorizontalLayoutGroup")
	if max_id > 2 then
		self.nodeLayoutGroup.spacing = 300
	else
		self.nodeLayoutGroup.spacing = 350
	end

	self:AddRedPointEvent()
	self:CallRedPointEvent()

	self:MyRefresh()

end

function M:MyRefresh()
	for i = 1,#self.items do
		local data = self.items[i]
		local lv = MainModel.GetHeadLevel(data.head_type)
		data.temp_ui.lv_txt.text = "LV.".. lv
		data.temp_ui.lv_txt.gameObject:SetActive(lv > 0)
		data.temp_ui.lock.gameObject:SetActive(lv == 0)
		if not data.temp_ui.ysz.gameObject.activeSelf then
			data.temp_ui.ysz_tx.gameObject:SetActive(false)
			data.temp_ui.ysz_tx.gameObject:SetActive(MainModel.UserInfo.GameInfo.head_type == data.head_type)
		end
		data.temp_ui.ysz.gameObject:SetActive(MainModel.UserInfo.GameInfo.head_type == data.head_type)
		local d = GameConfigCenter.GetHeroHeadDataConfig(data.head_type)
		if lv >= #d then
			data.temp_ui.progress_txt.text = "Max"
			data.temp_ui.slider.value = 1
			data.temp_ui.red_node.gameObject:SetActive(false)
			data.temp_ui.gray_node.gameObject:SetActive(false)
		else
			d = d[lv + 1]
			local asset = d.upgrade_asset

			local needNum = 0
			local curNum = 0
			for i, v in ipairs(asset) do
				if v.asset_type ~= "prop_jin_bi" then
					needNum = needNum + v.asset_value
					curNum = curNum + MainModel.GetAssetValueByKey(v.asset_type)
				end
			end

			if curNum == 0 then
				data.temp_ui.progress_txt.text = "<color=red>" .. curNum .. "/" .. needNum .. "</color>"
			else
				data.temp_ui.progress_txt.text = curNum .. "/" .. needNum
			end
			data.temp_ui.slider.value = curNum / needNum
		end
	end
end

function M:AddRedPointEvent()
	for i, v in ipairs(self.items) do
		v.onRedPointNumChange = function (redPointNode)
			local lv = MainModel.GetHeadLevel(v.head_type)
			local d = GameConfigCenter.GetHeroHeadDataConfig(v.head_type)
			if lv >= #d then
				v.temp_ui.red_node.gameObject:SetActive(false)
				v.temp_ui.gray_node.gameObject:SetActive(false)
				return
			end
			if redPointNode.num > 0 then
				v.temp_ui.red_node.gameObject:SetActive(true)
				v.temp_ui.gray_node.gameObject:SetActive(false)
			else
				v.temp_ui.red_node.gameObject:SetActive(false)
				v.temp_ui.gray_node.gameObject:SetActive(true)
			end
		end
		RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryHead .. "." .. v.id,v.onRedPointNumChange)
	end
end

function M:CallRedPointEvent()
	for i, v in ipairs(self.items) do
		RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryHead .. "." .. v.id,v.onRedPointNumChange)
	end
end

function M:RemoveRedPointEvent()
	dump(self.items,"<color=yellow>RemoveRedPointEvent</color>")
	for i, v in ipairs(self.items) do
		RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryHead .. "." .. v.id,v.onRedPointNumChange)
	end
end