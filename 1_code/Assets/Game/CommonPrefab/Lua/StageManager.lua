-- 创建时间:2021-7-28 14:40:34
-- 阶段关卡管理器
--[[
--]]
StageManager = {}
local M = StageManager

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

    M.lister["model_turret_change_msg"] = M.OnHeroChange

    for msg,cbk in pairs(M.lister) do
        Event.AddListener(msg, cbk)
    end

end

-- 数据
function M.Init()

    AddLister()

    GameInfoCenter.SetStageData({
        curLevel = MainModel.UserInfo.cur_level,
        maxLevel = MainModel.UserInfo.game_level,
        roomNo = 1,
        state = "normal",
        curStage = 0,
        maxStage = 0,
    })
    
    -- 模式对象
    M.modeObjs = {}
end

--关卡开始
function M.Start()

    UnityEngine.Profiling.Profiler.BeginSample("StageManager Start ");
    
    M.StatisticsCurAssets()

    M.state = "normal"

    local sd = GameInfoCenter.GetStageData()

    --每次直接生成关卡数据
    GameConfigCenter.CreateStageConfig(sd.curLevel)
    local curStageConfig = GameConfigCenter.GetStageConfig(sd.curLevel,sd.roomNo)

    local obj = CreateFactory.CreateStageObj({stage=sd.curLevel,roomNo=sd.roomNo})
    M.modeObjs[sd.roomNo] = obj

    GameInfoCenter.InitPlayerData()
    
    M.InitGoods()

    -- 蛇头
    local pos = Vector3.New(0, -20, 0)
    if curStageConfig.startPos then
        local n = #curStageConfig.startPos
        local np = math.random(n)
        pos = curStageConfig.startPos[np]
    end

    CreateFactory.CreateHeroHead({type=MainModel.GetHeadType(),level = MainModel.GetHeadLevel(),pos=pos,roomNo=sd.roomNo , isHeroHead = true })

    local htc = HeroDataManager.GetUnlockHeroType()
    local hi = math.random(#htc)
    local ht = htc[hi]
    
    local turret_list = {}

    if sd.curLevel == 0 then
        
        turret_list = {
            {
                heroId = 1,
                location = 1,
                type = 1,
                level = 1,
                star = 1,
            },
            {
                heroId = 2,
                location = 2,
                type = 2,
                level = 1,
                star = 1,
            },
            {
                heroId = 3,
                location = 3,
                type = 2,
                level = 1,
                star = 1,
            },
            {
                heroId = 4,
                location = 4,
                type = 3,
                level = 1,
                star = 1,
            },
            {
                heroId = 5,
                location = 5,
                type = 4,
                level = 1,
                star = 1,
            },
            {
                heroId = 6,
                location = 6,
                type = 4,
                level = 1,
                star = 1,
            },
            {
                heroId = 7,
                location = 7,
                type = 7,
                level = 1,
                star = 1,
            },
            {
                heroId = 8,
                location = 8,
                type = 13,
                level = 1,
                star = 1,
            },
            {
                heroId = 9,
                location = 9,
                type = 14,
                level = 1,
                star = 1,
            },
        }

    end

    GameInfoCenter.turret_list = turret_list
    -- 加载英雄
    CreateFactory.CreateHeroList(turret_list)

    -- 创建地图指示器
    CreateFactory.CreateTargetIndicator()
    
    CameraMoveBase.Start()
    local stageTag = nil
    -- if curStageConfig.roomType == "boss" then
    --     stageTag = "boss"
    -- end

    Event.Brocast("level_start", {
                                    hp=GameInfoCenter.playerDta.hp, 
                                    hpMax=GameInfoCenter.playerDta.hpMax,
                                    level=sd.curLevel,
                                    type=stageTag,
                                })

    TalkingDataManager.BeginMission("关卡" .. sd.curLevel)

    -- 游戏进度条满值
    Event.Brocast("stageRefreshMonsterProgress",0,1)
    -- 游戏等级0
    Event.Brocast("stageRefreshGameLv",1)
    M.stageGameLvMax = false

    UnityEngine.Profiling.Profiler.EndSample()

    -- 出场特效
    local head = GameInfoCenter.GetHeroHead()
    local hpos = head.transform.position
    local hup = CSModel.Get3DToUIPoint(hpos)
    CSEffectManager.PlayCircleSwitchMaskFX(CSPanel.transform,hup,0,0.5,1.5,6,function ( )
    end)

end

function M.Exit()
    DOTweenManager.KillAllStopTween()
    DOTweenManager.KillAllExitTween()
    DOTweenManager.KillAllLayerTween()

    Removelister()
    for k,v in pairs(M.modeObjs) do
        v:Exit()
        M.modeObjs[k] = nil
    end

    local sd = GameInfoCenter.GetStageData()
    GameConfigCenter.ClearStageConfigByStage(sd.curLevel)
    
    M.StageSaveData(0)

    ComponseManager.RemoveAll()
    AttackManager.RemoveAll()
    
    GameInfoCenter.turret_list = {}
    GameInfoCenter.Exit()
    ObjectCenter.Exit()
end

function M.FrameUpdate(timeElapsed)

end

--新的阶段开始
function M.StartNewStage(stage,roomNo)

    M.state = "normal"

    local obj = CreateFactory.CreateStageObj({stage=stage,roomNo=roomNo})
    M.modeObjs[roomNo] = obj

end


-- 保存关卡数据 完成后立刻调用 不需要等待其他UI等展示完成
function M.StageSaveData(state)
    local sd = GameInfoCenter.GetStageData()
    M.SettlementAssets(sd.curLevel,state)
end


-- 关卡结束 state 0|失败 1|胜利
function M.StageFinish(state)
    local sd = GameInfoCenter.GetStageData()
    
    Event.Brocast("StageFinish",{state=state , stageData = sd })

    if state == 1 then
        TalkingDataManager.CompleteMission("关卡" .. sd.curLevel)
        sd.curLevel = sd.curLevel + 1
        if sd.curLevel > MainModel.UserInfo.game_level then
            MainModel.UserInfo.cur_level = sd.curLevel
            MainModel.UserInfo.game_level = sd.curLevel
        end

        
    elseif state == 0 then
        if sd.curLevel == 0 then
            --教程关死掉就算成功
            TalkingDataManager.CompleteMission("关卡" .. sd.curLevel)
        else
            TalkingDataManager.FailedMission("关卡" .. sd.curLevel,"在房间" .. GameInfoCenter.stageData.roomNo .. "中死亡")
        end
    end

    GameInfoCenter.SetStageData({
        curLevel = sd.curLevel,
        maxLevel = MainModel.UserInfo.game_level,
        roomNo = 1,
    })

    M.Exit()
    
    MainLogic.GotoScene("game_Hall",nil,function ()
        --地图完成
        MapManager.Finish()
    end)

end

-- 统计当前资产
function M.StatisticsCurAssets()
    M.beginAssets = {}
    for k,v in pairs(MainModel.UserInfo.Asset) do
        M.beginAssets[k] = v
    end
end

-- 结算资产
function M.SettlementAssets(lv,result)
    if not M.beginAssets then
        return
    end

    local getAssets = {}
    for k,v in pairs(MainModel.UserInfo.Asset) do
        local ba = M.beginAssets[k] or 0
        local dv = v - ba
        if dv > 0 then
            table.insert(getAssets,{asset_type=k,asset_value=dv})
        end
    end

    local data = {game_level = lv,result = result,asset = getAssets}
    --处理网络缓存
    NetworkHelper.HandleNetworkCache(data)
    dump(data,"SettlementAssets")
    M.beginAssets = nil
end

-- 英雄改变
function M.OnHeroChange()
    local hn = #GameInfoCenter.turret_list
    local ht = hn
    Event.Brocast("stageRefreshMonsterProgress",0,1)
    if hn >= M.HeroRoomNum then
        ht = "Max"
        M.stageGameLvMax = true
        Event.Brocast("stageRefreshMonsterProgress",1,1)
    end

    Event.Brocast("stageRefreshGameLv",ht)
end


---------------------------------------------------------------------------------------------------
-------------------------------------------物品产出-------------------------------------------------
---------------------------------------------------------------------------------------------------
--[[ 说明：
    1.最后一个房间不分配物品(由于击杀了这个房间的boss就通关了，无法拾取物品)
    2.每个房间的配置award对应一个房间通过的奖励,若这个房间有分配英雄则必然是英雄魔方，否则就是金币(每个房间都有金币)
    3.每个房间的物品都是大致均分的。
    4.对房间分配产出物品时若至少够1个按一个基数进行平均分配，剩下的随机分配,否则按顺序
    5.若房间没有任何东西则不会进行填充物品产出。
    6.第一个房间若有房间的配置award则必然掉落一个英雄。
]]


local outputGoodCfg = {

    --所有物件的物品产出率最低值(当产出物体很少时会更大，即只有1个物体时将会必产出物品)
    outputProbability = 0.5,
    
    -- 特别的 房间过关产出奖励比较高级 只产出 英雄
    -- 从第1个开始按概率随，未中往下一个继续随，若都没中用最后一个，若要随的都没有会没有
    stage = {hero = 1,},

}

-- 初始化产出物品的数据(产出物体和配置)
function M.InitOutputGoodsData()

    -- 统计关卡产出来源物体数目
    local sourceObjData = {
        data={},
        building = 0,
        monster = 0,
        stage = 0,
        haveGoodRoomNum = 0,
    }

    local sd = GameInfoCenter.GetStageData()
    local sc = GameConfigCenter.GetLevelConfig(sd.curLevel)
    local smc = GameConfigCenter.GetStageMainCfg(sd.curLevel)
    
    for i,v in ipairs(sc.room_data) do
        sourceObjData.data[i] = {
            building = 0,
            monster = 0,
            stage = 0,
        }

        local isEndRoom = true
        for _,conn in pairs(v.connect) do
            if conn.next_room then
                isEndRoom = false
            end
        end
        
        -- 排除最后一个通关房间 (终点房间打了就过关了，捡不到物品)
        -- 第1个房间需要特殊处理
        if not isEndRoom and i ~= 1 then

            local rd = sourceObjData.data[i]

            if v.award == 1 then
                sourceObjData.stage = sourceObjData.stage + 1
                rd.stage = rd.stage + 1
            end

            if v.stage_data and next(v.stage_data) then
                for _,sd in ipairs(v.stage_data) do
                    if sd.monster_fixed_data and next(sd.monster_fixed_data) then
                        sourceObjData.monster = sourceObjData.monster + #sd.monster_fixed_data
                        rd.monster = rd.monster + #sd.monster_fixed_data
                    end
                end
            end

            if v.building and next(v.building) then
                for _,b in ipairs(v.building) do
                    if b.box_id then
                        sourceObjData.building = sourceObjData.building + 1
                        rd.building = rd.building + 1
                    end
                end
                
            end

            if rd.stage + rd.monster + rd.building > 0 then
                sourceObjData.haveGoodRoomNum = sourceObjData.haveGoodRoomNum + 1
            end

        end
    end

    -- 获取关卡产出配置 进行处理
    local allOutputGoodData = basefunc.deepcopy(GameConfigCenter.GetGuanneiAwardConfig(sd.curLevel))

    local randomKey = {
        "hero","power","coin","prop","skill",
    }
    for i,v in ipairs(randomKey) do
        if type(allOutputGoodData[v]) == "table" then
            allOutputGoodData[v] = math.random(allOutputGoodData[v][1],allOutputGoodData[v][2])
        end
    end

    local hhn = GameInfoCenter.GetHeroCapacity()
    
    -- 英雄产出数量跟蛇头等级的容量走 1号房间特殊的英雄要计算上
    local f1 = 0
    if sc.room_data[1].award == 1 then
        f1 = 1
    end
    allOutputGoodData.hero = math.min(sourceObjData.haveGoodRoomNum+f1,hhn)

    dump(sourceObjData,"sourceObjData*********************************",100)
    dump(allOutputGoodData,"allOutputGoodData*********************************",100)

    M.sourceObjData = sourceObjData
    M.allOutputGoodData = allOutputGoodData

    M.HeroRoomNum = hhn

    -- 特殊规则
    M.specialRoomData = {}

    -- 1号房产出英雄
    if sc.room_data[1].award == 1 and allOutputGoodData.hero > 0 then
        allOutputGoodData.hero = allOutputGoodData.hero - 1
        M.specialRoomData["firstRoom"] = {hero = 1}
    end

    -- 隐藏金币关
    if smc.gold_roomNo then

        local rml = {}
        -- 直接找一个房间进行投放
        for i,v in ipairs(M.sourceObjData.data) do
            local n = v.building + v.monster
            if n > 5 then
                table.insert(rml,i)
                objNum = n
            end
        end
        
        local ri = math.random(#rml)
        local rn = rml[ri]
        local objNum = M.sourceObjData.data[rn].building + M.sourceObjData.data[rn].monster

        M.specialRoomData["HideGoldRoom"] = {
            roomNo = smc.gold_roomNo,
            outputRoom = rn,
            objNum = objNum,
        }

    end

    dump(M.specialRoomData,"specialRoomData*********************************",100)
end

-- 对房间分配产出物品(若至少够1个按一个基数进行平均分配，剩下的随机分配,否则按顺序)
function M.RandomRoomOutputGoodsData(type,base)
    
    -- 计算按基数分配的基础数量
    local bn = math.floor(M.allOutputGoodData[type]/base)
    local hn = bn / M.sourceObjData.haveGoodRoomNum
    hn = math.floor(hn)*base

    -- 计算按基数分配后剩下的
    local hnm = M.allOutputGoodData[type] - hn*M.sourceObjData.haveGoodRoomNum

    local rml = {}
    for i,v in ipairs(M.sourceObjData.data) do
        rml[i]=i
    end

    if hn > 0 then
        basefunc.array_shuffle( rml )
    end

    -- 加基础的个数
    for i,v in ipairs(M.sourceObjData.data) do
        if v.building + v.monster + v.stage > 0 then
            M.outputGoodData[i][type] = hn
        end
    end

    -- 加随机的个数
    for i,v in ipairs(rml) do
        local ogd = M.sourceObjData.data[v]
        if ogd.building + ogd.monster + ogd.stage > 0 and hnm > 0 then
            
            local an = math.min(hnm,base)

            M.outputGoodData[v][type] = hn + an
            hnm = hnm - an

            if hnm < 1 then
                break
            end
        end
    end

end

function M.CreateGoodsCfg(type,num,tag)

    if type == "hero" then

        -- 三选一的英雄蛋
        if tag == "stage" then

            local heroConfig = {}
            for i,v in ipairs(M.allOutputGoodData.hero_type) do
                heroConfig["hero_"..v] = 1
            end

            return {
                key = "hero_3in1",
                heroConfig = heroConfig,
            }

        else

            local ht = M.allOutputGoodData.hero_type
            local i = math.random(#ht)

            return {
                key = "prop_hero_" .. ht[i],
                value = num,
            }

        end

    elseif type == "coin" then

        local sd = GameInfoCenter.GetStageData()
        local level = GameConfigCenter.GetGoldLevel( sd.curLevel , num )
        return {
            key = "prop_gold_coin" .. level,
            value = 1,
            jb = num,
        }
    elseif type == "power" then
        return {
            key = "prop_power_nl",
            value = num,
        }
    elseif type == "prop" then

        local pt = M.allOutputGoodData.prop_type
        local i = math.random(#pt)

        return {
            key = pt[i],
            value = num,
        }
    elseif type == "skill" then
        return {
            key = "add_extra_skill_usetime",
            value = num,
        }
    else
        print("CreateGoodsCfg error :",type)
    end

end

-- 对物体进行分配产出物品
function M.RandomOutputGoodsData(roomNo)
    local roomGoodData = M.outputGoodData[roomNo]
    if not roomGoodData then
        return
    end

    -- 物品拆分列表
    local roomGoodSplitList = {}

    --物品分类总数
    local goodsNum = 0
    for k,v in pairs(roomGoodData) do
        if v > 0 then
            -- 英雄和道具必须拆
            if (k == "hero" or k == "prop") and v > 1 then
                for i=1,v do
                    table.insert(roomGoodSplitList,{k,1})
                end
                goodsNum = goodsNum + v
            else
                table.insert(roomGoodSplitList,{k,v})
                goodsNum = goodsNum + 1
            end
        end
    end

    --源物体数
    local srcData = M.sourceObjData.data[roomNo]
    local objNum = srcData.building + srcData.monster + srcData.stage

    local haveStage = false
    if srcData.stage > 0 then
        haveStage = true
    end

    -- 存储物品产出列表
    local data = {}
    
    print("goodsNum,objNum：",goodsNum,objNum)

    if objNum >= goodsNum then

        -- 物品和附属物体数量相对一致
        if (goodsNum/objNum) > outputGoodCfg.outputProbability then
            -- 不进行拆分 直接用
        else
            local non = math.floor(objNum*outputGoodCfg.outputProbability)
            -- 将可拆分的物品进行拆分

            local dn = non - goodsNum

            local cn = roomGoodData.coin
            local pn = roomGoodData.power

            if cn < dn and pn < dn then
                -- 无法拆分 不拆分无影响
                pn = 0
                cn = 0
            elseif cn > dn and pn > dn then
                -- 对半拆分
                pn = math.floor(dn*0.5)
                cn = dn - pn
            else
                -- 单项拆分
                if cn > 0 then
                    cn = dn
                else
                    pn = dn
                end
            end

            local function splitGoods( tp , sn)
                if sn < 1 then
                    return
                end
                local goodSum = roomGoodData[tp]
                local dcn = math.floor(goodSum / sn+1)
                -- 30% 浮动
                local rcn = math.floor(dcn * 0.3)

                for i,d in ipairs(roomGoodSplitList) do
                    if d[1] == tp then
                        d[2] = dcn + math.random(-rcn,rcn)
                        goodSum = goodSum - d[2]
                        break
                    end
                end
                
                for i=1,sn do
                    
                    if goodSum > 0 then
                        local n = math.min(dcn + math.random(-rcn,rcn) , goodSum)
                        table.insert(roomGoodSplitList,{tp,n})
                        goodSum = goodSum - n
                    end

                end
            end

            splitGoods( "coin" , cn)
            splitGoods( "power" , pn)
            
        end

    else

        -- 进行合并
        local hs = goodsNum - objNum

        for i=1,hs do
            
            local sln = #roomGoodSplitList

            local hd = roomGoodSplitList[sln]
            local bhd = roomGoodSplitList[sln-1]

            for i=1,#hd,2 do
                bhd[2+i] = hd[i]
                bhd[3+i] = hd[i+1]
            end

            table.remove(roomGoodSplitList)
        end

    end

    -- 先预留产出过关的奖励
    local stageReservedGoods = nil
    local st = objNum

    if haveStage then
        
        for k,v in pairs(outputGoodCfg.stage) do
            if roomGoodData[k] and roomGoodData[k]>0 then

                -- 拆分表中找一个数值给他
                for i,d in ipairs(roomGoodSplitList) do
                    for di=1,#d,2 do
                        if d[di] == k then
                            stageReservedGoods = {k,i}
                            break
                        end
                    end
                end

                if math.random() < v then
                    break
                end
            end
        end
        -- 实在是没有就不要了 (1.通常是有金币打底2.不产生不影响过关)(又改成只有英雄，若没有就不要了)
        if stageReservedGoods then
            local spi = stageReservedGoods[2]
            local spd = roomGoodSplitList[spi]
            
            data.stageGoods = {}
            for i=1,#spd,2 do
                table.insert(data.stageGoods,M.CreateGoodsCfg(spd[i],spd[i+1],"stage"))
            end

            -- 移除拆分项
            table.remove(roomGoodSplitList,spi)
            
            st = st -1
        end

    end

    local ogl = {}
    for i=1,(st) do
        ogl[i]=i
    end
    basefunc.array_shuffle(ogl)

    for i,d in ipairs(roomGoodSplitList) do
        local id = ogl[i]
        data[id] = {}
        for i=1,#d,2 do
            table.insert(data[id],M.CreateGoodsCfg(d[i],d[i+1]))
        end
    end

    roomGoodData.data = data

end

function M.SpecialRoomOutput(key,data)
    if key == "firstRoom" then
        M.outputGoodData[1] = {
            coin  = 0,
            power = 0,
            prop  = 0,
            hero  = 1,
            skill = 0,
            data = {
                stageGoods = {
                    M.CreateGoodsCfg("hero",1,"stage"),
                },
            },
        }
    end

    if key == "HideGoldRoom" then
        local sd = M.specialRoomData["HideGoldRoom"]
        local od = M.outputGoodData[sd.outputRoom]

        local ri = math.random(sd.objNum)

        for i=1,100 do
            if od.data[ri] then
                ri = ri + 1
                if ri > sd.objNum then
                    ri = 1
                end
            else
                break
            end
        end

        od.data[ri] = {
            [1] = {
                key = "connector",
                data = {
                    roomNo = sd.roomNo,
                    connect_type = 2,
                }
            }
        }

    end

end

-- 初始化产出物品
function M.InitGoods()

    M.InitOutputGoodsData()
    
    -- 初始化输出数据表
    M.outputGoodData = {}
    for i,v in ipairs(M.sourceObjData.data) do
        if v.building + v.monster + v.stage > 0 then
            M.outputGoodData[i] = {}
        end
    end

    -- 金币的基数 为中堆金币的数量中位数(金币的关卡变化比较大)
    local sd = GameInfoCenter.GetStageData()
    local gc = GameConfigCenter.GetGoldConfig(sd.curLevel,2)
    local gn = 0
    if type(gc) == "table" then
        gn = math.floor((gc[1]+gc[2])/2)
    else
        gn = gc
    end

    -- 先把按基数物品分配到房间
    M.RandomRoomOutputGoodsData("hero",1)
    M.RandomRoomOutputGoodsData("coin",gn)
    M.RandomRoomOutputGoodsData("prop",1)
    M.RandomRoomOutputGoodsData("power",5)
    M.RandomRoomOutputGoodsData("skill",1)

    -- 每个房间具体分配
    for i,v in ipairs(M.sourceObjData.data) do
        M.RandomOutputGoodsData(i)
    end

    -- 特殊房间处理
    for k,v in pairs(M.specialRoomData) do
        M.SpecialRoomOutput(k,v)
    end

    dump(M.outputGoodData,"ooooooooooooopppppppppppppp",100)

end


--[[产出物品
    stage - 房间过关的产出(较为重要，为此预留了产出物品)
    monster - 击杀怪物的产出
    building - 破坏建筑的产出
]] 
function M.OutputGoods(type)

    local sd = GameInfoCenter.GetStageData()
    local gd = M.outputGoodData[sd.roomNo]

    if gd and gd.data then

        if type == "stage" then
            return gd.data.stageGoods
        else
            gd.id = gd.id or 1
            local cfg = gd.data[gd.id]
            gd.id = gd.id + 1

            return cfg
        end

    end

end
