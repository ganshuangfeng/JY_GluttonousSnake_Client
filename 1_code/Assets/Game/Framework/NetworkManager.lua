-- 创建时间:2021-10-09
-- 管理网络状态
-- 连接异常，连接断开，重连，心跳检测
local basefunc = require "Game.Common.basefunc"

IsConnectedServer = false -- 是否连接服务器

NetworkManager = {}
local M = NetworkManager
local this = nil

local isDebug = false

local UPDATE_INTERVAL = 0.5
--心跳丢失数量
local HeartBeatLostNum = 0


local RC_INTERVAL = 3 -- 重连时间间隔
local reConnectDt = 0
local reConnectFailedCurTime = 0 -- 当前重连失败次数
local reConnectFailedTime = 6 -- 重连失败最大次数
local reConnectServerCount = 0

local reLoginStartTime -- 重新登陆开始时间
local reLoginMaxTime = 5 -- 重新登陆超时判断时间
M.reLoginOverTimeCbk = nil -- 重连超时回调

--心跳
local HB_INTERVAL = 1
local heartbeatDt = 0
local sendClock = 0
local heartBeatLostCurTime = 0
local heartBeatLostMaxTime = 12
local heartbeat -- 心跳call

local sendReConnectRequest -- 发送重连消息
local reConnectServer -- 重连服务器

-- 弱网模式
local isWeakNet = true

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

    lister["ConnecteServerSucceed"] = this.OnConnecteServerSucceed
    lister["ServerConnectException"] = this.OnServerConnectException
    lister["ServerConnectDisconnect"] = this.OnServerConnectDisconnect
	
	lister["EnterForeGround"] = this.OnEnterForeGround
     
end

local function nmPrint(s)
    local traceback = basefunc.string.split(debug.traceback("", 2), "\n")
    if #traceback >= 3 then
        local tt = basefunc.string.split(traceback[3], ":")
        if #tt >= 2 then
            UnityEngine.MonoBehaviour.print( os.date("%H:%M:%S ", os.time() ) .. " [" .. basefunc.string.trim(tt[1]..":"..tt[2]) .. "]" .. "<color=yellow>[Debug Network] : </color> " .. s )
            return
        end
    end
    print("<color=yellow>[Debug Network] : </color> " .. s)
end

function M.Init()
	if this then
		M.Exit()
	end
	this = M

	MakeLister()
	AddLister()

    if isWeakNet then
        reConnectFailedTime = 99999999
    end

	this.reConnectServerState = 0 -- 重连状态  0-无  1-重连中  2-重连后正在登录

    this.updateTimer = Timer.New(this.Update, UPDATE_INTERVAL, -1, nil, true)
    this.updateTimer:Start()
end
function M.Exit()
	if this then
		RemoveLister()
		if this.updateTimer then
			this.updateTimer:Stop()
			this.updateTimer = nil
		end
		this = nil
	end
end

function M.Update()
	
    --登录后之后才会有这些操作
    if MainModel.IsLoged then
    	-- if not isWeakNet then
	        heartbeat(UPDATE_INTERVAL)
    	-- end

        sendReConnectRequest(UPDATE_INTERVAL)

    end

    if M.reLoginOverTimeCbk then
        if reLoginStartTime + reLoginMaxTime < os.time() then
            M.reLoginOverTimeCbk()
            M.reLoginOverTimeCbk = nil
        end
    end

end

function M.OnEnterForeGround()
    --重置心跳 数据
    heartbeatDt = 0
    sendClock = 0
    HeartBeatLostNum = 0
    heartBeatLostCurTime = 0
end

-----------------------------------------重连-------------------------------------------
-----------------------------------------重连-------------------------------------------

--重连服务器
reConnectServer = function()
    
    if not IsConnectedServer and this.reConnectServerState==0 then

        this.reConnectServerState = 1

        nmPrint("<color=red>重连 NetworkManager</color>")
        --立刻发起第一次重连
        networkMgr:SendConnect()
        reConnectServerCount = reConnectServerCount + 1

    end

end

--服务器连接异常
function M.OnServerConnectException ()

    --只有登录之后才管这些事情
    if MainModel.IsLoged then
        if not isWeakNet then
            NetJH.Create("正在重连服务器...",1011)
        end

        Event.Brocast("DisconnectServerConnect")

        reConnectServer()

        nmPrint("<color=red> OnServerConnectException ***----- </color>")
    end

end

--服务器连接断开
function M.OnServerConnectDisconnect ()

    --只有登录之后才管这些事情
    if MainModel.IsLoged then
        if not isWeakNet then
            NetJH.Create("正在重连服务器...",1011)
        end

        Event.Brocast("DisconnectServerConnect")
        
        reConnectServer()

        nmPrint("<color=red> OnServerConnectDisconnect ***----- </color>")
    end

end


--服务器重连成功
function M.OnConnecteServerSucceed ()

    --判断是否是重连的链接成功
    if this.reConnectServerState == 1 then

        this.is_on_query_asset = false
        this.reConnectServerState = 2 -- 重连成功 开始进行登录
        reConnectServerCount = 0
        reConnectDt = 0
    	
    	PROTO_TOKEN = nil
        MainLogic.reLogin()

        --添加一个超时回调
        reLoginStartTime = os.time()
        M.reLoginOverTimeCbk = function ()
            -- 直接回复登录错误
            Event.Brocast("login_response","login_response",{result=-1})
        end

        nmPrint("<color=blue> ReConnecteServerSucceed  start login ***----- </color>")

    end

end


-----------------------------------------重连-------------------------------------------
-----------------------------------------重连-------------------------------------------



-----------------------------------------心跳-------------------------------------------
-----------------------------------------心跳-------------------------------------------


--持续进行发送重连请求
sendReConnectRequest = function(dt)

    if this.reConnectServerState == 1 then

        --进行重连失败处理
        if reConnectFailedCurTime >= reConnectFailedTime then
            this.reConnectServerState = 0

            reConnectFailedCurTime = 0
            reConnectDt = 0
            reConnectServerCount = 0
            MainModel.IsLoged = false
            
            NetJH.RemoveByTag(1011)

            --重连后失败，应该跳转到登陆场景
            HintPanel.Create(1,"您连接服务器失败，需要重新登录",function ()
                MainLogic.GotoScene( "game_Login" )
            end)
            nmPrint("<color=red> reConnectFailed </color>")
        end

        reConnectDt = reConnectDt + dt
        if reConnectDt > RC_INTERVAL then
            reConnectDt = 0
            reConnectFailedCurTime = reConnectFailedCurTime + 1

            if not IsConnectedServer then
                networkMgr:SendConnect()
                reConnectServerCount = reConnectServerCount + 1
                nmPrint("<color=red> SendConnect ***----- Count=" .. reConnectServerCount .. " </color>")
            end

        end

    end

end


heartbeat = function(dt)

    --正常的链接状态才进行心跳
    if this.reConnectServerState ~= 0 then
        return
    end

    --上一个发送成功后并且间隔1s以上才发送新的心跳包

    heartbeatDt = heartbeatDt + dt
    heartBeatLostCurTime = heartBeatLostCurTime + dt
    if heartbeatDt > HB_INTERVAL then
        Network.SendRequest("heartbeat",nil,function ()
            HeartBeatLostNum = HeartBeatLostNum - 1
            this.ping = math.ceil((os.clock()-sendClock)*500)
            Event.Brocast("ping",this.ping)
            heartBeatLostCurTime = 0
            -- nmPrint("<color=red>ping:"..this.ping.."</color>")
        end)
        HeartBeatLostNum = HeartBeatLostNum + 1
        
        heartbeatDt = 0
        sendClock = os.clock()
    end

    if heartBeatLostCurTime > heartBeatLostMaxTime then
        --丢失过多  触发网络异常
        nmPrint("<color=red>[] heartBeatLostMaxTime to ServerConnectException </color>")
        heartbeatDt = 0
        sendClock = 0
        heartBeatLostCurTime = 0

        Network.DestroyConnect()
    end

end

-----------------------------------------心跳-------------------------------------------
-----------------------------------------心跳-------------------------------------------


