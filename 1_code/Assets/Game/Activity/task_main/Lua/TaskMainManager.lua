local basefunc = require "Game/Common/basefunc"
TaskMainManager = {}
local M = TaskMainManager
M.key = "task_main"
GameModuleManager.ExtLoadLua(M.key, "TaskMainPanel")
GameModuleManager.ExtLoadLua(M.key, "TaskMainEnter")
GameModuleManager.ExtLoadLua(M.key, "TaskMainItem")

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
        local a,b = GameModuleManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
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
        return TaskMainPanel.Create(parm)
    elseif parm.goto_scene_parm == "enter" then
        local allTask = task_mgr.GetAllTask()
        local complete_flag = true
        for k,v in pairs(allTask) do
            if v.config.task_type == 4 then
                if v.get_award_status() ~= task_mgr.award_status.complete then
                    complete_flag = false
                end
            end
        end
        if not complete_flag then
            return TaskMainEnter.Create(parm)
        else
            return false
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
end

function M.Init()
	M.Exit()

	this = TaskMainManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()

    M.AddRedPoint()
    M.SetRedPointNum()
end
function M.Exit()
	if this then
		RemoveLister()
        M.RemoveRedPoint()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end


function M.AddRedPoint()

end

function M.RemoveRedPoint()

end

function M.SetRedPointNum()

end