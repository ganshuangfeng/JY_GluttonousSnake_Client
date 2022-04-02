-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveBase
-- 控制Base

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveBase = basefunc.class()
local M = SnakeHeadMoveBase
M.name = "SnakeHeadMoveBase"

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
	if self.handle then
		UpdateBeat:RemoveListener(self.handle)
		self.handle = nil
	end
    EventTriggerListener.Get(CSPanel.topbutton.gameObject).onDown = nil
    EventTriggerListener.Get(CSPanel.topbutton.gameObject).onUp = nil
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
	local obj = NewObject(self.prefabName, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.isRun = false

	self.handle = UpdateBeat:CreateListener(self.Update, self)
	UpdateBeat:AddListener(self.handle)
    self.isDebug = AppDefine.IsEDITOR()

    EventTriggerListener.Get(CSPanel.topbutton.gameObject).onDown = basefunc.handler(self, self.OnDownClick)
    EventTriggerListener.Get(CSPanel.topbutton.gameObject).onUp = basefunc.handler(self, self.OnUpClick)
end

function M:MyRefresh()
end

function M:Update()
	if self.isDebug then
	    if UnityEngine.Input.GetKey("w") then
	        self:OnDir4Click(1)
	    elseif UnityEngine.Input.GetKey("s") then
	        self:OnDir4Click(3)
	    elseif UnityEngine.Input.GetKey("a") then
	        self:OnDir4Click(2)
	    elseif UnityEngine.Input.GetKey("d") then
	        self:OnDir4Click(0)
	    end

	    if UnityEngine.Input.GetKeyUp("w")
	    	or UnityEngine.Input.GetKeyUp("s")
	    	or UnityEngine.Input.GetKeyUp("a")
	    	or UnityEngine.Input.GetKeyUp("d") then
	    	Event.Brocast("head_manual_change_move_onoff", false)
	    end
	end

	if self.isRun then
    	self:OnMoveClick(UnityEngine.Input.mousePosition)
	end
end

function M:OnDownClick()
end
function M:OnMoveClick()
end
function M:OnUpClick()
end
function M:OnDir4Click(d)
	Event.Brocast("head_manual_change_target_dir", d)
end

