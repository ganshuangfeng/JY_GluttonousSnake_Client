-- 创建时间:2019-11-29
-- SYSQXManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSQXManager = {}
local M = SYSQXManager
local cpm = require "Game.CommonPrefab.Lua.common_permission_manager"

local this
local lister

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
    if not this then
        M.Exit()

        this = SYSQXManager

        this.m_data = {}
        MakeLister()
        AddLister()
        M.InitUIConfig()
    end
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

-- 检查条件或权限
function M.CheckCondition(condi_key, is_hint)
    is_hint = is_hint or true

    if condi_key == "technology" then
        if MainModel.UserInfo.game_level < 14 then
            if is_hint then
                HintPanel.Create(1, "通过第13关后解锁")
            end
            return false
        end
    elseif condi_key == "shop" then
        if MainModel.UserInfo.game_level < 7 then
            if is_hint then
                HintPanel.Create(1, "通过第6关后解锁")
            end
            return false
        end
    end
    return true
end
