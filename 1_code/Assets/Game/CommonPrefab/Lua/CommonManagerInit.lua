--[[	
	初始化各种公用代码
--]]

CommonManagerInit = {}

-- DataTool
require "Game.Common.Enum"
require "Game.Common.StringHelper"
require "Game.Common.MathExtend"
require "Game.Common.CustomUITool"
require "Game.CommonPrefab.Lua.GameGlobalOnOff"
require "Game.Framework.DOTweenManager"
require "Game.Framework.GameManager"
require "Game.Framework.Network"
require "Game.CommonPrefab.Lua.GameDefine"
require "Game.game_Loding.Lua.LodingLogic"
require "Game.Common.cardID_vertify"
util = require "Game.Common.3rd.cjson.util"
require "Game.Common.3rd.cjson.json2lua"
require "Game.Common.3rd.cjson.lua2json"
ewmTools = require "Game.Common.ewmTools"
require "Game.CommonPrefab.Lua.GameSceneManager"
require "Game.CommonPrefab.Lua.GameTaskManager"
require "Game.CommonPrefab.Lua.GameToolManager"
require "Game.CommonPrefab.Lua.GuideLogic"
require "Game.CommonPrefab.Lua.RedPointSystem"

-- CommonPrefab
require "Game.CommonPrefab.Lua.SmallLodingPanel"
require "Game.CommonPrefab.Lua.GMPanel"
require "Game.CommonPrefab.Lua.HotUpdatePanel"
require "Game.CommonPrefab.Lua.HotUpdateSmallPanel"
require "Game.CommonPrefab.Lua.IllustratePanel"
require "Game.CommonPrefab.Lua.NetJH"
require "Game.CommonPrefab.Lua.RectJH"
require "Game.CommonPrefab.Lua.HintPanel"
require "Game.CommonPrefab.Lua.ItemShowPanel"
require "Game.CommonPrefab.Lua.LittleTips"
require "Game.CommonPrefab.Lua.UIPaySuccess"
require "Game.CommonPrefab.Lua.GameTipsPrefab"
require "Game.CommonPrefab.Lua.GameButtonPanel"
require "Game.CommonPrefab.Lua.ExtPanel"
require "Game.CommonPrefab.Lua.ComGuideToolPanel"
require "Game.CommonPrefab.Lua.LTTipsPrefab"
require "Game.CommonPrefab.Lua.AwardConfigShowPanel"
require "Game.CommonPrefab.Lua.CommonAwardPrefab"

-- 配置
errorCode = require "Game.Common.error_code"
require "Game.CommonPrefab.Lua.GameSceneCfg"
require "Game.Common.normal_enum"
audio_config = require "Game.CommonPrefab.Lua.audio_config"
ExtRequireAudio("Game.CommonPrefab.Lua.audio_game_config","game")

-- UITool
require "Game.CommonPrefab.Lua.GameComAnimTool"
require "Game.CommonPrefab.Lua.ComDialCJComponent"
require "Game.Framework.URLImageManager"
require "Game.CommonPrefab.Lua.CommonPMDManager"
require "Game.CommonPrefab.Lua.CommonLotteryAnim"
require "Game.Common.panelManager"
require "Game.Common.ExtendSoundManager"
require "Game.CommonPrefab.Lua.CachePrefabManager"
require "Game.CommonPrefab.Lua.GameModuleManager"

-- Manager
require "Game.CommonPrefab.Lua.TimerExt"
require "Game.Framework.IosPayManager"
require "Game.Framework.AndroidPayManager"
require "Game.Framework.DataStatisticsManager"
require "Game.Framework.BuriedStatisticalDataSystem"
require "Game.Framework.LocalDatabaseManager"
require "Game.Framework.IosPayManager"
require "Game.Framework.AndroidPayManager"
require "Game.Framework.DataStatisticsManager"
require "Game.Framework.BuriedStatisticalDataSystem"
require "Game.CommonPrefab.Lua.TimerManager"
require "Game.CommonPrefab.Lua.CommonTimeManager"
require "Game.CommonPrefab.Lua.NetMsgSendManager"
require "Game.CommonPrefab.Lua.SYSQXManager"
require "Game.Common.UniWebViewMgr"
require "Game.Common.UniWebViewMessageMgr"
require "Game.Common.RewardADMgr"
require "Game.Common.YLHRewardADMgr"
require "Game.Common.TalkingDataManager"
require "Game.CommonPrefab.Lua.HeroDataManager"
require "Game.game_CS.Lua.GameConfigCenter"
require "Game.game_CS.Lua.ItemThreeChooseOneManager"


CommonManagerInit.Init = function ()
    Network.Init()
    ExtendSoundManager.Init()
    TimerManager.Init()
    CommonTimeManager.Init()
    URLImageManager.Init()
    SYSQXManager.Init()
    NetMsgSendManager.Init()
    UniWebViewMessageMgr.Init()
    UniWebViewMgr.Init()
    GameModuleManager.Init()
    TalkingDataManager.Init()

    HeroDataManager.Init()
    GameConfigCenter.Init()
    GuideLogic.Init()
    DSM.Init()
end
