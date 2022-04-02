GameInfoCenter = {}
local M = GameInfoCenter
local basefunc = require "Game/Common/basefunc"

function M.Init()
    
    ---- 对象存活池
    

    --------------------------------------- Stage ↓↓↓
    M.stageData = {
        curLevel = 0,           --当前关卡
        roomNo = 0,             --当前房间号
        maxLevel = 0,           --历史最大关卡
        state = "normal",       --当前状态
        curStage = 0,           --当前关卡波次
        maxStage = 0,           --当前关卡总波次
    }
    --------------------------------------- Stage ↑↑↑

    --------------------------------------- Monster ↓↓↓
    -- 所有的怪物数据， key = id ，value = monster_obj
    M.monsterData = {}
    -- 怪物数量
    M.monsterCount = 0
    -- boss怪的id数据，key = index , value = id 怪物id
    M.BossIds = {}
    --------------------------------------- Monster ↑↑↑

    --------------------------------------- goods ↓↓↓
    -- 建筑数据，key = type , value = { [id] = obj , ... }
    M.goods = {}
    --------------------------------------- goods ↑↑↑

    --------------------------------------- heroHead ↓↓↓
    -- 蛇头对象
    M.heroHead = nil
    M.heroHeadSkillProgress = 0     --- 
    --------------------------------------- heroHead ↑↑↑

    --------------------------------------- heroHead ↓↓↓
    --- 蛇身的列表，key = location , value = obj
    M.heroList = {}
    --- 蛇身的数据，key = heroId , value = obj
    M.heroData = {}
    M.heroCount = 0
    M.hero_attack_speed_size = 1 -- 全局英雄攻速系数

    --- 玩家的数据
    local hp = 1000
    M.playerDta = {
        state = "normal",
        hp = hp,
        hpMax = hp,
        heroCapacity = 20,  --英雄容量
    }

    -- 上阵炮台
--   [1] = "红色", 默认瓶子炮
-- 	 [2] = "绿色", 默认毒液
-- 	 [3] = "黄色", 默认弓箭
-- 	 [4] = "蓝色", 默认星星
    M.battleTurret = {
        [1] = 3,
        [2] = 4,
        [3] = 2,
        [4] = 1,
    }

    -- 炮台信息
    M.turretInfo = {
        [1] = {star=1,level = 1},
    }

    -- 资产数据
    M.assetData = {}
    --------------------------------------- heroHead ↑↑↑

    --- 关卡数据
    --M.stageData = {curStage=1,maxStage=1,}

    --- 地图相关
    M.map = {
        --[[

        grid_size = 1.6 , 
        sceen_size = { width = 32 , height = 48 } ,
        grid_num = { x = math.ceil( 32 / 1.6 ) , y = math.ceil( 48 / 1.6 ) } ,

        --]]
    }

    

end

----
function M.SetMapInfo( _grid_size , _sceen_size )
    M.map.grid_size = _grid_size
    M.map.sceen_size = _sceen_size
    M.map.grid_num = { x = math.ceil( _sceen_size.width / _grid_size ) , y = math.ceil( _sceen_size.height / _grid_size ) } 

    --M.SetForceNotPassGrid()

end

function M.GetCurRoomNo()
    return M.stageData.roomNo
end

---- 设置强制不能过的 格子
--[[function M.SetForceNotPassGrid()
    M.forceMapNotPassGridData = {}
    ----- 把周围围起来
    for x = 1 , M.map.grid_num.x do
        local no_down = GetMapNoByCoord(x , 1)
        local no_up = GetMapNoByCoord(x , M.map.grid_num.y )

        M.forceMapNotPassGridData[ no_down ] = true
        M.forceMapNotPassGridData[ no_up ] = true

    end

    for y = 1 , M.map.grid_num.y do
        local no_left = GetMapNoByCoord( 1 , y )
        local no_right = GetMapNoByCoord( M.map.grid_num.x , y )

        M.forceMapNotPassGridData[ no_left ] = true
        M.forceMapNotPassGridData[ no_right ] = true

    end
end--]]


function M.Exit()
    M.RemoveAllMonsters()
    M.RemoveAllGoods()
    M.RemoveAllHeros()
    M.RemoveAllHeroHeads()
end


---- 获得自动控制模式开关
function M.getIsAutoCtrlModelEnable()
    return AutoControlModelManager.isEnable
end

------------------------------------------------ 关卡 ↓↓↓
------------------------------------------------ 关卡 ↓↓↓
------------------------------------------------ 关卡 ↓↓↓

function M.GetStageData()
    return M.stageData
end

function M.SetStageData(data)
    for k,v in pairs(data) do
        M.stageData[k] = v
    end
end


------------------------------------------------ 怪物 ↓↓↓
------------------------------------------------ 怪物 ↓↓↓
------------------------------------------------ 怪物 ↓↓↓


function M.AddMonster(data)
    M.monsterData[data.id] = data
    M.monsterCount = M.monsterCount + 1
    if data.config.type > 100 then
        table.insert(M.BossIds,data.id)
        Event.Brocast("boss_arise",data)
    else
        Event.Brocast("monster_arise",data)
    end

end


function M.RemoveAllMonsters()
    for k,v in pairs(M.monsterData) do
        M.RemoveMonsterById(k)
    end
    M.BossIds = {}
end

function M.RemoveAllSmallMonster()
    for k,v in pairs(M.monsterData) do
        if v.config.type <= 100 then
            Event.Brocast("monster_die", v)
            M.RemoveMonsterById(k)
        end
    end
end

function M.RemoveMonsterById(id)
    local m = M.monsterData[id]
    if m then
        m.isLive = false
        for i,bid in ipairs(M.BossIds) do
            if bid == id then
                M.BossIds[i] = nil
            end
        end
        M.monsterData[id] = nil
        M.monsterCount = M.monsterCount - 1
    end
end

function M.GetAllMonsters()
    return M.monsterData
end

function M.GetMonsterById(id)
    
    return M.monsterData[id]
end

function M.GetMonsterBossObj()
    local id = M.BossIds[1]
    return M.GetMonsterById(id)
end

function M.GetMonsterPosById(id)
    local obj = M.GetMonsterById(id)
    if obj then
        return obj.transform.position
    end
    return Vector3.zero
end


function M.GetMonstersRangePos(pos,range)
    local result = {}
    local r2 = range*range
    for k,v in pairs(M.monsterData) do
        local dis = tls.pGetDistanceSqu(pos,v.transform.position)
        if dis < r2 then
            table.insert(result,v)
        end
    end
    return result
end


--获取离某一点最近的怪
function M.GetMonsterDisMin(pos)
    local monster = nil
    local mds = 999999999
    for k,v in pairs(M.monsterData) do
        local dis = tls.pGetDistanceSqu(pos,v.transform.position)
        if dis < mds then
            monster = v
            mds = dis
        end
    end
    return monster
end

 
function M.ScanTarget(pos, r)
    local array = {}
    for k,v in pairs(M.monsterData) do
        local dist = Vec2DLength(Vec2DSub(pos, v.transform.position))
        if dist < r then
            array[#array + 1] = v.vehicle
        end
    end
    return array
end



------------------------------------------------ 怪物 ↑↑↑
------------------------------------------------ 怪物 ↑↑↑
------------------------------------------------ 怪物 ↑↑↑








------------------------------------------------ 物件 ↓↓↓
------------------------------------------------ 物件 ↓↓↓
------------------------------------------------ 物件 ↓↓↓


function M.AddGoods(data)

    local td = M.goods[data.type] or {}
    M.goods[data.type] = td

    td[data.id] = data

end

function M.RemoveAllGoods()

    for t,v in pairs(M.goods) do
        for id,d in pairs(v) do
            d.isLive = false
            v[id] = nil
        end
        M.goods[t] = nil
    end

end

function M.RemoveGoodsById(id)

    for t,v in pairs(M.goods) do
        local d = v[id]
        if d then
            d.isLive = false
            v[id] = nil
            return true
        end
    end

end

function M.RemoveAllGoodsByType(t)

    local td = M.goods[t]
    if td then
        for id,d in pairs(td) do
            d.isLive = false
            td[id] = nil
        end
        M.goods[t] = nil
    end

end

function M.GetAllGoods()
    return M.goods
end


------------------------------------------------ 物件 ↑↑↑
------------------------------------------------ 物件 ↑↑↑
------------------------------------------------ 物件 ↑↑↑



------------------------------------------------ 蛇头 ↓↓↓
------------------------------------------------ 蛇头 ↓↓↓
------------------------------------------------ 蛇头 ↓↓↓

function M.AddHeroHead(obj)
    M.heroHead = obj
end

function M.RemoveHeroHeadById(id)
    if M.heroHead then
        M.heroHead.isLive = false
        M.heroHead = nil
    end
end

-- 清除所有
function M.RemoveAllHeroHeads()
    M.RemoveHeroHeadById()
end

function M.GetHeroHeadByLocation(l)
    if l == 0 then return end
    return M.heroHead
end

function M.GetHeroHead()
    return M.heroHead
end


-- 计算最近的队列距离的平方
function M.GetHeroHeadDistanceByPos(pos)

    if M.heroHead then
        return tls.pGetDistanceSqu(pos, M.heroHead.transform.position)
    end

    return 100000000
end

-- 平均位置
function M.GetHeroHeadAveragePos()
    
    if M.heroHead then
        return M.heroHead.transform.position
    end

end

--- 拿 蛇身 的位置
function M.GetHeroPosList()
    
    --[[if M.heroHead then
        return {M.heroHead.transform.position}
    end--]]
    local tarList = {}
    if M.heroList and type(M.heroList) == "table" then        
        for location,data in pairs( M.heroList ) do
            tarList[location] = data.transform.position
        end
    end

    return tarList
end



function M.AddHeroHeadSkillProgress(n)
    M.heroHeadSkillProgress = M.heroHeadSkillProgress + (n or 1)
    Event.Brocast("HeroHeadSkillProgressChange", {progress = M.heroHeadSkillProgress})
    return M.heroHeadSkillProgress
end

function M.SetHeroHeadSkillProgress(t)
    M.heroHeadSkillProgress = t
    Event.Brocast("HeroHeadSkillProgressChange", {progress = t})
    return M.heroHeadSkillProgress
end

function M.GetHeroHeadSkillProgress()
    return M.heroHeadSkillProgress
end


function M.SetHeroHeadTargetData(data)
    --print("xxx--------------SetHeroHeadTargetData:" , data and data.pos.x , data and data.pos.y , debug.traceback() )
    M.heroHeadTargetData = data

end

function M.GetHeroHeadTargetData()

    return M.heroHeadTargetData

end


------------------------------------------------ 蛇头 ↑↑↑
------------------------------------------------ 蛇头 ↑↑↑
------------------------------------------------ 蛇头 ↑↑↑




------------------------------------------------ 英雄 ↓↓↓
------------------------------------------------ 英雄 ↓↓↓
------------------------------------------------ 英雄 ↓↓↓

function M.BuyHero(data)
    local tn = #M.turret_list
    M.turret_list[tn+1] = {
        heroId = tn+1,
        location = tn+1,
        type = data.type,
        level = 1,
        star = M.GetTurretLevel(data.type),
    }
    Event.Brocast("model_turret_change_msg")
end

function M.SaleHero(data)
    local tn = #M.turret_list
    M.turret_list[tn] = nil
    Event.Brocast("model_turret_change_msg")
end

function M.RefreshHeroList()
    M.heroList = {}
    for heroId, data in pairs(M.heroData) do
        M.heroList[data.data.location] = data
    end
end

function M.AddHero(data)
    M.heroData[data.data.heroId] = data
    if data.data.location then
        M.heroList[data.data.location] = data
        Event.Brocast("new_hero_created",data)
    end
end

function M.GetHeroDataByID(id)
    local list = M.turret_list
    for i = 1,#list do
        if id == list[i].heroId then
            return list[i]
        end
    end
end

function M.RemoveHeroById(id)
    local obj = M.GetHeroByHeroId(id)
    if obj then
        obj.isLive = false
        M.heroData[id] = nil
        table.remove(M.heroList,obj.data.location)
    end
end
--获取英雄的数量
function M.GetHeroNum()
    local num = 0
    for k,v in pairs(M.heroData) do
        num = num + 1
    end
    return num
end

-- 清除所有英雄
function M.RemoveAllHeros()
    for id,v in pairs(M.heroData) do
        v.isLive = false
        M.heroData[id] = nil
        M.heroList[v.data.location] = nil
    end
end

function M.GetHeroByHeroId(id)
    return M.heroData[id]
end

--获取最近的英雄
function M.GetHeroDisMin(pos)
    local min_dis = 99999
    local dis
    local hero = nil
    for k,v in pairs(M.heroData) do
        dis = Vector3.Distance(v.transform.position, pos)
        if dis < min_dis then
            min_dis = dis
            hero = v
        end
    end
    return hero
end

-- 版本1：攻击英雄
-- 版本2：攻击蛇头
function M.GetMonsterAttkByDisMin(pos)
    -- return M.GetHeroDisMin(pos)
    return M.GetHeroHead()
end

function M.GetAllHero()
    return M.heroData
end


function M.InitPlayerData()

    local teamLevel = MainModel.QueryTeamLevel()
    local healthLevel = MainModel.QueryHealthLevel()

    local teamCfg = GameConfigCenter.GetTeamLevelDataConfig()
    local healthCfg = GameConfigCenter.GetHealthLevelDataConfig()

    local heroNum = teamCfg[teamLevel].num or 1
    local hpMax = healthCfg[healthLevel].hp or 1

    M.playerDta.hpMax = hpMax + TechnologyManager.GetMaxHpUp()
    M.playerDta.heroCapacity = heroNum

    M.playerDta.hp = M.playerDta.hpMax
    M.playerDta.state = "normal"
end


function M.GetPlayerSkillInfo()

    local ht = MainModel.GetHeadType()
    local headCfg = GameConfigCenter.GetHeroHeadDataConfig(ht)
    local hl = MainModel.GetHeadLevel(ht)
    local skill_num = headCfg[hl].skill_num
    local skill_num_max = headCfg[hl].skill_num_max
    return {
        skill_num = skill_num,
        skill_num_max = skill_num_max,
    }

end


function M.AddPlayerHp(hp)

    if M.playerDta.state == "die" then
        return
    end
    local oldHp = M.playerDta.hp

    M.playerDta.hp = math.max(M.playerDta.hp + hp , 0)
    M.playerDta.hp = math.min(M.playerDta.hp , M.playerDta.hpMax)
    
    Event.Brocast("hero_hp_change_msg",{ oldHp = oldHp , hp=M.playerDta.hp, hpMax=M.playerDta.hpMax})

end

function M.AddPlayerHpMax(hp_max)

    if M.playerDta.state == "die" then
        return
    end
    local oldHp = M.playerDta.hp
    local oldMaxHp = M.playerDta.hpMax
    M.playerDta.hpMax = M.playerDta.hpMax + hp_max

    
    Event.Brocast("hero_hp_change_msg",{oldMaxHp = oldMaxHp ,oldHp = oldHp , hp=M.playerDta.hp, hpMax=M.playerDta.hpMax})

end



function M.CheakIsCanComponse(hero1,hero2)
    if hero1 and hero2 and hero1.data.type == hero2.data.type then
        if hero1.data.level == hero2.data.level then
            return true
        end
    end
    return false
end

--获取某一点范围内的英雄
function M.GetHeroRangePos(pos,range)
    local result = {}
    for k,v in pairs(M.heroData) do
        local dis = tls.pGetDistanceSqu(pos,v.transform.position)
        if dis < range*range then
            result[#result + 1] = v
        end
    end
    local dis = tls.pGetDistanceSqu(pos,M.heroHead.transform.position)
    if dis < range*range then
        result[#result + 1] = M.heroHead
    end
    return result
end


function M.GetHeroByLocation(location)
    for k , v in pairs(M.heroData) do
        if v.data.location == location then
            return v
        end
    end
end

function M.GetHeroList()
    return M.heroList
end


------------------------------------------------ 英雄 ↑↑↑
------------------------------------------------ 英雄 ↑↑↑
------------------------------------------------ 英雄 ↑↑↑




------------------------------------------------ 其他 ↓↓↓
------------------------------------------------ 其他 ↓↓↓
------------------------------------------------ 其他 ↓↓↓

function M.GetObjSkillByType(obj,type)
    local sd = obj.skill
    if sd then
        for k,v in pairs(sd) do
            if v.type == type then
                return v
            end
        end
    end
    return nil
end

function M.GetObjSkillByTypeValue(obj , _type , _value)
    local sd = obj.skill
    if sd then
        for k,v in pairs(sd) do
            if v[_type] == _value then
                return v
            end
        end
    end
    return nil
end

------------------------------------------------ 其他 ↑↑↑
------------------------------------------------ 其他 ↑↑↑
------------------------------------------------ 其他 ↑↑↑





------------------------------------------------ 地图 ↓↓↓
------------------------------------------------ 地图 ↓↓↓
------------------------------------------------ 地图 ↓↓↓
--[[function M.GetMapSize()
    return M.map.sceen_size
end--]]


--[[function M.GetMapNotPassGridData()
    -- dump(M.mapNotPassGridData , "xxx---------------------M.mapNotPassGridData:")

    --- key = no , value = true
    local tarData = basefunc.deepcopy( M.mapNotPassGridData or {} )

    --- 把强制不能过的点，附加上来
    basefunc.merge( M.forceMapNotPassGridData or {} , tarData )

    return tarData
end

--- 全部设置
function M.SetMapNotPassGridData(data)
    M.mapNotPassGridData = {} -- data

    --- 直接设置
    for key ,_data in pairs(data) do
        local no = GetMapNoByCoord( _data.posX , _data.posY )
        M.mapNotPassGridData[no] = true
    end

    dump(M.mapNotPassGridData , "<color=yellow>xxx-----------SetMapNotPassGridData</color>")
    --- 同步
    SetMapCantPassGrid()
end

---- 添加
function M.AddMapNotPassGridData(data)
    --M.mapNotPassGridData = {} -- data

    --- 直接设置
    for key ,_data in pairs(data) do
        local no = GetMapNoByCoord( _data.posX , _data.posY )
        M.mapNotPassGridData[no] = true
    end

    --- 同步
    SetMapCantPassGrid()
end--]]

------------------------------------------------ 地图 ↑↑↑
------------------------------------------------ 地图 ↑↑↑
------------------------------------------------ 地图 ↑↑↑



------------------------------------------------ 资产 ↓↓↓
------------------------------------------------ 资产 ↓↓↓
------------------------------------------------ 资产 ↓↓↓
--[[
    宝石 = "prop_jin_bi"
    金蛇胆 = "prop_snake_egg"
    蘑菇 = "prop_mushroom"
    英雄碎片 = "prop_turret_fragment_(id)"
]]

function M.GetAssetData()
    return M.assetData
end

function M.GetAssetNum(type)
    return M.assetData[type] or 0
end

function M.AddAssetNum(type,num)
    M.assetData[type] = (M.assetData[type] or 0) + num
    return M.assetData[type]
end

------------------------------------------------ 资产 ↑↑↑
------------------------------------------------ 资产 ↑↑↑
------------------------------------------------ 资产 ↑↑↑



------------------------------------------------ 养成数据 ↓↓↓
------------------------------------------------ 养成数据 ↓↓↓
------------------------------------------------ 养成数据 ↓↓↓
--[[
]]


function M.GetBattleTurret()
    return M.battleTurret
end

function M.UpdateBattleTurret(color,id)
    M.battleTurret[color] = id
end

function M.GetBattleTurretByColor(color)
    return M.battleTurret[color]
end

function M.GetTurretInfo()
    return M.turretInfo
end

function M.UpdateTurretInfo(type,info)
    M.turretInfo[type] = info
end

function M.SetTurretLevel(type,level)
    if M.turretInfo[type] then
        M.turretInfo[type].level = level
    else
        M.InitOneTurretData(type)
    end
end

function M.SetTurretStar(type,star)
    if M.turretInfo[type] then
        M.turretInfo[type].star = star
    else
        M.InitOneTurretData(type)
    end
end

function M.GetTurretLevel(type)
    if not M.turretInfo[type] then
        M.InitOneTurretData(type)
    end
    return M.turretInfo[type].level
end

function M.GetTurretStar(type)
    if not M.turretInfo[type] then
        M.InitOneTurretData(type)
    end
    return M.turretInfo[type].star
end

function M.InitOneTurretData(type)
    M.turretInfo[type] = {star = 1,level =1}
end

function M.GetHeroCapacity()
    return M.playerDta.heroCapacity
end


function M.SetHeroCapacity(n)
    M.playerDta.heroCapacity = n
end


------------------------------------------------ 养成数据 ↑↑↑
------------------------------------------------ 养成数据 ↑↑↑
------------------------------------------------ 养成数据 ↑↑↑