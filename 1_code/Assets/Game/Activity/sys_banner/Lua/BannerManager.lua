-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
BannerManager = {}
local M = BannerManager
M.key = "sys_banner"
GameModuleManager.ExtLoadLua(M.key, "BannerPanel")
local config = GameModuleManager.ExtLoadLua(M.key, "banner_style_ui")
local lister
local this

function M.CheckIsShow()
    if not GameGlobalOnOff.Banner then
        return false
    end
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return M.RunBanner()
    elseif parm.goto_scene_parm == "panel_show" then
        return M.ShowBanner(parm.gotoID)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
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
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()
    this = M
	this.data = {}
	MakeLister()
    AddLister()
    this.InitUIConfig()
    this.data.IsFirstRun = MainModel.banner_if_first_run
    MainModel.banner_if_first_run = false
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
        config = {},
        hallconfig = {},
    }
    this.UIConfig.config = config.upconfig
    this.UIConfig.hallconfig = config.hallconfig
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

-- 运行广告 (id有就显示一个)
function M.RunBanner()
    this.CalcShowList()
    if #this.data.bannerList > 0 then
        return BannerPanel.Show()
    end
end
function M.ShowBanner(id)
    BannerPanel.Show(id)
end
function M.SetPopup(id)
    PlayerPrefs.SetString("BannerRecentlyRunTime" .. id, os.time())
    this.data.popup_banner_map = this.data.popup_banner_map or {}
    this.data.popup_banner_map[id] = true
end
-- 计算并排序显示列表
function M.CalcShowList()
    local newtime = tonumber(os.date("%Y%m%d", os.time()))

    local config = this.UIConfig.config
    this.UIConfig.upconfigMap = {}
    local bannerConfig = {}
    if next(config) then
        for k,v in ipairs(config) do
            bannerConfig[k] = v
        end
    end
    local nowtime = os.time()
    bannerConfig = MathExtend.SortList(bannerConfig, "order", true)
    this.data.bannerList = {}
    for k,v in ipairs(bannerConfig) do
        if (v.isOnOff and v.isOnOff == 1) and (not v.srartTime or v.srartTime == -1 or nowtime >= v.srartTime)
            and (not v.endTime or v.endTime == -1 or nowtime <= v.endTime) then
            if not v.shop_id or MainModel.GetGiftShopShowByID(v.shop_id) then
                if v.model == "DailyUp" then
                    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("BannerRecentlyRunTime" .. v.bannerID, 0))))
                    if oldtime ~= newtime then
                        this.data.bannerList[#this.data.bannerList + 1] = v.bannerID
                        this.UIConfig.upconfigMap[v.bannerID] = v
                    end
                else
                    if not this.data.popup_banner_map or not (this.data.popup_banner_map[v.bannerID] and v.model == "LoginUp") then
                        if v.condi_key then
                            -- body
                            dump(v.condi_key,"<color=yellow>v.condi_key:  </color>")
                            local a,b = GameModuleManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint=true}, "CheckCondition")
                
                            if a and b then
                                this.data.bannerList[#this.data.bannerList + 1] = v.bannerID
                                this.UIConfig.upconfigMap[v.bannerID] = v
                            end
                        else
                            this.data.bannerList[#this.data.bannerList + 1] = v.bannerID
                            this.UIConfig.upconfigMap[v.bannerID] = v
                        end
                    end                    
                end
            end
        end
    end
end

-- 计算并排序显示列表-大厅轮换切换
function M.CalcHallBannerList()
    local config = this.UIConfig.hallconfig
    this.UIConfig.hallconfigMap = {}
    local bannerConfig = {}
    if config then
        for k,v in ipairs(config) do
            bannerConfig[k] = v
        end
    end
    local nowtime = os.time()
    bannerConfig = MathExtend.SortList(bannerConfig, "order", true)
    this.data.hallBannerList = {}
    for k,v in ipairs(bannerConfig) do
        if (v.isOnOff and v.isOnOff == 1) and (not v.srartTime or v.srartTime == -1 or nowtime >= v.srartTime)
            and (not v.endTime or v.endTime == -1 or nowtime <= v.endTime) then
            if not v.shop_id or MainModel.GetGiftShopShowByID(v.shop_id) then

                -- 根据玩家标签及渠道，展示不同的banner图
                local a,b = GameModuleManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint=true}, "CheckCondition")
                if not a or b then
                    this.data.hallBannerList[#this.data.hallBannerList + 1] = v.bannerID
                    this.UIConfig.hallconfigMap[v.bannerID] = v                    
                end

            end
        end
    end
end


