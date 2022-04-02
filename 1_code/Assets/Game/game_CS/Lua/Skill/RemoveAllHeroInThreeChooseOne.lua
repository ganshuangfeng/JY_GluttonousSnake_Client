local basefunc = require "Game/Common/basefunc"

RemoveAllHeroInThreeChooseOne = basefunc.class()
local M = RemoveAllHeroInThreeChooseOne
M.name = "RemoveAllHeroInThreeChooseOne"
RemoveAllHeroInThreeChooseOne.IsOn = false

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

end

function M:InitUI()

	self:MyRefresh()
end

function M:MyRefresh()
end
