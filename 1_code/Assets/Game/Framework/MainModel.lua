-- 2020年1月5号捕鱼大版本分支
local basefunc = require "Game.Common.basefunc"
require "Game.Framework.ActactManager"

MainModel = {}

-- 时间函数重写
local _client_server_time_diff = 0
local _time_zone_diff = 946656000-os.time({year=2000,month=1,day=1,hour=0,min=0,sec=0})

if not os.old_time then

    os.old_time = os.time
    os.old_date = os.date

    function os.time(_t)
        if _t then
            return os.old_time(_t) + _time_zone_diff
        else
            return os.old_time(_t) + _client_server_time_diff
        end
    end

    function os.date(_fmt,_time)
        _time = _time or os.time()
        return os.old_date(_fmt,_time - _time_zone_diff)
    end
end

local this

--当前位置 nil代表无位置 - 服务器标记所在的位置
local Location

--我所在的位置-客户端所在的位置
local myLocation

--我正在游戏中的位置
local GamingLocation

--在某个游戏大厅
local gameHallLocation

--是否开启公益位置
local isPublicWelfareLocation

--是否登录了
local IsLoged

local RoomCardInfo

--网络延迟
local ping

-- 登陆后不请求资产
local no_send_assets = true

--[[自动登录状态
    第一次到登录页面
    0-ok 要自动登录
    1-other 不要自动登录
]]
local AutoLoginState

--[[个人数据

    UserInfo = {
        name,           --玩家名字，在登录时随user_id一起接收
        user_id,        --玩家唯一标识符，服务器逻辑产生
        login_id,       --登录ID，玩家输入的帐号信息
        head_image,     --玩家头像链接，用于获取玩家微信头像

        diamond $ : integer  		#-- 钻石
        shop_ticket $ : integer 	#-- 抵用券
        cash $ : integer  			#-- 现金
        vip $ : integer  			#-- vip
        million_fuhuo_ticket $ : integer  #--复活卡
        match_ticket $ : integer 	#-- 比赛券
        hammer $ : integer  		#-- 锤子
        bomb $ : integer  			#-- 炸弹
        kiss $ : integer  			#-- 亲吻
        egg $ : integer  			#-- 鸡蛋
        brick $ : integer  			#-- 砖头
        praise $ : integer  		#-- 赞
        
        channel_type,   --渠道

    }

]]
local UserInfo


--[[登陆信息
    login_id
    channel_type
    device_id
    device_os
]]
local LoginInfo

--GPS
local CityName --城市
local Latitude --纬度
local Longitude--经度

---------------------------------------------------私有数据----------------------------------------------------------

--update handle
local UpdateTimer
local UPDATE_INTERVAL = 0.5

-- key: 服务器标记 value:客户端场景
local serverSceneNameMap=
{
}

-- key: 服务器标记 value:客户端场景
-- 服务器上的游戏标记
MainModel.ServerToClientScene = 
{
}

-- key: 客户端场景 value:服务器标记
-- 客户端上的游戏标记
MainModel.ClientToServerScene = 
{
}
-- 服务器的位置，有可能需要调整，比如天府斗地主
local function getServerLocation(location, gameid)
    return location
end

function MainModel.GetServerToClientScene(parm)
    dump(parm, "<color=red>GetServerToClientScene</color>")
    if type(parm) == "table" then
        local gt
        if MainModel.ClientToServerScene[parm.game_type] then
            gt = parm.game_type
        else
            gt = MainModel.ServerToClientScene[parm.game_type]
        end
        return gt
    else
        return MainModel.ServerToClientScene[parm]
    end
end
---------------------------------------------------私有数据----------------------------------------------------------

function MainModel.getServerToClient(location)
    
    if location then
        return serverSceneNameMap[location]
    end

end


local lister
local function AddLister()
    lister={}
    lister["login_response"] = this.OnLogin
    lister["query_asset_response"] = this.on_query_asset
    lister["query_system_variant_data_response"] = this.query_system_variant_data

    lister["will_kick_reason"] = this.will_kick_reason
    lister["notify_asset_change_msg"] = this.OnNotifyAssetChangeMsg
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["ServerConnectException"] = this.OnServerConnectException
    lister["ServerConnectDisconnect"] = this.OnServerConnectDisconnect
    lister["notify_pay_order_msg"] = this.OnNotifyPayOrderMsg
    lister["ping"] = this.OnPing
	lister["callup_service_center"] = this.OnCallupServiceCenter
    --百万大奖赛奖杯
    lister["notify_million_cup_msg"] = this.notify_million_cup_msg
    lister["confirm_million_cup_response"] = this.on_confirm_million_cup_response

    -- 礼包商品
    lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg

    --vip下载ip列表
    lister["OnLoginResponse"] = this.on_LoginResponse
    lister["ExitScene"] = this.OnExitScene

    --创建奖励界面
    lister["common_award_panel"] = this.OnCommonAwardPanel

    -- 强制客户端热更新
    lister["server_change_notify"] = this.on_server_change_notify
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function MainModel.on_server_change_notify(_, data)
    if TableIsNull(data.data) then
        local platform = gameMgr:getMarketPlatform()
        for k,v in ipairs(data.data) do
            if v.platform == platform then
                gameMgr:CheckFilesUpdate("localconfig/" .. v.version .. "/", gameMgr:getLocalPath("localconfig/"), "file_list.txt", v.hash, nil, function(isok)
                    if isok then
                        package.loaded["Game.Framework.GameForceUpdate"] = nil
                        require("Game.Framework.GameForceUpdate")
                        GameForceUpdate.Call(v)
                    end
                end)
                return
            end
        end
    end
end

function MainModel.on_confirm_million_cup_response(_,data)
    Event.Brocast("main_model_confirm_million_cup_response",data.result)
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function MainModel.Init ()

    MainModel.CleanWebViewAllCookies()
    
    MainModel.cur_myLocation = "game_Login"
    MainModel.CleanWebViewAllCookies()
    this = MainModel
    -- 初始化加密字段
    PROTO_TOKEN = nil

    AddLister()

    Screen.sleepTimeout = -1

    this.IsLoged = false
    this.AutoLoginState = this.AutoLoginState or 0

    MainModel.RefreshDeviceInfo()
    dump(this.LoginInfo.device_id, "[Debug] device_id: ")
    dump(gameMgr:getMarketChannel(), "[Debug] market_channel: ")
    dump(gameMgr:getMarketPlatform(), "[Debug] platform: ")

    UpdateTimer = Timer.New(this.Update, UPDATE_INTERVAL, -1, nil, true)
    UpdateTimer:Start()
    --ios订单处理
    IosPayManager.Init()
	--android订单处理
	AndroidPayManager.Init()


    return this
end

function MainModel.RefreshDeviceInfo()
    local deivesInfo = Util.getDeviceInfo()
    this.LoginInfo = 
    {
        device_id = deivesInfo[0],
        device_os = deivesInfo[1],
    }
    if gameRuntimePlatform == "Android" or gameRuntimePlatform == "Ios" then
       this.LoginInfo.device_id = sdkMgr:GetDeviceID()
    end
end

-- 检查是否要自动登录
function MainModel.GetIsAutoLogin()
    if this.AutoLoginState== 0 then
    	if LoginModel.loginData.lastLoginChannel and LoginModel.loginData.lastLoginChannel ~= "youke" then
		return true
	end
    end
    return false
end

function MainModel.OnLogin (_,data )
    dump(data, "<color=red>登录数据</color>")
    if data.result == 0 then
        if os.old_time and data.server_time then
            _client_server_time_diff = tonumber(data.server_time) - os.old_time()
        end
        local instance_id = this.instance_id or 0
	    if instance_id ~= 0 and instance_id ~= data.instance_id then
        		HintPanel.Create(1, "更新完毕，请重启游戏", function ()
        			--UnityEngine.Application.Quit()
    			gameMgr:QuitAll()
        		end)
    		return
    	end
        this.instance_id = data.instance_id
        
        ActactManager.Init({value=data.vit or 20,time=tonumber(data.vit_time) or os.time()})
        local old_asset = nil
        --网络中断后，如果本地有数据优先用本地数据
        if this.UserInfo and this.UserInfo.Asset then
            dump(this.UserInfo.Asset, "<color=red>AAAAAAA 本地数据 assets 资产</color>")
            old_asset = this.UserInfo.Asset
        else
            dump(this.UserInfo, "<color=red>AAAAAAA 本地数据 </color>")
        end
        this.UserInfo = this.UserInfo or {}
        for k,v in pairs(data) do
            if k ~= "asset" then
                this.UserInfo[k] = v
            end
        end
        this.UserInfo.shop_gold_sum = 0
        this.UserInfo.shop_gold_sum = 0
        this.UserInfo.jing_bi = 0
        this.UserInfo.player_asset = nil
        this.UserInfo.GiftShopStatus = {}
        if old_asset then
            this.UserInfo.Asset = old_asset
        else
            this.UserInfo.Asset = {}
            for k,v in ipairs(data.asset) do
                this.UserInfo.Asset[v.asset_type] = tonumber(v.asset_value)
            end
        end
        this.IsLoged = true
        this.LoginInfo.login_id=data.login_id
        this.LoginInfo.channel_type=data.channel_type
        this.LoginInfo.is_test = data.is_test
        this.LoginInfo.xsyd_status = data.xsyd_status or 0
        this.LoginInfo.refresh_token=data.refresh_token
        
        if data.refresh_token then
            local tt = {}
            tt.refresh_token = data.refresh_token
            tt.token = data.refresh_token
        	this.LoginInfo.channel_args = lua2json(tt)
        end
        local channelTbl = LoginModel.GetChannelLuaTable(data.channel_type)
        if channelTbl then
        	this.LoginInfo.openid = channelTbl.openid
        end

        this.Location = getServerLocation(data.location, data.game_id)
        this.game_id = data.game_id

        -- 游戏内数据
        this.UserInfo.GameInfo = {}
        this.UserInfo.game_level = data.game_level
        this.UserInfo.GameInfo.game_level = data.game_level
        this.UserInfo.GameInfo.team_level = data.team_level
        this.UserInfo.GameInfo.health_level = data.health_level
        this.UserInfo.GameInfo.turret_info = data.turret_info
        this.UserInfo.GameInfo.head_info = data.head_info
        this.UserInfo.GameInfo.head_type = MainModel.LoadHeadType()
        this.UserInfo.GameInfo.technology_info = data.technology_info

        if not this.UserInfo.name then
            this.UserInfo.name = ""
        end

    	local player_level = this.UserInfo.player_level or 0
    	if player_level > 0 then
    		gestureMgr:TryAddGesture("GestureLines")
    		-- gestureMgr:TryAddGesture("GestureCircle")
    	end

    else
        this.IsLoged = false
    end

    NetworkManager.reLoginOverTimeCbk = nil

    --重连登录完成
    if NetworkManager.reConnectServerState == 2 then
        NetworkManager.reConnectServerState = 0

        print("<color=blue> ReConnecte Succeed </color>")

        NetJH.RemoveAll()
        --重连后登录完成
        if data.result == 0 then
            this.UserInfo.is_login = 1
            if no_send_assets then
                MainModel.finish_login_flow()
            else
                MainModel.AssetClear()
                this.query_asset_index = 1
                this.login_query_map = {query_asset = 1}
                if this.is_on_query_asset then
                    this.reset_query_asset = true
                else
                    this.is_on_query_asset = true
                    Network.SendRequest("query_asset", {index = this.query_asset_index})
                end
                NetJH.Create("正在登陆", "login")
            end
        else
            Event.Brocast("ReConnecteServerResponse",data.result)
        end
    else
        NetJH.RemoveAll()
        --正常的登陆完成
        if data.result == 0 then
            this.UserInfo.is_login = 2
            LoginLogic.SetGoodIP(AppConst.SocketAddress)
            TalkingDataManager.OnLogin()
            if no_send_assets then
                MainModel.finish_login_flow()
            else
                MainModel.AssetClear()
                this.query_asset_index = 1
                this.login_query_map = {query_asset = 1}
                if this.is_on_query_asset then
                    this.reset_query_asset = true
                else
                    this.is_on_query_asset = true
                    Network.SendRequest("query_asset", {index = this.query_asset_index})
                end
                NetJH.Create("正在登陆", "login")
            end
        else
            Event.Brocast("Ext_OnLoginResponse", data.result)
        end
    end
end

--[[
----------------------
    资产相关
----------------------
--]]
-- 清除资产
function MainModel.AssetClear()
    this.UserInfo.Asset = {}
end
-- 获取资产数量
function MainModel.GetAssetValueByKey(key)
    if not this.UserInfo or not this.UserInfo.Asset then
        return 0
    end
    if this.UserInfo.Asset[key] then
        return this.UserInfo.Asset[key]
    end
    return 0
end

function MainModel.AddAsset(type,value)
    this.UserInfo.Asset[type] = (this.UserInfo.Asset[type] or 0) + value
    Event.Brocast("model_asset_change_msg")
end


function MainModel.TestAddAsset(asset)
    if not IsConnectedServer then
        return
    end

    Network.SendRequest("test_add_assets",{asset = asset},"同步数据")
    for i,v in ipairs(asset) do
        this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) + v.asset_value
    end

    Event.Brocast("model_asset_change_msg")

end


function MainModel.UpgradeHero(hero,asset,callback)
    if not IsConnectedServer then
        callback({result = 1078})
    end

    Network.SendRequest("upgrade_hero",{hero = hero,asset = asset},"同步数据",function (ret)
        if ret.result == 0 then
            for i,v in ipairs(asset) do
                this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) - v.asset_value
            end
            Event.Brocast("model_asset_change_msg")

            local tif = nil
            for i,v in ipairs(this.UserInfo.GameInfo.turret_info) do
                if v.type == hero then
                    tif = v
                    break
                end
            end
            if not tif then
                tif = {
                    type = hero,
                    star = 0,
                    level = 0,
                }
                table.insert(this.UserInfo.GameInfo.turret_info,tif)
            end

            tif.level = tif.level + 1

        end
        callback({result = ret.result})
    end)

end

function MainModel.QueryHeroInfo()
    return this.UserInfo.GameInfo.turret_info
end

function MainModel.UpgradeHead(head,asset,callback)
    if not IsConnectedServer then
        callback({result = 1078})
        return
    end

    Network.SendRequest("upgrade_head",{head = head,asset = asset},"同步数据",function (ret)
        if ret.result == 0 then
            for i,v in ipairs(asset) do
                this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) - v.asset_value
            end

            local tif = nil
            for i,v in ipairs(this.UserInfo.GameInfo.head_info) do
                if v.type == head then
                    tif = v
                    break
                end
            end
            if not tif then
                tif = {
                    type = head,
                    level = 0,
                }
                table.insert(this.UserInfo.GameInfo.head_info,tif)
            end

            tif.level = tif.level + 1
            Event.Brocast("UpgradeHead",{head = tif})
            Event.Brocast("model_asset_change_msg")
            task_mgr.TriggerMsg( "upgrade_head_msg"  )
        end
        callback({result = ret.result})
    end)

end

function MainModel.QueryHeadInfo()
    return this.UserInfo.GameInfo.head_info
end

function MainModel.SelectHeadType(head_type)
    if not head_type then return end
    this.UserInfo.GameInfo.head_type = head_type
    MainModel.SaveHeadType()
    Event.Brocast("SelectHead",{head_type = head_type})
end

function MainModel.SaveHeadType()
    UnityEngine.PlayerPrefs.SetInt("headType" .. MainModel.UserInfo.user_id,this.UserInfo.GameInfo.head_type)
end

function MainModel.LoadHeadType()
    return UnityEngine.PlayerPrefs.GetInt("headType" .. MainModel.UserInfo.user_id,1)
end

function MainModel.GetHeadType()
    return this.UserInfo.GameInfo.head_type
end

function MainModel.GetHeadLevel(head_type)
    head_type = head_type or this.UserInfo.GameInfo.head_type
    for k, v in pairs(this.UserInfo.GameInfo.head_info) do
        if v.type == head_type then
            return v.level
        end
    end
    return 0
end


function MainModel.QueryTechnologyInfo()
    return this.UserInfo.GameInfo.technology_info
end

function MainModel.UpgradeTechnology(id,asset,callback)
    
    for i,v in ipairs(this.UserInfo.GameInfo.technology_info) do
        if v == id then
            callback({result = 1002})
            return 
        end
    end

    if not IsConnectedServer then
        callback({result = 1078})
        return
    end

    Network.SendRequest("upgrade_technology",{id = id,asset = asset},"同步数据",function (ret)
        if ret.result == 0 then
            for i,v in ipairs(asset) do
                this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) - v.asset_value
            end
            Event.Brocast("model_asset_change_msg")
            
            table.insert(this.UserInfo.GameInfo.technology_info,id)

        end
        callback({result = ret.result})
    end)

end

function MainModel.QueryTeamLevel()
    return this.UserInfo.GameInfo.team_level
end

function MainModel.QueryHealthLevel()
    return this.UserInfo.GameInfo.health_level
end


function MainModel.UpgradeTeamLevel(asset,callback)
    
    if not IsConnectedServer then
        callback({result = 1078})
        return
    end

    Network.SendRequest("upgrade_team",{asset = asset},"同步数据",function (ret)
        dump(ret,"<color=yellow>队伍数升级</color>")
        if ret.result == 0 then
            for i,v in ipairs(asset) do
                this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) - v.asset_value
            end
            
            this.UserInfo.GameInfo.team_level = this.UserInfo.GameInfo.team_level + 1

            Event.Brocast("model_asset_change_msg")
        end
        callback({result = ret.result})
    end)

end

function MainModel.UpgradeHealthLevel(asset,callback)
    
    if not IsConnectedServer then
        callback({result = 1078})
        return
    end

    Network.SendRequest("upgrade_health",{asset = asset},"同步数据",function (ret)
        dump(ret,"<color=yellow>血量数升级</color>")
        if ret.result == 0 then
            for i,v in ipairs(asset) do
                this.UserInfo.Asset[v.asset_type] = (this.UserInfo.Asset[v.asset_type] or 0) - v.asset_value
            end
            
            this.UserInfo.GameInfo.health_level = this.UserInfo.GameInfo.health_level + 1

            Event.Brocast("model_asset_change_msg")
        end
        callback({result = ret.result})
    end)

end

-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------
function MainModel.OnNotifyAssetChangeMsg(proto_name,data)
    dump(data, "<color=white>资产改变改变</color>")

    this.UserInfo = this.UserInfo or {}
    this.UserInfo.Asset = this.UserInfo.Asset or {}

    --改变的资产处理
    local change_assets = {}
    --改变的Obj资产列表
    local obj_assets_list = {}
    --改变的prop资产列表
    local prop_assets_list = {}

    --改变的资产 获得的
    local change_assets_get = {}
    if data.change_asset then
        local item
        for k,v in pairs(data.change_asset) do        
            local is_add_bag = false
            if basefunc.is_object_asset(v.asset_type) then
                if not v.attribute then
                    this.UserInfo.Asset[v.asset_value] = nil
                    obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="del"}
                else
                    local change_attribute = false -- 只是修改属性
                    if this.UserInfo.Asset[v.asset_value] then
                        change_attribute = true
                        obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="chg"}
                    else
                        obj_assets_list[#obj_assets_list + 1] = {key=v.asset_type, id=v.asset_value, type="add"}
                    end
                    local vv = {}
                    this.UserInfo.Asset[v.asset_value] = vv
                    vv.id = v.asset_value
                    vv.asset_type = v.asset_type
                    for k1,v1 in ipairs(v.attribute) do
                        if tonumber(v1.value) then
                            vv[v1.name] = tonumber(v1.value)
                        else
                            vv[v1.name] = v1.value
                        end
                    end
                    if not change_attribute then
                        change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = 1}
                        change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = 1}
                    end
                end
            else
                if tonumber(v.asset_value) then
                    local num = tonumber(v.asset_value)
                    if not this.UserInfo.Asset[v.asset_type] then
                        this.UserInfo.Asset[v.asset_type] = 0
                    end
                    this.UserInfo.Asset[v.asset_type] = this.UserInfo.Asset[v.asset_type] + num

                    change_assets[#change_assets + 1] = {asset_type = v.asset_type, value = num}
                    if num > 0 then
                        change_assets_get[#change_assets_get + 1] = {asset_type = v.asset_type, value = num}
                        prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="add"}
                    else
                        if this.UserInfo.Asset[v.asset_type] > 0 then
                            prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="chg"}
                        else
                            prop_assets_list[#prop_assets_list + 1] = {key=v.asset_type, id=v.asset_type, type="del"}
                        end
                    end
                else
                    dump(v, "<color=red>非限时道具asset_value不能转成number</color>")
                end 
            end
        end
    end

    Event.Brocast("AssetChange", {data = change_assets_get, change_type = data.type, 
                                  prop_assets_list = prop_assets_list, obj_assets_list = obj_assets_list})

    if MainModel.IsShowAward(data.type) and #change_assets_get > 0 then
        Event.Brocast("AssetGet",{data = change_assets_get, change_type = data.type})
    end

    MainModel.check_asset_change_no(data.no)
end
function MainModel.IsShowAward(a_type)
    return false
end

function MainModel.on_query_asset(_, data)
    dump(data, "<color=red>on_query_asset</color>")
    if not TableIsNull(data.player_asset) then
        for k,v in ipairs(data.player_asset) do
            if not v.attribute then
                this.UserInfo.Asset[v.asset_type] = tonumber(v.asset_value)
            else
                local vv = {}
                this.UserInfo.Asset[v.asset_value] = vv
                vv.id = v.asset_value
                vv.asset_type = v.asset_type
                for k1,v1 in pairs(v.attribute) do
                    if tonumber(v1.value) then
                        vv[v1.name] = tonumber(v1.value)
                    else
                        vv[v1.name] = v1.value
                    end
                end
            end
        end
    end

    if this.reset_query_asset then
        MainModel.AssetClear()
        this.query_asset_index = 1
        this.reset_query_asset = false

        Network.SendRequest("query_asset", {index = this.query_asset_index})
        return
    end

    MainModel.check_asset_change_no(data.no)

    if not data.player_asset or (#data.player_asset < 100 and #data.player_asset >= 0) then
        this.is_on_query_asset = false
        Event.Brocast("AssetChange", {data={}})
        MainModel.finish_login_query("query_asset")
    else
        this.query_asset_index = this.query_asset_index + 1
        Network.SendRequest("query_asset", {index = this.query_asset_index})
    end
end
function MainModel.query_system_variant_data(_,data)
    MainModel.finish_login_query("query_system_variant_data")
    Event.Brocast("model_query_system_variant_data", "query_system_variant_data", data)
end
function MainModel.finish_login_query(key)
    this.login_query_map[key] = nil

    if not this.login_query_map or not next(this.login_query_map) then
        MainModel.finish_login_flow()
    end
end
-- 完成登录流程
function MainModel.finish_login_flow()
    NetJH.RemoveById("login")

    -- 启动网络消息发送管理器
    Event.Brocast("main_model_finish_login_msg")

    if this.UserInfo.is_login then
        if this.UserInfo.is_login == 1 then
            Event.Brocast("ReConnecteServerResponse", 0)
        elseif this.UserInfo.is_login == 2 then
            Event.Brocast("Ext_OnLoginResponse", 0)
        end
    end

    this.UserInfo.is_login = 0
end

------------------------ping------------------
function MainModel.OnPing(ping)
    LuaHelper.OnPing(ping)
end

function MainModel.OnCallupServiceCenter(phoneNumber)
	print("OnCallupServiceCenter:" .. phoneNumber)
	if gameMgr:getMarketChannel() == "hw_wqp" then
		UniClipboard.SetText(phoneNumber)
		LittleTips.Create("已复制客服电话:" .. phoneNumber)
	else
		sdkMgr:CallUp(phoneNumber)
	end
end

-----------------------------------------被踢下线-------------------------------------------
function MainModel.will_kick_reason(proto_name,data)

    if data.reason == "logout" then
        --由于后台很久了，服务器已经把代理杀了 将会自动重连登陆
        print("<color=red> server wait over time  </color>")

    elseif data.reason == "relogin" then
        MainModel.IsLoged = false
        --有人用我的login_id在其他地方登陆
        print("<color=red> other is logining </color>")

        HintPanel.Create(1,"您的账号已经在其他设备登陆",function ()
            LoginModel.ClearLoginData("dh")

            MainLogic.Exit()
            networkMgr:Init()
            Network.Start()
            MainLogic.Init()
            
        end)

    else

        print("<color=red> error </color>")
        dump(data,proto_name)

    end

end

-----------------------------------------百万大奖赛奖杯------------------
function MainModel.notify_million_cup_msg (proto_name,data)
    this.UserInfo.million_cup_status = data.million_cup_status
    if this.UserInfo.million_cup_status then
        Event.Brocast("on_notify_million_cup_msg")
    end
end

function MainModel.check_asset_change_no(_no)
    if _no and this.UserInfo.asset_change_no then
        local no = this.UserInfo.asset_change_no + 1
        if no > 65000 then
            no = 1
        end
        if _no ~= no then
            this.UserInfo.asset_change_no = nil
            if this.is_on_query_asset then
                this.reset_query_asset = true
            else
                this.is_on_query_asset = true
                MainModel.AssetClear()
                this.query_asset_index = 1

                Network.SendRequest("query_asset", {index = this.query_asset_index}, "请求背包数据")
            end
        end
    end
    this.UserInfo.asset_change_no = no
end

function MainModel.GetHBValue()
    if MainModel.UserInfo.shop_gold_sum then
        return MainModel.UserInfo.shop_gold_sum
    else
        return 0
    end
end

-- 获取区域
function MainModel.GetAreaID()
    MainModel.UserInfo.AreaID = 1-- 成都
    return MainModel.UserInfo.AreaID
end
-- 设置区域
function MainModel.SetAreaID(area)
    MainModel.UserInfo.AreaID = area
    Event.Brocast("update_player_area_id")
end

-- 返回收货地址
function MainModel.GetAddress()
    if MainModel.UserInfo.shipping_address and MainModel.UserInfo.shipping_address.address then
        return StringHelper.Split(MainModel.UserInfo.shipping_address.address, "#")
    end
end

-- 返回收货地址
function MainModel.CacheShop()
    local pp = GameObject.Find("WebView__shop_")
    if IsEquals(pp) then
        return
    end
    local shop_url
    Network.SendRequest(
        "create_shoping_token",
        {geturl = shop_url and "n" or "y"},
        function(_data)
            if _data.result == 0 then
                shop_url = _data.url or shop_url
                if not shop_url then return end
                local url = string.gsub(shop_url, "@token@", _data.token)
                --UniWebViewMgr.CreateUniWebView("shop")
                --UniWebViewMgr.SetWebContentsDebuggingEnabled("shop")
                -- print("gameWeb:OnShopClick() : ", url)
                -- gameWeb:OnShopClick(url, true)
				-- gameWeb:EvaluateJS("_shop_", "webviewWillAppear()")

                -- local webObj = GameObject.Find("WebView__shop_")
                -- if IsEquals(webObj) then
                --     print("<color=red>EEEEEEEEEEEEEEEEEEEEE</color>")
                --     dump(webObj)
                --     GameObject.DontDestroyOnLoad(webObj)
                -- end
            else
                print("<color=red>result = " .. _data.result .. "</color>")
            end
        end
    )
end
-- 是否需要绑定
function MainModel.IsNeedBindPhone()
    if MainModel.UserInfo then
        local is_not_bind = (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
        return is_not_bind
    end
    return false
end
function MainModel.OpenDH(parm)
    if GameGlobalOnOff.InternalTest then
        HintPanel.Create(1, "测试期间，暂不开放")
        return
    end

    local can_do = false
    if MainModel.GetHBValue() >= 1000 then
        if GameGlobalOnOff.BindingPhone and MainModel.IsNeedBindPhone() then
            local b = HintPanel.Create(1,"为了您的账号安全,请进行手机绑定，绑定后可进行商城兑换",function ()
                AwardBindingPhonePanel.Create()
            end)
            b:SetButtonText(nil,"前往绑定")
        else
            can_do = true
        end
    else
        can_do = true
    end

    if can_do then
        Network.SendRequest("create_shoping_token", {geturl=shop_url and "n" or "y"},function(_data)
            if _data.result == 0 then
                if MainModel.GetHBValue() >= 10 then
                    PlayerPrefs.SetString("HallDHHintTime" .. MainModel.UserInfo.user_id, os.time())
                end
                shop_url = _data.url or shop_url
                if not shop_url then
                    HintPanel.Create(1, "测试服没有兑换商城")
                    return
                end

                local url = string.gsub(shop_url,"@token@",_data.token)
                if parm then
                    url = url .. parm
                end
                dump(url, "<color=white> <<<<<<<< OpenDH >>>>>>>> </color>")
                UniWebViewMgr.OpenUrl("shop",url)
                -- if parm then
                --     gameWeb:OnShopClickLoadURL(url)
                -- else
                --     gameWeb:OnShopClickLoadURL(url)
                -- end
				-- gameWe("_shop_", "webviewWillAppear()")
            end
        end )
    end
end
-- 客服反馈
function MainModel.OpenKFFK()
    local url = string.format("http://kfapp.game3396.com/jyhd/hlby/#/userfeedback?playerid=%s", MainModel.UserInfo.user_id)
    if MainModel.GetServerName() == SERVER_TYPE.CS then
        url = string.format("http://testkfapp.game3396.com/jyhd/hlby/#/userfeedback?playerid=%s", MainModel.UserInfo.user_id)
    end
    if AppDefine.IsEDITOR() then
		Application.OpenURL(url);
		return
	end
    dump(url, "<color=white> <<<<<<<< OpenDH >>>>>>>> </color>")
    UniWebViewMgr.OpenUrl("kffk",url)
    --gameWeb:OnShopClickLoadURL(url)
	--gameWeb:EvaluateJS("_shop_", "webviewWillAppear()")
end

function MainModel.GetShopingConfigTge(_type)
    if not _type then
        return shoping_config.tge
    end

    if shoping_config.tge then
        for k,v in pairs(shoping_config.tge) do
            if _type == v.type then
                return v
            end
        end
    end

    return nil
end

function MainModel.GetShopingConfig(_type, id, _item_type)
    if not _type then
        return shoping_config
    elseif not id then
        if shoping_config then
            return shoping_config[_type]
        end
    end

    if shoping_config and shoping_config[_type] then
        for i,v in ipairs(shoping_config[_type]) do
            if _type ~= GOODS_TYPE.item then
                if id == v.id then
                    return v
                end
            else
                if id == v.id and _item_type == v.type then
                    return v
                end
            end
        end
    end
    return nil
end

-- 获取礼包的status
function MainModel.GetItemStatus(type, id, itemType)
    local cfg = MainModel.GetShopingConfig(type, id, itemType)
    if not (MainModel.UserInfo.GiftShopStatus[id] and cfg) then
        log("<color=red>--->>>Make sure item exist in config file! ID:" .. id .. "</color>")
        return -1
    else
        return MainModel.UserInfo.GiftShopStatus[id].status
    end
end
-- 设置礼包的status
function MainModel.SetItemStatus(id, status)
    if MainModel.UserInfo.GiftShopStatus[id] then
        MainModel.UserInfo.GiftShopStatus[id].status = status
    end
end
-- 礼包数据改变
function MainModel.on_gift_bag_status_change_msg(pName, data)
    if not this.UserInfo or not this.UserInfo.GiftShopStatus then
        return
    end
    MainModel.SetGiftData(data)
    Event.Brocast("main_change_gift_bag_data_msg", data.gift_bag_id)
end

function MainModel.SetGiftData(data)
    local id = data.gift_bag_id
    if not this.UserInfo.GiftShopStatus[id] then
        this.UserInfo.GiftShopStatus[id] = {}
    end
    this.UserInfo.GiftShopStatus[id].status = data.status
    this.UserInfo.GiftShopStatus[id].permit_time = data.permit_time --权限持续时间
    this.UserInfo.GiftShopStatus[id].permit_start_time = data.permit_start_time --权限开始时间
    this.UserInfo.GiftShopStatus[id].time = data.time --上次购买时间
    this.UserInfo.GiftShopStatus[id].remain_time = data.remain_time --剩余数量
end
-- 是否需要请求剩余次数
function MainModel.IsNeedQueryRemainTimeByShopID(id)
    if not this.UserInfo or not this.UserInfo.GiftShopStatus then
        return true
    end
    if not this.UserInfo.GiftShopStatus[id] or not this.UserInfo.GiftShopStatus[id].remain_time then
        return true
    end
    return false
end

-- 获取礼包数据
function MainModel.GetGiftDataByID(id)
    if MainModel.UserInfo and MainModel.UserInfo.GiftShopStatus and MainModel.UserInfo.GiftShopStatus[id] then
        return MainModel.UserInfo.GiftShopStatus[id]
    end
end
-- 获取礼包剩余次数
function MainModel.GetRemainTimeByShopID(id)
    if not this.UserInfo or not this.UserInfo.GiftShopStatus then
        return 0
    end
    if not this.UserInfo.GiftShopStatus[id] then
        this.UserInfo.GiftShopStatus[id] = {}
    end
    return this.UserInfo.GiftShopStatus[id].remain_time or 0
end
-- 获取礼包结束时间
function MainModel.GetGiftEndTimeByID(id)
    local data = MainModel.GetGiftDataByID(id)
    if data then
        local permit_time = tonumber(data.permit_time) or 0
        local permit_start_time = tonumber(data.permit_start_time) or 0
        local permit_end_time = permit_time + permit_start_time
        return math.max( 0, permit_end_time)
    else
        return 0
    end
end
-- 礼包能不能购买
function MainModel.IsCanBuyGiftByID(id)
    local data = MainModel.GetGiftDataByID(id)
    if data then
        local permit_time = tonumber(data.permit_time) or 0
        local permit_start_time = tonumber(data.permit_start_time) or 0
        local permit_end_time = permit_time + permit_start_time
        local cur_t = os.time()
        if data.status == 1 and (permit_start_time == 0 or (cur_t <= permit_end_time) ) then  --(permit_start_time - 60) <= cur_t   权限礼包展示开始时间
            return true
        end
    end
end
-- 礼包是否购买过 true:买过  false:没有买过
function MainModel.IsHadBuyGiftByID(id)
    local data = MainModel.GetGiftDataByID(id)
    if data then
        local permit_time = tonumber(data.permit_time) or 0
        local permit_start_time = tonumber(data.permit_start_time) or 0
        local permit_end_time = permit_time + permit_start_time
        local cur_t = os.time()
        if data.status == 1 and (permit_start_time == 0 or (cur_t <= permit_end_time) ) then  --(permit_start_time - 60) <= cur_t   权限礼包展示开始时间
            return false
        end
        if data.status == 0 and data.remain_time > 0 then
            return false
        end
        return true
    end
    return true
end
-- 查询礼包商品显示与否
function MainModel.GetGiftShopShowByID(id)
    if not id then
        return false
    end
    -- 不存在 或者存在但是on_off=0
    local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
    if not config or config.on_off == 0 then
        return false
    end
    if not MainModel.UserInfo or not MainModel.UserInfo.GiftShopStatus then return false end
    local status
    if not MainModel.UserInfo.GiftShopStatus[id] then
        status = 0
    else
        status = MainModel.UserInfo.GiftShopStatus[id].status
    end
    local b1 = MathExtend.isTimeValidity(config.start_time, config.end_time)
    if b1 then
        if config.buy_limt == 0 then
            if status == 0 then
                return false
            else
                return true
            end
        elseif config.buy_limt == 1 then
            return true
        else
            return true
        end
    else
        return false
    end
end

-- 查询礼包商品状态
function MainModel.GetGiftShopStatusByID(id)
    if not id then
        return 0
    end
    -- 不存在 或者存在但是on_off=0
    if not MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id) or MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id).on_off == 0 then
        return 0
    end
    if not MainModel.UserInfo or not MainModel.UserInfo.GiftShopStatus or not MainModel.UserInfo.GiftShopStatus[id] then
        return 0
    else
        return MainModel.UserInfo.GiftShopStatus[id].status
    end
end

function MainModel.FinishGiftShopByID(id)
    if not MainModel.UserInfo.GiftShopStatus[id] then
        MainModel.UserInfo.GiftShopStatus[id] = {}
    end
    --购买后份数减少
    if MainModel.UserInfo.GiftShopStatus[id].remain_time then
        MainModel.UserInfo.GiftShopStatus[id].remain_time = MainModel.UserInfo.GiftShopStatus[id].remain_time - 1
        if MainModel.UserInfo.GiftShopStatus[id].remain_time <= 0 then
            MainModel.UserInfo.GiftShopStatus[id].status = 0
        end
    else
        MainModel.UserInfo.GiftShopStatus[id].status = 0
    end
    
    MainModel.UserInfo.GiftShopStatus[id].time = os.time()
    Event.Brocast("finish_gift_shop_shopid_"..id)
    Event.Brocast("finish_gift_shop", id)
end

-- 查询礼包商品数量
function MainModel.GetGiftShopNumByID(id)
    if not MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id) then
        if not MainModel.UserInfo.GiftShopStatus[id] then
            MainModel.UserInfo.GiftShopStatus[id] = {}
        end
        MainModel.UserInfo.GiftShopStatus[id].count = 0
        Event.Brocast("model_query_gift_bag_num_shopid_"..id, {shopid=id, count=0})        
    end

    Network.SendRequest("query_gift_bag_num", {gift_bag_id=id})
end

function MainModel.on_query_gift_bag_num_response(_,data)
    dump(data, "<color=red>on_query_gift_bag_num_response</color>")
    if data.result==1008 then 
        print("<color=red> 获取礼包数量返回码 1008<color>")
            return 
    end 
    if not data.result or data.result ~= 0 then
        return
    end
    if not MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] then
        MainModel.UserInfo.GiftShopStatus[data.gift_bag_id] = {}
    end
    MainModel.UserInfo.GiftShopStatus[data.gift_bag_id].count = data.num
    Event.Brocast("model_query_gift_bag_num_shopid_"..data.gift_bag_id, {shopid=data.gift_bag_id, count=data.num})    
end

--查询常规礼包状态 v.Lua：礼包对应的脚本,里面必须实现Create方法
function MainModel.GetConventionalGift()
    local gift_cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag)
    local cg_gift = {}
    for k,v in pairs(gift_cfg) do
        if v.on_off and v.on_off == 1 and v.is_cg and v.is_cg == 1 and v.start_time and os.time() >= v.start_time and v.end_time and os.time() <= v.end_time then
            table.insert( cg_gift,v)
        end
    end
    if TableIsNull(cg_gift) then
        return
    end
    table.sort(
        cg_gift,
        function(a, b)
            if a.cg_order == b.cg_order then
                return a.id < b.id
            else
                return a.cg_order < b.cg_order
            end
        end
    )
    local gift_data = {}
    for i,v in ipairs(cg_gift) do
        local state = MainModel.GetGiftShopStatusByID(v.id)
        if state then
            table.insert(gift_data,{state = state,config = v})
        end
    end
    return gift_data
end

-----------------------------------------资产改变-------------------------------------------
-----------------------------------------资产改变-------------------------------------------


-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------
function MainModel.OnNotifyPayOrderMsg(proto_name,msg)
    Event.Brocast("ReceivePayOrderMsg",msg)
    if msg.result == 0 then
        MainModel.FinishGiftShopByID(msg.goods_id)

		--向sdk发送支付结果
		--目前只有android 拼多多用到
		if gameRuntimePlatform == "Android" then
			local pay_channel_type = MainModel.pay_channel_type or ""
			if pay_channel_type ~= "" and gameMgr:getMarketChannel() == "pdd" then
					local lua_tbl = {}
					--pay
					lua_tbl.msg = 1

					--channel
					if pay_channel_type == "weixin" then
						lua_tbl.payWay = 0
					else
						lua_tbl.payWay = 1
					end

					--money
					lua_tbl.payNum = msg.money or 0

					dump(lua_tbl, "SendToSDKMessage")

					sdkMgr:SendToSDKMessage(lua2json(lua_tbl))
			end
		end
    end
end
-----------------------------------------支付-------------------------------------------
-----------------------------------------支付-------------------------------------------

-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.OnForeGround ()
    Event.Brocast("EnterForeGround")
    local deeplink = sdkMgr:GetDeeplink()
    if deeplink and deeplink ~= "" then
        print("<color=red>deeplink = " .. deeplink .. "</color>")
	    MainLogic.HandleOpenURL(deeplink)
    end
end
function MainModel.OnBackGround ()
    Event.Brocast("EnterBackGround")
end


-----------------------------------------前后台-------------------------------------------
-----------------------------------------前后台-------------------------------------------

function MainModel.Update ()
    if MainModel.UserInfo and MainModel.UserInfo.first_login_time and MainModel.UserInfo.ui_config_id and MainModel.UserInfo.ui_config_id == 2 then
        local c_t = os.time()
        if c_t > tonumber(MainModel.UserInfo.first_login_time) + 7 * 86400 then
            MainModel.UserInfo.ui_config_id = 1
            Event.Brocast("player_new_change_to_old")
        end
    end
end

function MainModel.Exit ()
    if this then
        UpdateTimer:Stop()

        RemoveLister()

        this.Location = nil
        this.IsLoged = nil
        this.UserInfo = nil
        this.LoginInfo = nil
        this.RoomCardInfo = nil
        this = nil

        IosPayManager.Exit()
		AndroidPayManager.Exit()
    end
    
end

function MainModel.OnGestureCircle()
    Event.Brocast("GMPanel")
end
function MainModel.OnGestureLines()
    Event.Brocast("GMPanel")
end

function MainModel.GetMarketChannel()
    if MainModel.UserInfo and MainModel.UserInfo.market_channel then
        return MainModel.UserInfo.market_channel
    end
    return "normal"
end

function MainModel.FirstLoginTime()
    if MainModel.UserInfo and MainModel.UserInfo.first_login_time then
        return tonumber(MainModel.UserInfo.first_login_time)
    end
    return os.time()
end

function MainModel.on_LoginResponse(result)
    if result ~= 0 then return end
end

function MainModel.OnExitScene()
    MainModel.asset_change_list = {}
end

local function ClearDir(dir)
	if not Directory.Exists(dir) then return end

	local files = Directory.GetFiles(dir)
	for i = 0, files.Length - 1 do
		if not string.find(files[i], "com.android.opengl.shaders_cache") then
			print("delete file:" .. files[i])
			File.Delete(files[i])
		end
	end

	local dirs = Directory.GetDirectories(dir)
	for i = 0, dirs.Length - 1 do
		Directory.Delete(dirs[i],true)
	end
end
local package_table = {
    normal = "com.sesx.byydtcs",
}
function MainModel.CleanWebViewAllCookies()
    if gameRuntimePlatform ~= "Android" then return end
    if PlayerPrefs.GetInt("Clean_WebView_Cookies", 0) == 0 then
        local platform = gameMgr:getMarketPlatform()
        local package_name = package_table[platform]
        if not package_name then return end
        local dir = "/data/data/" .. package_name
        if Directory.Exists(dir) then
			local cache = dir .. "/" .. "cache"
			if Directory.Exists(cache) then
				ClearDir(cache)
			end

			local databases = dir .. "/" .. "databases"
			if Directory.Exists(databases) then
				print("delete dir:" .. databases)
				Directory.Delete(databases,true)
			end
        end
        PlayerPrefs.SetInt("Clean_WebView_Cookies", 1)
    end
end

function MainModel.OnCommonAwardPanel(data)
    CommonAwardPrefab.Create(data)
end