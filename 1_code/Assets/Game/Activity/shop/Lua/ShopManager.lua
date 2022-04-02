-- 创建时间:2021-10-26
-- ShopManager 管理器

local basefunc = require "Game/Common/basefunc"
ShopManager = {}
local M = ShopManager
M.key = "shop"
local config = GameModuleManager.ExtLoadLua(M.key, "shop_config")
GameModuleManager.ExtLoadLua(M.key, "ShopMainUIPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopCurrencyPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopPTItem")
GameModuleManager.ExtLoadLua(M.key, "ShopBoxPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopJXPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopBoxItem")
GameModuleManager.ExtLoadLua(M.key, "ShopJXItem")
GameModuleManager.ExtLoadLua(M.key, "ShopBuyHintPanel")
GameModuleManager.ExtLoadLua(M.key, "ShopBoxHintPanel")

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
        return ShopMainUIPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    local curT = os.time()

    local list = M.GetBXData()
    for k,v in ipairs(list) do
        local da = M.GetShopItemData(v)
        if (da.buy_type == 1 or da.buy_type == 2) and
            (not da.P1 or da.buyNum < da.P1) and
            ((da.cd + da.buyTime) <= curT) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end
    list = M.GetPTData()
    for k,v in ipairs(list) do
        local da = M.GetShopItemData(v)
        if (da.buy_type == 1 or da.buy_type == 2) and
            (not da.P1 or da.buyNum < da.P1) and
            ((da.cd + da.buyTime) <= curT) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end
    list = M.GetJXData()
    for k,v in ipairs(list) do
        local da = M.GetShopItemData(v)
        if (da.is_buy == 1 or da.buy_type == 2) and
            (not da.is_buy) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
    end

	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.CallCD()
    local state = M.GetHintState()
    if state ~= this.cur_state then
        this.cur_state = state
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
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

	this = ShopManager
	this.m_data = {}
    this.m_data.shopData = {}
	MakeLister()
    AddLister()
    this.cdTime = Timer.New(function ()
        this.CallCD()
    end, 1, -1)
    this.cdTime:Start()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        if this.cdTime then
            this.cdTime:Stop()
            this.cdTime = nil
        end
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.shop_config = {}
    this.UIConfig.shop_map = {}
    this.UIConfig.shop_list = {}
    for k,v in pairs(config.shop_config) do
        this.UIConfig.shop_map[v.id] = v
        this.UIConfig.shop_list[#this.UIConfig.shop_list + 1] = v

        if v.type == 1 then
            --最上方免费领取的货币
            this.UIConfig.shop_config.currency = this.UIConfig.shop_config.currency or {}
            this.UIConfig.shop_config.currency[#this.UIConfig.shop_config.currency + 1] = v
        elseif v.type == 2 then
            --下方的宝箱
            this.UIConfig.shop_config.box = this.UIConfig.shop_config.box or {}
            this.UIConfig.shop_config.box[#this.UIConfig.shop_config.box + 1] = v
        elseif v.type == 3 then
            --精选商品
            this.UIConfig.shop_config.jingxuan = this.UIConfig.shop_config.jingxuan or {}
            this.UIConfig.shop_config.jingxuan[#this.UIConfig.shop_config.jingxuan + 1] = v
            this.UIConfig.shop_config.jingxuanP2 = this.UIConfig.shop_config.jingxuanP2 or {}
            this.UIConfig.shop_config.jingxuanP2[v.P2] = this.UIConfig.shop_config.jingxuanP2[v.P2] or {}
            this.UIConfig.shop_config.jingxuanP2[v.P2][#this.UIConfig.shop_config.jingxuanP2[v.P2] + 1] = v.id
        end
    end
    for k,tbl in pairs(this.UIConfig.shop_config) do
        if type(next(tbl)) == "table" then
            table.sort(tbl,function(a,b) return a.id < b.id end)
        end
    end
    this.UIConfig.box_config = config.box_config
    dump(this.UIConfig,"<color=green>商店系统配置</color>")
end

function M.OnLoginResponse(result)
	if result == 0 then
        --请求服务器数据
        this.queryShopData()
	end
end
function M.OnReConnecteServerSucceed()
end

-- 必定返回一个值，越界就返回数组最后一个值
local get_table_num = function (list, index)
    if type(list) == "table" then
        if index <= #list then
            return list[index]
        else
            return list[#list]
        end
    else
        return list
    end
end

-- 获取商品数据
function M.GetShopItemData(id)
    local cfg = this.UIConfig.shop_map[id]
    local data = {}
    basefunc.merge(cfg, data)
    if data.type == 1 or data.type == 2 then
        if this.m_data.shopData.pt_map and this.m_data.shopData.pt_map[data.id] then
            data.buyNum = this.m_data.shopData.pt_map[data.id].num
            data.buyTime = this.m_data.shopData.pt_map[data.id].time
        else
            data.buyNum = 0
            data.buyTime = 0
        end
        if data.P2 and data.buyNum > 0 and data.buyNum <= #data.P2 then
            data.cd = get_table_num(data.P2, data.buyNum)
        else
            data.cd = 0
        end
    else
        if this.m_data.shopData.mrjx_gm_map[data.id] then
            data.is_buy = true
        else
            data.is_buy = false
        end
    end
    return data
end

function M.CreateJXData()
    local list = {}
    for k,v in pairs(this.UIConfig.shop_config.jingxuanP2) do
        local s = MathExtend.RandomGroup(#v)
        for i = 1, k do
            list[#list + 1] = v[ s[i] ]
        end
    end
    return list
end
function M.GetJXData()
    if not this.m_data.shopData.mrjx_wp_list then
        return
    end

    return this.m_data.shopData.mrjx_wp_list
end
-- 普通商品
function M.GetPTData()
    local list = {}
    for k,v in ipairs(ShopManager.UIConfig.shop_config.currency) do
        list[#list + 1] = v.id
    end
    return list
end
-- 宝箱商品
function M.GetBXData()
    local list = {}
    for k,v in ipairs(ShopManager.UIConfig.shop_config.box) do
        list[#list + 1] = v.id
    end
    return list
end
-- 获取商品刷新时间
function M.GetShopRefreshTime()
    return this.m_data.shopData.mrjx_refresh_time
end

-- 查询商品信息
function M.queryShopData()
    if not IsConnectedServer then
        Event.Brocast("query_shop_data_msg", {result = 1078})
        return
    end

    Network.SendRequest("query_shop_data", nil, "", function (ret)
        dump(ret,"<color=red>queryShopData 商店数据</color>")
        ret.result = nil
        this.m_data.shopData = {}
        this.m_data.shopData.pt_map = {}
        this.m_data.shopData.mrjx_gm_map = {}

        for i,v in ipairs(ret.pt) do
            v.time = tonumber(v.time)
            this.m_data.shopData.pt_map[v.id] = v
        end

        this.m_data.shopData.mrjx_wp_list = ret.mrjx_wp_list
        if TableIsNull(this.m_data.shopData.mrjx_wp_list) then
            local list = M.CreateJXData()
            M.shopSetMrjxWpList(list)
        else
            if os.time() >= tonumber(ret.mrjx_refresh_time) then
                local list = M.CreateJXData()
                M.shopSetMrjxWpList(list)                
            else
                for k,v in ipairs(ret.mrjx_gm_list) do
                    this.m_data.shopData.mrjx_gm_map[v] = true
                end
                this.m_data.shopData.mrjx_refresh_time = tonumber(ret.mrjx_refresh_time)
            end
        end
        Event.Brocast("query_shop_data_msg", {result = 0})
    end)

end

function M.BuyShopByID(id, call)
    local data = M.GetShopItemData(id)
    local pay_assets = {}
    local gain_assets = GameConfigCenter.GetCommonAwardData(data.award_id)

    if data.buy_type == 3 then
        pay_assets[1] = {asset_type="prop_jin_bi", asset_value=data.buy_value}
    elseif data.buy_type == 4 then
        pay_assets[1] = {asset_type="prop_diamond", asset_value=data.buy_value}
    end
    local tt = 1
    if data.type == 3 then
        tt = 2
    end

    local buy_call = function ()
        ShopManager.shopBuy(tt, data.id, pay_assets, gain_assets, function ( data )
            if data.result == 0 then
                Event.Brocast("common_award_panel",gain_assets)
            end
            if call then
                call(data)
            end
        end) 
    end

    if TableIsNull(pay_assets) then
        buy_call()
    else
        if data.buy_type == 3 and data.buy_value > MainModel.UserInfo.Asset.prop_jin_bi then
            HintPanel.Create(1, "购买条件不足")
            return
        end
        if data.buy_type == 4 and data.buy_value > MainModel.UserInfo.Asset.prop_diamond then
            HintPanel.Create(1, "购买条件不足")
            return
        end
        ShopBuyHintPanel.Create(data, buy_call)
    end
end

function M.shopBuy(tp,id,pay_assets,gain_assets,callback)

    if not IsConnectedServer then
        callback({result = 1078})
        return
    end
    local _data = M.GetShopItemData(id)
    Network.SendRequest("shop_buy",
                        {type=tp,id=id,pay_assets=pay_assets,gain_assets=gain_assets},
                        "购买",function (ret)

            dump(ret, "<color=red>AAAAAAAAAAAAA buy</color>")
            if ret.result == 0 then
                task_mgr.TriggerMsg( "get_goods_from_shop_msg" ,  id , _data.type )
                
                for i,v in ipairs(pay_assets or {}) do
                    MainModel.AddAsset(v.asset_type , -v.asset_value)
                end
                for i,v in ipairs(gain_assets or {}) do
                    MainModel.AddAsset(v.asset_type , v.asset_value)
                end
                
                if tp == 1 then
                    if this.m_data.shopData.pt_map[id] then
                        this.m_data.shopData.pt_map[id].num = this.m_data.shopData.pt_map[id].num + 1
                        this.m_data.shopData.pt_map[id].time = os.time()
                    else
                        this.m_data.shopData.pt_map[id] = {id=id, num=1, time=os.time()}
                    end
                elseif tp == 2 then
                    this.m_data.shopData.mrjx_gm_map = this.m_data.shopData.mrjx_gm_map or {}
                    this.m_data.shopData.mrjx_gm_map[id] = true

                end

                Event.Brocast("model_asset_change_msg")
                Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })

            end
            callback({result = ret.result})

    end)

end


function M.shopSetMrjxWpList(mrjx_wp_list)

    if not IsConnectedServer then
        callback({result = 1078})
        return
    end

    this.m_data.shopData.mrjx_wp_list = mrjx_wp_list
    this.m_data.shopData.mrjx_gm_map = {}
    this.m_data.shopData.pt_map[10101] = this.m_data.shopData.pt_map[10101] or {num = 0, time = 0}
    this.m_data.shopData.pt_map[10101].num = 0
    this.m_data.shopData.pt_map[10102] = this.m_data.shopData.pt_map[10102] or {num = 0, time = 0}
    this.m_data.shopData.pt_map[10102].num = 0
    this.m_data.shopData.pt_map[10201] = this.m_data.shopData.pt_map[10201] or {num = 0, time = 0}
    this.m_data.shopData.pt_map[10201].num = 0
    --每日精选刷新时间固定为次日0点
    local cDateCurrectTime = os.date("*t")
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
    this.m_data.shopData.mrjx_refresh_time = cDateTodayTime + 86400
    

    Network.SendRequest("shop_set_mrjx_wp_list",
                        {mrjx_wp_list = mrjx_wp_list,mrjx_refresh_time=this.m_data.shopData.mrjx_refresh_time}
                        ,"同步数据",function (ret)


    end)

    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end