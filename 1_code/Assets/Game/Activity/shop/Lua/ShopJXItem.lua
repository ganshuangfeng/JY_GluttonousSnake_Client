-- 创建时间:2021-10-28
-- Panel:ShopJXItem
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

ShopJXItem = basefunc.class()
local M = ShopJXItem
M.name = "ShopJXItem"

function M.Create(parent_transform, data, call, panelSelf)
	return M.New(parent_transform, data, call, panelSelf)
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

function M:Ctor(parent_transform, data, call, panelSelf)
	self.data = data
	self.call = call
	self.panelSelf = panelSelf

	local obj = NewObject(M.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.get1_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.data)
	end)
	self.get2_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.data)
	end)
	self.desc_btn = self.icon_img.transform:GetComponent("Button")
	self.desc_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		ItemShowPanel.Create(AssetItemConfig[self.data.P1].asset_type)
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	self.name_txt.text = self.data.name
	self.desc_txt.text = self.data.value
	self.buy_txt.text = self.data.buy_value
	self.icon_img.sprite = GetTexture( AssetItemConfig[self.data.P1].icon )

	if self.data.is_buy then
		self.hint_txt.gameObject:SetActive(true)
		self.get1_btn.gameObject:SetActive(false)
		self.get2_btn.gameObject:SetActive(false)
	else
		self.hint_txt.gameObject:SetActive(false)
		self.get1_btn.gameObject:SetActive(false)
		self.get2_btn.gameObject:SetActive(false)
		if self.data.P2 == 1 then
			self.get1_btn.gameObject:SetActive(true)
		else
			self.get2_btn.gameObject:SetActive(true)
			if self.data.P2 == 2 then
				self.desc_img.sprite = GetTexture("wf4_jb")
			else
				self.desc_img.sprite = GetTexture("xfg_sd_zs_1")
			end
		end
	end
end
