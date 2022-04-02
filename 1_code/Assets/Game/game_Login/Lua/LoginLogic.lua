package.loaded["Game.game_Login.Lua.LoginModel"] = nil
require "Game.game_Login.Lua.LoginModel"

package.loaded["Game.game_Login.Lua.LoginPanel"] = nil
require "Game.game_Login.Lua.LoginPanel"

package.loaded["Game.game_Login.Lua.GameXYText"] = nil
local GameXY = require "Game.game_Login.Lua.GameXYText"

package.loaded["Game.game_Login.Lua.ClauseHintPanel"] = nil
require "Game.game_Login.Lua.ClauseHintPanel"

package.loaded["Game.game_Login.Lua.LoginHelper"] = nil
require "Game.game_Login.Lua.LoginHelper"

if GameGlobalOnOff.LoginProxy then
    package.loaded["Game.game_Login.Lua.LoginProxy"] = nil
    require "Game.game_Login.Lua.LoginProxy"
end

local basefunc = require "Game.Common.basefunc"

LoginLogic = {}

local this  -- 单例
local loginModel


local lister
local function AddLister()
    lister = {}
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

local IP_KEY = "_GOOD_IP_"
local ip_list = {}
local ip_count = 0
local ip_index = 0

local function SetupIPList()
    local function checking(item)
        for k, v in ipairs(ip_list) do
            if item == v then
                return k
            end
        end
        return -1
    end

    local function fill_list(list, revert)
        revert = revert or false

        local item

        if revert then
            for i = list.Length - 1, 0, -1 do
                item = list[i]
                if checking(item) == -1 then
                    table.insert(ip_list, item)
                end
            end
        else
            for i = 0, list.Length - 1, 1 do
                item = list[i]
                if checking(item) == -1 then
                    table.insert(ip_list, item)
                end
            end
        end

        ip_count = #ip_list
        ip_index = 1
    end

    ip_list = {}
    ip_count = 0
    ip_index = 0

    local serverList = gameMgr:getServerList()
    if serverList and serverList.Length > 0 then
        fill_list(serverList, false)

        --debug
        dump(ip_list, "server ip list")
    end

    if PlayerPrefs.HasKey(IP_KEY) then
        local ip = PlayerPrefs.GetString(IP_KEY, "")
        if ip and ip ~= "" then
            local idx = checking(ip)
            if idx > 1 then
                local item = ip_list[idx]
                ip_list[idx] = ip_list[1]
                ip_list[1] = item

                print("good id: " .. item)
            end
        end
    end
end

function LoginLogic.GetIP()
    if ip_index <= 0 or ip_index > ip_count then
        return ""
    end
    return ip_list[ip_index]
end

function LoginLogic.TryGetIP()
    if ip_index <= 0 or ip_index > ip_count then
        return ""
    end

    local ip = ip_list[ip_index]
    ip_index = ip_index + 1

    return ip
end

function LoginLogic.SetGoodIP(ip)
    print("set good ip:" .. ip)
    if not ip or ip == "" then
        PlayerPrefs.DeleteKey(IP_KEY)
    else
        PlayerPrefs.SetString(IP_KEY, ip)
    end
end

function LoginLogic.Init()
    LoginLogic.Exit()
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = LoginLogic

    loginModel = LoginModel.Init()
    this.GameXY = GameXY
    this.checkServerStatus = true
    AddLister()

    SetupIPList()

    if GameGlobalOnOff.LoginProxy then
        LoginProxy.Init(this)
    end
    LoginHelper.Init()
    LoginPanel.Create()

    return this
end

function LoginLogic.CheckServerStatus(showHint)
    print("CheckServerStatus ........................................")
    local serverStatus = gameMgr:getServerStatus() or ""
    print("CheckServerStatus result >>>>>>>>>:")
    if serverStatus == "" then
        return true
    end

    local result = false

    local segs = basefunc.string.split(serverStatus, "#")
    local text = ""
    if #segs ~= 2 then
        text = serverStatus
    else
        text = segs[2]
        if string.lower(segs[1]) == "on" then
            result = true
        end
    end

    local hint = showHint or false
    if hint then
        HintPanel.Create(1, text)
    end
    print("CheckServerStatus result :")
    return result
end


function LoginLogic.Exit()
    if this then
        if loginModel then
            loginModel.Exit()
        end
        loginModel = nil

        RemoveLister()
        LoginHelper.Exit()
        this = nil
    end
end

return LoginLogic
