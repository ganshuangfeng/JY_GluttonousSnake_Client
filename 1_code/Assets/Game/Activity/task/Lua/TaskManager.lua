-- 创建时间:2021-10-28
-- TaskManager 管理器

local basefunc = require "Game/Common/basefunc"
TaskManager = {}
local M = TaskManager
M.key = "task"
GameModuleManager.ExtLoadLua(M.key, "TaskPanel")
GameModuleManager.ExtLoadLua(M.key, "TaskEnter")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    
    if parm.goto_scene_parm == "panel" then
        return TaskPanel.Create({parent = parm.parent})
    end
    if parm.goto_scene_parm == "enter" then
        return TaskEnter.Create({parent = parm.parent})
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	local allTask = task_mgr.GetAllTask()
    local array_all_task = {}
	if allTask and type(allTask) == "table" then
		for k,v in pairs(allTask) do
			if v.config.task_type ~= 4 then
                if v.get_award_status() == task_mgr.award_status.can_get then
                    return ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
		end
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
-- 关心的模块才处理
function M.on_global_hint_state_change_msg(parm)
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg
end

function M.Init()
	M.Exit()

	this = TaskManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end
