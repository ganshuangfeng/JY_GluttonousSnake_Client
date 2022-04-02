local basefunc = require "Game/Common/basefunc"

TaskMainPanel = basefunc.class()
local M = TaskMainPanel
M.name = "TaskMainPanel"

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
	self.lister["task_item_add"] = basefunc.handler(self,self.on_task_item_add )
	self.lister["task_item_delete"] = basefunc.handler(self,self.on_task_item_delete )
	self.lister["task_item_update"] = basefunc.handler(self,self.on_task_item_update )
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
	local parent = parm.parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.parm = parm
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.close_btn.onClick:AddListener(function()
		self:Exit()
	end)
end

function M:InitUI()
	local allTask = task_mgr.GetAllTask()
	local mainTasks = {}
	for k,v in pairs(allTask) do
		if v.config.task_type == 4 then
			mainTasks[#mainTasks + 1]=  v
		end
	end
	table.sort(mainTasks,function(a,b) return a.id > b.id end)
	for k,task_obj in ipairs(mainTasks) do
		self.mainTaskItems = self.mainTaskItems or {}
		self.mainTaskItems[#self.mainTaskItems + 1] = TaskMainItem.Create(self.content,task_obj)
	end
	self:MyRefresh()
	if self.parm.cur_task_obj then
		local cur_level = self.parm.cur_task_obj.config.P1
		--一页里显示5个
		local page_count = 5
		local value = (cur_level - (page_count / 2)) / #self.mainTaskItems
		local min = 3
		local max = 13
		if cur_level <= min then
			value = 0
		elseif cur_level >= max then
			value = 1
		else
			value = (cur_level - min) / (max - min )
		end
		self.ScrollView:GetComponent("ScrollRect").verticalNormalizedPosition = value
	end
end

function M:MyRefresh()
	for k,v in ipairs(self.mainTaskItems) do
		v:MyRefresh()
	end	
end
--- 当创建任务项目
function M:on_task_item_add( task_obj )
	self.mainTaskItems = self.mainTaskItems or {}
	self.mainTaskItems[self.mainTaskItems + 1] = TaskMainItem.Create(self.content,task_obj)
end

--- 当删除任务
function M:on_task_item_delete( taskId )
	self.mainTaskItems = self.mainTaskItems or {}
	for k,v in ipairs(self.mainTaskItems) do
		if v.task_obj.task_id == taskId then
			v:Exit()
			table.remove(self.mainTaskItems,k)
			break
		end
	end
end


--- 当任务刷新
function M:on_task_item_update( task_obj )
	self.mainTaskItems = self.mainTaskItems or {}
	for k,v in ipairs(self.mainTaskItems) do
		if v.task_obj.id == task_obj.id then
			v:MyRefresh(task_obj)
		end
	end
end