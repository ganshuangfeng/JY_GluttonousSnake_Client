-- 创建时间:2021-10-09
-- 处理网络缓存等
local basefunc = require "Game.Common.basefunc"

NetworkHelper = {}
local M = NetworkHelper
local this = nil

local networkCacheQueue = {}
local GetSavePath = function()
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    return path
end
local GetSaveFile = function ()
    local saveFile = "NetworkCache"
    if AppDefine.IsEDITOR() then
        return saveFile
    else
        if MainModel and MainModel.UserInfo and MainModel.UserInfo.user_id then
            return saveFile .. MainModel.UserInfo.user_id
        end
    end
    return saveFile
end


local isDebug = false

local lister

local function CheckIsConnectedServer()
    return IsConnectedServer
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
	lister["ReConnecteServerResponse"] = M.OnReConnecteServerResponse
	lister["Ext_OnLoginResponse"] = M.OnExt_OnLoginResponse
	lister["save_game_data_response"] = M.on_save_game_data_response
end

function M.Init()
	if this then
		M.Exit()
	end
	this = M

	MakeLister()
	AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.SaveNetworkCache()
    dump(networkCacheQueue,"<color=yellow>NetworkHelper 保存网络缓存</color>")
    SaveLua2Json(networkCacheQueue,GetSaveFile(),GetSavePath())
end

function M.LoadNetworkCache()
    networkCacheQueue = LoadJson2Lua(GetSaveFile(),GetSavePath()) or networkCacheQueue
    dump(networkCacheQueue,"<color=yellow>NetworkHelper 加载网络缓存</color>")
end

function M.PushNetworkCache(data)
    if CheckIsConnectedServer() then return end
    networkCacheQueue[#networkCacheQueue+1] = data
    -- networkCacheQueue:push_back(data)
    M.SaveNetworkCache()
end

function M.SendNetworkCache()
    if not CheckIsConnectedServer() then return end
    if not next(networkCacheQueue) then return end

    local t = {}
    local c = 0
    local size = #networkCacheQueue
    for i = 1, size do
        c = c + 1

        t[#t+1] = networkCacheQueue[i]

        if c == 100 or i == size then
            local data = t
            dump(data,"<color=yellow>NetworkHelper 同步数据 save_game_data ???????</color>")
            Network.SendRequest("save_game_data",{data = data},"同步数据")
            t = {}
        end

        if c == 100 then
            c = 0
        end
    end
    networkCacheQueue = {}
    M.SaveNetworkCache()
end

function M.SendNetworkData(data)
    if not CheckIsConnectedServer() then return end
    local d = {[1] = data}
    dump(d,"<color=yellow>NetworkHelper 同步数据 save_game_data ???????</color>")
    Network.SendRequest("save_game_data",{data = d},"同步数据")
end

M.recoverTaskData = {}
--恢复本地数据
function M.RecoverLocalData()
    if not next(networkCacheQueue) then return end
    
    M.recoverTaskData = {}

    local maxLevel = MainModel.UserInfo.game_level - 1
    for i, v in ipairs(networkCacheQueue) do
        if v.result == 1 and v.game_level and v.game_level > maxLevel then
            maxLevel = v.game_level
        end
        
        if v.asset then
            for index, value in ipairs(v.asset) do
                MainModel.AddAsset(value.asset_type,value.asset_value)
            end
        end

        --- 合并任务的 本地缓存
        if v.task then
            table.insert( M.recoverTaskData , v.task )

        end

    end
    MainModel.UserInfo.game_level = maxLevel + 1
end

function M.on_save_game_data_response(msgName,data)
    dump(data,"<color=yellow>NetworkHelper save_game_data_response</color>")
end

function M.OnReConnecteServerResponse(result)
    dump(result,"<color=yellow>NetworkHelper 断线重连登录 ?????</color>")
    if result ~= 0 then return end
    M.LoadNetworkCache()
    M.SendNetworkCache()
end

function M.OnExt_OnLoginResponse(result)
    dump(result,"<color=yellow>NetworkHelper 正常登录 ?????</color>")
    if result ~= 0 then return end
    
   
    --重新登录游戏需要先恢复客户端数据，再向服务器同步
    M.LoadNetworkCache()
    M.RecoverLocalData()
    M.SendNetworkCache()

     --- 载入 服务器任务数据
    task_mgr.LoadTaskDataByServer( M.recoverTaskData )
    
    
end

function M.HandleNetworkCache(data)
    dump(data,"<color=yellow>NetworkHelper 游戏数据缓存？？？？？？</color>")
    M.PushNetworkCache(data)
    M.SendNetworkCache()
    M.SendNetworkData(data)
end

M.Init()