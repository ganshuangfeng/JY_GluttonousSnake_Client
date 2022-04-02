-- 创建时间:2018-05-28

local basefunc = require "Game.Common.basefunc"
StageEditorPanel = basefunc.class()
local M = StageEditorPanel
M.name = "StageEditorPanel"

local instance
function M.Create()
	instance = M.New()
	return instance
end

function M:Ctor()
    self.gameObject = NewObject(M.name,GameObject.Find("Canvas/GUIRoot").transform)
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)

	local obj = NewObject("CSGame2DNode")
	obj.gameObject.name = "3DNode"
end

function M:Exit()
    Destroy(self.gameObject)
end
