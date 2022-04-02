-- 创建时间:2021-10-13
-- FactoryManager 管理器
-- 工厂模块--炮台 蛇头 解锁 升级 等

local basefunc = require "Game/Common/basefunc"
FactoryManager = {}
local M = FactoryManager
M.key = "factory"
GameModuleManager.ExtLoadLua(M.key, "FactoryPanel")
GameModuleManager.ExtLoadLua(M.key, "TurretShowPanel")
GameModuleManager.ExtLoadLua(M.key, "HeadShowPanel")
GameModuleManager.ExtLoadLua(M.key, "TurretCompanyPanel")
GameModuleManager.ExtLoadLua(M.key, "FactoryMainUIPanel")
GameModuleManager.ExtLoadLua(M.key, "FactoryHeadPanel")
GameModuleManager.ExtLoadLua(M.key, "FactoryHeroPanel")
GameModuleManager.ExtLoadLua(M.key, "FactoryGongjuPanel")
GameModuleManager.ExtLoadLua(M.key, "HeroShowPanel")
GameModuleManager.ExtLoadLua(M.key, "HeroShowMasterPanel")
GameModuleManager.ExtLoadLua(M.key, "GongjuShowPanel")
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
        --return FactoryPanel.Create(parm.parent)
        return FactoryMainUIPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local config = {1,2,3,4,7,13,14}

    for i = 1,#config do
        local hero_type = config[i]
        local fragment_num = HeroDataManager.GetHeroFragmentNumByType(hero_type)
        local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
        local level = HeroDataManager.GetHeroLevelByType(hero_type)
        local need = HeroDataManager.GetUnlockNeed(hero_type,level)
        if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end
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
    lister["Ext_OnLoginResponse"] = this.OnExt_OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["HeroDataChange"] = this.OnHeroDataChange
    lister["UpgradeHead"] = this.OnUpgradeHead
    lister["model_asset_change_msg"] = this.on_model_asset_change_msg
end

function M.Init()
	M.Exit()

	this = FactoryManager
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
        Event.Brocast("FactoryMainUIPanelExit")
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnExt_OnLoginResponse(result)
	if result ~= 0 then return end
    M.SetRedPointNum()
end
function M.OnReConnecteServerSucceed()
    if result ~= 0 then return end
    M.SetRedPointNum()
end

function M.OnHeroDataChange(parm)
   M.SetRedPointNum()
end

function M.OnUpgradeHead()
    M.SetRedPointNum()
end

function M.on_model_asset_change_msg()
    M.SetRedPointNum()
end

function M.AddRedPoint()
	RedPointSystem.Instance:CreateNode(RedPointEnum.Factory)

    --蛇头
    local config = GameConfigCenter.GetAllHeroHeadConfig()
    for i = 1, #config do
        RedPointSystem.Instance:CreateNode(RedPointEnum.FactoryHead.. "." .. config[i].id)
    end

    --英雄
    local config = GameConfigCenter.GetHeroAttackTypeConfig()
    for i = 1,#config do
        local hero_list = GameConfigCenter.GetHeroListByAttackType(config[i].attack_type)
        for j = 1,#hero_list do
            RedPointSystem.Instance:CreateNode(RedPointEnum.FactoryHero.. "." .. config[i].attack_type .. "." .. hero_list[j])
        end
	end

    --工具
    local config = GameConfigCenter.GetGongjuCfg()
    for k, v in pairs(config) do
        RedPointSystem.Instance:CreateNode(RedPointEnum.FactoryGongju.. "." .. v.id)
    end
end

function M.RemoveRedPoint()
    local config = GameConfigCenter.GetAllHeroHeadConfig()
    for i = 1, #config do
        RedPointSystem.Instance:ClearNode(RedPointEnum.FactoryHead.. "." .. config[i].id)
    end

    local config = GameConfigCenter.GetHeroAttackTypeConfig()
    for i = 1,#config do
        local hero_list = GameConfigCenter.GetHeroListByAttackType(config[i].attack_type)
        for j = 1,#hero_list do
            RedPointSystem.Instance:ClearNode(RedPointEnum.FactoryHero.. "." .. config[i].attack_type .. "." .. hero_list[j])
        end
	end

    local config = GameConfigCenter.GetGongjuCfg()
    for k, v in pairs(config) do
        RedPointSystem.Instance:ClearNode(RedPointEnum.FactoryGongju.. "." .. v.id)
    end

    RedPointSystem.Instance:ClearNode(RedPointEnum.Factory)
end

function M.SetRedPointNum()
    --蛇头
    local config = GameConfigCenter.GetAllHeroHeadConfig()
    for i = 1, #config do
        local num = M.GetHeadUpNum(config[i].id)
        RedPointSystem.Instance:SetRedPointNum(RedPointEnum.FactoryHead.. "." .. config[i].id,num)
    end

    --英雄
    local config = GameConfigCenter.GetHeroAttackTypeConfig()
    for i = 1,#config do
        local hero_list = GameConfigCenter.GetHeroListByAttackType(config[i].attack_type)
        for j = 1,#hero_list do
            local num = M.GetHeroUpNum(hero_list[j])
            RedPointSystem.Instance:SetRedPointNum(RedPointEnum.FactoryHero.. "." .. config[i].attack_type .. "." .. hero_list[j],num)
        end
	end

    --工具
    local config = GameConfigCenter.GetGongjuCfg()
    for k, v in pairs(config) do
        local num = M.GetGongjuUpNum(v.id)
        RedPointSystem.Instance:SetRedPointNum(RedPointEnum.FactoryGongju.. "." .. v.id,num)
    end
end

function M.GetHeadUpNum(headType)
    -- local config = GameConfigCenter.GetHeroHeadConfig(headType)
	local data = GameConfigCenter.GetHeroHeadDataConfig(headType)
    if not data then
        return 0
    end
	--如果curLevel == 0 表示没有解锁
	local curLevel = MainModel.GetHeadLevel(headType)
	local nextLevel = curLevel + 1
	local maxLevel = #data
    if curLevel >= maxLevel then
        return 0
    end

    local check_asset = function (upgrade_asset)
        for ai,ass in ipairs(upgrade_asset) do
            if type(ass.asset_type) == "string" and tonumber(ass.asset_value) then
                if MainModel.GetAssetValueByKey(ass.asset_type) < tonumber(ass.asset_value) then
                    return
                end
            else
                return
            end
        end
        return true
    end

    local num = 0
    for i = nextLevel, maxLevel do
        if check_asset(data[i].upgrade_asset) then
            num = num + 1
        else
            break
        end
    end
    return num
end

function M.GetHeroUpNum(heroType)
    local fragment_num = HeroDataManager.GetHeroFragmentNumByType(heroType)
    local jin_bi = MainModel.UserInfo.Asset.prop_jin_bi
    local level = HeroDataManager.GetHeroLevelByType(heroType)
    local need = HeroDataManager.GetUnlockNeed(heroType,level)
    if fragment_num >= need.fragment_need and jin_bi >= need.gold_need then
        if level < 20 then
            return 1
        end
    end
    return 0
end

function M.GetGongjuUpNum(k)
    local data
    local lv
    if k == "team" then
        lv = MainModel.QueryTeamLevel()
        data = GameConfigCenter.GetTeamLevelDataConfig()
    elseif k == "health" then
        lv = MainModel.QueryHealthLevel()
        data = GameConfigCenter.GetHealthLevelDataConfig()
    end

    if lv >= #data then return 0 end

    for k, v in pairs(data[lv + 1].upgrade_asset) do
        if MainModel.GetAssetValueByKey(v.asset_type) < v.asset_value then
            return 0
        end
    end

    return 1
end