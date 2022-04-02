-- 创建时间:2021-10-26
-- Panel:ShopMainUIPanel
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

ShopMainUIPanel = basefunc.class()
local M = ShopMainUIPanel
M.name = "ShopMainUIPanel"

function M.Create()
	return M.New()
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["query_shop_data_msg"] = basefunc.handler(self,self.on_query_shop_data_msg)
    self.lister["shop_data_change_msg"] = basefunc.handler(self,self.on_shop_data_change_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	Event.Brocast("global_game_panel_close_msg", {ui="shop"})
	print("<color=red>ShopMain AAAAAAAAAAAAAA  Exit</color>")
	self.currency_panel:Exit()
	self.box_panel:Exit()
	self.jx_panel:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	ShopManager.queryShopData()
	Event.Brocast("global_game_panel_open_msg", {ui="shop"})
end

function M:InitCurrencyPanel()
	if self.currency_panel then
		self.currency_panel:Exit()
	end
	self.currency_panel = ShopCurrencyPanel.Create(self.currency_node)
end
function M:InitBoxPanel()
	if self.box_panel then
		self.box_panel:Exit()
	end
	self.box_panel = ShopBoxPanel.Create(self.box_node)
end
function M:InitJXPanel()
	if self.jx_panel then
		self.jx_panel:Exit()
	end
	self.jx_panel = ShopJXPanel.Create(self.jingxuan_node)
end

function M:MyRefresh()
	self:InitCurrencyPanel()
	self:InitBoxPanel()
	self:InitJXPanel()
end
function M:on_query_shop_data_msg(data)
	if data.result == 0 then
		self.hint_node.gameObject:SetActive(false)
		self:MyRefresh()
	else
		self.hint_node.gameObject:SetActive(true)
		HintPanel.ErrorMsg(data.result)
	end
end

function M:on_shop_data_change_msg()
	if self.currency_panel then
		self.currency_panel:MyRefresh()
	end
	if self.box_panel then
		self.box_panel:MyRefresh()
	end
	if self.jx_panel then
		self.jx_panel:MyRefresh()
	end
end
