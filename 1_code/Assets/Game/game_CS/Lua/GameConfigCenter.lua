GameConfigCenter = {}
local M = GameConfigCenter

local basefunc = require "Game/Common/basefunc"

ExtRequire "Game.game_CS.Lua.MoveAlgorithm.MoveAlgorithmNew"
ExtRequire "Game.game_CS.Lua.Modifier.ModifierSystem"
ExtRequire "Game.game_CS.Lua.Modifier.PropModifier"


ExtRequire "Game.game_CS.Lua.GameInfoCenter"
ExtRequire "Game.game_CS.Lua.CreateFactory"
ExtRequire "Game.game_CS.Lua.ObserverCenter"
ExtRequire "Game.CommonPrefab.Lua.FsmLogic"
ExtRequire "Game.game_CS.Lua.Object.Base"
ExtRequire "Game.game_CS.Lua.Object.Object"
ExtRequire "Game.game_CS.Lua.Object.Hero"
ExtRequire "Game.game_CS.Lua.Object.Monster"
ExtRequire "Game.game_CS.Lua.Object.HeroHead"
ExtRequire "Game.game_CS.Lua.Object.GoodsGem"
ExtRequire "Game.game_CS.Lua.Object.GoodsSkill"
ExtRequire "Game.game_CS.Lua.Object.GoodsBuildings"
ExtRequire "Game.game_CS.Lua.Object.GoodsGoldBox"
ExtRequire "Game.game_CS.Lua.Object.GoodsPower"
ExtRequire "Game.game_CS.Lua.Object.GoodsHero"
ExtRequire "Game.game_CS.Lua.Object.GoodsGoldCoin"
ExtRequire "Game.game_CS.Lua.Object.GoodsSpike"
ExtRequire "Game.game_CS.Lua.Object.GoodsTNT"
ExtRequire "Game.game_CS.Lua.Object.GoodsSpeedUpBoard"
ExtRequire "Game.game_CS.Lua.Object.GoodsItem"
ExtRequire "Game.game_CS.Lua.GoodsAddSkillTime"
ExtRequire "Game.game_CS.Lua.MonsterHatch"

ExtRequire "Game.game_CS.Lua.FsmCtrl.BaseCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.AttackStateCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.SkillStateCtrl"

ExtRequire "Game.game_CS.Lua.FsmCtrl.HeroAttackCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.HeroIdelCtrl"

ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterAttackCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterChaseCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterIdelCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBreathCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterWalkCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterRunawayCtrl"


ExtRequire "Game.game_CS.Lua.FsmCtrl.HeadEatDiamondCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.HeadManualCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.HeadForceOffsetCtrl"


ExtRequire "Game.game_CS.Lua.Skill.Skill"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroDuyeNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroDuyeSuperAttack"

ExtRequire "Game.game_CS.Lua.Skill.SkillHeroShanDianAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterPreciousAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroLaserAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroRocketAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroTankAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroBuffBase"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroBuffAttackSpeed"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroBuffAttackPower"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBossNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBossSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBossSuperJetAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBossFireSnakeKingNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBossFireSnakeKingSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterShiRenFlowerNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterShiRenFlowerJYAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterShaMoDuChongAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterShaMoMengChongAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillLightHitSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillShieldNorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillEternityFreezeSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillLavaHitSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillDemonVampireSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillDarkLingerSuperAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterInfightAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterYCJiJuXieAttack"

ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperLaserAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperHealAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperFreshAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperPZP2Attack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroSuperRocketAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterDetonate"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterView"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterWindAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeadChaoSuZhuangZhi"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeadBaoLieHuoYan"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeroJiaTeLinAttacK"
ExtRequire "Game.game_CS.Lua.Skill.SkillHeadZuanTou"

HeroHeadFsmTable = require "Game.game_CS.Lua.FsmConfig.HeroHeadFsmTable"
monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"
monsterBossSKFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossSKFsmTable"
monsterFsmSRHTable = require "Game.game_CS.Lua.FsmConfig.monsterFsmSRHTable"
monsterFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterFsmTable"
monsterPreciousFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterPreciousFsmTable"
heroFsmTable = require "Game.game_CS.Lua.FsmConfig.heroFsmTable"
TestFsmTable = require "Game.game_CS.Lua.FsmConfig.TestFsmTable"

ExtRequire "Game.game_CS.Lua.boss_Crab.MonsterBossCrab" --boss 寄居蟹
ExtRequire "Game.game_CS.Lua.boss_Crab.SkillMonsterBossCrabNorAttack"
ExtRequire "Game.game_CS.Lua.boss_Crab.SkillMonsterBossCrabSuperSandAttack"
ExtRequire "Game.game_CS.Lua.boss_Crab.SkillMonsterBossCrabSuperRollDownAttack"
ExtRequire "Game.game_CS.Lua.boss_Crab.SkillMonsterBossCrabSuperBombAttack"
ExtRequire "Game.game_CS.Lua.boss_Crab.SkillMonsterBossCrabSuperComplexAttack"

ExtRequire "Game.game_CS.Lua.boss_BawangFlower.MonsterBossBaWangFlower" --boss 霸王花
ExtRequire "Game.game_CS.Lua.boss_BawangFlower.SkillMonsterBossBaWangFlowerNorAttack"
ExtRequire "Game.game_CS.Lua.boss_BawangFlower.SkillMonsterBossBaWangFlowerSuperAttack"
ExtRequire "Game.game_CS.Lua.boss_BawangFlower.SkillMonsterBossBaWangFlowerSuperChargeAttack"

ExtRequire "Game.game_CS.Lua.boss_StoneFigure.MonsterBossStoneFigure" --boss 遗迹石像
ExtRequire "Game.game_CS.Lua.boss_StoneFigure.SkillMonsterBossStoneFigurerNorAttack" 
ExtRequire "Game.game_CS.Lua.boss_StoneFigure.SkillMonsterBossStoneFigureSuperStoneAttack"
ExtRequire "Game.game_CS.Lua.boss_StoneFigure.SkillMonsterBossStoneFigureSuperStoneBoomAttack"
ExtRequire "Game.game_CS.Lua.boss_StoneFigure.GoodsBossStone"

ExtRequire "Game.game_CS.Lua.boss_Sandworm.MonsterBossSandwormMain" --boss 沙漠巨虫(主体)
ExtRequire "Game.game_CS.Lua.boss_Sandworm.MonsterBossSandworm" --boss 沙漠巨虫
ExtRequire "Game.game_CS.Lua.boss_Sandworm.SkillMonsterBossSandWormLaserAttack"
ExtRequire "Game.game_CS.Lua.boss_Sandworm.SkillMonsterBossSandWormMainAttack"
ExtRequire "Game.game_CS.Lua.boss_Sandworm.SkillMonsterBossSandWormDropAttack"
ExtRequire "Game.game_CS.Lua.boss_Sandworm.SkillMonsterBossSandWormChaseAttack"
ExtRequire "Game.game_CS.Lua.boss_Sandworm.SkillMonsterBossSandWormFireAttack"

ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBoss3NorAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterBoss3SuperAttack"

ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterNorInfightAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterTotemAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillPlayerSuperCrashAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillPlayerGoldRush"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterSprintInfightAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemHeal"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemHpMaxUp"
ExtRequire "Game.game_CS.Lua.Skill.SkillInvincible"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemAddAttackSpeed2"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemAddAttackDamage2"

ExtRequire "Game.game_CS.Lua.Skill.SkillItemAddAttackSpeed"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemAddAttackDamage"
ExtRequire "Game.game_CS.Lua.Skill.SkillItemAddMoveSpeed"
ExtRequire "Game.game_CS.Lua.Skill.SkillSnakeCircleGroundAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterSRHAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterDashAttack"
ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterNorLaserAttack"

ExtRequire "Game.game_CS.Lua.FsmCtrl.FrozenCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.DizzinessCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.StationaryCtrl"

ExtRequire "Game.game_CS.Lua.Object.MonsterBoss"
ExtRequire "Game.game_CS.Lua.Object.MonsterTotem"
ExtRequire "Game.game_CS.Lua.Object.MonsterSnake"
ExtRequire "Game.game_CS.Lua.Object.MonsterXianrenzhang"
ExtRequire "Game.game_CS.Lua.Object.MonsterWind"
ExtRequire "Game.game_CS.Lua.Object.MonsterPrecious"
ExtRequire "Game.game_CS.Lua.Object.MonsterBossFireSnakeKing"-- boss 火焰蛇
ExtRequire "Game.game_CS.Lua.Object.MonsterBossMummy"

ExtRequire "Game.game_CS.Lua.Object.TargetIndicator"
ExtRequire "Game.game_CS.Lua.Object.Portal"
ExtRequire "Game.game_CS.Lua.Object.Connector1"
ExtRequire "Game.game_CS.Lua.Object.Connector2"
ExtRequire "Game.game_CS.Lua.Object.Connector3"

ExtRequire "Game.game_CS.Lua.FsmCtrl.HeadIntoHoleCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.HeadCircleMoveCtrl"

ExtRequire("Game.game_CS.Lua.Follow.FollowController")
ExtRequire("Game.game_CS.Lua.Follow.FollowModel")
ExtRequire("Game.game_CS.Lua.Follow.FollowView")

ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBossIdelCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBossCreateCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBossAttackCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBossSuperAttackCtrl"
ExtRequire "Game.game_CS.Lua.FsmCtrl.MonsterBossChaseCtrl"

ExtRequire("Game.game_CS.Lua.Poisoning")
ExtRequire("Game.game_CS.Lua.Slow")
ExtRequire("Game.game_CS.Lua.Firing")
ExtRequire("Game.game_CS.Lua.Bursting")
ExtRequire("Game.game_CS.Lua.TagCenter")
ExtRequire "Game.game_CS.Lua.HeroThreeChoseOnePanel"

--地图
ExtRequire("Game.game_CS.Lua.Map.MapCtrl")
ExtRequire("Game.game_CS.Lua.Map.MapModel")
ExtRequire("Game.game_CS.Lua.Map.MapView")
ExtRequire("Game.game_CS.Lua.Map.Building")
ExtRequire("Game.game_CS.Lua.Map.Grid")
ExtRequire("Game.game_CS.Lua.Map.MapLib")
ExtRequire("Game.game_CS.Lua.Map.MapBuilder")
ExtRequire("Game.game_CS.Lua.Map.GridBuilder")
ExtRequire("Game.game_CS.Lua.Map.MapBinding")
ExtRequire("Game.game_CS.Lua.activefloor.ActiveFloorSaw")
ExtRequire("Game.game_CS.Lua.activefloor.ActiveFloorPeng")
ExtRequire("Game.game_CS.Lua.activefloor.ActiveFloorZiDan")


ExtRequire("Game.game_CS.Lua.activefloor.ActiveFloorRockFall")
ExtRequire("Game.game_CS.Lua.AdsorbAnim")
ExtRequire("Game.game_CS.Lua.Object.BuildingGeraRollWood")
ExtRequire("Game.game_CS.Lua.Object.RollWood")
ExtRequire("Game.game_CS.Lua.Object.BuildingGeraRollWoodContinue")
ExtRequire("Game.game_CS.Lua.Object.RollWoodContinue")


ExtRequire("Game.CommonPrefab.Lua.StageModeA")
ExtRequire("Game.CommonPrefab.Lua.StageModeB")
ExtRequire("Game.CommonPrefab.Lua.StageModeC")


ExtRequire("Game.game_CS.Lua.SetHeroPanel")
ExtRequire("Game.game_CS.Lua.SetHero2Panel")
ExtRequire("Game.game_CS.Lua.HeroUpPanel")
ExtRequire("Game.game_CS.Lua.HeroLengthUpPanel")
ExtRequire("Game.game_CS.Lua.MainUIPanel")
ExtRequire("Game.game_CS.Lua.DropAsset")
ExtRequire "Game.game_CS.Lua.HeadSkillManager"
ExtRequire "Game.game_CS.Lua.HeadSkillPanel"

ExtRequire "Game.game_CS.Lua.Skill.SkillFuzhuFunctions"
ExtRequire "Game.game_CS.Lua.MonsterProfession.MonsterProfessionManager"

ExtRequire "Game.game_CS.Lua.Skill.SkillMonsterSmallCactusNorAttack"

GameObjectType = {
	hero = 1 ,
	monster = 2 ,
	bullet = 3,

}


local this
function M.Init()
    if not this then
        M.InitMonsterConfig()

    	M.InitComponentConfig()
        M.InitNewStageConfig()
        M.InitBulletConfig()
        M.InitHeroConfig()
        M.InitSkillItemConfig()
        M.InitHeroHeadConfig()
        M.InitGongjuConfig()
        M.InitGongjuCfg()
        M.InitAwardConfig()
        M.InitBoxConfig()
        M.InitSKillConfig()
        M.InitSkillClassifyConfig()

        M.InitCommonAwardConfig()
        this = M
    end
end

function M.Clear()

end


--组件配置
local unity_component_config = ExtRequire("Game.CommonPrefab.Lua.unity_component_config")
local component_base_config = ExtRequire("Game.CommonPrefab.Lua.component_base_config")

function M.InitComponentConfig()
    local building = {
        box = "box",
        shrub = "shrub",
        jar = "jar",
        water = "water",
        spike = "spike",
        saw = "saw",
        rollWood = "rollWood",
        gearRollWood = "gearRollWood",
        ThreeChooseOne = "ThreeChooseOne",
        wall = "wall",
        ActiveFloorPeng = "ActiveFloorPeng",
        ActiveFloorZiDan = "ActiveFloorZiDan",
    }

    for key, value in pairs(unity_component_config.main) do
        if building[value.comType] then
            --建筑
            value.keyType = "building"
            for k, v in pairs(component_base_config.building[value.data_id]) do
                if k == "assist_attr" then
                    for k1, v1 in pairs(component_base_config.building_assist_attr[v]) do
                        value[k1] = v1
                    end
                end
                value[k] = v
            end
        elseif value.comType == "monster" then
            --怪物
            value.keyType = "monster"

            for k, v in pairs( M.monster_config[value.data_id] ) do
                value[k] = v
            end

        elseif value.comType == "prop" then
            --道具
            value.keyType = "prop"
            for k, v in pairs(component_base_config.prop[value.data_id]) do
                value[k] = v
            end
        else
            --其它
            value.keyType = "normal"
        end
    end
end

function M.GetComponentConfig()
    return unity_component_config
end

local normal_stage_config = ExtRequire("Game.CommonPrefab.Lua.normal_stage_config")

function M.InitNewStageConfig()
    --M.InitMonsterFinalConfig(normal_stage_config)

    -- 配置转化

    -- 房间信息处理
    local roomInfo = {}
    if normal_stage_config.room_info then
        for i,v in ipairs(normal_stage_config.room_info) do
            local rtf = roomInfo[v.type] or {}
            roomInfo[v.type] = rtf
            table.insert(rtf,v.room)
        end
    end
    normal_stage_config.room_info = roomInfo


    if normal_stage_config.main then
        for key,data in pairs( normal_stage_config.main ) do
            if data.valueFactor and type(data.valueFactor) == "number" then
                data.valueFactorData = basefunc.deepcopy( normal_stage_config.valueFactor[data.valueFactor] or {} )
                if not next(data.valueFactorData) then
                    data.valueFactorData = nil
                end
            end

            data.room = {}
            for i=1,20 do
                local rm = data["room_"..i]
                if rm then
                    table.insert(data.room,rm)
                    data["room_"..i] = nil
                end
            end

            local relation = {}
            local emi = data.end_room or #data.room
            for i=2,emi do
                table.insert(relation,{i})
            end
            table.insert(relation,{})

            if data.relation then
                local rss = string.split(data.relation,"/")
                for ri,rs in ipairs(rss) do
                    local r = string.split(rs,"*")
                    for ri,rv in ipairs(r) do
                        local crv = tonumber(rv)
                        r[ri] = crv or rv
                    end
                    local ri = r[1]
                    table.remove(r,1)
                    local rt = r
                    relation[ri] = rt
                end
            end
            data.relation = relation

            -- 隐藏金币房间处理
            if data.tag == 1 then
                local gt = roomInfo["gold"]
                local gi = math.random(#gt)
                table.insert(data.room,gt[gi])
                data.gold_roomNo = #data.room
            end

        end
    end


    dump(normal_stage_config.main,"nnnnnnnnnnssssssssssssssssccccccccccccccc")
end

--- 获取全部配置
function M.GetStageAllCfg( )
    return normal_stage_config 
end

--- 获取关卡的主要配置
function M.GetStageMainCfg(stage)
    return normal_stage_config.main[ stage ]
end

function M.ClearStageConfigByStage(stage)
    M.stage_config_list[stage] = nil
end

--- 获取 在某一关，指定金币数量是哪个金币等级
function M.GetGoldLevel( stage , gold )
    local level = 1
    local d = { key = "goldCoin2" }
    if d.key then
        DataInfoToConfig(d)

        NorStageFinalDataToDataInfo(d , stage)

        NorStageValueFactorToDataInfo(d , stage )
    end

    if d.data and type(d.data) == "table" and #d.data == 2 then
        if gold > d.data[2] then
            level = 3
        elseif gold < d.data[1] then
            level = 1
        else
            level = 2
        end

    end
    return level
end

--- 获取 在某一关，指定金币数量是哪个金币等级
function M.GetGoldConfig( stage , level )
    local d = { key = "goldCoin" .. level }
    if d.key then
        DataInfoToConfig(d)

        NorStageFinalDataToDataInfo(d , stage)

        NorStageValueFactorToDataInfo(d , stage )
    end

    return d.data
    
end

--- 获取 金币 一个等级 相比 另一个等级的 倍数
function M.GetGoldLevelBeiShu( stage , nowLevel , judgeLevel )
    local nowData = M.GetGoldConfig( stage , nowLevel )
    
    local judgeData = M.GetGoldConfig( stage , judgeLevel )

    local function get_value (_data)
        local value = 1
        if _data and type(_data) == "table" and #_data >= 2 then
            value = _data[1] + _data[2]
        elseif _data and type(_data) == "number" then
            value = _data
        end
        return value
    end

    local nowValue = get_value(nowData)
    local judgeValue = get_value(judgeData)
    
    return math.floor( nowValue / judgeValue )
end

------------------------------------关卡配置---------------------------------------
------------------------------------关卡配置---------------------------------------
------------------------------------关卡配置---------------------------------------

function M.ResetStageMonsterData(stage,roomNo,lot,data)
    -- dump(stage)
    -- dump(roomNo)
    -- dump(lot)
    -- dump(data)
    local _d = M.stage_config_list[stage].room_data[roomNo].stage_data[lot].monster_fixed_data
    _d[#_d + 1] = data
end

function M.ResetStageGemData(stage,roomNo,lot,data)
    M.stage_config_list[stage].room_data[roomNo].stage_data[lot].gem_data = M.stage_config_list[stage].room_data[roomNo].stage_data[lot].gem_data or {}
    local _d = M.stage_config_list[stage].room_data[roomNo].stage_data[lot].gem_data
    _d[#_d + 1] = data
end

function M.GetStageConfig(stage,roomNo)
    -- dump({stage = stage,roomNo = roomNo},"<color=yellow>stage roomNo :</color>")
    if not M.stage_config_list or not next(M.stage_config_list) then
        return
    end
    if not M.stage_config_list[stage] or not M.stage_config_list[stage].room_data then
        return
    end
    -- dump(M.stage_config_list[stage].room_data,"<color=yellow>M.stage_config_list[stage].room_data :</color>")
    return M.stage_config_list[stage].room_data[roomNo]
end

function M.GetLevelConfig(stage)
    if not M.stage_config_list or not next(M.stage_config_list) then
        return
    end
    if not M.stage_config_list[stage] then
        return
    end

    return M.stage_config_list[stage]
end

--波次相关数据
function M.CreateWaveNumberCfg(roomInfo,dataInfo,gameObject)
    if not dataInfo or dataInfo.comType ~= "waveNumber" then
        return
    end
    --波次
    local stageInfo = {
        pass_type = dataInfo.pass_type,
        pass_data = dataInfo.pass_data,
        time = dataInfo.time,
        monster_fixed_data = {},
        monster_time_data = {},
        prop_time_data = {},
        gem_data = {},
    }
    local childDataInfos = gameObject:GetComponentsInChildren(typeof(DataInfo),true)
    local childGo
    local childDataInfo
    for i = 0, childDataInfos.Length - 1 do
        childGo = childDataInfos[i].gameObject
        childDataInfo = GetDataInfo(childGo)
        if childDataInfo.comType == "monster" then
            childDataInfo.use_id = childDataInfo.id
            childDataInfo.pos = childGo.transform.position
            stageInfo.monster_fixed_data[#stageInfo.monster_fixed_data+1] = childDataInfo

        elseif childDataInfo.comType == "goodsGem" then
            --宝石
            stageInfo.gem_data[#stageInfo.gem_data+1] = childGo.transform.position
        end

        if childDataInfo.key == "monster_time_hatch" then
            --怪物时间类孵化器
            table.insert(stageInfo.monster_time_data,{
                pos = childGo.transform.position,
                interval = childDataInfo.interval,
                monsters = childDataInfo.monsters,
                max = childDataInfo.max,
                r = childDataInfo.r,
            })
        end

        if childDataInfo.key == "prop_time_hatch" then
            --道具时间类孵化器
            local propType = {
                [1] = "item_heal",
                [2] = "hit_speed_up",
                [3] = "run_speed_up",
            }
            local props = {}
            for pi,pv in ipairs(childDataInfo.props) do
                table.insert(props,propType[pv])
            end
            table.insert(stageInfo.prop_time_data,{
                pos = childGo.transform.position,
                interval = childDataInfo.interval,
                props = props,
                max = childDataInfo.max,
                r = childDataInfo.r,
            })
        end

    end

    roomInfo.stage_data = roomInfo.stage_data or {}
    roomInfo.stage_data[dataInfo.waveNumber] = stageInfo
end

--道路配置
function M.CreateRoomRoadCfg(roomInfo,dataInfo,stageId,roomNo,gameObject)
    if dataInfo.comType == "connect" then
        roomInfo.connect = roomInfo.connect or {}
        local cnd = {}
        table.insert(roomInfo.connect,cnd)

        local relation
        if normal_stage_config.main[stageId].relation then
            relation = normal_stage_config.main[stageId].relation[roomNo]
        else
            if roomNo < #normal_stage_config.main[stageId].room then
                relation = {roomNo + 1}
            end
        end
        
        if relation then
            local n = #roomInfo.connect
            cnd.next_room = relation[n]
        end

        cnd.connect_type = dataInfo.connect_type
        cnd.connect_cond = dataInfo.connect_cond
        cnd.connect_name = dataInfo.connect_name
        if dataInfo.connect_type == 1 then
            --道路连接器
            cnd.pos = gameObject.transform.position
            cnd.dir = "up_down"
            if gameObject.transform.childCount > 0 then
                local road = gameObject.transform:GetChild(0)
                if IsEquals(road) then
                    cnd.dir = road.gameObject.name
                    cnd.dir = string.gsub(cnd.dir,"tongdao_","")
                end 
            end

            --有道路的情况
            local childs = gameObject:GetComponentsInChildren(typeof(DataInfo))
            local road
            local roadInfo

            cnd.size = {w = 0,h = 0}
            cnd.endPos = gameObject.transform.position
            cnd.pos = gameObject.transform.position

            for j = 0, childs.Length - 1 do
                road = childs[j].gameObject
                roadInfo = GetDataInfo(road)
                if roadInfo.key == "road" then
                    cnd.endPos = road.gameObject.transform:Find("endPos").transform.position
                    cnd.size = roadInfo.size
                    cnd.colls = {}
                    local notPassNode = road.transform:Find("NotPassNode")
                    if IsEquals(notPassNode) then
                        local colls = notPassNode.transform:GetComponentsInChildren(typeof(UnityEngine.Collider2D))
                        for i = 0, colls.Length - 1 do
                            local coll = colls[i]
                            local t = {}
                            t.collPos = {x = coll.bounds.center.x, y = coll.bounds.center.y}
                            if gameObject.transform.localRotation.z == 90 or gameObject.transform.localRotation.z == -90 then
                                t.collSize = { w = coll.bounds.extents.y * 2, h = coll.bounds.extents.x * 2}
                            else
                                t.collSize = { w = coll.bounds.extents.x * 2, h = coll.bounds.extents.y * 2}
                            end
                            cnd.colls[#cnd.colls+1] = t
                            coll.enabled = false
                        end
                    end
                end
            end
        elseif dataInfo.connect_type == 2 then
            --传送连接器
            cnd.size = {w = 0,h = 0}
            cnd.endPos = gameObject.transform.position
            cnd.pos = gameObject.transform.position
        elseif dataInfo.connect_type == 3 then
            cnd.size = {w = 0,h = 0}
            cnd.endPos = gameObject.transform.position
            cnd.pos = gameObject.transform.position
        end
    elseif dataInfo.comType == "startPos" then
        roomInfo.startPos = roomInfo.startPos or {}
        roomInfo.startPos[#roomInfo.startPos+1] = gameObject.transform.position
    elseif dataInfo.comType == "endPos" then
        --起终点
        roomInfo.endPos = roomInfo.endPos or {}
        roomInfo.endPos[#roomInfo.endPos+1] = gameObject.transform.position
    end
end

--建筑配置
function M.CreateBuildingCfg(roomInfo,dataInfo,gameObject)
    if not dataInfo or dataInfo.keyType ~= "building" then
        return
    end
    roomInfo.building = roomInfo.building or {}
    roomInfo.building[#roomInfo.building+1] = dataInfo
end

function M.CreateRoomConfig(stageId,roomNo,go)
    -- dump({stageId,roomNo},"<color=green>房间配置生成</color>")
    -- dump(normal_stage_config,"<color=green>关卡配置？？？？？？</color>"
    local roomDataInfo = GetDataInfo(go)
    local roomInfo = {}
    if not roomDataInfo or roomDataInfo.type ~= "room" then
        return roomInfo
    end
    --房间
    roomInfo = roomDataInfo
    roomInfo.pos = go.transform.position
    roomInfo.roomNo = roomNo
    roomInfo.prefab = go.name
    roomInfo.stage_data = {}
    roomInfo.building = {}

    local roomChildInfos = go:GetComponentsInChildren(typeof(DataInfo))
    local roomChildDataInfo
    local roomChildGo
    for i = 0, roomChildInfos.Length - 1 do
        roomChildGo = roomChildInfos[i].gameObject
        roomChildDataInfo = GetDataInfo(roomChildGo)

        M.CreateWaveNumberCfg(roomInfo,roomChildDataInfo,roomChildGo)
        M.CreateRoomRoadCfg(roomInfo,roomChildDataInfo,stageId,roomNo,roomChildGo)
        M.CreateBuildingCfg(roomInfo,roomChildDataInfo,roomChildGo)
    end

    return roomInfo
end

function M.CreateStageStruct(rooms,stageId,style)
    --方向就是上下左右
    local dir = {
        up = "up",
        down = "down",
        left = "left",
        right = "right",
    }
    --路的类型，房间不允许同方向相连
    local road = {
        up = {
            down = "up_down",
            left = "up_left",
            right = "up_right",
        },
        down = {
            up = "down_up",
            left = "down_left",
            right = "down_right",
        },
        left = {
            up = "left_up",
            down = "left_down",
            right = "left_right",
        },
        right = {
            up = "right_up",
            down = "right_down",
            left = "right_left",
        },
    }

    local dirList = {
        up = {
            "down",
            "right",
            "left",
        },
        down = {
            "up",
            "right",
            "left",
        },
        left = {
            "right",
            "up",
            "down",
        },
        right = {
            "left",
            "up",
            "down",
        }
    }

    local function getRoomRoadInfo(roomGo,stageId,roomNo)
        local components = roomGo:GetComponentsInChildren(typeof(DataInfo))
        local roomInfo = {}
        for i = 0, components.Length - 1 do
            local gameObject = components[i].gameObject
            local dataInfo = GetDataInfo(gameObject)
            M.CreateRoomRoadCfg(roomInfo,dataInfo,stageId,roomNo,gameObject)
            if dataInfo.comType == "connect" then
                roomInfo.connect[#roomInfo.connect].gameObject = gameObject
            elseif dataInfo.comType == "startPos" then
            elseif dataInfo.comType == "endPos" then
            end
        end
        -- dump(roomInfo,"<color=yellow>房间道路配置</color>")
        return roomInfo
    end

     --生成关卡结构
    local roomGos = {}
    for i, roomId in ipairs(rooms) do
        local roomPre = "room_" .. roomId
        local roomGo = NewObject(roomPre,MapManager.GetMapNode())
        roomGo.transform.position = Vector3.zero
        roomGos[i] = roomGo
    end

    local hideMonster = function (roomGo)
        local component = roomGo:GetComponentsInChildren(typeof(DataInfo))
        for j = 0, component.Length - 1 do
            local componentGo = component[j].gameObject
            local componentInfo = GetDataInfo(componentGo)
            -- dump({componentGo.name,componentInfo},"<color=yellow>组件信息</color>")
            if componentInfo.comType == "waveNumber" then
                for k = 0, componentGo.transform.childCount - 1 do
                    local sc = componentGo.transform:GetChild(k):GetComponent(typeof(DataInfo))
                    if IsEquals(sc) then
                        local scInfo = GetDataInfo(sc.gameObject)
                        if scInfo.comType == "monster" then
                            sc.gameObject:SetActive(false)
                        end
                    end
                end
            end
        end
    end

    for i, v in ipairs(roomGos) do
        hideMonster(v) 
    end

    local checkDir = function (size,pos)
        local xMax = size.w / 2
        local xMin = -size.w / 2
        local yMax = size.h / 2
        local yMin = -size.h / 2
        local angle1 = Vec2DAngle({x = xMax,y = yMax})
        local angle2 = Vec2DAngle({x = xMin,y = yMax})
        local angle3 = Vec2DAngle({x = xMin,y = yMin})
        local angle4 = Vec2DAngle({x = xMax,y = yMin})
        local angle = Vec2DAngle(pos)
        if angle <= angle1 or angle > angle4 then
            return dir.right
        elseif angle <= angle2 and angle > angle1 then
            return dir.up
        elseif angle <= angle3 and angle > angle2 then
            return dir.left
        elseif angle <= angle4 and angle > angle3 then
            return dir.down
        end
    end

    local levelInfoList = {}
    local levelInfoDic = {}
    local levelInfoHideRoomList = {}
    local levelInfoHideRoomDic = {}
    --生成关卡配置
    for i, v in ipairs(rooms) do
        local roomGo =  roomGos[i]
        local roomInfo = GetDataInfo(roomGo)
        local roomRoadInfo = getRoomRoadInfo(roomGo,stageId,i)
        for key, value in pairs(roomRoadInfo) do
            if key == "startPos" then
                for i, v in ipairs(value) do
                    roomRoadInfo.startPosDir = roomRoadInfo.startPosDir or {}
                    roomRoadInfo.startPosDir[i] = checkDir(roomInfo.size,v)
                end
            elseif key == "connect" then
                for i, v in ipairs(value) do
                    if v.pos then
                        roomRoadInfo.connectDir = roomRoadInfo.connectDir or {}
                        roomRoadInfo.connectDir[i] = checkDir(roomInfo.size,v.pos) 
                    end
                end
            end
        end

        local data = {
            roomId = v,
            roomGo = roomGo,
            roomInfo = roomInfo,
            roomRoadInfo = roomRoadInfo
        }
        if data.roomInfo.roomType == "hide" then
            --隐藏房间
            levelInfoHideRoomList[#levelInfoHideRoomList+1] = data
            levelInfoHideRoomDic[i] = data
        else
            --其它房间
            levelInfoList[#levelInfoList+1] = data
            levelInfoDic[i] = data
        end

        -- levelInfoList[i] = data

        -- if i == 1 then
        --     roomGo.transform.position = Vector3.zero
        -- else
        --     local frontRoomInfo = GetDataInfo(roomGos[i - 1])
        --     local y = roomGos[i - 1].transform.position.y + frontRoomInfo.size.h / 2 + roomInfo.size.h / 2
        --     roomGo.transform.position = Vector3.New(0,y,0)
        -- end
    end

    -- dump(levelInfoList,"<color=yellow>levelInfoList</color>",100)

    local function getNextRoomStartPosIndex(connectDir,nextRoomRoadInfo)
        local spIndex
        for index, value in ipairs(dirList[connectDir]) do
            for i, v in ipairs(nextRoomRoadInfo.startPosDir or {}) do
                --下一个房间的连接器没有用过
                if v == value and (not nextRoomRoadInfo.startPosUse or not nextRoomRoadInfo.startPosUse[i]) then
                    spIndex = i
                end
            end
        end

        if not spIndex then
            dump(levelInfoList,"<color=yellow>levelInfoList</color>")
            dump(connectDir,"<color=yellow>connectDir</color>")
            dump(nextRoomRoadInfo,"<color=yellow>nextRoomRoadInfo</color>")
            error("！！！！！！！！！！！！！！地图配置错误")
        end

        return spIndex
    end

    --根据关卡配置调整结构
    for i = 1, #levelInfoList, 1 do
        local curRoom = levelInfoList[i]
        --第一个房间就在原来的位置，从第一个房间开始往后面设置
        if curRoom and curRoom.roomRoadInfo.connect and next(curRoom.roomRoadInfo.connect) then
            for index, value in ipairs(curRoom.roomRoadInfo.connect) do
                if value.next_room and levelInfoDic[value.next_room] then
                    local nextRoom = levelInfoDic[value.next_room]
                    local cd = curRoom.roomRoadInfo.connectDir[index]
                    local ci = getNextRoomStartPosIndex(cd,nextRoom.roomRoadInfo)
                    nextRoom.roomRoadInfo.startPosUse = nextRoom.roomRoadInfo.startPosUse or {}
                    if ci then
                        nextRoom.roomRoadInfo.startPosUse[ci] = true
                        --放到最合适的位置即可
                        local sd = nextRoom.roomRoadInfo.startPosDir[ci]
                        --路
                        local cr = road[cd][sd]
                        -- dump({i,cr},"<color=yellow>选择的路</color>")
                        local tongdaoName = "tongdao_" .. cr
                        --匹配不同风格道路
                        if style and style ~= "" then
                            tongdaoName = tongdaoName .. "_" .. style
                        end
                        --拼接房间和道路P
                        local roadGo = NewObject(tongdaoName,curRoom.roomRoadInfo.connect[index].gameObject.transform)
                        roadGo.name = "tongdao_" .. cr
                        local roadSGo = roadGo.transform:Find("startPos")
                        local roadEGo = roadGo.transform:Find("endPos")
                        --道路和起点位置的偏移
                        local roadSO = roadGo.transform.position - roadSGo.transform.position

                        --下个房间中心点和房间的偏移
                        local roomSO = -nextRoom.roomRoadInfo.startPos[index]
                        
                        roadGo.transform.position = curRoom.roomRoadInfo.connect[index].gameObject.transform.position + roadSO
                        nextRoom.roomGo.transform.position = roadEGo.transform.position + roomSO
                    end
                end
            end
        end
    end

    local hideOffsetY = -100
    for i = 1, #levelInfoHideRoomList, 1 do
        local curRoom = levelInfoHideRoomList[i]
        if curRoom then
            curRoom.roomGo.transform.position = Vector3.New(0,hideOffsetY,0)
            hideOffsetY = hideOffsetY + hideOffsetY
        end
    end

    return roomGos
end

--根据连接情况连接器的size，保证一定能通过连接器
function M.CorrectionConnectSize(levelInfo)
    local roomInfo
    local connectInfo
    for i = 1, #levelInfo do
        roomInfo = levelInfo[i]
        if roomInfo.connect and next(roomInfo.connect) then
            for j = 1, #roomInfo.connect do
                connectInfo = roomInfo.connect[j]
                if connectInfo.connect_type == 1 and connectInfo.next_room then
                    --道路连接器
                    if connectInfo.dir == "up_down" then
                        local connectMinY = connectInfo.pos.y
                        local connectMaxY = connectInfo.pos.y + connectInfo.size.h
                        local roomMinY = roomInfo.pos.y - roomInfo.size.h / 2
                        local roomMaxY = roomInfo.pos.y + roomInfo.size.h / 2
                        local realMinY = connectMinY 
                        local realMaxY = connectMaxY

                        if not(connectMinY < roomMaxY and roomMaxY - connectMinY >= 1.6 * 2 )then
                            --最下边寻路格子没有和房间重合
                            realMinY = roomMaxY - 1.6 * 2
                        end

                        local nextRoomInfo = levelInfo[connectInfo.next_room]
                        local nextRoomMinY = nextRoomInfo.pos.y - nextRoomInfo.size.h / 2
                        local nextRoomMaxY = nextRoomInfo.pos.y + nextRoomInfo.size.h / 2
                        if not(connectMaxY > nextRoomMinY and connectMaxY - nextRoomMinY >= 1.6 * 2 )then
                            --最上边边寻路格子没有和房间重合
                            realMaxY = nextRoomMinY + 1.6 * 2
                        end

                        --根据real尺寸调整连接器尺寸
                        local realOffset = realMaxY - realMinY
                        if realOffset > connectInfo.size.h then
                            local h = math.ceil((realMaxY - realMinY) / 1.6)
                            h = h % 2 == 0 and h or h + 1
                            h = h * 1.6
                            local center = (realMaxY - realMinY) / 2 + realMinY
                            local offsetH = (realMaxY - realMinY) - (connectMaxY - connectMinY)
                            connectInfo.aStarSize = {
                                w = connectInfo.size.w,
                                h = h,
                            }
                            connectInfo.aStarPos = {
                                x = connectInfo.pos.x,
                                y = center,
                                z = connectInfo.pos.z,
                            }
                        else
                            connectInfo.aStarSize = connectInfo.size
                            connectInfo.aStarPos ={
                                x = connectInfo.pos.x,
                                y = connectInfo.pos.y + connectInfo.aStarSize.h / 2,
                                z = connectInfo.pos.z,
                            } 
                        end
                    elseif connectInfo.dir == "down_up" then
                        local connectMinY = connectInfo.pos.y - connectInfo.size.h
                        local connectMaxY = connectInfo.pos.y
                        local roomMinY = roomInfo.pos.y - roomInfo.size.h / 2
                        local roomMaxY = roomInfo.pos.y + roomInfo.size.h / 2
                        local realMinY = connectMinY 
                        local realMaxY = connectMaxY

                        if not(connectMaxY > roomMinY and connectMaxY - roomMinY >= 1.6 * 2 )then
                            --最上边边寻路格子没有和房间重合
                            realMaxY = roomMinY + 1.6 * 2
                        end

                        local nextRoomInfo = levelInfo[connectInfo.next_room]
                        local nextRoomMinY = nextRoomInfo.pos.y - nextRoomInfo.size.h / 2
                        local nextRoomMaxY = nextRoomInfo.pos.y + nextRoomInfo.size.h / 2
                        if not(connectMinY < nextRoomMaxY and nextRoomMaxY - connectMinY >= 1.6 * 2 )then
                            --最上边边寻路格子没有和房间重合
                            realMinY = nextRoomMaxY - 1.6 * 2
                        end

                        --根据real尺寸调整连接器尺寸
                        local realOffset = realMaxY - realMinY
                        if realOffset > connectInfo.size.h then
                            local h = math.ceil((realMaxY - realMinY) / 1.6)
                            h = h % 2 == 0 and h or h + 1
                            h = h * 1.6
                            local center = (realMaxY - realMinY) / 2 + realMinY
                            local offsetH = (realMaxY - realMinY) - (connectMaxY - connectMinY)
                            connectInfo.aStarSize = {
                                w = connectInfo.size.w,
                                h = h,
                            }
                            connectInfo.aStarPos = {
                                x = connectInfo.pos.x,
                                y = center,
                                z = connectInfo.pos.z,
                            }
                        else
                            connectInfo.aStarSize = connectInfo.size
                            connectInfo.aStarPos ={
                                x = connectInfo.pos.x,
                                y = connectInfo.pos.y + connectInfo.aStarSize.h / 2,
                                z = connectInfo.pos.z,
                            } 
                        end
                    elseif connectInfo.dir == "left_right" then
                        local connectMin = connectInfo.pos.x - connectInfo.size.w
                        local connectMax = connectInfo.pos.x
                        local roomMin = roomInfo.pos.x - roomInfo.size.w / 2
                        local roomMax = roomInfo.pos.x + roomInfo.size.w / 2
                        local realMin = connectMin
                        local realMax = connectMax

                        if not(connectMax > roomMin and connectMax - roomMin >= 1.6 * 2 )then
                            --最右边寻路格子没有和房间重合
                            realMax = roomMin + 1.6 * 2
                        end

                        local nextRoomInfo = levelInfo[connectInfo.next_room]
                        local nextRoomMin = nextRoomInfo.pos.x - nextRoomInfo.size.w / 2
                        local nextRoomMax = nextRoomInfo.pos.x + nextRoomInfo.size.w / 2
                        if not(connectMin < nextRoomMax and nextRoomMax - connectMin >= 1.6 * 2 )then
                            --最左边边边寻路格子没有和房间重合
                            realMin = nextRoomMax - 1.6 * 2
                        end

                        --根据real尺寸调整连接器尺寸
                        local realOffset = realMax - realMin
                        if realOffset > connectInfo.size.w then
                            local realSize = math.ceil((realMax - realMin) / 1.6)
                            realSize = realSize % 2 == 0 and realSize or realSize + 1
                            realSize = realSize * 1.6
                            local center = (realMax - realMin) / 2 + realMin
                            connectInfo.aStarSize = {
                                w = realSize,
                                h = connectInfo.size.h,
                            }
                            connectInfo.aStarPos = {
                                x = center,
                                y = connectInfo.pos.y,
                                z = connectInfo.pos.z,
                            }
                        else
                            connectInfo.aStarSize = connectInfo.size
                            connectInfo.aStarPos ={
                                x = connectInfo.pos.x + connectInfo.aStarSize.w / 2,
                                y = connectInfo.pos.y,
                                z = connectInfo.pos.z,
                            }
                        end
                    elseif connectInfo.dir == "right_left" then
                        local connectMin = connectInfo.pos.x
                        local connectMax = connectInfo.pos.x + connectInfo.size.w
                        local realMin = connectMin
                        local realMax = connectMax

                        local roomMin = roomInfo.pos.x - roomInfo.size.w / 2
                        local roomMax = roomInfo.pos.x + roomInfo.size.w / 2
                        if not(connectMin < roomMax and roomMax - connectMin >= 1.6 * 2 )then
                            --最左边边寻路格子没有和房间重合
                            realMin = roomMax - 1.6 * 2
                        end

                        local nextRoomInfo = levelInfo[connectInfo.next_room]
                        local nextRoomMin = nextRoomInfo.pos.x - nextRoomInfo.size.w / 2
                        local nextRoomMax = nextRoomInfo.pos.x + nextRoomInfo.size.w / 2
                        if not(connectMax > nextRoomMin and connectMax - nextRoomMin >= 1.6 * 2 )then
                            --最右边边寻路格子没有和房间重合
                            realMax = nextRoomMin + 1.6 * 2
                        end

                        --根据real尺寸调整连接器尺寸
                        local realOffset = realMax - realMin
                        if realOffset > connectInfo.size.w then
                            local realSize = math.ceil((realMax - realMin) / 1.6)
                            realSize = realSize % 2 == 0 and realSize or realSize + 1
                            realSize = realSize * 1.6
                            local center = (realMax - realMin) / 2 + realMin
                            connectInfo.aStarSize = {
                                w = realSize,
                                h = connectInfo.size.h,
                            }
                            connectInfo.aStarPos = {
                                x = center,
                                y = connectInfo.pos.y,
                                z = connectInfo.pos.z,
                            }
                        else
                            connectInfo.aStarSize = connectInfo.size
                            connectInfo.aStarPos ={
                                x = connectInfo.pos.x + connectInfo.aStarSize.w / 2,
                                y = connectInfo.pos.y,
                                z = connectInfo.pos.z,
                            }
                        end
                    end

                end
            end
        end
    end
end

function M.GetStyleByStage(stage)
    local checkStyle = function (style)
        if not style then
            style = ""
        end
        if style == "maya" then
            style = ""
        end
        return style
    end
    for k, v in pairs(normal_stage_config.style) do
        for i, value in ipairs(v.stage) do
            if value[1] <= stage and value[2] >= stage then
                return checkStyle(k)
            end
        end
    end
    return checkStyle()
end

--根据预制体生成当前关卡信息
function M.CreateStageConfig(stage)
    local levelInfo = {}
    local roomGos
    local style = M.GetStyleByStage(stage)
    dump(style,"<color=yellow>关卡风格？？？？？</color>")

    if normal_stage_config.main[stage] then

        -- 重新随机金币房间
        local grn = normal_stage_config.main[stage].gold_roomNo
        if grn then
            local gt = normal_stage_config.room_info["gold"]
            local gi = math.random(#gt)
            normal_stage_config.main[stage].room[grn] = gt[gi]
        end

        local rooms = normal_stage_config.main[stage].room

        --生成关卡结构
        roomGos = M.CreateStageStruct(rooms,stage,style)

        --生成关卡配置
        for i, v in ipairs(rooms) do
            local roomInfo = M.CreateRoomConfig(stage,i,roomGos[i])
            levelInfo[#levelInfo+1] = roomInfo
        end
    else
        error("stage no cfg",stage)
    end

    --根据连接情况调整连接器的size，保证一定能通过连接器
    M.CorrectionConnectSize(levelInfo)

    --设置门牌号
    local addMenTxt = function ()
        local maxRoom = 0
        for i, v in ipairs(levelInfo) do
            if v.roomType ~= "hide" then
                maxRoom = maxRoom + 1
            end
        end

        local curIndex = 1
        for i, roomGo in ipairs(roomGos) do
            if levelInfo[i].roomType ~= "hide" then
                local TMP_Text = roomGo:GetComponentsInChildren(typeof(TMPro.TMP_Text))
                for j = 0, TMP_Text.Length - 1 do
                    if TMP_Text[j].gameObject.name == "@men_txt" then
                        TMP_Text[j].text = curIndex .. "/" .. maxRoom
                    end
                end
                curIndex = curIndex + 1
            end
        end
    end
    addMenTxt()

    --为门添加墙壁
    local addMenWall = function ()
        for i, roomData in ipairs(levelInfo) do
            local isNextRoom = false
            if roomData.connect and next(roomData.connect) then
                for index, value in ipairs(roomData.connect) do
                    if value.next_room then
                        isNextRoom = true
                        break
                    end
                end
            end

            --不能到下一个房间
            if not isNextRoom then
                local roomGo = roomGos[i]
                local TMP_Text = roomGo:GetComponentsInChildren(typeof(TMPro.TMP_Text))
                for j = 0, TMP_Text.Length - 1 do
                    if TMP_Text[j].gameObject.name == "@men_txt" then
                        if TMP_Text[j].transform.parent.localPosition.y > 0 then
                            --只改上面的房间
                            local qb = TMP_Text[j].transform.parent:Find("MenQiangBi")
                            NewObject("men_qiangbi",qb.transform)
                        end
                    end
                end
            end
        end
    end
    addMenWall()

    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
    else
        local debugLog = function (roomInfo)
            -- if true then return end
            local buildings = roomInfo.building
            roomInfo.building = nil
            dump(roomInfo,"<color=green>房间配置</color>",100)
            dump(buildings,"<color=green>房间建筑配置</color>",100)
            roomInfo.building = buildings
            buildings = nil
        end
        for i = 1, #levelInfo do
            debugLog(levelInfo[i])
        end
    end

    M.stage_config_list = M.stage_config_list or {}
    M.stage_config_list[stage] = M.stage_config_list[stage] or {}
    M.stage_config_list[stage].room_data = levelInfo
    M.stage_config_list[stage].roomGos = roomGos
    M.stage_config_list[stage].style = style

end

-- 获取一个阶段的随机怪物数据
function M.GetStageRandomMonsterData(level,roomNo,stage)
    local sc = M.GetStageConfig(level,roomNo)
    local sd = sc.stage_data[stage]

    if sc.mode == "C" then
        
        local mn = sd.monster_num_data

        local mdh = {}
        for i=1,mn do
                
            local md = nil
            local wa = math.random(sd.monster_weight_data_sum)
            for wi,wd in ipairs(sd.monster_weight_data) do
                wa = wa - wd
                if wa < 1 then
                    md = sd.monster_attr_data[wi]
                    mdh[wi] = (mdh[wi] or 0) + 1
                    break
                end
            end

        end

        local monsters = {}
        for k,v in pairs(mdh) do
            local md = sd.monster_attr_data[k]
            table.insert(monsters,{type=md.type,level=md.level,num=v})
        end

        if sd.boss_data then
            table.insert(monsters,{type=sd.boss_data.type,level=sd.boss_data.level,num=1})
        end
        
        local pos = Vector3.New(sd.monster_create_pos[1],sd.monster_create_pos[2],0)

        return {{
            monsters = monsters,
            pos = pos,
            radius = sd.monster_create_radius,
        },}

    elseif sc.mode == "B" then

        local monsters = {}
        
        if sd.boss_data then
            table.insert(monsters,{
                type = sd.boss_data.type,
                level = sd.boss_data.level,
                num = 1,
                gem_data = sd.gem_data,
            })
        end
        
        return {{
            monsters = monsters,
        },}

    elseif sc.mode == "A" then
        
        local mn = sd.monster_num_data

        local mdh = {}
        if mn then
            for i=1,mn do
                    
                local md = nil
                local wa = math.random(sd.monster_weight_data_sum)
                for wi,wd in ipairs(sd.monster_weight_data) do
                    wa = wa - wd
                    if wa < 1 then
                        md = sd.monster_attr_data[wi]
                        mdh[wi] = (mdh[wi] or 0) + 1
                        break
                    end
                end

            end
        end

        local info = {monsters=0,boss=0}

        local monsters = {}
        for k,v in pairs(mdh) do
            local md = sd.monster_attr_data[k]
            table.insert(monsters,{type=md.type,level=md.level,num=v})
            info.monsters = info.monsters + v
        end

        -- if sd.boss_data then
        --     table.insert(monsters,{type=sd.boss_data.type,level=sd.boss_data.level,num=1})
        --     info.boss = info.boss + 1
        -- end
        
        local pos = nil
        local radius = nil

        if sd.monster_create_place then
            pos = Vector3.New(sd.monster_create_place.x,sd.monster_create_place.y,0)
            radius = sd.monster_create_place.r
        end

        local data = {}

        if next(monsters) then
            table.insert(data,{
                        monsters = monsters,
                        pos = pos,
                        radius = radius,
                    })
        end

        --fixed
        if sd.monster_fixed_data then
            for i,v in ipairs(sd.monster_fixed_data) do
                --table.insert(data,{monsters={{use_id=v.use_id,level=v.level,num=1},},pos=v.pos})
                v.num = 1
                table.insert(data,{monsters={ v ,},pos=v.pos})
                local ud = M.GetMonsterConfig( {use_id=v.use_id,stage = stage ,roomNo = roomNo} )
                if ud.type > 100 then
                    info.boss = info.boss + 1
                else
                    info.monsters = info.monsters + 1
                end
            end
        end

        if info.monsters > 0 or info.boss > 0 then
            return data,info
        else
            return nil
        end

    end

end


-- 获取一个阶段的宝石数据
function M.GetStageGemData(level,roomNo,stage)
    local sc = M.GetStageConfig(level,roomNo)

    if sc.mode ~= "A" then
        return
    end
    if sc.mode == "A" then
        local sd = sc.stage_data[stage]
        if sd and sd.gem_data and next(sd.gem_data) then
            local gds = {}

            local tag = "normal"
            local nsd = sc.stage_data[stage+1]
            if not nsd and sd.pass_type == 1 then
                tag = "over"
            elseif nsd and nsd.boss_data then
                tag = "boss"
            end

            for i,v in ipairs(sd.gem_data) do
                
                local g = {type=1,jb=10,jbNum = 100,tag=tag}
                local pos = Vector3.New(v.x,v.y,0)

                g.pos = pos
                g.obj = v.obj
                
                table.insert(gds,g)

            end
            local gd = gds[#gds]
            gd.jbCount = 10
            gd.jbNum = 100
            return gds

        end

        return nil

    end

    local ret = {type=1,jb=100}
    local tag = "normal"

    local nsc = sc.stage_data[stage+1]
    if not nsc then
        tag = "over"
        ret.jbCount = 10
        ret.jbNum = 100
    end

    local sd = sc.stage_data[stage]

    if sd.boss_data then
        tag = "boss"
    end

    ret.tag = tag

    local pos = Vector3.New(sd.monster_create_pos[1],sd.monster_create_pos[2],0)

    ret.pos = pos

    return ret
end

-- 获取一个阶段的箱子数据
function M.GetStageBoxData(level,roomNo,stage)
    local sc = M.GetStageConfig(level,roomNo)
    if sc.mode ~= "C" then
        return
    end

    local ret = {type=4,jb=0}
    local tag = "normal"

    local nsc = sc.stage_data[stage+1]
    if not nsc then
        tag = "over"
        ret.jbCount = 10
        ret.jbNum = 100
    end

    local sd = sc.stage_data[stage]

    ret.tag = tag

    local pos = Vector3.New(sd.monster_create_pos[1],sd.monster_create_pos[2],0)
    
    ret.pos = pos

    return ret
end

function M.GetStageGoodsData(level,roomNo,stage)
    local sc = M.GetStageConfig(level,roomNo)

    if sc.mode ~= "A" then
        return
    end
    
    local sd = sc.stage_data[stage]

    if sd and sd.goods_data then
        local gds = {}

        for i,v in ipairs(sd.goods_data) do
            local d = nil
            if v.type == 1 then
                d = {type=5,heroType=v.data,}
            elseif v.type == 2 then
                d = {type=2,prefab_name="skill_1",disableAutoMove=true,
                        cfg=
                        {
                            skill_type = "SkillHeroBuffAttackSpeed",
                            wj_prefab_name = "skill_1",
                            effect_hero = "all",
                            change_value = 3,
                            effect_time = v.data,
                        }
                }
            elseif v.type == 3 then
                d = {type=6,pos=v.pos,jb=v.jb,}
            end
            table.insert(gds,d)
        end

        return gds

    end

    return nil

end



------------------------------------关卡技能道具配置---------------------------------------
------------------------------------关卡技能道具配置---------------------------------------
------------------------------------关卡技能道具配置---------------------------------------

local buff_skill_item_config = ExtRequire("Game.CommonPrefab.Lua.buff_skill_item_config")

function M.InitSkillItemConfig()
    M.stageSkillItemConfig = {}
    for k,v in pairs(buff_skill_item_config.stage_skill_config) do
        for k,skill_id in ipairs(v.skill_list) do
            v.buff_skills = v.buff_skills or {}
            v.buff_skills[#v.buff_skills + 1] = buff_skill_item_config.buff_skill_config[skill_id]
        end
        M.stageSkillItemConfig[v.stage] = M.stageSkillItemConfig[v.stage] or {}
        M.stageSkillItemConfig[v.stage][#M.stageSkillItemConfig[v.stage] + 1] = v   
    end
end

function M.GetSkillItemConfig(stage)

    return M.stageSkillItemConfig[stage]

end

--随机按配置表的数据获取buff技能
function M.RandomCreateSkillItem(skillItemConfig)
    local ret = {}
    if skillItemConfig then
        for k,v in ipairs(skillItemConfig) do
            local rdn = math.random()
            if rdn <= v.create_probability then
                local skill_item = v.buff_skills[math.random(1,#v.buff_skills)]
                ret = ret or {}
                ret[#ret + 1] = skill_item
            end
        end
    end
    return ret
end


------------------------------------怪物配置---------------------------------------
------------------------------------怪物配置---------------------------------------
------------------------------------怪物配置---------------------------------------

local monster_config = ExtRequire("Game.CommonPrefab.Lua.monster_base_config")
local monster_bullet_config = ExtRequire("Game.CommonPrefab.Lua.monster_bullet_config")
function M.InitMonsterConfig()
    M.monster_config = {}

    ---- data 处理
    local base_data = {}
    if monster_config.data then
        for key,_data in pairs( monster_config.data ) do
            base_data[key] = _data
            _data.id = nil
        end
    end

    if monster_config.base then
        for key,data in pairs(monster_config.base) do
            ---- 
            if data.data_id then
                basefunc.merge( base_data[data.data_id] or {} , data )
            end

            data.move_speed = type(data.move_speed) ~= "table" and {data.move_speed} or data.move_speed
            --data.skill = type(data.skill) ~= "table" and {data.skill} or data.skill
            data.skill = basefunc.list_to_map( data.skill )

        end
    end

    if monster_config.pefession then
        for key,data in pairs(monster_config.pefession) do
            data.add_skill = type(data.add_skill) ~= "table" and {data.add_skill} or data.add_skill
        end
    end


    --- 组合use_monster 数据
    if monster_config.use_monster then
        for id,data in pairs(monster_config.use_monster) do
            if data.base_id then
                basefunc.merge( monster_config.base[data.base_id] or {} , data )
            end

            if data.profession then
                local profession_data = monster_config.profession[data.profession] or {}
                profession_data.id = nil

                basefunc.merge( profession_data , data )

                if data.add_skill then
                    for key,skill_id in pairs(data.add_skill) do
                        data.skill[skill_id] = true
                    end
                end
            end

            M.monster_config[id] = data
        end
    end


    M.InitMonsterBulletConfig()
end

---- 处理 怪物的总表
--[[function M.InitMonsterFinalConfig(_config)

    M.monster_final_nor_stage_config = {}
    if _config and _config.monster then
        for key,data in pairs(_config.monster) do
            local stage_range = {}
            if type(data.stage) == "table" then
                for i = 1 , #data.stage , 2 do
                    stage_range[#stage_range + 1] = { min = data.stage[i] , max = data.stage[i+1] }
                end
            elseif tonumber(data.stage) then
                stage_range[#stage_range + 1] = { min = tonumber(data.stage)  , max = tonumber(data.stage) }
            end

            if next(stage_range) then
                for key,data in ipairs(stage_range) do
                    for i = data.min , data.max do
                        local fKey = string.format("%s_%s_%s_%s" , i , data.room or "*" , data.boci or "*" , data.use_id or "*" )
                        M.monster_final_nor_stage_config[fKey] = data
                    end
                end
            else
                local fKey = string.format("%s_%s_%s_%s" , data.stage or "*" , data.room or "*" , data.boci or "*" , data.use_id or "*" )
                M.monster_final_nor_stage_config[fKey] = data
            end


            data.no = nil
            data.stage = nil
            data.room = nil
            data.boci = nil
            data.use_id = nil
        end
    end

end--]]

function M.InitMonsterBulletConfig()
    M.monster_bullet_config = {}
    local totable = function(d)
        if type(d) ~= "table" then
            return {d}
        end
        return d
    end
    local p_do = function(_bullet_data)
        local _data = {} 
        local _bullet_data =  basefunc.deepcopy(_bullet_data)
        _data.attackFrom = "monster"
        _data.damage = totable(_bullet_data.damage)
        _data.bulletPrefabName = totable(_bullet_data.bullet_prefab_name)
        _data.moveWay = totable(_bullet_data.move)
        _data.bulletLifeTime = _bullet_data.bullet_life_time or 3
        _data.hitEffect = totable(_bullet_data.hit_effect)
        _data.hitStartWay = totable(_bullet_data.hit_start)
        _data.hitType = totable(_bullet_data.hit_type)
        _data.bulletNumDatas = totable(_bullet_data.bullet_num)
        _data.speed = totable(_bullet_data.speed)
        _data.attr = totable(_bullet_data.attr)
        _data.shouji_pre = totable(_bullet_data.shouji_pre)
        _data.hit_range = _bullet_data.hit_range
        return _data
    end

    for k,v in pairs(monster_bullet_config.bullet) do
        M.monster_bullet_config[v.id] = p_do(v)
    end
    dump(M.monster_bullet_config,"<color=red>子弹配置+——++++++++++++++++</color>")
end

function M.GetMonsterBulletConfigByID(id)
    return M.monster_bullet_config[id]
end 

---- 获得 额外的怪物数据，
--[[function M.GetExtMonsterConfig(data)
    ---- 处理关卡，波次影响的 怪物数据
    local tarExtConfig = nil
    if M.monster_final_nor_stage_config then
        
        ---- 优先级确定
        local defineKey = {
            string.format("%d_%d_%d_%d" , data.stage or 0 , data.room or 0 , data.boci or 0 , data.use_id ) ,
            string.format("%d_%d_*_%d" , data.stage or 0 , data.room or 0 , data.use_id ) ,
            string.format("%d_*_*_%d" , data.stage or 0 , data.use_id ) ,
        }

        for key, fKey in pairs(defineKey) do
            if M.monster_final_nor_stage_config[ fKey ] then
                tarExtConfig = M.monster_final_nor_stage_config[ fKey ]
                break
            end
        end

    end

    data.stage = nil
    data.room = nil
    data.boci = nil

    return tarExtConfig or {}
end--]]

---- 获取 monster 的最终配置
--[[
    data 参数表 ， {
        use_id  怪物的use_id
        level   等级，
        stage   关卡(会去根据这个字段处理总表数据)
        room    房间
        boci    波次

    }
--]]
function M.GetMonsterConfig( data )
    local mc = basefunc.deepcopy( M.monster_config[data.use_id] ) -- M.monster_config[data.use_id] )

    data.level = 1

    --[[local extcfg = M.GetExtMonsterConfig(data)
    basefunc.merge( extcfg , mc )--]]

    --data.use_id = nil

    ---- 强制赋值
    basefunc.merge( data , mc )

    ---- 普通关卡的数据附加
    NorStageFinalDataToDataInfo(mc)
    NorStageValueFactorToDataInfo(mc)

    --[[if mc and mc.data[level] then
        
        local cfg = {}

        for k,v in pairs(mc) do
            if k ~= "data" then
                cfg[k] = v
            end
        end

        for k,v in pairs(mc.data[level]) do
            cfg[k] = v
        end
    
        return cfg
    end--]]

    return mc
end

------------------------------------英雄配置---------------------------------------
------------------------------------英雄配置---------------------------------------
------------------------------------英雄配置---------------------------------------


--local hero_config = ExtRequire("Game.CommonPrefab.Lua.hero_config")
--local hero_extra_config = ExtRequire("Game.CommonPrefab.Lua.hero_extra_config")

--[[function M.InitHeroConfig()
    M.hero_config = {}
    M.hero_extra_config = {}

    --预处理英雄data
    local function pretreatmentHeroData(data)

        if data == nil then return {} end

        local totable = function(d)
            if type(d) ~= "table" then
                return {d}
            end
            return d
        end

        local p_do = function(data)
            local _data = basefunc.deepcopy(data)
            if _data.type then

                local config_data = _data

                _data.hp = 10
                --子弹配置
                local bullet_config = M.GetBulletConfig(config_data.bullet_id)
                local _bullet_data
                --hero_ext_config里配置暂时还没改，所以这里判断处理一下
                if bullet_config then
                    _bullet_data = bullet_config
                else
                    _bullet_data = config_data
                end
                
                _data.attackFrom = "hero"
                _data.bulletPrefabName = totable(_bullet_data.bullet_prefab_name)
                _data.moveWay = totable(_bullet_data.move)
                _data.bulletLifeTime = _bullet_data.bullet_life_time or 3
                _data.hitEffect = totable(_bullet_data.hit_effect)
                _data.hitStartWay = totable(_bullet_data.hit_start)
                _data.hitType = totable(_bullet_data.hit_type)
                _data.bulletNumDatas = totable(_bullet_data.bullet_num)
                _data.speed = totable(_bullet_data.speed)
                _data.attr = totable(_bullet_data.attr)
                _data.shouji_pre = totable(_bullet_data.shouji_pre)

                if _bullet_data.damage then
                    _data.damage = totable(_bullet_data.damage)
                else
                    _data.damage = totable(config_data.damage)
                end

                -- 音效
                _data.audio_name = _bullet_data.audio_name
                --炮台的名字
                _data.prefab_name = config_data.prefab_name
                --基座的名字
                _data.base_name = config_data.base_name
                _data.hit_range = config_data.hit_range
                _data.size = config_data.size
                _data.hit_space = config_data.hit_space

            end
            return _data
        end

        --如果这个数据是个表格（包含过个英雄数据）
        if data[1] then
            for i = 1,#data do
                data[i] = p_do(data[i])
            end
        else
            data = p_do(data)
        end

        return data
    end

    M.hero_config = pretreatmentHeroData(hero_config.base)
    M.hero_extra_config = pretreatmentHeroData(hero_extra_config.base)
end--]]

local hero_config = ExtRequire("Game.CommonPrefab.Lua.hero_base_config")
local hero_factory_config = ExtRequire("Game.CommonPrefab.Lua.hero_base_config")

function M.InitHeroConfig()
    --- 英雄的基础属性
    M.hero_config = {}
    --- 英雄的基础属性改变 , 从小到大配置
    local base_change = {}
    --- 英雄的技能属性改变 ，从小到大配置
    local skill_change = {}

    if hero_config.base_change then
        for key,data in ipairs(hero_config.base_change) do
            base_change[ data.id ] = base_change[ data.id ] or {}
            local tar_data = base_change[ data.id ]

            --data.skill = type(data.skill) ~= "table" and {data.skill} or data.skill
            if data.skill then
                data.skill = basefunc.list_to_map( data.skill )
            end    

            tar_data[#tar_data + 1] = data
        end
    end

    if hero_config.skill_change then
        for key,data in ipairs(hero_config.skill_change) do
            skill_change[ data.id ] = skill_change[ data.id ] or {}
            local tar_data = skill_change[ data.id ]

            data.skill_id = type(data.skill_id) ~= "table" and {data.skill_id} or data.skill_id

            tar_data[#tar_data + 1] = data
        end
    end

    for key,data in pairs( hero_config.base ) do
        M.hero_config[data.type] = data

        --data.skill = type(data.skill) ~= "table" and {data.skill} or data.skill
        data.skill = basefunc.list_to_map( data.skill )

        data.base_change = basefunc.deepcopy( data.base_change and base_change[data.base_change] or {} )
        data.skill_change = basefunc.deepcopy( data.skill_change and skill_change[data.skill_change] or {} )
    end 

end

--[[function M.GetHeroConfigByType(type)
    return  M.hero_config[type]
end--]]

function M.GetHeroConfigAll()
    return M.hero_config
end

function M.GetHeroConfig(type , star , level)
    level = level or 1
    local tar_data = {}
    local hero_data = M.hero_config[type]
    if hero_data then
        tar_data = basefunc.deepcopy( hero_data )

        tar_data = BaseChangeByRuleKey( tar_data , tar_data.base_change , "level" , level , "add" )

        tar_data = BaseChangeByRuleKey( tar_data , tar_data.base_change , "star" , star , "add" )
        tar_data = SkillChangeByRuleKey( tar_data , tar_data.skill_change , "star" , star )
    end

    tar_data.level = level
    tar_data.star = star

    return tar_data
end

function M.GetHeroConfigByColor(color)
    local result = {}
    for k,v in ipairs(M.hero_config) do
        if v.hero_color == color then
            result[v.type] = result[v.type] or {}
            result[v.type][v.star] = v
        end
    end
    return result
end
--通过攻击类型获取该类英雄的列表
function M.GetHeroListByAttackType(AttackType)
    for i = 1,#hero_config.hero_attack_type do
        if hero_config.hero_attack_type[i].attack_type == AttackType then
            if type(hero_config.hero_attack_type[i].hero_type_list) == "table" then
                return hero_config.hero_attack_type[i].hero_type_list
            else
                return {hero_config.hero_attack_type[i].hero_type_list}
            end
        end
    end
end
--通过攻击类型获取该类英雄的列表(仅仅用作UI排列,hero_type = 999 表示 占位的ui)
function M.GetHeroListUIByAttackType(AttackType)
    for i = 1,#hero_config.hero_attack_type do
        if hero_config.hero_attack_type[i].attack_type == AttackType then
            if type(hero_config.hero_attack_type[i].hero_type_list_fake) == "table" then
                return hero_config.hero_attack_type[i].hero_type_list_fake
            else
                return {hero_config.hero_attack_type[i].hero_type_list_fake}
            end
        end
    end
end

--获取一个英雄的攻击类型
function M.GetHeroAttackType(hero_type)
    for i = 1,#hero_config.hero_attack_type do
        if type(hero_config.hero_attack_type[i].hero_type_list) == "table" then
            for ii = 1,#hero_config.hero_attack_type[i].hero_type_list do
                if hero_config.hero_attack_type[i].hero_type_list[ii] == hero_type then
                    return hero_config.hero_attack_type[i].attack_type
                end
            end
        else
            if hero_config.hero_attack_type[i].hero_type_list == hero_type then
                return hero_config.hero_attack_type[i].attack_type
            end
        end
    end
end

--获取炮台大师的增益效果
function M.GetMasterBuffByHeroType(hero_type)
    local re = {}
    local check_key = {
        "damage_up",
        "hitSpeed_up"
    }

    for i = 1,#hero_config.master_config do
        --满足等级条件英雄的数量
        local hero_num = 0
        local AttackType = M.GetHeroAttackType(hero_type)
        local hero_list = M.GetHeroListByAttackType(AttackType)

        for ii = 1,#hero_list do
            local level = HeroDataManager.GetHeroLevelByType(hero_list[ii])
            if level >= hero_config.master_config[i].hero_level_num_need then
                hero_num = hero_num + 1
            end
        end

        if hero_num >= hero_config.master_config[i].hero_type_num_need then
            for iii = 1,#check_key do
                re[check_key[iii]] = re[check_key[iii]] or 0
                if hero_config.master_config[i][check_key[iii]] then
                    re[check_key[iii]] = re[check_key[iii]] + hero_config.master_config[i][check_key[iii]]
                end
            end
        end
    end
    return re
end

function M.GetHeroAttackTypeConfig()
    return hero_config.hero_attack_type
end
function M.GetHeroMasterConfig()
    return hero_config.master_config
end

--[[function M.GetHeroExtraConfigByType(type)
    return M.hero_extra_config[type]
end--]]

------------------------------------蛇头配置---------------------------------------
------------------------------------蛇头配置---------------------------------------
------------------------------------蛇头配置---------------------------------------

local hero_head_config = ExtRequire("Game.CommonPrefab.Lua.hero_head_config")
local head_data_config = ExtRequire("Game.CommonPrefab.Lua.head_data_config")


-- 被动id类型
local bd_id_type = {
    [10001] = "hero_num", --英雄数量
    [10002] = "hp", --血量
    [10003] = "skill_num", --技能初始数量
    [10004] = "skill_num_max", --技能上限数量
}

function M.InitHeroHeadConfig()
    M.HeroHeadConfig = {}
    for k,v in pairs(hero_head_config.base) do
        M.HeroHeadConfig[v.id] = v
    end

    M.HeroHeadDataConfig = {}

    for k,v in pairs(head_data_config.main) do
        local hd = M.HeroHeadDataConfig[v.id] or {}
        M.HeroHeadDataConfig[v.id] = hd

        hd[v.level] = v

        -- 升级资产
        v.upgrade_asset = {}
        for i=1,20 do
            local asset_type = v["upgrade_asset_type_"..i]
            local asset_value = v["upgrade_asset_data_"..i]
            if asset_type and asset_value then
                local ait = AssetItemConfig[asset_type].asset_type
                if not ait then
                    error(string.format("error asset_type is undefine : %s",asset_type))
                end
                table.insert(v.upgrade_asset,{asset_type=ait,asset_value=asset_value})
                v["upgrade_asset_type_"..i] = nil
                v["upgrade_asset_data_"..i] = nil
            else
                break
            end
        end

        -- 被动技能属性
        for i=1,20 do
            local bdn = v["bd_skill_"..i]
            local bdd = v["bd_skill_data_"..i]
            if bdn and bdd then
                local bdt = bd_id_type[bdn]
                if not bdt then
                    error(string.format("error bd_skill is undefine : %s",bdn))
                end
                v[bdt] = bdd
                -- v["bd_skill_"..i] = nil
                -- v["bd_skill_data_"..i] = nil
            else
                break
            end
        end

    end

    dump(M.HeroHeadDataConfig,"<color=yellow>HeroHeadDataConfig</color>")
end

function M.GetAllHeroHeadConfig()
    return M.HeroHeadConfig
end

function M.GetHeroFragmentIcon(hero_type)
    local key = "prop_hero_fragment_"..hero_type

    for k,v in pairs(AssetItemConfig) do
        if v.asset_type == key then
            return v.icon
        end
    end
end 

function M.GetHeroHeadConfig(id)
    return M.HeroHeadConfig[id]
end

function M.GetAllHeroHeadDataConfig(id)
    return M.HeroHeadDataConfig[id]
end

function M.GetHeroHeadDataConfig(id)
    return M.HeroHeadDataConfig[id]
end


------------------------------------工具配置---------------------------------------
------------------------------------工具配置---------------------------------------
------------------------------------工具配置---------------------------------------

local gongju_data_config = ExtRequire("Game.CommonPrefab.Lua.gongju_data_config")
function M.InitGongjuConfig()
    M.gongjuDataConfig = gongju_data_config

    for k,v in pairs(gongju_data_config.team) do
            
        -- 升级资产
        v.upgrade_asset = {}
        for i=1,20 do
            local asset_type = v["upgrade_asset_type_"..i]
            local asset_value = v["upgrade_asset_data_"..i]
            if asset_type and asset_value then
                local ait = AssetItemConfig[asset_type].asset_type
                if not ait then
                    error(string.format("error asset_type is undefine : %s",asset_type))
                end
                table.insert(v.upgrade_asset,{asset_type=ait,asset_value=asset_value})
                v["upgrade_asset_type_"..i] = nil
                v["upgrade_asset_data_"..i] = nil
            else
                break
            end
        end

    end

    for k,v in pairs(gongju_data_config.health) do
            
        -- 升级资产
        v.upgrade_asset = {}
        for i=1,20 do
            local asset_type = v["upgrade_asset_type_"..i]
            local asset_value = v["upgrade_asset_data_"..i]
            if asset_type and asset_value then
                local ait = AssetItemConfig[asset_type].asset_type
                if not ait then
                    error(string.format("error asset_type is undefine : %s",asset_type))
                end
                table.insert(v.upgrade_asset,{asset_type=ait,asset_value=asset_value})
                v["upgrade_asset_type_"..i] = nil
                v["upgrade_asset_data_"..i] = nil
            else
                break
            end
        end
        
    end

    dump(M.gongjuDataConfig,"M.gongjuDataConfig*********************************")
end

function M.GetTeamLevelDataConfig()
    return M.gongjuDataConfig.team
end

function M.GetHealthLevelDataConfig()
    return M.gongjuDataConfig.health
end

local gongju_config = ExtRequire("Game.CommonPrefab.Lua.gongju_config")
function M.InitGongjuCfg()
    M.gongjuConfig = gongju_config.main
    dump(M.gongjuConfig,"<color=yellow>gongjuConfig?????</color>")
end

function M.GetGongjuCfg()
    return M.gongjuConfig   
end

function M.GetGongjuCfgByKey(key)
    return M.gongjuConfig[key]
end

------------------------------------子弹配置---------------------------------------
------------------------------------子弹配置---------------------------------------
------------------------------------子弹配置---------------------------------------

local bullet_config = ExtRequire("Game.CommonPrefab.Lua.bullet_base_config")

function M.InitBulletConfig()
    M.BulletConfig = {}

    local totable = function(d)
        if type(d) ~= "table" then
            return {d}
        end
        return d
    end
    local p_do = function(_bullet_data)
        local _data = {} 
        local _bullet_data =  basefunc.deepcopy(_bullet_data)
        _data.attackFrom = "hero"
        _data.bulletPrefabName = totable(_bullet_data.bullet_prefab_name)
        _data.damage = totable( _bullet_data.damage )
        _data.moveWay = totable(_bullet_data.move)
        _data.bulletLifeTime = _bullet_data.bullet_life_time or 3
        _data.hitEffect = totable(_bullet_data.hit_effect)
        _data.hitStartWay = totable(_bullet_data.hit_start)
        _data.hitType = totable(_bullet_data.hit_type)
        _data.bulletNumDatas = totable(_bullet_data.bullet_num)
        _data.speed = totable(_bullet_data.speed)
        _data.attr = totable(_bullet_data.attr)
        _data.shouji_pre = totable(_bullet_data.shouji_pre)
        _data.hit_range = _bullet_data.hit_range
        _data.audio_name = _bullet_data.audio_name
        return _data
    end

    for k,v in ipairs(bullet_config.bullet) do
        M.BulletConfig[v.id] = p_do(v)
    end

    dump(M.BulletConfig , "xxx-------------M.BulletConfig:")
end

function M.GetBulletConfig(id)
    return M.BulletConfig[id]
end

function M.PretreatmentBulletData(id,attackFrom,_bullet_data)
    local _bullet_data = _bullet_data or basefunc.deepcopy(M.GetBulletConfig(id))
    local _data = _bullet_data
    
    local totable = function(d)
        if type(d) ~= "table" then
            return {d}
        end
        return d
    end

    _data.attackFrom = attackFrom
    _data.bulletPrefabName = totable(_bullet_data.bullet_prefab_name)
    _data.moveWay = totable(_bullet_data.move)
    _data.bulletLifeTime = _bullet_data.bullet_life_time or 3
    _data.hitEffect = totable(_bullet_data.hit_effect)
    _data.hitStartWay = totable(_bullet_data.hit_start)
    _data.hitType = totable(_bullet_data.hit_type)
    _data.bulletNumDatas = totable(_bullet_data.bullet_num)
    _data.speed = totable(_bullet_data.speed)
    _data.attr = totable(_bullet_data.attr)
    return _data
end

------------------------------------奖励配置---------------------------------------
------------------------------------奖励配置---------------------------------------
------------------------------------奖励配置---------------------------------------
local award_config = ExtRequire("Game.game_CS.Lua.award_config")

function M.InitAwardConfig()
    M.AwardConfig = award_config
end

function M.GetAwardConfig()
    return M.AwardConfig
end

function M.GetAwardConfigByID(id)
    return M.AwardConfig.base[id]
end

function M.GetHeroIconByType(type)
    return M.AwardConfig.asset_info["prop_turret_fragment_"..type].icon
end

function M.GetAwardUIInfoBy(id)
    local _type2str = {
        [1] = "hero_info",
        [2] = "asset_info",
    }
    local config = M.GetAwardConfigByID(id)
    local re = {}
    for i = 1,#config.award do
        local award_info = config.award[i]
        local award_info_list = StringHelper.Split(award_info,"#")
        local type_name,cfg = award_info_list[1],{award_info_list[2],award_info_list[3],award_info_list[4],award_info_list[5],award_info_list[6],award_info_list[7]}
        if type_name == "prop_turret_fragment_" then
            type_name = type_name..math.random(1,12)
        else
            type_name = tonumber(type_name)
        end
        local info = M.AwardConfig[_type2str[config.type]][type_name]
        info.num = M.RandomGetNum(cfg)
        info.type_name = type_name
        info.type_index = config.type
        re[#re + 1] = basefunc.deepcopy(info)
    end
    return re
end
--随机获取一个资源的数量（暂时客户端处理）
function M.RandomGetNum(config)
    if config and #config > 0 then
        return math.random(config[1],config[2] or config[1])
    end
end


------------------------------------宝箱配置---------------------------------------
------------------------------------宝箱配置---------------------------------------
------------------------------------宝箱配置---------------------------------------
local box_config = ExtRequire("Game.game_CS.Lua.box_config")

function M.InitBoxConfig()
    M.BoxMap = {}
    for k,v in pairs(box_config.config) do
        local t = {}
        t.trigger_prob = v.trigger_prob
        t.award = {}
        t.award.award_prob = 0
        t.award.award_list = {}
        for kk,vv in pairs(v.award_data) do
            t.award.award_prob = t.award.award_prob + vv[1]
            local tt = {}
            t.award.award_list[#t.award.award_list + 1] = tt
            tt.prob = t.award.award_prob
            tt.list = {}
            for i = 2, #vv do
                tt.list[#tt.list + 1] = vv[i]
            end
        end

        M.BoxMap[v.id] = t
    end
    M.BoxAwardMap = {}
    for k,v in pairs(box_config.award) do
        M.BoxAwardMap[v.id] = v
    end
end

-- 开宝箱得奖励
--[[
数据格式  为空就是没有奖励或者没有触发奖励
        {
            [1] = {
                key = "prop_xxxxx",
                value = xxxx,
            }
            [2]
            ...
        }
]]
function M.OpenBoxById(id)
    if M.BoxMap[id] then
        local cfg = M.BoxMap[id]
        
        if math.random(1, 10000) <= cfg.trigger_prob then
            local prob = math.random(1, cfg.award.award_prob)
            for k,v in ipairs(cfg.award.award_list) do
                if prob <= v.prob then
                    local award = {}
                    for kk,vv in ipairs(v.list) do
                        if M.BoxAwardMap[vv] then
                            local t = {}
                            t.key = M.BoxAwardMap[vv].award
                            t.value = math.random(M.BoxAwardMap[vv].min, M.BoxAwardMap[vv].max)
                            award[#award + 1] = t
                        else
                            dump(vv, "<color>[Bug] 奖励id没有找到</color>")
                        end
                    end
                    return award
                end
            end
            print("<color>[Bug] 触发宝箱但是没有开出奖励</color>")
            dump({id=id, cfg}, "宝箱配置")
        end
    end
    return nil
end


-- 限定英雄掉落的宝箱产出
function M.OpenLimitHeroBoxById(id,heroNum)

    local ln = 20
    for i=1,ln do
        local aw = M.OpenBoxById(id)
        if aw then

            local hn = 0
            for _,v in ipairs(aw) do
                if string.sub(v.key, 1, 10) == "prop_hero_" then
                    hn = hn + 1
                end
            end

            if hn > heroNum then
                -- 继续重新生成
            else
                return aw,hn
            end

        end
    end

    print("<color>[Bug] 宝箱无法开出无英雄的结果(现产生一个小堆金币)</color>")
    return {{prop_gold_coin1=1}}
end

------------------------------------技能配置---------------------------------------
------------------------------------技能配置---------------------------------------
------------------------------------技能配置---------------------------------------

local skill_config = ExtRequire("Game.CommonPrefab.Lua.skill_base_config")

function M.InitSKillConfig()
    M.skill_config = {}


    for key,data in pairs(skill_config.main) do
        M.skill_config[data.id] = data

        if data.prop_type and data.prop_id then

            basefunc.merge( skill_config[data.prop_type] and skill_config[data.prop_type][data.prop_id] or {} , data )
        end

        

    end

end

---- 获取技能配置
function M.GetSkillConfig( skillId , _change_data )

    local skill_config = basefunc.deepcopy( M.skill_config[ skillId ] or {} )

    ---- 把改变的加上去
    if _change_data then
        for c_key , c_data in pairs(_change_data) do
            if c_data.change_type and c_data.change_value then
                if c_data.change_type == 1 then
                    skill_config[ c_key ] = (skill_config[ c_key ] or 0) + c_data.change_value
                elseif c_data.change_type == 2 then
                    skill_config[ c_key ] = (skill_config[ c_key ] or 0) * (100 + c_data.change_value) / 100
                elseif c_data.change_type == 3 then
                    skill_config[ c_key ] = c_data.change_value
                end
            end
        end
    end

    return skill_config
end


---------------------------------------技能房相关---------------------------------------------
---------------------------------------技能房相关---------------------------------------------
---------------------------------------技能房相关---------------------------------------------
skill_classify_config = ExtRequire "Game.game_CS.Lua.Skill.skill_classify_config"

function M.InitSkillClassifyConfig()
    --阵营区分
    M.angel_skills = {}
    M.demon_skills = {}
    --效果区分
    M.attack_skills = {}
    M.subsist_skills = {}
    M.weaken_skill  = {}
    for k , v in pairs(skill_classify_config.main) do
        if v.camp_id == 1 then
            M.angel_skills[#M.angel_skills + 1] = v
        elseif v.camp_id == 2 then
            M.demon_skills[#M.demon_skills + 1] = v
        end
        if v.type_id == 1 then
            M.attack_skills[#M.attack_skills + 1] = v
        elseif v.type_id == 2 then
            M.subsist_skills[#M.subsist_skills + 1] = v
        elseif v.type_id == 3 then
            M.weaken_skill[#M.weaken_skill + 1] = v
        end
    end
end

--当前随机给一个天使技能(后续获得一个技能应该会有策划的策略)
function M.GetOneAngelSkill()
    return M.angel_skills[math.random(1,#M.angel_skills)]
end

function M.GetOneDemonSkill()
    return M.demon_skills[math.random(1,#M.demon_skills)]
end

function M.GetRandomSkill(camp_id,type_id)
    M.skill_camp_id_type_id = M.skill_camp_id_type_id or {}
    if M.skill_camp_id_type_id[camp_id] and M.skill_camp_id_type_id[camp_id][type_id] then
        
    else
        for k , v in pairs(skill_classify_config.main) do
            if v.camp_id == camp_id and v.type_id == type_id then
                M.skill_camp_id_type_id[camp_id] = M.skill_camp_id_type_id[camp_id] or {}
                M.skill_camp_id_type_id[camp_id][type_id] = M.skill_camp_id_type_id[camp_id][type_id] or {}
                local d = M.skill_camp_id_type_id[camp_id][type_id]
                d[#d + 1] = v
            end
        end
    end
    local d = M.skill_camp_id_type_id[camp_id][type_id]
    return d[math.random(1,#d)]
end

------------------------------------------------英雄解锁相关---------------------------------------------
------------------------------------------------英雄解锁相关---------------------------------------------
------------------------------------------------英雄解锁相关---------------------------------------------
local unlock_hero_config = ExtRequire "Game.game_CS.Lua.unlock_hero_config"

function M.GetUnlockNeed(hero_type,level)
    local need = {}
    need.fragment_need = 0
    need.gold_need = 0

    need.fragment_need = unlock_hero_config["hero_"..hero_type][level].fragment_need
    need.gold_need = unlock_hero_config["hero_"..hero_type][level].gold_need
    return need
end

------------------------------------------------ 关内奖励的配置 ---------------------------------------------
------------------------------------------------ 关内奖励的配置 ---------------------------------------------
------------------------------------------------ 关内奖励的配置 ---------------------------------------------
local guannei_award_config = ExtRequire "Game.CommonPrefab.Lua.guannei_award_config"

function M.InitGuanneiAwardConfig()

end

---- 获取 关内奖励配置，通过关卡号
function M.GetGuanneiAwardConfig( stage )
    local tarConfig = nil
    for key,data in pairs(guannei_award_config.main) do
        if type(data.guan) == "number" and data.guan == stage then
            tarConfig = data
            break
        elseif type(data.guan) == "table" and #data.guan == 2 then
            if stage >= data.guan[1] and stage <= data.guan[2] then
                tarConfig = data
                break
            end
        end
    end
    return tarConfig
end


------------------------------------------------ 过关奖励的配置 ---------------------------------------------
------------------------------------------------ 过关奖励的配置 ---------------------------------------------
------------------------------------------------ 过关奖励的配置 ---------------------------------------------


local statement_award_config = ExtRequire "Game.CommonPrefab.Lua.statement_award_config".config

function M.GetCurrStateConfig()
    local curr_state = GameInfoCenter.GetStageData().curLevel
    for k , v in pairs (statement_award_config) do
        if curr_state >= v.start_state and curr_state <= v.end_state then
            return v
        end
    end
end


function M.GetCurrScoreLevel(percent_score)
    local config = M.GetCurrStateConfig()
    if not config then
        return 1
    end
    local max = 3

    for i = 1,max - 1 do
        local ts = config["score_level_"..i]
        if percent_score < ts then
            return i
        end
    end
    
    return max
end


--确定几种碎片，将总数量随机分配
function M.GetHeroFragment(percent_score)
    local config = M.GetCurrStateConfig()
    if not config then
        return {}
    end
    local level = M.GetCurrScoreLevel(percent_score)
    local num = config["fragment_"..level]
    local fragment_pool = basefunc.deepcopy(config.fragment_pool or {1,2,3,4,7,13,14})
    local fragment_type_num = config.fragment_type_num or 3

    local hero_fragment_data = {}
    for i = 1,fragment_type_num do
        local r = math.random(1,#fragment_pool)
        local type = fragment_pool[r]
        hero_fragment_data[#hero_fragment_data + 1] = type
        table.remove(fragment_pool,r)
    end

    local re = {}
    for i = 1,#hero_fragment_data do
        local data = {type = hero_fragment_data[i],num = 0}
        re[#re + 1] = data
    end
    local left_num = num
    for i = 1,num do
        if left_num > 0 then
            local turn = (i % #re) + 1
            if re[turn].num == 0 then
                re[turn].num = 1
                left_num = left_num - 1
            else
                local ran = math.random(1,left_num)
                left_num = left_num - ran
                re[turn].num = re[turn].num + ran
            end
        else
            break
        end
    end

    return re
end

--- 获取 金币 一个等级 相比 另一个等级的 倍数
function M.GetGoldLevelBeiShu( stage , nowLevel , judgeLevel )
    local nowData = M.GetGoldConfig( stage , nowLevel )
    
    local judgeData = M.GetGoldConfig( stage , judgeLevel )

    local function get_value (_data)
        local value = 1
        if _data and type(_data) == "table" and #_data >= 2 then
            value = _data[1] + _data[2]
        elseif _data and type(_data) == "number" then
            value = _data
        end
        return value
    end

    local nowValue = get_value(nowData)
    local judgeValue = get_value(judgeData)
    

    local num = math.floor( nowValue / judgeValue )
    if num > 20 then
        num = 20
    end

    return num 
end

------------------------------------------------ 通用奖励的配置 ↓ ---------------------------------------------
------------------------------------------------ 通用奖励的配置 ↓ ---------------------------------------------
------------------------------------------------ 通用奖励的配置 ↓ ---------------------------------------------
local common_award_config = ExtRequire "Game.CommonPrefab.Lua.common_award_config"

--[[
    award_id  = {
        award_type = 1(全部) or 2(随机) , 
        random_award_num = xx(随机时获得奖励个数) , 
        award_data = { 
            [1] = {
                award_name = 
                asset_type = 
                value =
                weight = 
            } , 
            [2] = {
                ...
            }  
        }  
    }

--]] 
M.commonAwardConfig = {}

function M.InitCommonAwardConfig()
    --- 先处理 奖励item
    local awards = {}
    if common_award_config.award_item then
        for key,data in pairs(common_award_config.award_item) do
            awards[data.award_id] = awards[data.award_id] or {}

            --dump( { data.asset_id , AssetItemConfig } , "xxx---------deal__award_item" )

            local tar_data = {
                award_name = data.award_name,
                asset_type = tonumber(data.asset_id) and AssetItemConfig[data.asset_id].asset_type or data.asset_id ,
                value = data.asset_count,
                weight = data.P1 or 1,
                item_id = data.item_id
            }

            table.insert( awards[data.award_id] , tar_data )
        end
    end

    if common_award_config.award then
        for award_id , data in pairs( common_award_config.award ) do
            M.commonAwardConfig[award_id] = {
                award_type = data.award_type , 
                random_award_num = data.P1 or 1 ,
                award_data = basefunc.deepcopy( awards[award_id] or {} )
            }
        end
    end

end

--- 获取一个奖励 id 的数据
function M.GetBaseCommonAwardCfg( awardId )
    return basefunc.deepcopy( M.commonAwardConfig[awardId] or {} )
end

function M.GetCommonAwardData(awardId)
    local awardCfg = M.GetBaseCommonAwardCfg( awardId )
    if not awardCfg then
        return nil
    end

    local end_award = {}

    ----- 目标奖励,,随机选一个，
    if awardCfg.award_type == 2 then
        for i = 1 , awardCfg.random_award_num do
            local target_rand_award , key = basefunc.get_random_data_by_weight( awardCfg.award_data , "weight" )
            awardCfg.award_data[key] = nil
            end_award[#end_award + 1] = target_rand_award 
        end
    elseif awardCfg.award_type == 1 then
        end_award = awardCfg.award_data
    end

    ------ 处理 value 的自带随机功能
    for key,data in pairs(end_award) do
        --local awa = basefunc.deepcopy( data )
        local end_value = 0
        if data.value and type(data.value) ~= "table" then
            end_value = data.value
        elseif data.value and type(data.value) == "table" then
            if #data.value == 1 then
                end_value = data.value[1]
            elseif #data.value > 1 then
                local min_value = math.min( data.value[1],data.value[2] )
                local max_value = math.max( data.value[1],data.value[2] )
                end_value = math.random(min_value,max_value)
            end
        end
        data.value = end_value
        data.asset_value = end_value
        --target_award[#target_award + 1] = awa
        --break
    end

    ------- 处理限时道具 -------------
    for key,data in pairs(end_award) do
        if data.lifetime then
            data.attribute = {valid_time= os.time() + data.lifetime }
            data.value = nil
            data.lifetime = nil
        end
    end

    return end_award
end

----  领取奖励
function M.GetCommonAward(awardId , callBack )
    local awardCfg = M.GetBaseCommonAwardCfg( awardId )
    if not awardCfg then
        return nil
    end

    local end_award = M.GetCommonAwardData(awardId)

    ---- 直接加资产
    if end_award and type(end_award) == "table" then

        ---- 处理一些特殊的奖励
        M.DealSpecialCommonAward( end_award )

        for index, data in ipairs(end_award) do
            MainModel.AddAsset(data.asset_type , data.value)
        end
    end
    dump(end_award , "xxx----------------end_award:")
    ---- 回调函数 ，一般用于同步资产
    if callBack and type(callBack) == "function" then
        callBack(end_award)
    end

    return end_award
end

function M.DealSpecialCommonAward( end_award )
    if not end_award or type(end_award) ~= "table" then
        return end_award
    end

    for key,data in pairs(end_award) do
        if type(data.asset_type) == "string" and string.find(data.asset_type , "^task_(.+)") then
            local s,e, task_id = string.find(data.asset_type , "^task_(.+)")
            task_id = tonumber(task_id)
            --- 
            if task_id and task_mgr.task_list[task_id] then
                task_mgr.task_list[task_id].add_process( data.value )
            end

            end_award[key] = nil
        end
    end

    return end_award
end

------------------------------------------------ 通用奖励的配置 ↑ ---------------------------------------------
------------------------------------------------ 通用奖励的配置 ↑ ---------------------------------------------
------------------------------------------------ 通用奖励的配置 ↑ ---------------------------------------------


function M.GetAssetConfigByType(type)
    for k,v in pairs(AssetItemConfig) do
        if v.asset_type == type then return v end
    end
end