local basefunc = require "Game/Common/basefunc"

ItemShowPanel = basefunc.class()
local M = ItemShowPanel
M.name = "ItemShowPanel"

function M.Create(itemType)
	return M.New(itemType)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["EnterScene"] = basefunc.handler(self,self.Exit)
	self.lister["ExitScene"] = basefunc.handler(self,self.Exit)
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

function M:Ctor(itemType)
	ExtPanel.ExtMsg(self)
	self.config = GameConfigCenter.GetAssetConfigByType(itemType)
	if not self.config then
		LittleTips.Create(itemType.. " 道具配置错误")
		return
	end
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.name_txt.text = self.config.name
	self.desc_txt.text = self.config.desc
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.back_btn.onClick:AddListener(function ()
		self:Exit()
	end)
	self:MyRefresh()
end

function M:MyRefresh()
end
