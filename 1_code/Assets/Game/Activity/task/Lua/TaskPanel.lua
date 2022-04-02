local basefunc = require "Game/Common/basefunc"

TaskPanel = basefunc.class()
local M = TaskPanel
M.name = "TaskPanel"
local xunzhang_task_id = 10010014
function M.Create()
	return M.New()
end

function M:Ctor()
	ExtPanel.ExtMsg(self)
	--- 所有的任务的面板数据
	self.taskItemVec = {}

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:Exit()
		end
	)

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
	if self.update_timer then
		self.update_timer:Stop()
		self.update_timer = nil
	end
	if self.AwardConfigShowPanel then
		self.AwardConfigShowPanel:Exit()
	end
	self:RemoveListener()
	DOTweenManager.KillLayerKeyTween("task_seq")

	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end



function M:InitUI()
	local allTask = task_mgr.GetAllTask()

	if allTask and type(allTask) == "table" then
		self.array_all_task = {}
		for k,v in pairs(allTask) do
			self.array_all_task[#self.array_all_task + 1] = v
		end
		table.sort(self.array_all_task,function(a,b) return a.id < b.id end)
	end

	self:InitXunZhangAward()
	self:CreateTaskObjByType(1)
	self.day_task_img.gameObject:SetActive(true)
	self.day_task_btn.gameObject:SetActive(false)
	self.week_task_img.gameObject:SetActive(false)
	self.week_task_btn.gameObject:SetActive(true)
	self.main_task_img.gameObject:SetActive(false)
	self.main_task_btn.gameObject:SetActive(true)
	self.day_task_btn.onClick:AddListener(function()
		self.day_task_img.gameObject:SetActive(true)
		self.day_task_btn.gameObject:SetActive(false)
		self.week_task_img.gameObject:SetActive(false)
		self.week_task_btn.gameObject:SetActive(true)
		self.main_task_img.gameObject:SetActive(false)
		self.main_task_btn.gameObject:SetActive(true)
		self:CreateTaskObjByType(1)
	end)
	self.week_task_btn.onClick:AddListener(function()
		do 
			LittleTips.Create("敬请期待")
			return 
		end
		self.day_task_img.gameObject:SetActive(false)
		self.day_task_btn.gameObject:SetActive(true)
		self.week_task_img.gameObject:SetActive(true)
		self.week_task_btn.gameObject:SetActive(false)
		self.main_task_img.gameObject:SetActive(false)
		self.main_task_btn.gameObject:SetActive(true)
		self:CreateTaskObjByType(2)
	end)
	self.main_task_btn.onClick:AddListener(function()
		do 
			LittleTips.Create("敬请期待")
			return 
		end
		self.day_task_img.gameObject:SetActive(false)
		self.day_task_btn.gameObject:SetActive(true)
		self.week_task_img.gameObject:SetActive(false)
		self.week_task_btn.gameObject:SetActive(true)
		self.main_task_img.gameObject:SetActive(true)
		self.main_task_btn.gameObject:SetActive(false)
		self:CreateTaskObjByType(3)
	end)
	local refresh_time = function()
		local cDateCurrectTime = os.date("*t")
		local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day + 1, hour=0,min=0,sec=0})
		local date_data = basefunc.timeStampToDateTime(cDateTodayTime - os.time())
		self.remain_time_txt.text = "剩余时间：" .. date_data.hour .. ":" .. date_data.min .. ":" .. date_data.sec
	end
	refresh_time()
	self.update_timer = Timer.New(function()
		refresh_time()
	end,1,-1)
	self.update_timer:Start()
end

function M:CreateTaskObjByType(type)
	if not self.array_all_task then return end
	self:ClearTaskObj()
	self.cur_task_items = {}
	self.cur_task_type = type
	for k,v in ipairs(self.array_all_task) do
		if v.config.task_type == type and v.config.id ~= xunzhang_task_id then
			self.cur_task_items[#self.cur_task_items + 1] = v
		end
	end
	table.sort(self.cur_task_items,function(a,b)
		local sort_order_func = function(award_status)
			if award_status == task_mgr.award_status.can_get then
				return 1
			elseif award_status == task_mgr.award_status.not_can_get then
				return 2
			elseif award_status == task_mgr.award_status.complete then
				return 3
			end
		end
		if  sort_order_func(a.get_award_status()) ~=  sort_order_func(b.get_award_status()) then
			return sort_order_func(a.get_award_status()) < sort_order_func(b.get_award_status())
		else
			return a.id < b.id
		end
	end)
	for k,v in ipairs(self.cur_task_items) do
		self:CreateOneTaskItem(v.id,v)
	end
end

function M:ClearTaskObj()
	if not self.cur_task_items then return end
	for k,v in ipairs(self.cur_task_items) do
		self:on_task_item_delete(v.config.id)
	end
	self.cur_task_items = {}
end

local gotoui_config = {
	[1] = "adventure",
	[2] = "factory",
	[3] = "technology",
	[5] = "shop",
}

---- 创建一个 任务对象
function M:CreateOneTaskItem( task_id , task_obj )
	if self.taskItemVec[task_id] then
		return
	end

	local parent = self.Content
	local taskItemObj = NewObject( "TaskItem" , parent )
	self.taskItemVec[task_id] = { itemObj = taskItemObj , objData = {} }
	LuaHelper.GeneratingVar(taskItemObj.transform, self.taskItemVec[task_id].objData )

	self.taskItemVec[task_id].objData.main_btn.onClick:AddListener(function()
		local task_seq = DoTweenSequence.Create({dotweenLayerKey = "task_seq"})
		local begin_pos = self.taskItemVec[task_id].objData.task_point_txt.transform.position
		for i = 1,10 do
			task_seq:AppendInterval(0.04)
			task_seq:AppendCallback(function()
				M.CreateGold(self.fx_node,
					begin_pos,
					self.cur_reward_txt.transform.position,0)
			end)
		end
		---- 领奖
		task_mgr.GetTaskAward( task_id , 1 )
	end)
	self.taskItemVec[task_id].objData.gotoui_btn.onClick:AddListener(function()
		if task_obj.config and task_obj.config.gotoui and gotoui_config[task_obj.config.gotoui] then
			HallBottomManager.BottomGotoUI(gotoui_config[task_obj.config.gotoui])
			self:Exit()
		else
			dump(task_obj.config,"<color=red>没有对应的跳转配置</color>")
		end
	end)
	--日常任务显示勋章奖励数量
	if task_obj.config.task_type == 1 then
		local award = GameConfigCenter.GetBaseCommonAwardCfg(task_obj.config.award_data)
		for k,v in ipairs(award.award_data) do
			if v.asset_type == "task_10010014" then
				self.taskItemVec[task_id].objData.task_point_txt.text = v.value
				break
			end
		end
	end

	self:UpdateTaskItem( task_obj )
end

function M:UpdateTaskItem( task_obj )
	if not self.taskItemVec[task_obj.id] then
		return
	end

	local objData = self.taskItemVec[task_obj.id].objData
	objData.main_txt.text = task_obj.config.name
	local now_process = task_obj.get_now_process()
	local need_process = task_obj.get_need_process()
	objData.progress_txt.text = now_process .. "/" .. need_process
	local max_width = 346
	local height = 30.81
	objData.progress_img.transform:GetComponent("RectTransform").sizeDelta = {
		y = height,
		x = now_process / need_process * max_width
	}

	if task_obj.get_award_status() == task_mgr.award_status.not_can_get then
		objData.complete_node.gameObject:SetActive(false)
		objData.get_award_node.gameObject:SetActive(false)
		objData.goto_node.gameObject:SetActive(true)
	elseif task_obj.get_award_status() == task_mgr.award_status.complete then
		objData.complete_node.gameObject:SetActive(true)
		objData.get_award_node.gameObject:SetActive(false)
		objData.goto_node.gameObject:SetActive(false)
	elseif task_obj.get_award_status() == task_mgr.award_status.can_get then
		objData.complete_node.gameObject:SetActive(false)
		objData.get_award_node.gameObject:SetActive(true)
		objData.goto_node.gameObject:SetActive(false)
	end
	self:RefreshAwardItems()
end

--- 当创建任务项目
function M:on_task_item_add( task_obj )
	self:createOneTaskItem( task_obj.id , task_obj )
end

--- 当删除任务
function M:on_task_item_delete( taskId )
	if not self.taskItemVec[taskId] then
		return
	end

	Destroy( self.taskItemVec[taskId].itemObj )
	self.taskItemVec[taskId] = nil

end


--- 当任务刷新
function M:on_task_item_update( task_obj )
	self:UpdateTaskItem( task_obj )
	if self.cur_task_type then
		self:CreateTaskObjByType(self.cur_task_type)
	end
end

function M:MyRefresh()

end

local award_max_width = 715
function M:InitXunZhangAward()
	for k,v in ipairs(self.array_all_task) do
		if v.config.id == xunzhang_task_id then
			self.xunzhang_task = v
			break
		end
	end
	local _process = 0
	for k,process in ipairs(self.xunzhang_task.config.process_data) do
		_process = _process + process
		self:InitAwardItem(k,_process)
	end
	self:RefreshAwardItems()
end
local award_box_img_cfg = {
	[1] = "xfg_bx_1",
	[2] = "xfg_bx_2"
}

function M:InitAwardItem(lv,process)
	self.award_items = self.award_items or {}
	local award_obj = {}
	local obj = GameObject.Instantiate(self.award_item,self.award_node)
	local x = self.award_progress_bg.localPosition.x + (process - 50)/100 * award_max_width - 10
	obj.transform.localPosition = Vector3.New(x,obj.transform.localPosition.y,0)
	award_obj.gameObject = obj.gameObject
	award_obj.gameObject:SetActive(true)
	award_obj.process = process
	award_obj.lv = lv
	award_obj.tbl = LuaHelper.GeneratingVar(obj.transform)
	award_obj.tbl.award_process_txt.text = process
	award_obj.tbl.award_item_btn.onClick:AddListener(function()
		local award_status_vec = basefunc.decode_task_award_status( self.xunzhang_task.task_award_get_status )
		if award_status_vec[lv] then
			LittleTips.Create("已领取")
		elseif self.xunzhang_task.lv > lv or (self.xunzhang_task.lv == self.xunzhang_task.max_task_round and lv == self.xunzhang_task.lv and self.xunzhang_task.now_lv_process == self.xunzhang_task.now_lv_need_process) then
			self.xunzhang_task.get_award_new(lv)
			--创建通用奖励弹窗
			local cfg_award = GameConfigCenter.GetBaseCommonAwardCfg(self.xunzhang_task.config.award_data[lv])
			Event.Brocast("common_award_panel",cfg_award.award_data)
		else
			if self.AwardConfigShowPanel and IsEquals(self.AwardConfigShowPanel.gameObject) then
				self.AwardConfigShowPanel:Exit()				
			end
			self.AwardConfigShowPanel = AwardConfigShowPanel.Create({
				parent = self.transform,
				position = award_obj.gameObject.transform.position + Vector3.New(0,71,0),
				common_award_id = self.xunzhang_task.config.award_data[lv]})
		end
	end)
	self.award_items[#self.award_items + 1] = award_obj
	if lv <= 4 then
		award_obj.tbl.award_item_img.sprite = GetTexture(award_box_img_cfg[1])
	else
		award_obj.tbl.award_item_img.sprite = GetTexture(award_box_img_cfg[2])
	end
end

function M:RefreshAwardItems()
	if not self.xunzhang_task then return end
	local now_lv = self.xunzhang_task.lv
	local now_process = self.xunzhang_task.now_lv_process
	local now_total_process = now_process
	if now_lv > 1 then
		for i = 1,now_lv - 1 do
			now_total_process = now_total_process + self.xunzhang_task.config.process_data[i]
		end
	end
	self.cur_reward_txt.text = now_total_process
	self.award_progress_img.transform:GetComponent("RectTransform").sizeDelta = {
		x = award_max_width * (now_total_process / self.xunzhang_task.max_process),
		y = 22
	}
	local award_status_vec = basefunc.decode_task_award_status( self.xunzhang_task.task_award_get_status )
	for k,award_obj in pairs(self.award_items) do
		if now_total_process >= award_obj.process then
			award_obj.tbl.award_progress.gameObject:SetActive(true)
		end
		if award_status_vec[award_obj.lv] then
			if award_obj.lv <= 4 then
				award_obj.tbl.award_item_img.sprite = GetTexture(award_box_img_cfg[1] .. "_1")
			else
				award_obj.tbl.award_item_img.sprite = GetTexture(award_box_img_cfg[2] .. "_1")
			end
			award_obj.gameObject.transform:GetComponent("Animator").enabled = false
			award_obj.tbl.award_fx_node.gameObject:SetActive(false)
		elseif now_lv > award_obj.lv or (self.xunzhang_task.lv == self.xunzhang_task.max_task_round and self.xunzhang_task.lv == award_obj.lv and self.xunzhang_task.now_lv_process == self.xunzhang_task.now_lv_need_process) then
			award_obj.gameObject.transform:GetComponent("Animator").enabled = true
			award_obj.tbl.award_fx_node.gameObject:SetActive(true)
		else
			award_obj.gameObject.transform:GetComponent("Animator").enabled = false
			award_obj.tbl.award_fx_node.gameObject:SetActive(false)
		end
	end
end

function M.CreateGold(parent, beginPos, endPos, delay, call, prefab_name)
	prefab_name = prefab_name or "TaskFx"
	local prefab = NewObject("TaskFx",parent)
	local tran = prefab.transform
	-- prefab.prefab.prefabObj.transform.gameObject:SetActive(math.random(0,100) < 20)
	local romdom_pos =  Vector3.New(beginPos.x + math.random(-40,40),beginPos.y + math.random(-40,40),beginPos.z)
	tran.position = romdom_pos
	local seq = DoTweenSequence.Create({dotweenLayerKey = "task_seq"})
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	local len = math.sqrt( (romdom_pos.x - endPos.x) * (romdom_pos.x - endPos.x) + (romdom_pos.y - endPos.y) * (romdom_pos.y - endPos.y) )
	local HH = 35
	local t = len / 200
	local h = math.random(-200, 200)
	seq:Append(tran:DOMove(endPos, t):SetEase(Enum.Ease.Linear))
	seq:Insert(0,tran:DOScale(Vector3.New(1.8,1.8,1.8), t * 2/5))
	seq:Insert(t * 2/5,tran:DOScale(Vector3.New(1, 1, 1), t * 3/5))

	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if IsEquals(prefab) then
			Destroy(prefab)
		end
	end)
end