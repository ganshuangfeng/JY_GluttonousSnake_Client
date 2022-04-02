-- 创建时间:2021-10-20
-- TechnologyManager 管理器

local basefunc = require "Game/Common/basefunc"
TechnologyManager = {}
local M = TechnologyManager
M.key = "technology"
GameModuleManager.ExtLoadLua(M.key, "TechnologyMainPanel")
GameModuleManager.ExtLoadLua(M.key, "TechnologyPanel")
GameModuleManager.ExtLoadLua(M.key, "TechnologyGianPanel")
local config = GameModuleManager.ExtLoadLua(M.key, "technology_config")

local this
local lister
--我们自己配
local icon_config = {
    single_hero_attack = {icon = "xfg_kj_icn_dtgj_02",icon_mask = "xfg_kj_icn_dtgj_01",desc = "单发炮台攻击"},
    single_hero_gunshot = {icon = "xfg_kj_icn_dtsc_02",icon_mask = "xfg_kj_icn_dtsc_01",desc = "单发炮台射程"},
    single_hero_hitspace = {icon = "xfg_kj_icn_dtss_02",icon_mask = "xfg_kj_icn_dtss_01",desc = "单发炮台攻速"},
    range_hero_attack = {icon = "xfg_kj_icn_dfgj_02",icon_mask = "xfg_kj_icn_dfgj_01",desc = "多发炮台攻击"},
    range_hero_gunshot = {icon = "xfg_kj_icn_dfsc_02",icon_mask = "xfg_kj_icn_dfsc_01",desc = "多发炮台射程"},
    range_hero_hitspace = {icon = "xfg_kj_icn_dfss_02",icon_mask = "xfg_kj_icn_dfss_01",desc = "多发炮台攻速"},
    sustained_hero_attack = {icon = "xfg_kj_icn_cxgj_02",icon_mask = "xfg_kj_icn_cxgj_01",desc = "持续炮台攻击"},
    sustained_hero_gunshot = {icon = "xfg_kj_icn_cxsc_02",icon_mask = "xfg_kj_icn_cxsc_01",desc = "持续炮台射程"},
    sustained_hero_hitspace = {icon = "xfg_kj_icn_j02",icon_mask = "xfg_kj_icn_cxss_01",desc = "持续炮台攻速"},
    control_hero_attack = {icon = "xfg_kj_icn_kzgj_02",icon_mask = "xfg_kj_icn_kzgj_01",desc = "控制炮台攻击"},
    control_hero_gunshot = {icon = "xfg_kj_icn_kzsc_02",icon_mask = "xfg_kj_icn_kzsc_01",desc = "控制炮台射程"},
    control_hero_hitspace = {icon = "xfg_kj_icn_kzss_02",icon_mask = "xfg_kj_icn_kzss_01",desc = "控制炮台攻速"},
    close_in_hero_attack = {icon = "xfg_kj_icn_jsgj_02",icon_mask = "xfg_kj_icn_jsgj_01",desc = "近战炮台攻击"},
    close_in_hero_gunshot = {icon = "xfg_kj_icn_jssc_02",icon_mask = "xfg_kj_icn_jssc_01",desc = "近战炮台射程"},
    close_in_hero_hitspace = {icon = "xfg_kj_icn_jsss_02",icon_mask = "xfg_kj_icn_jsss_01",desc = "近战炮台攻速"},
    max_hp = {icon = "xfg_kj_icn_smsx_02",icon_mask = "xfg_kj_icn_smsx_01",desc = "最大血量"},
    gold_get = {icon = "xfg_kj_icn_jbhql_02",icon_mask = "xfg_kj_icn_jbhql_01",desc = "金币增加(%)"},
    heal_up = {icon = "xfg_kj_icn_hfdjhfl_02",icon_mask = "xfg_kj_icn_hfdjhfl_01",desc = "血量恢复增加"},
    gold_rush_time = {icon = "xfg_kj_icn_cnsk_02",icon_mask = "xfg_kj_icn_cnsk_01",desc = "超能时刻时间延长"},
}

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
        --return FactoryPanel.Create(parm.parent)
        return TechnologyMainPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
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
    lister["model_asset_change_msg"] = this.on_model_asset_change_msg
end

function M.Init()
	M.Exit()

	this = TechnologyManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitConfigByIndex()
    M.AddRedPoint()
    M.SetRedPointNum()
    dump(M.ConfigByIndex,"<color=red>配置初始话</color>")
end
function M.Exit()
	if this then
		RemoveLister()
        M.RemoveRedPoint()
		this = nil
	end
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

-- 获取第N页的属性加成
function M.GetPropertyByIndex(index)
    local result = {}
    local data = M.ConfigByIndex[index]
    for i = 1,#data do
        if M.IsPropertyIDUnLock(data[i].property_id) then  
            local d = M.GetPropertyByID(data[i].property_id)
            for k,v in pairs(icon_config) do
                if d and d[k] then
                    result[k] = result[k] or 0
                    result[k] = result[k] + d[k]
                end
            end
        end
    end
    return result
end

-- 解锁一个属性点
function M.UnLockProperty(property_id)
    if M.IsCanUnLock(property_id) then
        local id = M.GetPropertyByID(property_id).cast_id
        local type = AssetItemConfig[id].asset_type
        local curr_value =  M.GetPropertyByID(property_id).cast_num
        MainModel.UpgradeTechnology(property_id,{[1] = {asset_type = type,asset_value = curr_value}},
        function(data)
            --dump(data.result , "xxxx-----------resultttt")
            if data.result == 0 then
                Event.Brocast("one_property_unlocked")
                task_mgr.TriggerMsg( "unlock_technology_msg"  )
                M.SetRedPointNum()
            end
        end
    )
    else
        print("<color=red>不满足解锁条件</color>")
    end
end
-- 检查一个属性点是否满足解锁条件
function M.IsCanUnLock(property_id)
    --首先看上一个解锁点是否解锁
    local last_unlocked = false
    for i = 1,#M.ConfigByIndex do
        for ii = 1,#M.ConfigByIndex[i] do
            if M.ConfigByIndex[i][ii].property_id == property_id then
                if ii == 1 then
                    last_unlocked = true
                else
                    local b = M.IsPropertyIDUnLock( M.ConfigByIndex[i][ii - 1].property_id)
                    
                    last_unlocked = b
                end 
                local b2 = not M.IsPropertyIDUnLock(property_id)
                last_unlocked = last_unlocked and b2
                if last_unlocked then
                    local id =  M.ConfigByIndex[i][ii].cast_id
                    local type = AssetItemConfig[id].asset_type
                    local curr_value = MainModel.GetAssetValueByKey(type)

                    if curr_value >= M.ConfigByIndex[i][ii].cast_num then
                        return true
                    end
                else
                    return false
                end
            end
        end
    end
end

--按照分页来初始化配置表
function M.InitConfigByIndex()
    M.ConfigByIndex = {}
    local find = function(type)
        local data = {}
        for k , v in pairs(config.technology) do
            if v.type == type then
                data[#data + 1] = v
            end
        end
        table.sort(data,function(a,b)
            if a.id < b.id then
                return true
            else
                return false
            end
        end)
        return data
    end

    for i = 1,9999 do
        local d = find(i)
        if #d == 0 then
            return M.ConfigByIndex
        else
            M.ConfigByIndex[i] = d
        end
    end
end

--获取分页数量
function M.GetMaxIndex()
    return #M.ConfigByIndex
end

--获取某一个分页的配置
function M.GetConfigByIndex(index)
    return M.ConfigByIndex[index]
end

--获取当前类型得英雄增益
function M.GetHeroGain(hero_type)
    local keys = {
        "attack",
        "gunshot",
        "hitspace",
    }
    local attack_type = GameConfigCenter.GetHeroAttackType(hero_type)
    local main_key = attack_type.."_hero_"
    local result = {}
    for i = 1,#keys do
        local key = main_key..keys[i]
        local up_value = 0
        for k,v in pairs(config) do
            local property_id = v.property_id
            if  M.IsPropertyIDUnLock(property_id) then
                local d = M.GetPropertyByID(property_id)
                if d and d[key] then
                    up_value = up_value + d[key]
                end
            end
        end
        --方便人员判断
        result[key] = up_value
        --方便程序读取
        result[keys[i]] = up_value
    end
    return result
end

--通过属性id获取具体属性
function M.GetPropertyByID(property_id)
    local re1 = nil
    for k , v in pairs(config.property) do
        if v.property_id == property_id then
            re1 = v
        end
    end
    local re2 = nil
    for k , v in pairs(config.technology) do
        if v.property_id == property_id then
            re2 = v
        end
    end
    return basefunc.merge(re1,re2)
end

--获取超能时间增益
function M.GoldRushTimeUp()
    local re = 0
    for k , v in pairs(config.technology) do
        local property_id = v.property_id
        if  M.IsPropertyIDUnLock(property_id) then
            local d = M.GetPropertyByID(property_id)
            if d and d.gold_rush_time then
                re = re + d.gold_rush_time
            end
        end
    end
    return re
end

--获取回复量增益
function M.HealUp()
    local re = 0
    for k , v in pairs(config.technology) do
        local property_id = v.property_id
        if  M.IsPropertyIDUnLock(property_id) then
            local d = M.GetPropertyByID(property_id)
            if d and d.heal_up then
                re = re + d.heal_up
            end
        end
    end
    return re
end

--获取金币获取量增益
function M.GetGoldGetUp()
    local re = 0
    for k , v in pairs(config.technology) do
        local property_id = v.property_id
        if  M.IsPropertyIDUnLock(property_id) then
            local d = M.GetPropertyByID(property_id)
            if d and d.gold_get then
                re = re + d.gold_get
            end
        end
    end
    return re
end

--获取最大血量得增益
function M.GetMaxHpUp()
    local re = 0
    for k , v in pairs(config.technology) do
        local property_id = v.property_id
        if  M.IsPropertyIDUnLock(property_id) then
            local d = M.GetPropertyByID(property_id)
            if d and d.max_hp then
                re = re + d.max_hp
            end
        end
    end
    return re
end

--判断一个属性id是否解锁
function M.IsPropertyIDUnLock(property_id)
    for k , v in pairs(MainModel.QueryTechnologyInfo()) do
        if v == property_id then
            return true
        end
    end
end

function M.GetIcon(property_name)
    dump(property_name)
    return icon_config[property_name].icon
end

function M.GetIconByPropertyID(property_id)
    local d = M.GetPropertyByID(property_id)
    for k , v in pairs(icon_config) do
        if d and d[k] then
            return M.GetIcon(k) 
        end
    end
end

function M.GetIconMask(property_name)
    return icon_config[property_name].icon_mask
end

function M.GetIconMaskByPropertyID(property_id)
    local d = M.GetPropertyByID(property_id)
    for k , v in pairs(icon_config) do
        if d and d[k] then
            return M.GetIconMask(k) 
        end
    end
end

function M.GetDesc(property_name)
    dump(property_name)
    return icon_config[property_name].desc
end

function M.IsAllUnlockByIndex(index)
    local data = M.ConfigByIndex[index]
    if not data then return false end
    for k , v in pairs(data) do
        if not M.IsPropertyIDUnLock(v.property_id) then
            return false
        end
    end
    return true
end

function M.IsAllUnlock()
    for i = 1,#M.ConfigByIndex do
        if not M.IsAllUnlockByIndex(i) then
            return false
        end
    end
    return true
end

function M.GetTitle(index)
    local title_config = {
        "1.初级科技树","2.中级科技树"
    }
    return title_config[index]
end

function M.GetAllProperty()
    local result = {}
    for i = 1,#M.ConfigByIndex do
        local d = M.GetPropertyByIndex(i)
        for k , v in pairs(d) do
            result[k] = result[k] or 0
            result[k] = result[k] + v
        end
    end
    return result
end

function M.GetCurrIndex()
    local index = 1
	for i = 1,#M.ConfigByIndex do
		if not TechnologyManager.IsAllUnlockByIndex(i) then
			index = i
            break
		end
	end
    return index
end


function M.AddRedPoint()
	RedPointSystem.Instance:CreateNode(RedPointEnum.Technology)
    RedPointSystem.Instance:CreateNode(RedPointEnum.Technology.. "." .. "button")
end

function M.RemoveRedPoint()
    RedPointSystem.Instance:ClearNode(RedPointEnum.Technology)
    RedPointSystem.Instance:ClearNode(RedPointEnum.Technology.. "." .. "button")
end

function M.SetRedPointNum()
    local num = 0
    for k, v in pairs(config.property) do
        if M.IsCanUnLock(v.property_id) then
            num = 1
            break
        end
    end

    RedPointSystem.Instance:SetRedPointNum(RedPointEnum.Technology,num)
    RedPointSystem.Instance:SetRedPointNum(RedPointEnum.Technology.. "." .. "button",num)
end

function M.on_model_asset_change_msg()
    M.SetRedPointNum() 
end
