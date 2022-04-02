--Author:fk 

local basefunc = require "Game.Common.basefunc"
LoginHelper = {}
local M = LoginHelper

--登录渠道类型
M.ChannelType = {
    youke = "youke",
    wechat = "wechat",
    phone = "phone",
    robot = "robot",
    phone_vcode = "phone_vcode",

}

--登录渠道sdk
M.ChannelSdk = {
    -- youke = LoginYoukeSDK,
    -- wechat = LoginWechatSDK,
}


--登录相关>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local loginModel 
local this 
local lister
local connectTimer
local status
local curChannel 

local connectTimeDelay = 3 --每次发起重连的时间间隔
local connectMaxTime = 3 --发起连接的最大次数
local connectCurTime = 0 --当前发起次数
--[[登录菊花的超时
    如果发起了登录请求，很久都没有回应，则应该进行清理操作
]]
local sendLoginRequestOverTime = 20
local sendLoginRequestOverTimer
local setSendLoginOverTimeCBK


local AddLister = function()
    lister = {}
    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResult
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local RemoveLister = function()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

function M.Init()
    M.Exit()
    this = M
    AddLister()
    loginModel = LoginModel.Init()
    return this
end

function M.Exit()
    if this then
        status = nil
        curChannel = nil
        LoginLogic.SetGoodIP("")
        loginModel.Exit()
        RemoveLister()
        this = nil
    end
end

-- 登录完成，逻辑处理
function M.OnLoginResult(result)
    status = 3
    if result == 0 then
        status = 0
        --go to hall
        NetJH.RemoveById(1)
        LoginLogic.Exit()
        MainLogic.GotoScene(GameSceneManager.EnterFirstScene)
        Event.Brocast("bsds_send_power",{key = "login_succes"})
    elseif result == 2153 or result == 2155 or result == 2156 or (result == 2150 and curChannel == "wechat") then
        if wechatErrorStatus == 0 then
            LoginModel.ClearChannelData("wechat")
            wechatErrorStatus = 1

            --等一帧再执行，等待消息分发出去，状态正确
            coroutine.start(
                function()
                    Yield(0)
                    this.Login("wechat")
                end
            )
        else
            HintPanel.ErrorMsg(result)
        end
    elseif result == 2150 then
        print("login id is error please clear login id data!!!")
        HintPanel.ErrorMsg(result)
    else
        print("login error : ", result)
        HintPanel.ErrorMsg(result)
    end

    -- 手机登录失败后清除数据
    if result ~= 0 then
        LoginModel.ClearLoginData("dlbc", LoginModel.loginData.cur_channel)
        if curChannel == "phone" then
            status = nil
        end
        this.CancelLogin()
    end
end

function M.BeginLogin(_type,loginId,refresh_token,_sms_vcode,appid)
    -- 更新设备信息
    MainModel.RefreshDeviceInfo()
    loginModel.loginData.device_id = MainModel.LoginInfo.device_id
    loginModel.loginData.device_os = MainModel.LoginInfo.device_os

    -- Ios14以及以上引导设置
    local os = string.gsub(MainModel.LoginInfo.device_os, "%s+", "")
    os = string.lower(os)
    if not MainModel.is_off_guide_set and gameRuntimePlatform == "Ios" 
        and (not MainModel.LoginInfo.device_id or MainModel.LoginInfo.device_id == "")
        and (MainModel.LoginInfo.device_os and string.find(os, "ios14")) then
            MainModel.is_off_guide_set = true
            HintPanel.Create(1, "请在设置-隐私-Tracking中允许App请求跟踪", function ()
                sdkMgr:GotoSetScene("set_device_id")
            end)
            NetJH.RemoveAll()
            status = nil
            return
    end
    
    PROTO_TOKEN = nil
    print("<color=white>curChannel</color>", _type)
    ---通过传递的参数 进行选择方法
    if _type and M[_type] then
        M[_type](loginId,refresh_token,_sms_vcode,appid)
    else
        return
    end

    setSendLoginOverTimeCBK()
end


function M.wechatTokenToLogin()
    local function callback(json_data)
        local lua_tbl = json2lua(json_data)
        if not lua_tbl then
            print("[LOGIN] wechatTokenToLogin exception: json_data invalid")
            return
        end

        lua_tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        dump(lua_tbl, "[LOGIN] wechatTokenToLogin")

        if lua_tbl.result == 0 then
            local loginData = {
                channel_type = "wechat",
                channel_args = lua2json(lua_tbl),
                device_id = loginModel.loginData.device_id,
                device_os = loginModel.loginData.device_os,
                market_channel = gameMgr:getMarketChannel(),
                platform = gameMgr:getMarketPlatform()
            }
            MainModel.LoginInfo = loginData
            UnityEngine.PlayerPrefs.SetString("_APPID_", lua_tbl.appid)
            --Network.SendRequest("login", loginData)
            Event.Brocast("bsds_send_power",{key = "login_wechat"})

            Network.SendRequest("login", loginData, "")
        else
            NetJH.RemoveAll()
            status = nil
            if lua_tbl.result == -5 then
                --sdk error
                local channel = MainModel.LoginInfo.channel_type or ""
                HintPanel.Create(1, "登陆微信错误(" .. channel .. ":" .. lua_tbl.errno .. ")")
            elseif lua_tbl.result == -4 then
                HintPanel.ErrorMsg(3032)
            elseif lua_tbl.result == -2 then
                HintPanel.ErrorMsg(3031)
            elseif lua_tbl.result == -3 then
                HintPanel.ErrorMsg(3033)
            else
                HintPanel.ErrorMsg(lua_tbl.result)
            end
            this.CancelLogin()
        end
    end

    print("<color=white>sdkMgr login</color>")
    sdkMgr:Login("", callback)
end

function M.youke(loginId,refresh_token)
    local loginData = {
        channel_type = "youke",
        login_id = loginId,
        device_id = loginModel.loginData.device_id,
        device_os = loginModel.loginData.device_os,
        market_channel = gameMgr:getMarketChannel(),
        platform = gameMgr:getMarketPlatform(),
        channel_args = '{"test_code":"' .. UnityEngine.PlayerPrefs.GetString("_Test_Code_", "") .. '"}',
        }
    -- 创建账号用设备ID，如果本地存有ID就用本地的
    if not loginData.login_id or loginData.login_id == "" then
        loginData.login_id = sdkMgr:GetDeviceID()
    end
    Network.SendRequest("login", loginData, "")
    Event.Brocast("bsds_send_power",{key = "login_youke"})
end

function M.robot(loginId)
   local loginData = {
        channel_type = "robot",
        login_id = loginId,
        device_id = loginModel.loginData.device_id,
        device_os = loginModel.loginData.device_os,
        market_channel = "",
        market_platform = ""
    }
    Network.SendRequest("login", loginData, "")
end

function M.wechat(loginId,refresh_token)
   local appid = UnityEngine.PlayerPrefs.GetString("_APPID_", "")
    dump({loginId = loginId,appid = appid,refresh_token = refresh_token},"<color=white>请求登录</color>")
    if loginId and appid ~= "" and refresh_token and refresh_token ~= "" then
        local tbl = {}
        tbl.appid = appid
        tbl.refresh_token = refresh_token
        tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        local loginData = {
            channel_type = "wechat",
            login_id = loginId,
            channel_args = lua2json(tbl),
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform()
        }

        dump(loginData, "[Debug] loginData")
        Network.SendRequest("login", loginData, "")
        Event.Brocast("bsds_send_power",{key = "login_wechat"})
        print("login curLoginId " .. loginId)
        dump(loginData)
    else
        this.wechatTokenToLogin()
    end
end

function M.phone(loginId,refresh_token)
    dump({curLoginId = curLoginId,refresh_token = refresh_token},"<color=>phone</color>")
    if loginId and loginId ~= "" and refresh_token and refresh_token ~= "" then
        local tbl = {}
        tbl.refresh_token = refresh_token
        tbl.token = refresh_token
        tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        local loginData = {
            channel_type = "phone",
            login_id = loginId,
            channel_args = lua2json(tbl),
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform(),
            old_channel_type = "youke",
            old_login_id = loginModel.loginData.youke
        }

        dump(loginData, "[Debug] loginData")
        Network.SendRequest("login", loginData, "")
        Event.Brocast("bsds_send_power",{key = "login_phone"})
    else
        if not IsConnectedServer then
            this.ConnectServer()
        else
            NetJH.RemoveAll()
            status = nil
            Event.Brocast("model_phone_login_ui")
        end
        return
    end
end

function M.phone_vcode(loginId,refresh_token,_sms_vcode,appid)
    if loginId then
        local tbl = {}
        tbl.sms_vcode = _sms_vcode
        tbl.test_code = UnityEngine.PlayerPrefs.GetString("_Test_Code_", "")

        local loginData = {
            channel_type = "phone",
            login_id = loginId,
            channel_args = lua2json(tbl),
            device_id = loginModel.loginData.device_id,
            device_os = loginModel.loginData.device_os,
            market_channel = gameMgr:getMarketChannel(),
            platform = gameMgr:getMarketPlatform(),
            old_channel_type = "youke",
            old_login_id = loginModel.loginData.youke
        }

        dump(loginData, "[Debug] loginData")
        Network.SendRequest("login", loginData, "")
        Event.Brocast("bsds_send_power",{key = "login_phone"})
    end
end

function M.AutoLogin() 
    local last_type = loginModel.loginData.lastLoginChannel
    if last_type then
        this.Login(last_type)
    else
        dump(loginModel.loginData, "<color=red>loginModel.loginData</color>")
    end 
end

function M.OnConnecteServerSucceed()
    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    this.Login(BaseUnpack(this._cur_login_data))
end

function M.CancelLogin()
    status = nil
    curChannel = nil
    LoginLogic.SetGoodIP("")

    connectCurTime = 0
    wechatErrorStatus = 0

    NetJH.RemoveAll()

    if connectTimer then
        connectTimer:Stop()
        connectTimer = nil
    end

    Network.DestroyConnect()
    print("<color=red> login is cancel or error </color>")
    Event.Brocast("bsds_send_power",{key = "login_fail"})

end
setSendLoginOverTimeCBK = function ()
    if sendLoginRequestOverTimer then
        sendLoginRequestOverTimer:Stop()
    end

    local function cbk()
        if MainModel.myLocation ~= "game_Login" then
            return
        end
        if status == 1 or status == 2 then
            --微信的渠道就进行一次清除本地账号
            if curChannel == "wechat" then
                this.clearWechatData()
            end

            Event.Brocast("cancel_login", {"timeout"})
            this.CancelLogin()

            HintPanel.Create(1, "登录服务器失败，请稍后重试")
        end
    end
    sendLoginRequestOverTimer = Timer.New(cbk, sendLoginRequestOverTime, 1, nil, true)
    sendLoginRequestOverTimer:Start()
end

function M.ConnectServer(_type,loginId,refresh_token,_sms_vcode,appid)
    if IsConnectedServer then
        this.BeginLogin(_type,loginId,refresh_token,_sms_vcode)
    else
        NetJH.Create("正在登陆...", 1)
        --断网情况下，每3秒尝试一次重新连接
        local sendConnect = function()
            if not IsConnectedServer then
                networkMgr:SendConnect()
            end
            connectCurTime = connectCurTime + 1
            if connectCurTime >= connectMaxTime then
                local ip = LoginLogic.TryGetIP()
                if ip and ip ~= "" then
                    AppConst.SocketAddress = ip
                    connectCurTime = 0
                    print("reconnect server use ip: " .. ip)
                else
                    Event.Brocast("cancel_login", {"connectout"})
                    this.CancelLogin()
                    HintPanel.Create(1, "连接服务器失败，请检查网络是否连接")
                end
            end
        end

        connectTimer = Timer.New(sendConnect, connectTimeDelay, -1, nil, true)
        connectTimer:Start()
        sendConnect()
    end
end

function M.Login(_type, login_infor, _sms_vcode, appid)
    this._cur_login_data = {_type, login_infor, _sms_vcode, appid}

    this._cur_login_data.n = 4
    if LoginLogic.checkServerStatus then
        if not LoginLogic.CheckServerStatus(true) then
            return
        end
    end

    curChannel = (_type ~= "phone_vcode") and _type  or "phone"
    local loginId = (_type == "phone_vcode" or _type == "robot") and login_infor or loginModel.loginData[_type]

    local refresh_token = loginModel.loginData.refresh_token

    --登录
    this.ConnectServer(_type,loginId,refresh_token,_sms_vcode,appid)
end

--清除游客数据
function M.clearYoukeData()
    loginModel.ClearChannelData("youke")
    PlayerPrefs.DeleteKey("SGE_SALE_DAY_3")
    PlayerPrefs.DeleteKey("SGE_SALE_DAY_4")
    PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")
end

--清除微信数据
function M.clearWechatData()
    loginModel.ClearChannelData("wechat")
end

--清除手机数据
function M.clearPhoneData()
    loginModel.ClearChannelData("phone")
end
