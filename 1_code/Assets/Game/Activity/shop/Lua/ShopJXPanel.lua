-- 创建时间:2021-10-27
-- Panel:ShopJXPanel
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

ShopJXPanel = basefunc.class()
local M = ShopJXPanel
M.name = "ShopJXPanel"

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
	self:ClearList()
	self:StopCDTime()
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
	parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self:MyRefresh()
end

function M:MyRefresh()
	self:ClearList()
	local ll = ShopManager.GetJXData()
	self.list = {}
	for k,v in ipairs(ll) do
		self.list[#self.list + 1] = ShopManager.GetShopItemData(v)
	end
	for k,v in ipairs(self.list) do
		self.items[#self.items + 1] = ShopJXItem.Create(self.content, v, self.OnBuyClick, self)
	end
	self:RefreshCD()
end
function M:ClearList()
	if self.items then
		for k,v in ipairs(self.items) do
			v:Exit()
		end
	end
	self.items = {}
end

function M:OnBuyClick(data)
	ShopManager.BuyShopByID(data.id, function (data)
		if data.result == 0 then
			self:MyRefresh()
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end

function M:RefreshCD()
	self.updateT = ShopManager.GetShopRefreshTime()
	self:StopCDTime()
	local curT = os.time()
	if self.updateT > curT then
		self.cdTime = Timer.New(function ()
			self:CallCD()
		end, 0.2, -1)
		self.cdTime:Start()
		self:CallCD()
	else
		self.cd_txt.text = "--:--"
	end
end
function M:CallCD()
	local curT = os.time()
	if self.updateT > curT then
		self.cd_txt.text = StringHelper.formatTimeDHMS5(self.updateT - curT, 2)
	else
        ShopManager.shopSetMrjxWpList( ShopManager.CreateJXData() )
        Event.Brocast("shop_data_change_msg")
		-- self:MyRefresh()
	end	
end
function M:StopCDTime()
	if self.cdTime then
		self.cdTime:Stop()
	end
	self.cdTime = nil
end
