--[[关卡模式 A
    吃宝石过关模式
]]
StageModeC = {}
local M = StageModeC

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
    M.lister["monster_arise"] = M.OnMonsterArise
    M.lister["monster_die"] = M.OnMonsterDie

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
    
    -- 关卡数据
    M.curStageConfig = GameConfigCenter.GetStageConfig(M.curLevel,M.roomNo)

    M.state = "normal"

    M.gameData = {}
    M.gameData.getGoodsNum = 0
    M.gameData.allGoodsNum = 0

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

    -- 位置暂时失效
    local heroHeadPos = nil
    -- local sd1 = M.curStageConfig.stage_data[1]
    -- if sd1.type == 0 then
    --     heroHeadPos = sd1.pos
    -- end
    -- 蛇头
    CreateFactory.CreateHeroHead({type=MainModel.GetHeadType(),level = MainModel.GetHeadLevel(),pos=heroHeadPos})

    -- 加载英雄
    CreateFactory.CreateHeroList(MainModel.UserInfo.GameInfo.turret_list)

    -- 创建地图指示器
    CreateFactory.CreateTargetIndicator()
    
    Event.Brocast("stage_start", {
                                    hp=GameInfoCenter.playerDta.hp, 
                                    hpMax=GameInfoCenter.playerDta.hpMax,
                                    level=M.curStageConfig.level,
                                    type="jlg",
                                })

    Event.Brocast("stage_state_change","normal","box")
    Event.Brocast("stageShowTargetProgress",true)
    Event.Brocast("stageRefreshMonsterProgress",nil)
    Event.Brocast("stageSetKillData",nil)

    M.time = 0

    M.hasStageCountdown = false

    -- 必须出金币怪
    M.jbgBox = 0

    M.CreateAllItem()

    ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_award_BGM.audio_name)
end


function M.Exit()
    ExtendSoundManager.PlayOldBGM()

    Removelister()
end

function M.Awake()
end

function M.FrameUpdate(timeElapsed)
    M.time = M.time + timeElapsed
    Event.Brocast("stage_time_count_down",1-M.time/M.curStageConfig.time)
    if M.time > M.curStageConfig.time then
        M.OnStageOver(1)
    end

    if not M.hasStageCountdown and M.time+5 > M.curStageConfig.time then
        M.hasStageCountdown = true
        Event.Brocast("awardStageLastCountdown",{time = 5})
    end
end

local function caclSettleAward()
    local tt = {}
    if M.gameData.getGoodsNum >= M.gameData.allGoodsNum then
       tt.isPerfect = true
    end
    tt.jbNum = M.gameData.jb or 0
    tt.boxNum = M.gameData.box or 0
    tt.monsterNum = M.gameData.monster or 0

    tt.jbJb = tt.jbNum
    tt.boxJb = tt.boxNum * 100
    tt.monsterJb = tt.monsterNum * 10

    tt.allJb = tt.jbJb + tt.boxJb + tt.monsterJb

    return tt
end

function M.ChangeAllNumber(_num, _type)
    M.gameData[_type] = M.gameData[_type] or 0
    M.gameData[_type] = M.gameData[_type] + _num
    M.gameData.allGoodsNum = M.gameData.allGoodsNum + _num

    -- dump(M.gameData,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
end

function M.ChangeGetNumber(_num, _type)
    M.gameData[_type] = M.gameData[_type] or 0
    M.gameData[_type] = M.gameData[_type] + _num

    M.gameData.getGoodsNum = M.gameData.getGoodsNum + _num
    -- dump(M.gameData,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22")
    if M.gameData.getGoodsNum >= M.gameData.allGoodsNum then
        M.OnStageOver(1)
    end
end

-- 关卡结束 state 0|失败 1|胜利
function M.OnStageOver(state)

    if M.state == "over" then
        return
    end
    M.state = "over"

    local function startNext ()
        Event.Brocast("stage_manager_level_change_msg",{cur_level = M.cur_level})
        StageManager.StageFinish(state)
    end

    if state == 0 then

        Event.Brocast("GameLoseFx", {callback=startNext})

    elseif state == 1 then

        local sd = caclSettleAward()

        Event.Brocast("GameWinFx", {type="box",callback=startNext,settleData=sd})

    end

end


function CreateBox()
    
    local sd = M.curStageConfig.stage_data

    local lastBoxIdx = 0
    for i,v in ipairs(sd) do
        if v.type == 1 or v.type == 2 then
            lastBoxIdx = i
        end
    end

    for i,v in ipairs(sd) do
        if v.type == 1 or v.type == 2 then
            
            local gc = {
                pos = v.pos,
                type = 4,
            }
            local rd = nil
            local r = math.random(v.weight_data_sum)
            for _,vd in ipairs(v.data) do
                r = r - vd.weight
                if r < 1 then
                    rd = vd
                    break
                end
            end
            
            if i == lastBoxIdx and M.jbgBox < 1 then
                rd.type = 1
            end

            if rd.type == 1 then

                gc.collisionCallback = function (obj)
                    obj:DieByGoldMonster(rd.data)
                    M.ChangeAllNumber(rd.data, "add_monster")
                    M.ChangeGetNumber(1, "box")
                end
                M.ChangeAllNumber(1, "add_box")
                CreateFactory.CreateGoods(gc)
                
                M.jbgBox = M.jbgBox + 1

            elseif rd.type == 2 then

                gc.collisionCallback = function (obj)
                    obj:Over()
                end

                gc.aniOverCallback = function ()
                    for i = 1, rd.data do
                        local pos = RandomSquares(v.pos,5,1)
                        local jbc = {type=6,jb=1,pos=pos}
                        jbc.aniOverCallback = function ()
                            M.ChangeGetNumber(1, "jb")
                        end
                        CreateFactory.CreateGoods(jbc)
                        M.ChangeAllNumber(1, "add_jb")
                    end
                    M.ChangeGetNumber(1, "box")
                end
                M.ChangeAllNumber(1, "add_box")
                CreateFactory.CreateGoods(gc)

            elseif rd.type == 3 then

                gc.collisionCallback = function (obj)
                    obj:Over()
                end

                gc.aniOverCallback = function ()
                    local pos = RandomSquares(v.pos,5,2)
                    local tc = {type=3,buildingsName="time",pos=pos}
                    tc.aniOverCallback = function ()
                        M.time = math.max(0,M.time-rd.data)
                        M.ChangeGetNumber(1, "time")
                        M.hasStageCountdown = false
                        Event.Brocast("awardStageLastCountdown",nil)
                    end
                    CreateFactory.CreateGoods(tc)
                    M.ChangeAllNumber(1, "add_time")
                    M.ChangeGetNumber(1, "box")
                end
                M.ChangeAllNumber(1, "add_box")
                CreateFactory.CreateGoods(gc)
            end
        end
    end

end

-- 按照三角形创建物品
function CreateGoodsTriangle(pos, len, _data, _size)
    local num = 0
    local size = _size or {w=1, h=1}
    local beginPos = {x=pos.x, y=pos.y+0.5*(len-1)*size.h}
    for i = 1, len do
        for j = 1, i do
            local tc = basefunc.deepcopy(_data)
            tc.pos = {x=beginPos.x-0.5*(i-1)*size.w+size.w*(j-1), y=beginPos.y-size.h*(i-1)}
            tc.aniOverCallback = function ()
                M.ChangeGetNumber(1, "jb")
            end
            CreateFactory.CreateGoods(tc)
            num = num + 1
        end
    end
    return num
end

-- 按照矩形创建物品
function CreateGoodsRectangle(pos, w, h, _data, _size)
    local num = 0
    local size = _size or {w=1, h=1}
    local beginPos = {x=pos.x-0.5*(w-1)*size.w, y=pos.y+0.5*(h-1)*size.h}
    for i = 1, w do
        for j = 1, h do
            local tc = basefunc.deepcopy(_data)
            tc.pos = {x=beginPos.x+size.w*(i-1), y=beginPos.y-size.h*(j-1)}
            tc.aniOverCallback = function ()
                M.ChangeGetNumber(1, "jb")
            end
            CreateFactory.CreateGoods(tc)
            num = num + 1
        end
    end
    return num
end

-- 按照菱形创建物品
function CreateGoodsRhombus(pos, len, _data, _size)
    local num = 0
    local size = _size or {w=1, h=1}
    local beginPos = {x=pos.x, y=pos.y+0.5*(len-1)*size.h}
    local hl = math.ceil(len*0.5)
    for i = 1, len do
        local n = i
        if i > hl then
            n = 2*hl-i
        end
        for j = 1, n do
            local tc = basefunc.deepcopy(_data)
            tc.pos = {x=beginPos.x-0.5*(n-1)*size.w+size.w*(j-1), y=beginPos.y-size.h*(i-1)}
            tc.aniOverCallback = function ()
                M.ChangeGetNumber(1, "jb")
            end
            CreateFactory.CreateGoods(tc)
            num = num + 1
        end
    end
    return num
end

-- 金币堆
function CreateGoldCoinHeap()
    local sd = M.curStageConfig.stage_data

    for i,v in ipairs(sd) do
        if v.type == 3 then
            if v.data.type == 1 then
                local num = CreateGoodsTriangle(v.pos, v.data.data[1], {type=6, jb=1, isUsePos=true}, {w=1.4, h=1.7})
                M.ChangeAllNumber(num, "add_jb")
            elseif v.data.type == 2 then
                local num = CreateGoodsRectangle(v.pos, v.data.data[1], v.data.data[2], {type=6, jb=1, isUsePos=true}, {w=1.4, h=1.7})
                M.ChangeAllNumber(num, "add_jb")
            elseif v.data.type == 3 then
                local num = CreateGoodsRhombus(v.pos, v.data.data[1], {type=6, jb=1, isUsePos=true}, {w=1.4, h=1.7})
                M.ChangeAllNumber(num, "add_jb")
            else
                print("金币堆 模式不存在 type = " .. v.data.type)
            end
        end
    end
end

-- 按照直线创建物品
function CreateGoodsPath(pos1, pos2, _data, _size)
    -- do return 0 end
    local num = 0
    local size = _size or {w=1, h=1}
    local jl = size.w * size.h

    local call = function (p1, p2, step, isZJ)
        local beginPos = {x=p1.x, y=p1.y}
        local endPos = {x=p2.x, y=p2.y}
        if not isZJ then
            beginPos = {x=p1.x+2*step.x, y=p1.y+2*step.y}
            endPos = {x=p2.x-2*step.x, y=p2.y-2*step.y}
        end

        local curPos = {x=beginPos.x, y=beginPos.y}
        local b = true
        while (b) do
            local tc = basefunc.deepcopy(_data)
            tc.pos = {x=curPos.x, y=curPos.y}
            tc.aniOverCallback = function ()
                M.ChangeGetNumber(1, "jb")
            end
            CreateFactory.CreateGoods(tc)
            num = num + 1

            curPos = {x = curPos.x + size.w*step.x, y = curPos.y + size.h*step.y}
            if (step.x > 0 and curPos.x < endPos.x)
                or (step.x < 0 and curPos.x > endPos.x)
                or (step.y > 0 and curPos.y < endPos.y)
                or (step.y < 0 and curPos.y > endPos.y) then
                b = true
            else
                b = false
            end
        end
    end

    if math.abs(pos1.x-pos2.x) < 0.1 then -- x同线
        if math.abs(pos1.y-pos2.y) < 0.1 then -- y同线
            local tc = basefunc.deepcopy(_data)
            tc.pos = {x=pos1.x, y=pos1.y}
            tc.aniOverCallback = function ()
                M.ChangeGetNumber(1, "jb")
            end
            CreateFactory.CreateGoods(tc)
            num = num + 1
        else
            if pos1.y > pos2.y then
                call(pos1, pos2, {x=0, y=-1})
            else
                call(pos1, pos2, {x=0, y=1})
            end
        end
    else
        if math.abs(pos1.y-pos2.y) < 0.1 then
            if pos1.x > pos2.x then
                call(pos1, pos2, {x=-1, y=0})
            else
                call(pos1, pos2, {x=1, y=0})
            end
        else
            local gdPos = {x=pos1.x, y=pos2.y}
            if pos1.y > gdPos.y then
                call(pos1, gdPos, {x=0, y=-1}, true)
            else
                call(pos1, gdPos, {x=0, y=1}, true)
            end
            if gdPos.x > pos2.x then
                call(gdPos, pos2, {x=-1, y=0}, true)
            else
                call(gdPos, pos2, {x=1, y=0}, true)
            end
        end
    end
    return num
end


function CreateGoldCoinPath()
    local sd = M.curStageConfig.stage_data

    local li = 0
    -- 金币堆 不进行连线
    for i,v in ipairs(sd) do
        if v.type ~= 3 then
            
            if li < 1 then

                li = i

            else

                local beginPos = sd[li].pos
                local endPos = sd[i].pos
                local num = CreateGoodsPath(beginPos, endPos, {type=6, jb=1, isUsePos=true}, {w=2.1, h=2.5})
                M.ChangeAllNumber(num, "add_jb")

                li = i
            end

        end
    end

end


function M.CreateAllItem()
    CreateBox()
    CreateGoldCoinHeap()
    CreateGoldCoinPath()
end



-- 英雄死了
function M.OnHeroAllDie()
    M.OnStageOver(0)
end


-- 死亡
function M.OnMonsterDie(md)
    M.ChangeGetNumber(1, "monster")
end

