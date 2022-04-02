-- 创建时间:2021-10-13
-- 签到 管理器

local basefunc = require "Game/Common/basefunc"
SysSignInManager = {}
local M = SysSignInManager
M.key = "sys_signin"
local signin_config_client = GameModuleManager.ExtLoadLua(M.key, "signin_config_client")
GameModuleManager.ExtLoadLua(M.key, "SignInPanel")
GameModuleManager.ExtLoadLua(M.key, "SignInEnterPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    return true
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
        return SignInPanel.Create(parm.backcall)
    elseif parm.goto_scene_parm == "panel1" then
        if MainModel.myLocation == "game_Hall" and not this.signin_today and not this.signin_clear then
            return SignInPanel.Create(parm.backcall)
        end
    elseif parm.goto_scene_parm == "enter" then
        if not this.signin_clear then
            return SignInEnterPrefab.Create(parm)
        end
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["query_sign_in_data_response"] = this.on_query_sign_in_data_response
    lister["get_sign_in_award_response"] = this.on_get_sign_in_award_response
end

function M.Init()
	M.Exit()

	this = SysSignInManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    if PlayerPrefs.GetInt("sign_in_manager_sign_in_today" .. MainModel.UserInfo.user_id,0) == GetTodayTimeStamp() then
        this.signin_today = true
    end
    if PlayerPrefs.GetInt("sign_in_seven_day_clear_" .. MainModel.UserInfo.user_id,0) == 1 then
        this.signin_clear = true
    end
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.sign_in_seven_day = signin_config_client.sign_in_seven_day
    for k,v in ipairs(this.UIConfig.sign_in_seven_day) do
        if v.award_id then
            -- v.award_data = signin_config_client.award_config[v.award_id]
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_sign_in_data")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_sign_in_data_response(_,data)
    dump(data,"<color=green>签到数据</color>")
    if data.result == 0 then
        this.m_data.sign_in_day = data.sign_in_day + 1 --七天签到天数
        this.m_data.sign_in_time = data.sign_in_time
        if tonumber(this.m_data.sign_in_time) >= GetTodayTimeStamp() then
            this.signin_today = true
        end
        if this.m_data.sign_in_day > 7 then
            this.signin_clear = true
        end
        Event.Brocast("model_on_query_sign_in_data_response")
    end
end

function M.GetSignInAward(type,index)
    local cfg = this.UIConfig.sign_in_seven_day[index]
    if not cfg then return end
    local award_data = GameConfigCenter.GetBaseCommonAwardCfg(cfg.award_id).award_data
    local player_assets = {}
    for k,v in ipairs(award_data) do
        local player_asset = {}
        player_asset.asset_type = v.asset_type
        player_asset.asset_value = v.value
        player_assets[#player_assets + 1] = player_asset
    end
    Network.SendRequest("get_sign_in_award",{asset = player_assets},"请求奖励",function(data)
        dump(data,"<color=red>请求签到奖励</color>")
        if data.result == 0 then
            
            local cfg = this.UIConfig.sign_in_seven_day[index]
            if cfg.award_id then
                GameConfigCenter.GetCommonAward(cfg.award_id)
                Event.Brocast("common_award_panel",award_data)
                Event.Brocast("get_sign_in_award_response","get_sign_in_award_response",data)
            end
            if index == 7 then
                PlayerPrefs.SetInt("sign_in_seven_day_clear_" .. MainModel.UserInfo.user_id,1)
            end
        end
    end)
end

function M.on_get_sign_in_award_response(_,data)
    if data.result == 0 then
        Network.SendRequest("query_sign_in_data")
        PlayerPrefs.SetInt("sign_in_manager_sign_in_today" .. MainModel.UserInfo.user_id,GetTodayTimeStamp())
        this.signin_today = true
    else
        HintPanel.ErrorMsg(data.result)
    end
end