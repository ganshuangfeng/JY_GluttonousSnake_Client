-- 创建时间:2021-10-26
-- Panel:ShopCurrencyPanel
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

ShopBoxPanel = basefunc.class()
local M = ShopBoxPanel
M.name = "ShopBoxPanel"

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
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:CloseCellItem()
	self:RemoveListener()
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

	self.yxbox = self.transform:Find("@content/yxbox")
	self.zzbox = self.transform:Find("@content/zzbox")
	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function M:InitUI()
	
	self.items = {}
	self.items[#self.items + 1] = ShopBoxItem.Create(self.yxbox, ShopManager.GetShopItemData(10201))
	self.items[#self.items + 1] = ShopBoxItem.Create(self.zzbox, ShopManager.GetShopItemData(10202))

	self:MyRefresh()
end

function M:MyRefresh()
	if self.items then
		for k,v in ipairs(self.items) do
			v:RefreshData(ShopManager.GetShopItemData(v.data.id))
		end
	end
end

function M:CloseCellItem()
	if self.items then
		for k,v in ipairs(self.items) do
			v:Exit()
		end
	end
end
