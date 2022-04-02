-- 创建时间:2021-10-21
-- Panel:TechnologyPanel
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

TechnologyPanel = basefunc.class()
local M = TechnologyPanel
M.name = "TechnologyPanel"


function M.Create(parent,index,mainPanel)
	return M.New(parent,index,mainPanel)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["one_property_unlocked"] = basefunc.handler(self,self.on_one_property_unlocked)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveRedPointEvent()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent,index,mainPanel)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject( "Technology"..index.."panel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.mainPanel = mainPanel
	LuaHelper.GeneratingVar(self.transform, self)
	self.index = index
	self.update_time = Timer.New(
		function()
			self:Update()
		end
	,0.02,-1)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:AddRedPointEvent()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.items = {}
	local size2scale = {
		[1] = 0.8,
		[2] = 1.15,
	}
	local data = TechnologyManager.GetConfigByIndex(self.index)

	dump(data,"<color=red>当前的数据</color>")
	for i = 1,#data do
		local obj = NewObject("TechnologyItem",self["node"..i])
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.main_btn.onClick:AddListener(
			function()
				if temp_ui.main_btn.gameObject.transform.position.x < 0 then
					LTTipsPrefab.Show(temp_ui.main_btn.gameObject.transform,1,data[i].desc)
				else
					LTTipsPrefab.Show(temp_ui.main_btn.gameObject.transform,2,data[i].desc)
				end
				
			end
		)
		temp_ui.icon_img.sprite = GetTexture(TechnologyManager.GetIconByPropertyID(data[i].property_id))
		temp_ui.icon_img:SetNativeSize()
		obj.transform.localScale = Vector3.one * size2scale[data[i].icon_size]
		self.items[#self.items + 1] = temp_ui

	end
	self.main_btn.onClick:AddListener(
		function()
			local property_id = data[self.curr_choose_index or 1].property_id
			if not TechnologyManager.IsPropertyIDUnLock(property_id) then
				if TechnologyManager.IsCanUnLock(property_id) then
					TechnologyManager.UnLockProperty(property_id)
					LittleTips.Create(data[self.curr_choose_index or 1].desc)
					self.items[self.curr_choose_index or 1].up_tx.gameObject:SetActive(false)
					self.items[self.curr_choose_index or 1].up_tx.gameObject:SetActive(true)
					Timer.New(
						function()
							if not IsEquals(self.mainPanel) then return end
							if TechnologyManager.IsAllUnlockByIndex(self.index) then
								self.mainPanel.Hy:GoNext()
							end
						end,0.3,1
					):Start()
				else
					LittleTips.Create("不满足解锁条件")
				end
			else
				LittleTips.Create("属性点已解锁")
			end
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			Event.Brocast("go_technology_first")
		end
	)
	self:MyRefresh()
end

function M:MyRefresh()
	local data = TechnologyManager.GetConfigByIndex(self.index)
	for i = 1,#self.items do
		local property_id = data[i].property_id
		if TechnologyManager.IsPropertyIDUnLock(property_id) then
			self.items[i].bg_img.sprite = GetTexture("kj_tfk_l")
			self.items[i].icon_img.sprite = GetTexture(TechnologyManager.GetIconMaskByPropertyID(data[i].property_id))
			self.items[i].icon_img:SetNativeSize()
			if i > 1 then
				self["xian"..i - 1].gameObject:SetActive(true)
			end
		else
			self.curr_choose_index = i
			self.items[i].bg_img.sprite = GetTexture("kj_tfk_an")
			break
		end
	end

	local curr_index = TechnologyManager.GetCurrIndex()
	self.main_btn.gameObject:SetActive(curr_index == self.index)
	self.go_btn.gameObject:SetActive(curr_index ~= self.index)

	self.go_txt.text = TechnologyManager.GetTitle(curr_index)
	local property_id = data[self.curr_choose_index or 1].property_id
	local data = TechnologyManager.GetPropertyByID(property_id)
	
	if TechnologyManager.IsCanUnLock(property_id) then
		self.main_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("kj_btn_js_liang")
	else
		self.main_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("kj_btn_js_an")
	end

	local id = TechnologyManager.GetPropertyByID(property_id).cast_id
	local icon = AssetItemConfig[id].icon
	local type = AssetItemConfig[id].asset_type
	self.cast_txt.text = MainModel.GetAssetValueByKey(type).."/".. data.cast_num
	if MainModel.GetAssetValueByKey(type) < data.cast_num then
		self.cast_txt.color = Color.New(1,0,0)
	else
		self.cast_txt.color = Color.New(1,1,1)
	end
	self.cast_icon_img.sprite = GetTexture(icon)
	if not self.cast_icon_img_btn then
		self.cast_icon_img_btn = self.cast_icon_img.gameObject.transform:GetComponent("Button")
	end
	self.cast_icon_img_btn.onClick:RemoveAllListeners()
	self.cast_icon_img_btn.onClick:AddListener(
		function()
			ItemShowPanel.Create(type)
		end
	)

	if TechnologyManager.IsAllUnlock() then
		self.main_btn.gameObject:SetActive(false)
		self.go_btn.gameObject:SetActive(false)
		self.all_unlock.gameObject:SetActive(true)
	end
end

function M:Update()
	if self.use_time >= 0 then
		self.use_time = self.use_time - 0.02
	end
end

function M:on_one_property_unlocked()
	print("<color=red>解锁成功+++++++++</color>")
	self:MyRefresh()
end

function M:AddRedPointEvent()
	self.OnTechnologyRedPointNumChange = function (redPointNode)
		if redPointNode.num > 0 then
			self.red_node.gameObject:SetActive(true)
		else
			self.red_node.gameObject:SetActive(false)
		end
	end
	RedPointSystem.Instance:RegisterEvent(RedPointEnum.Technology.. "." .. "button",self.OnTechnologyRedPointNumChange)
end

function M:CallRedPointEvent()
	RedPointSystem.Instance:CallEvent(RedPointEnum.Technology.. "." .. "button",self.OnTechnologyRedPointNumChange)
end

function M:RemoveRedPointEvent()
	RedPointSystem.Instance:RemoveEvent(RedPointEnum.Technology.. "." .. "button",self.OnTechnologyRedPointNumChange)
end