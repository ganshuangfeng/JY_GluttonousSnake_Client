-- 创建时间:2021-10-13
-- HallBottomManager 管理器

local basefunc = require "Game/Common/basefunc"
HallBottomManager = {}
local M = HallBottomManager
M.key = "hall_bottom"
GameModuleManager.ExtLoadLua(M.key, "HallBottomPanel")
GameModuleManager.ExtLoadLua(M.key, "HallBottomPrefab")
local config = GameModuleManager.ExtLoadLua(M.key, "hall_bottom_config")

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
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "panel" then
        this.cur_panel = HallBottomPanel.Create(parm.parent)
        return this.cur_panel
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local list = M.GetAnList()
    local stage = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    for k,v in ipairs(list) do
        if v.goto_ui then
            local a,b = GameModuleManager.RunFunExt(GetGotoUIParm(cfg.goto_ui), "GetHintState")
            if a then
                if b == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                    stage = ACTIVITY_HINT_STATUS_ENUM.AT_Get
                    break
                elseif b == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
                    stage = ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
        end
    end
	return stage
end
function M.on_global_hint_state_change_msg(parm)
	if this.UIConfig.gotoui_map[ parm.gotoui ] then
        -- 
        coroutine.start(function ( )
            Yield(0)
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        end)
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg
end

function M.Init()
	M.Exit()

	this = HallBottomManager
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

    this.UIConfig.an_list = {}
    this.UIConfig.gotoui_map = {}
    for k,v in ipairs(config) do
        if v.is_show then
            this.UIConfig.an_list[#this.UIConfig.an_list + 1] = v
            if v.goto_ui then
                this.UIConfig.gotoui_map[ v.goto_ui[1] ] = v
            end
        end
    end
    MathExtend.SortList(this.UIConfig.an_list, "order", true)
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

-- 获取按钮列表
function M.GetAnList()
    return this.UIConfig.an_list
end
function M.IsContain(gotoui)
    if this.UIConfig.gotoui_map[ gotoui ] then
        return true
    end
    return false
end

function M.BottomGotoUI(gotoui)
    if not this.cur_panel then return end
    for k,v in ipairs(this.GetAnList()) do
        if v.goto_ui and v.goto_ui[1] == gotoui then
            this.cur_panel:OnGetClick(k,true)
        end
    end
end