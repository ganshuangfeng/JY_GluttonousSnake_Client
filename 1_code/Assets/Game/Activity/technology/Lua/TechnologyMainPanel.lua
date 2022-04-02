local basefunc = require "Game/Common/basefunc"

TechnologyMainPanel = basefunc.class()
local M = TechnologyMainPanel
M.name = "TechnologyMainPanel"

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
	self.lister["go_technology_first"] = basefunc.handler(self,self.on_go_technology_first)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self.Hy:MyExit()
	for i = 1,#self.panels do
		self.panels[i]:Exit()
	end
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
	local parent = parent or HallGamePanel.Panel_Node
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
	self.all_technology_btn.onClick:AddListener(
		function()
			TechnologyGianPanel.Create(self.index or 1)
		end
	)
	local max = TechnologyManager.GetMaxIndex()
	self.panels = {}
	for i = 1,max do
		local panel = TechnologyPanel.Create(self.Content,i,self)
		self.panels[#self.panels + 1] = panel
	end
	self.Hy = CommonHYAnim.Create(self.Content,TechnologyManager.GetCurrIndex(),false)

	self.left_btn.onClick:AddListener(
		function()
			self.Hy:GoLast()
		end
	)
	self.right_btn.onClick:AddListener(
		function()
			self.Hy:GoNext()
		end
	)

	self.Hy:OnIndexCall(
		function(index)
			self.right_btn.gameObject:SetActive(index ~= max)
			self.left_btn.gameObject:SetActive(index ~= 1)
			self.index = index
			self.title_txt.text = TechnologyManager.GetTitle(self.index)
		end
	)
	self.left_btn.gameObject:SetActive(false)
	self:MyRefresh()
end

function M:MyRefresh()

end

function M:on_go_technology_first()
	local index = TechnologyManager.GetCurrIndex()
	dump(index)
	self.Hy:GoIndex(index)
end