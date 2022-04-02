--[[关卡模式 A
    吃宝石过关模式
]]

local basefunc = require "Game/Common/basefunc"

StageModeA = basefunc.class(Object)
local M = StageModeA

function M:Ctor(data)
    self.super.Ctor( self , data )
end


function M:Removelister()
    if self.lister then
        for msg,cbk in pairs(self.lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    self.lister=nil
end

function M:AddLister()
    self.lister = {}

    self.lister["HeroAllDie"] = basefunc.handler(self,self.OnHeroAllDie)
    self.lister["boss_die"] = basefunc.handler(self,self.OnBossDie)
    self.lister["boss_arise"] = basefunc.handler(self,self.OnBossArise)
    self.lister["monster_die"] = basefunc.handler(self,self.OnMonsterDie)
    self.lister["hit_boss"] = basefunc.handler(self,self.OnHitBoss)
    self.lister["ItemDestroy"] = basefunc.handler(self,self.OnItemDestroy)

    for msg,cbk in pairs(self.lister) do
        Event.AddListener(msg, cbk)
    end

end


local function checkPassType(cfg,type)
    if cfg then
        for _,pt in ipairs(cfg.pass_type) do
            if pt == type then
                return true
            end
        end
    end
    return nil
end

-- 数据
function M:Init(data)

    self:AddLister()

    self.data = data
    
    -- 关卡
    self.curLevel = self.data.stage
    self.roomNo = self.data.roomNo
    
    GameInfoCenter.SetStageData({
        curLevel = self.curLevel,
        roomNo = self.roomNo,
    })

    -- 关卡数据
    self.curStageConfig = GameConfigCenter.GetStageConfig(self.curLevel,self.roomNo)
    
    -- 波次
    self.curStage = 0

    self.maxStage = #self.curStageConfig.stage_data
    
    self.pass_id = 1

    self:InitGemStag()

    self.state = "normal"

    self.has_passed = false

    -- GameInfoCenter.Exit()
    -- ObjectCenter.Exit()

    -- ComponseManager.RemoveAll()
    -- AttackManager.RemoveAll()

    local roomData = {
        name = self.curStageConfig.prefab,
        level = self.curLevel,
        roomNo = self.roomNo,
    }
    MapManager.Start(roomData)
    ---print("xxx--------------- MapManager.Start ")
    SnakeHeadMoveAI.Start()
    
    -- 关卡生存倒计时
    if self.curStageConfig.stage_data[1] and self.curStageConfig.stage_data[1].time then
        self.stageCountdownTime = 0
        self.StageCountdownAll = self.curStageConfig.stage_data[1].time
        self.hasStageCountdownAni = false
    end

    local stageTag = nil
    if self.curStageConfig.roomType == "boss" then
        stageTag = "boss"
    end

    -- Event.Brocast("stage_start", {
    --                                 hp=GameInfoCenter.playerDta.hp, 
    --                                 hpMax=GameInfoCenter.playerDta.hpMax,
    --                                 level=self.curLevel,
    --                                 type=stageTag,
    --                             })

    Event.Brocast("stage_state_change","normal","gem")
    Event.Brocast("stageShowTargetProgress",true)
    
    GameInfoCenter.SetStageData({
        maxStage = self.maxStage,
        curStage = self.curStage,
        state = self.state,
    })

    self.gameData = {
        allGoodsNum = 0,
        getGoodsNum = 0,

        allMonsterNum = 0,
        getMonsterNum = 0,
        getMonsterData = {},
        
        allGemNum = 0,
        getGemNum = 0,

        allBossNum = 0,
        getBossNum = 0,
    }
    -- local sd = self.curStageConfig.stage_data[self.maxStage]
    -- if sd.pass_type == 5 then
    --     self:RefreshKillData()
    -- else
        Event.Brocast("stageSetKillData",nil)
    -- end

    -- -- 目标点模式
    -- if sd.pass_type == 6 then
    --     -- 创建地图指示器
    --     CreateFactory.CreateTargetIndicator({pos=sd.pass_data,type="csm"})
    --     CreateFactory.CreatePortal({pos=sd.pass_data})
    -- end

    self.isEndRoom = true

    if not StageManager.stageGameLvMax then
        Event.Brocast("stageRefreshMonsterProgress",0,1)
        local isBossType = nil
        for i,v in ipairs(self.curStageConfig.stage_data) do
            if v.pass_type == 4 then
                isBossType = true
                break
            end
        end
        
        self.passGameData = {
            type = "normal",
            killNum = 0,
            AllNum = 0,
        }

        if isBossType then
            self.passGameData.type = "boss"
            self.passGameData.AllNum = 1
        else
            for i,sd in ipairs(self.curStageConfig.stage_data) do
                if sd.monster_fixed_data and next(sd.monster_fixed_data) then
                    self.passGameData.AllNum = self.passGameData.AllNum + #sd.monster_fixed_data
                end
            end
        end
    end

    -- 连接器
    self.connector_data = {}
    for k,v in pairs(self.curStageConfig.connect) do
        if v.next_room or v.connect_type == 3 then
            local obj = CreateFactory.CreateConnector({
                                    aStarPos = v.aStarPos,
                                    aStarSize = v.aStarSize,
                                    pos=v.pos,
                                    endPos=v.endPos,
                                    dir=v.dir,
                                    roomNo=v.next_room,
                                    size=v.size , 
                                    colls=v.colls,
                                    connect_type=v.connect_type,
                                    connect_name=v.connect_name,
                                    roomPos = self.curStageConfig.pos,
                                    roomSize = self.curStageConfig.size,
                                    })
            self.connector_data[k] = obj
            self.isEndRoom = false
        end
    end

    -- ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_usually_BGM.audio_name)
    
    self:GoToNextStage()
end


function M:InitGemStag()
    
    self.gemStage = 0

    for i,v in ipairs(self.curStageConfig.stage_data) do
        if v.gem_data then
            self.gemStage = self.gemStage + 1
        end
    end

    Event.Brocast("stageRefreshStageValue", 0, self.gemStage)

end


function M:Exit()
    self:Removelister()
end


function M:FrameUpdate(timeElapsed)

    if self.has_passed then
        return
    end

    -- 最终阶段是目标点模式
    -- if self.state ~= "over" then
    --     local msd = self.curStageConfig.stage_data[self.maxStage]
    --     if msd.pass_type == 6 then

    --         local head = GameInfoCenter.GetHeroHead()
    --         if tls.pGetDistanceSqu(head.transform.position,msd.pass_data) < 1 then

    --             -- 蛇进洞
    --             local function enterPortalCallback()

    --                 self:OnStageOver(1)
    --             end
    --             Event.Brocast("SerpentGotoPortal",{pos=msd.pass_data,callback=enterPortalCallback})

    --             self.state = "over"
    --         end

    --     end
    -- end

    if self.StageCountdownAll then
        self.stageCountdownTime = self.stageCountdownTime + timeElapsed
        Event.Brocast("stage_time_count_down",1-self.stageCountdownTime/self.StageCountdownAll)
        if self.stageCountdownTime > self.StageCountdownAll then
            self.pass_id = 1
            local sd = self.curStageConfig.stage_data[self.curStage]
            for pid,pt in ipairs(sd.pass_type) do
                if pt == 2 then
                    self.pass_id = pid
                end
            end
            self:PassLevel(self.pass_id)
            Event.Brocast("stage_time_count_down",nil)
            self.StageCountdownAll = nil
        end

        if not self.hasStageCountdownAni and self.stageCountdownTime+5 > self.StageCountdownAll then
            self.hasStageCountdownAni = true
            Event.Brocast("awardStageLastCountdown",{time = 5})
        end
    end

    if self.create_monster_time_data then
        for i,c in ipairs(self.create_monster_time_data.cfg) do
            local d = self.create_monster_time_data.data[i] or {time=0,num=0}
            self.create_monster_time_data.data[i] = d
            d.time = d.time + timeElapsed
            if (not c.max or d.num < c.max) and d.time >= c.interval then
                local mi = math.random(#c.monsters)
                local pos = RandomSquares(c.pos, c.r[1], c.r[2])
                local md = {use_id=c.monsters[mi],pos=pos,roomNo=self.roomNo}
                CreateFactory.CreateMonster(md)
                d.time = d.time - c.interval
                d.num = d.num + 1
            end
        end
    end

    if self.create_prop_time_data then
        for i,c in ipairs(self.create_prop_time_data.cfg) do
            local d = self.create_prop_time_data.data[i] or {time=0,num=0}
            self.create_prop_time_data.data[i] = d
            d.time = d.time + timeElapsed
            if (not c.max or d.num < c.max) and d.time >= c.interval then
                local mi = math.random(#c.props)
                local pos = RandomSquares(c.pos, c.r[1], c.r[2])
                local pd = {pos=pos,config={[1]={key=c.props[mi],value=1}}}
                DropAsset.Create(pd)
                d.time = d.time - c.interval
                d.num = d.num + 1
            end
        end
    end

end

-- 关卡结束 state 0|失败 1|胜利
function M:OnStageOver(state)
    
    if self.stageOver then
        return
    end

    local function startNext ()
        Event.Brocast("stage_manager_level_change_msg",{cur_level = self.cur_level})
        StageManager.StageFinish(state)
    end
    
    if state == 0 then

        Event.Brocast("GameLoseFx", {type=self.state,callback=startNext})
        StageManager.StageSaveData(state)

    elseif state == 1 then
        local award_id = nil
        if self.boss_award_data then
            award_id = self.boss_award_data.award_id
        end
        Event.Brocast("GameWinFx", {type=self.state,callback=startNext,award=award_id})
    end

    -- 游戏完成 设置玩家无敌
    Event.Brocast("HeroSetState","gameFinish")
    

    self.stageOver = true
end

-- 
function M:checkPassStag(tp)
    
    if self.has_passed then
        return
    end

    local sd = self.curStageConfig.stage_data[self.curStage]

    if not sd then
        return
    end

    local ok = false

    for i,pd in ipairs(sd.pass_type) do
            
        if pd == 1 then
            if self.gameData.getGemNum >= self.gameData.allGemNum then
                ok = true
            end
        elseif pd == 2 then
            if self.gameData.getGoodsNum >= self.gameData.allGoodsNum then
                ok = true
            end
        elseif pd == 3 then
            if self.gameData.getMonsterNum >= self.gameData.allMonsterNum then
                ok = true
            end
        elseif pd == 4 then
            if self.gameData.getBossNum >= self.gameData.allBossNum then
                ok = true
            end
        -- elseif pd == 5 then
        --     if sd.pass_data then
        --         ok = true
        --         for k,v in pairs(sd.pass_data) do
        --             if (self.gameData.getMonsterData[k] or 0) < v then
        --                 ok = false
        --                 break
        --             end
        --         end
        --         if tp == "MonsterDie" then
        --             self:RefreshKillData()
        --         end
        --     else
        --         if self.gameData.getMonsterNum >= self.gameData.allMonsterNum then
        --             ok = true
        --         end
        --     end

        elseif pd == 6 then
            if self.gameData.getBossNum >= self.gameData.allBossNum 
                    and self.gameData.getMonsterNum >= self.gameData.allMonsterNum then
                ok = true
            end
        end

        if ok then

            self.pass_id = i

            local empty = tp == "first"
            self:GoToNextStage(empty)

            break
        end

    end

end

-- 显示击杀数据
function M:RefreshKillData()

    -- local sd = self.curStageConfig.stage_data[self.maxStage]
    -- if sd.pass_type == 5 then
    --     local pd = {}
    --     for k,v in pairs(sd.pass_data) do
    --         table.insert(pd,{id=k,value=(self.gameData.getMonsterData[k] or 0),maxValue=v})
    --     end
    --     Event.Brocast("stageSetKillData",pd)
    -- end
end

function M:CreateGem()

    local gcs = GameConfigCenter.GetStageGemData(self.curLevel,self.roomNo,self.curStage)
    if not gcs then
        return
    end

    local hm = nil
    local nsd = self.curStageConfig.stage_data[self.curStage+1]
    if nsd and nsd.monster_attr_data then
        hm = true
    end

    for i,gc in ipairs(gcs) do
        if gc.tag == "normal" then

            gc.collisionCallback = function (obj)
                GameInfoCenter.SetHeroHeadTargetData()
                Event.Brocast("stageRefreshStageValue", self.gameData.getGemNum + 1, self.gemStage)
                
                if hm then
                    obj:AnimateAriseMonster()
                else
                    obj:Over()
                end

            end

            gc.aniOverCallback = function ( obj )
                self.gameData.getGemNum = self.gameData.getGemNum + 1
                self:checkPassStag()
            end

        elseif gc.tag == "boss" then

            gc.collisionCallback = function (obj)
                GameInfoCenter.SetHeroHeadTargetData()
                Event.Brocast("stageRefreshStageValue", self.gameData.getGemNum + 1, self.gemStage)
                obj:AnimateAriseBoss()
            end

            gc.aniOverCallback = function ( obj )

                self.gameData.getGemNum = self.gameData.getGemNum + 1
                self:checkPassStag()
            end

        elseif gc.tag == "over" then

            gc.collisionCallback = function (obj)
                GameInfoCenter.SetHeroHeadTargetData()
                Event.Brocast("stageRefreshStageValue", self.gameData.getGemNum + 1, self.gemStage)
                if self.gameData.getGemNum+1 >= self.gameData.allGemNum then
                    obj:AnimateStageOver()
                end
            end

            gc.cjbFinishCallback = function (obj)
                if self.gameData.getGemNum+1 >= self.gameData.allGemNum then
                    SpawnBulletManager.RemoveAll()
                    AttackManager.RemoveAll()
                    GameInfoCenter.RemoveAllMonsters()
                end
            end

            gc.aniOverCallback = function ( obj )
                self.gameData.getGemNum = self.gameData.getGemNum + 1
                self:checkPassStag()
            end

        end
        if gc.obj then
            gc.obj.data = gc
        else
            CreateFactory.CreateGoods(gc)
        end
        GameInfoCenter.SetHeroHeadTargetData({pos=gc.pos,type="gem"})

    end
        
    self.gameData.allGemNum = self.gameData.allGemNum + #gcs

end

function M:CreateGoods()

    -- local gc = GameConfigCenter.GetStageGoodsData(self.curLevel,self.roomNo,self.curStage)
    -- if not gc then
    --     return
    -- end

    -- -- 基础 位置 为 当前蛇头位置
    -- local tp = GameInfoCenter.GetHeroHeadAveragePos()
    -- local hd = {}
    -- for i,v in ipairs(gc) do
    --     v.pos = v.pos or RandomSquaresMul(tp,5,1,hd,1.5)
    --     v.aniOverCallback = function ()
    --         self.gameData.getGoodsNum = self.gameData.getGoodsNum + 1
    --         self:checkPassStag()
    --     end
    --     CreateFactory.CreateGoods(v)
    -- end

    -- self.gameData.allGoodsNum = self.gameData.allGoodsNum + #gc

    local sd = self.curStageConfig.stage_data[self.curStage]
    self.goods_objs = nil
    if checkPassType(sd,2) then
        self.goods_objs = MapManager.GetWaveNumberAllItems(self.roomNo,self.curStage)
        local n = 0
        for k,v in pairs(self.goods_objs) do
            n = n + 1
        end
        self.gameData.allGoodsNum = self.gameData.allGoodsNum + n
    end


    -- 按时间创建道具
    self.create_prop_time_data = nil
    if sd.prop_time_data and next(sd.prop_time_data) then
        self.create_prop_time_data = {
            cfg = sd.prop_time_data,
            data = {},
        }
    end

end

function M:AriseMonster()

    local lc = self.curStageConfig.stage_data[self.curStage]

    local mok = checkPassType(lc,3)

    local mc,info = GameConfigCenter.GetStageRandomMonsterData(self.curLevel,self.roomNo,self.curStage)
    if mc then
        CreateFactory.CreateMonsterGroup(mc,self.roomNo)

        self.gameData.allMonsterNum = self.gameData.allMonsterNum + info.monsters
        self.gameData.allBossNum = self.gameData.allBossNum + info.boss

        if info.boss > 0 then
            -- ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_BOSS_BGM.audio_name)
        end

        if mok then
            self.gameData.allMonsterNum = self.gameData.allMonsterNum - self.gameData.getMonsterNum
            self.gameData.getMonsterNum = 0
            -- Event.Brocast("stageRefreshMonsterProgress",0,self.gameData.allMonsterNum)
        end

    end

    -- if not mok then
    --     Event.Brocast("stageRefreshMonsterProgress",nil)
    -- end 

    -- 按时间创建怪物
    self.create_monster_time_data = nil
    if lc.monster_time_data and next(lc.monster_time_data) then
        self.create_monster_time_data = {
            cfg = lc.monster_time_data,
            data = {},
        }
    end

end

function M:PassLevel(pass_id,empty)

    -- 空房间和最后一个房间不用显示区域已清空
    if not empty and not self.isEndRoom then
        Event.Brocast("ClearStageFx")
    end

    local gsz = GetGridSize( MapManager.GetCurRoomAStar() )
    local cd = self.connector_data[pass_id]

    -- 可去下一关
    if not self.isEndRoom then

        if self.curStageConfig.award == 1 then

            local pos = Vector3.zero
            if cd then
                pos = Vector3.New(cd.data.pos.x, cd.data.pos.y-4*gsz, 0)
            end
            
            local config = StageManager.OutputGoods("stage")
            if config then

                -- DropAsset.Create({pos = pos,config = config, aniOverCallback=eatEggCbk,})

                local hero3in1 = nil
                for i,v in ipairs(config) do
                    if v.key == "hero_3in1" then
                        hero3in1 = i
                        break
                    end
                end

                if hero3in1 then

                    -- 升级特效 稍晚一点 等待进度条涨满
            
                    local heroConfig = config[hero3in1].heroConfig

                    local seq = DoTweenSequence.Create()

                    -- 空房间不播放升级特效
                    if not empty then
                        seq:AppendInterval(0.5)
                        seq:AppendCallback(function ()
                            Event.Brocast("GameLvUpFx")
                        end)
                    end

                    seq:AppendInterval(1)
                    seq:AppendCallback(function ()
                        ItemThreeChooseOneManager.Create(heroConfig)
                    end)

                    table.remove(config,hero3in1)

                end

                if next(config) then
                    DropAsset.Create({pos = pos,config = config})
                end

            end

        end
    
        Event.Brocast("stage_time_count_down",nil)

    end

    if self.isEndRoom then
        self:OnStageOver(1)
    elseif cd then
        cd:event(1)
    end

    
    self.has_passed = true

end


-- 进入下一个阶段(波次)
function M:GoToNextStage(empty)

    -- 是否还有下一关
    self.curStage = self.curStage + 1
    if self.curStage > self.maxStage then
        self.curStage = self.maxStage

        self:PassLevel(self.pass_id,empty)

        return
    end


    -- 下一关是boss
    local nc = self.curStageConfig.stage_data[self.curStage]
    if checkPassType(nc,4) then

        Event.Brocast("stage_state_change","boss_coming",basefunc.handler(self,self.dealStageConent))

    else

        self:dealStageConent()

    end


end


function M:dealStageConent()

    -- 进行下一关的内容
    GameInfoCenter.SetStageData({
        curStage = math.min(self.curStage,self.maxStage),
    })

    -- 创建宝石
    self:CreateGem()

    self:CreateGoods()

    -- 刷怪
    self:AriseMonster()

    -- 下一帧立刻检测一次是否达成过关条件
    coroutine.start(function ( )
        Yield(0)
        self:checkPassStag("first")
    end)

end


---------------------------------------------------------------------------

-- 英雄死了
function M:OnHeroAllDie()
    self:OnStageOver(0)
end


-- boss出现
function M:OnBossArise(md)
    if md.data.roomNo ~= self.roomNo then
        return
    end

    self.state = "boss"
    self.boss_award_data = {award_id=md.data.config.award_box}

    Event.Brocast("stageRefreshBossValue",md.hp,md.maxHp)

    GameInfoCenter.SetStageData({
        state = self.state,
    })

end


-- boss死亡
function M:OnBossDie(md)
    if md.data.roomNo ~= self.roomNo then
        return
    end


    self.gameData.getBossNum = self.gameData.getBossNum + 1

    local n = (self.gameData.getMonsterData[md.data.type] or 0) + 1
    self.gameData.getMonsterData[md.data.config.type] = n

    if self.gameData.getBossNum >= self.gameData.allBossNum then
        Event.Brocast("stage_state_change","normal","gem")
    end

    if self.passGameData and self.passGameData.type == "boss" then
        self.passGameData.killNum = self.passGameData.killNum + 1
        
        local hup = CSModel.Get3DToUIPoint(md.transform.position)
        CSEffectManager.PlayMoveAndHideFX(CSPanel.transform, "TW_zise_ui", hup, CSPanel:GetExpNode(), nil, 1,function ()
            Event.Brocast("stageRefreshMonsterProgress",self.passGameData.killNum,self.passGameData.AllNum)
        end)
    end

    self:checkPassStag()

end


function M:OnMonsterDie(md)
    
    if md.data.roomNo ~= self.roomNo then
        return
    end

    self.gameData.getMonsterNum = self.gameData.getMonsterNum + 1

    local n = (self.gameData.getMonsterData[md.data.type] or 0) + 1
    self.gameData.getMonsterData[md.data.config.type] = n

    -- local lc = self.curStageConfig.stage_data[self.curStage]

    -- local mok = checkPassType(lc,3)

    -- if mok then
    --     Event.Brocast("stageRefreshMonsterProgress",self.gameData.getMonsterNum,self.gameData.allMonsterNum)
    -- end

    if self.passGameData and self.passGameData.type == "normal" then

        self.passGameData.killNum = self.passGameData.killNum + 1

        local hup = CSModel.Get3DToUIPoint(md.transform.position)
        CSEffectManager.PlayMoveAndHideFX(CSPanel.transform, "TW_zise_ui", hup, CSPanel:GetExpNode(), nil, 1,function ()
            Event.Brocast("stageRefreshMonsterProgress",self.passGameData.killNum,self.passGameData.AllNum)
        end)

    end

    self:checkPassStag("MonsterDie")
end

-- boss受攻击
function M:OnHitBoss(md)
    if md.data.roomNo ~= self.roomNo then
        return
    end

    if self.state == "boss" then
        Event.Brocast("stageRefreshBossValue",md.hp,md.maxHp)
    end

end

-- 道具被吃了
function M:OnItemDestroy(data)

    if self.goods_objs and self.goods_objs[data.id] then
        self.goods_objs[data.id] = nil
        self.gameData.getGoodsNum = self.gameData.getGoodsNum + 1
        self:checkPassStag()
    end

end
