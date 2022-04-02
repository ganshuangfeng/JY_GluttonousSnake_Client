local basefunc = require "Game/Common/basefunc"

TaskMainEnter = basefunc.class()
local M = TaskMainEnter
M.name = "TaskMainEnter"

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
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.enter_btn.onClick:AddListener(function()
		TaskMainPanel.Create({cur_task_obj = self.cur_task_obj})
	end)
end

function M:InitUI()
	self:MyRefresh()
end

function M:MyRefresh()
	local allTask = task_mgr.GetAllTask()
	
	local complete_flag = true
	for k,v in pairs(allTask) do
		if v.config.task_type == 4 then
			if v.get_award_status() ~= task_mgr.award_status.complete then
				complete_flag = false
			end
		end
	end
	if complete_flag then
		self:Exit()
		return
	end
	local mainTasks = {}
	for k,v in pairs(allTask) do
		if v.config.task_type == 4 then
			mainTasks[#mainTasks + 1]=  v
		end
	end
	table.sort(mainTasks,function(a,b) return a.config.P1 < b.config.P1 end)
	local get_award_flag = false
	for k,v in ipairs(mainTasks) do
		if v.get_award_status() == task_mgr.award_status.can_get then
			get_award_flag = true
			self.cur_task_obj = v
			break
		end
	end
	if not get_award_flag then
		for k,v in ipairs(mainTasks) do
			if k == #mainTasks then 
				self.cur_task_obj = v
				break
			elseif v.config.P1 == 1 and v.get_award_status() ~= task_mgr.award_status.complete then
				self.cur_task_obj = v
				break
			elseif v.get_award_status() == task_mgr.award_status.complete 
			and mainTasks[k + 1].get_award_status() ~= task_mgr.award_status.complete then
				self.cur_task_obj = mainTasks[k + 1]
				break
			end 
		end
	end
	if get_award_flag then
		self.get_award_node.gameObject:SetActive(true)
	else
		self.get_award_node.gameObject:SetActive(false)
	end
	self.cur_task_img.sprite = GetTexture(self.cur_task_obj.config.P3)
	self.cur_task_desc_txt.text = self.cur_task_obj.config.P2
	self.cur_level_txt.text = "通过第" .. self.cur_task_obj.config.P1 .. "关"
end

function M:on_task_item_update(task_obj)
	self:MyRefresh()
end