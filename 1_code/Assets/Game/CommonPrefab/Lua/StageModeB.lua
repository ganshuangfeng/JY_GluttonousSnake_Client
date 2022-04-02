--[[关卡模式 A
    吃宝石过关模式
]]
StageModeB = {}
local M = StageModeB

local basefunc = require "Game/Common/basefunc"

local function Removelister()
    if M.lister then
        for msg,cbk in pairs(M.lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    M.lister=nil
end

local function AddLister()
    M.lister = {}

    M.lister["HeroAllDie"] = M.OnHeroAllDie
    M.lister["boss_die"] = M.OnBossDie
    M.lister["hit_boss"] = M.OnHitBoss
    M.lister["boss_arise"] = M.OnHitArise

    for msg,cbk in pairs(M.lister) do
        Event.AddListener(msg, cbk)
    end

end

-- 数据
function M.Init(data)

    AddLister()

    M.data = data

    local sd = GameInfoCenter.GetStageData()
    -- 关卡
    M.curLevel = sd.curLevel
    M.roomNo = sd.roomNo
    
    -- 所有关卡的配置
    -- M.allStageConfig = GameConfigCenter.GetAllStageConfig()

    -- 关卡数据
    M.curStageConfig = GameConfigCenter.GetStageConfig(M.curLevel,M.roomNo)

    -- 最大关卡
    M.maxLevel = #M.allStageConfig

    M.time = M.curStageConfig.time
    M.timeMax = M.time

    -- 波次
    M.curStage = 0

    M.maxStage = #M.curStageConfig.stage_data

    M.state = "boss"

    GameInfoCenter.SetStageData({
        maxStage = M.maxStage,
        curStage = M.curStage,
        state = M.state,
    })

    GameInfoCenter.Exit()
    ObjectCenter.Exit()

    ComponseManager.RemoveAll()
    AttackManager.RemoveAll()

    local roomData = {
        name = M.curStageConfig.prefab,
        roomNo = M.roomNo
    }
    MapManager.Start(roomData)

    SnakeHeadMoveAI.Start()
    
    GameInfoCenter.InitPlayerData()
    
    -- 蛇头
    CreateFactory.CreateHeroHead({type=MainModel.GetHeadType(),level = MainModel.GetHeadLevel()})
    -- 加载英雄
    CreateFactory.CreateHeroList(MainModel.UserInfo.GameInfo.turret_list)

    -- 创建地图指示器
    CreateFactory.CreateTargetIndicator()
    
    Event.Brocast("stage_start", {
                                    hp=GameInfoCenter.playerDta.hp, 
                                    hpMax=GameInfoCenter.playerDta.hpMax,
                                    level=M.curStageConfig.level,
                                    type="boss",
                                })

    Event.Brocast("stage_state_change","boss_coming")
    Event.Brocast("stageShowTargetProgress",true)
    Event.Brocast("stageSetKillData",nil)
    Event.Brocast("stageRefreshMonsterProgress",nil)

    -- ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_BOSS_BGM.audio_name)
    
    M.GoToNextStage()
end


function M.Exit()
    
    --GameInfoCenter.SetMapNotPassGridData({})
    SetMapNotPassGridData( MapManager.GetAStar(self.roomNo) , {} )

    Removelister()

end

function M.Awake()
end

function M.FrameUpdate(timeElapsed)
    
    if M.state == "over" then
        return
    end

    M.time = M.time - timeElapsed

    Event.Brocast("stage_time_count_down",M.time/M.timeMax)
    
    if M.time < 0 then
        M.OnStageOver(0)
    end

end

-- 关卡结束 state 0|失败 1|胜利
function M.OnStageOver(state)
    
    local function startNext ()
        Event.Brocast("stage_manager_level_change_msg",{cur_level = M.cur_level})
        StageManager.StageFinish(state)
    end
    
    if state == 0 then
        
        Event.Brocast("GameLoseFx", {type="normal",callback=startNext})

    elseif state == 1 then

        Event.Brocast("GameWinFx", {type="normal",callback=startNext})

    end

end


local function AriseMonster()

    local mc = GameConfigCenter.GetStageRandomMonsterData(M.curLevel,M.curStage)
    CreateFactory.CreateMonsterGroup(mc)

end


local function PassLevel()
    
    M.state = "over"

    local function createdPortalCallback( pos )
        
        -- 蛇进洞
        local function enterPortalCallback()
            GameInfoCenter.SetHeroHeadTargetData(nil)
            M.OnStageOver(1)
        end
        
        GameInfoCenter.SetHeroHeadTargetData({pos=pos,type="csm"})
        Event.Brocast("SerpentGotoPortal",{pos=pos,callback=enterPortalCallback,type="settle"})
    end
    -- 创建传送门
    CreateFactory.CreatePortal({callback=createdPortalCallback,award=M.curStageConfig.award})
end


-- 进入下一个阶段(波次)
function M.GoToNextStage()

    M.curStage = M.curStage + 1

    GameInfoCenter.SetStageData({
        curStage = math.min(M.curStage,M.maxStage),
    })

    -- 刷怪
    AriseMonster()

    Event.Brocast("stage_change",{stage = M.curStage, level=M.curLevel})
end


-- 英雄死了
function M.OnHeroAllDie()
    M.OnStageOver(0)
end


-- boss死亡
function M.OnBossDie(md)
    SpawnBulletManager.RemoveAll()
    PassLevel()
end


-- boss受攻击
function M.OnHitBoss(md)

    Event.Brocast("stageRefreshBossValue",md.hp,md.maxHp)

end


-- boss出现
function M.OnHitArise(md)

    if M.state == "boss" then
        Event.Brocast("stageRefreshBossValue",md.hp,md.maxHp)
    end

end