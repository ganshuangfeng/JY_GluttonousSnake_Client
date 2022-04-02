--用来布局工厂相关的界面

local basefunc = require "Game/Common/basefunc"

FactoryMainUIPanel = basefunc.class()
local M = FactoryMainUIPanel
M.name = "FactoryMainUIPanel"

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
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	Event.Brocast("FactoryMainUIPanelExit")
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
	self:InitHeadPanel()
	self:InitHeroPanel()
	self:InitGongjuPanel()
	self:MyRefresh()


	local data = HeroDataManager.InitGoIntoBattleData()
	
	self.sv = self.ScrollView:GetComponent("ScrollRect")

    if GuideLogic.IsHaveGuide("hall") then
	    coroutine.start(function ( )
	        Yield(0)
	        Yield(0)--间隔一帧不得行
	        if IsEquals(self.Content) then
	            self.sv:StopMovement()
	            self.Content.transform.localPosition = Vector3.New(self.Content.transform.localPosition.x, 2234, 0)        
				GuideLogic.CheckRunGuide("hall")
	        end
	    end)
    end
end

function M:MyRefresh()
end


function M:InitHeadPanel()
	self.head_panel = FactoryHeadPanel.Create(self.head_show_node)
end

function M:InitHeroPanel()
	local config = GameConfigCenter.GetHeroAttackTypeConfig()
	self.hero_panel_list = {}
	for i = 1,#config do
		local panel = FactoryHeroPanel.Create(self.turret_show_node,config[i])

		self.hero_panel_list[#self.hero_panel_list + 1] = panel

	end
end

function M:InitGongjuPanel()
	FactoryGongjuPanel.Create(self.gongju_show_node)
end