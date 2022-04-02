local basefunc = require "Game/Common/basefunc"

TurretCompanyPanel = basefunc.class()
local M = TurretCompanyPanel
M.name = "TurretCompanyPanel"

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
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	
end

function M:RefreshCompanyInfo(hero_type)
	local hero_base_config = HeroDataManager.GetHeroBaseConfig()
	local base_config = hero_base_config.base[hero_type]
	for k,v in ipairs(hero_base_config.base_change) do
		if v.id == hero_type and v.link_desc and self["turret_company_item_" .. (v.star - 1)] then
			local tbl = LuaHelper.GeneratingVar(self["turret_company_item_" .. (v.star - 1)])
			tbl.huoban_count_desc_txt.text = base_config.remark .. "x" .. v.star
			tbl.huoban_desc_txt.text = v.link_desc
		end
	end
end
