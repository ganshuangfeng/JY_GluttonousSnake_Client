-- 创建时间:2021-06-07
local cur_path = "Game.game_CS.Lua."
ExtRequire(cur_path .. "CSModel")
ExtRequire(cur_path .. "CSGamePanel")
-- ExtRequire "Game.game_CS.Lua.GameConfigCenter"
ExtRequire "Game.game_CS.Lua.AutoControlModelManager"

ExtRequire("Game.CommonPrefab.Lua.MapManager")
ExtRequire("Game.CommonPrefab.Lua.StageManager")
ExtRequire("Game.CommonPrefab.Lua.AttackManager")
ExtRequire("Game.CommonPrefab.Lua.Vector2D")
ExtRequire("Game.CommonPrefab.Lua.SpawnBulletManager")
ExtRequire("Game.game_CS.Lua.VehicleManager")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveAI")
ExtRequire("Game.CommonPrefab.Lua.GameCacheLoadingPanel")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveManual")

ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveSelectPanel")


ExtRequire("Game.CommonPrefab.Lua.ObjectCenter")

ExtRequire("Game.game_CS.Lua.Object.Hero")

ExtRequire("Game.game_CS.Lua.CreateFactory")
ExtRequire("Game.CommonPrefab.Lua.ChargePrefab")
ExtRequire("Game.game_CS.Lua.MonsterComAttackWarningPrefab")

ExtRequire("Game.game_CS.Lua.CSAnimManager")
ExtRequire("Game.game_CS.Lua.LotteryManager")
-- ExtRequire("Game.game_CS.Lua.LotteryPanel")
ExtRequire("Game.CommonPrefab.Lua.SkillManager")
ExtRequire("Game.game_CS.Lua.ComponseManager")
ExtRequire("Game.game_CS.Lua.ExtSkillPanel")
ExtRequire("Game.game_CS.Lua.Poisoning")

ExtRequire("Game.game_CS.Lua.ComponsePanel_New1")
ExtRequire("Game.CommonPrefab.Lua.HeroWait")
ExtRequire("Game.game_CS.Lua.CSEffectManager")
ExtRequire("Game.game_CS.Lua.StagePanel")
ExtRequireAudio("Game.game_CS.Lua.audio_cs_config","cs")
ExtRequire("Game.game_CS.Lua.AwardPanel")
ExtRequire("Game.game_CS.Lua.AwardSettlePanel")
ExtRequire("Game.game_CS.Lua.ExtSkillSP2Panel")
ExtRequire("Game.game_CS.Lua.ExtSkillSP4Panel")
ExtRequire("Game.game_CS.Lua.ExtSkillSP2Prefab")

ExtRequire("Game.game_CS.Lua.EggOfSkill")
ExtRequire("Game.game_CS.Lua.HeroHeadSkillManager")
ExtRequire("Game.CommonPrefab.Lua.LevelStatements")
ExtRequire("Game.CommonPrefab.Lua.LevelStatementsPanel")
ExtRequire("Game.game_CS.Lua.HeroLinkCheck")
ExtRequire("Game.game_CS.Lua.ItemThreeChooseOnePanel")
ExtRequire("Game.CommonPrefab.Lua.FindTargetFunc")
ExtRequire("Game.game_CS.Lua.ThreeChooseOne")

CSLogic = {}
local L = CSLogic
L.panelNameMap = {
    game = "game",
    hall = "hall"
}

local cur_panel

local this
--自己关心的事件
local lister
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}

    lister["model_status_no_error_msg"] = this.on_status_error_msg
    -- 网络
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    -- lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    -- lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["ui_game_get_jin_bi_msg"] = this.on_add_jb

end

-- Logic
local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end
-- View 的消息处理相关方法
local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    -- DOTweenManager.KillAllStopTween()
end
local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

local function SendRequestAllInfo()
end

--状态错误处理
function L.on_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function L.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end

function L.on_add_jb(jb)
    --ClientAndSystemManager.SendRequest("cs_add_gold",{jb = jb})
    MainModel.AddAsset("prop_jin_bi",jb)
end
--游戏后台消息
function L.on_background_msg()
    cancelViewMsgRegister()
end
--游戏重新连接消息
function L.on_reconnect_msg()
    SendRequestAllInfo()
end
--游戏网络破损消息
function L.on_network_error_msg()
    cancelViewMsgRegister()
end


function L.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function L.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function L.Init(parm)
    math.randomseed(os.time())
    this = L
    dump(parm, "<color=red>CSLogic Init parm</color>")
    this.parm = parm
    if parm and parm.level then
        MainModel.UserInfo.cur_level = parm.level
    end
    --初始化model
    local model = CSModel.Init()
    MakeLister()
    AddMsgListener(lister)

    MainLogic.EnterGame()
    SendRequestAllInfo()
    L.change_panel(L.panelNameMap.game)
    ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_usually_BGM.audio_name)
end

function L.Exit()
    if this then
        print("<color=green>Exit  CSLogic</color>")
        this = nil
        if cur_panel then
            cur_panel.instance:Exit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        CSModel.Exit()
    end
end

function L.change_panel(panelName)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == L.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:Exit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == L.panelNameMap.hall then
            GameManager.GotoSceneName(GameSceneManager.EnterFirstScene)
        elseif panelName == L.panelNameMap.game then
            cur_panel = {name = panelName, instance = CSGamePanel.Create()}
        end
    end
end

function L.quit_game(call, quit_msg_call)
    Network.SendRequest("xxx发送退出协议", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            if not call then
                L.change_panel(L.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end


return CSLogic