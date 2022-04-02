-- 创建时间:
local basefunc = require "Game/Common/basefunc"
SysSettingManager = {}

local M = SysSettingManager
M.key = "sys_setting"
GameModuleManager.ExtLoadLua(M.key, "SettingPanel")
GameModuleManager.ExtLoadLua(M.key, "SettingEnterPrefab")

local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return SettingPanel.Show()
    elseif parm.goto_scene_parm == "enter" then
        return SettingEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end