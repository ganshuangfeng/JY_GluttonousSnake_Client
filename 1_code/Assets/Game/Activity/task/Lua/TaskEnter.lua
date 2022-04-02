-- 创建时间:2021-10-29
-- Panel:TaskEnter
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

TaskEnter = basefunc.class()
local M = TaskEnter
M.name = "TaskEnter"

function M.Create(parm)
	return M.New(parm)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["task_item_update"] = basefunc.handler(self,self.on_task_item_update)
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

function M:Ctor(parm)
	ExtPanel.ExtMsg(self)
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		TaskPanel.Create({})
	end)
end

function M:InitUI()
	if TaskManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.red_node.gameObject:SetActive(true)
	else
		self.red_node.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function M:MyRefresh()
end

function M:on_task_item_update()
	if TaskManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.red_node.gameObject:SetActive(true)
	else
		self.red_node.gameObject:SetActive(false)
	end
end