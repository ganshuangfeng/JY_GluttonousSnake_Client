-- 创建时间:2021-06-30

ComponseManager = {}

local M = ComponseManager
M.Max = 15

local lister = {}
local function AddLister()
    lister={}
    lister["model_turret_change_msg"] = M.on_model_turret_change_msg
    lister["new_hero_created"] = M.on_new_hero_created
    lister["StagFinish"] = M.on_StagFinish
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function M.Init()
    M.Exit()
    M.Hero_Wait = {}
    AddLister() 
    M.Timer = Timer.New(function()
        --M.HeroComponse()
    end,0.6,-1)
    M.Timer:Start()
end

function M.Exit()
    if M.Timer then
        M.Timer:Stop()
    end
    RemoveLister()
end

function M.GetData()
    return M.Hero_Wait
end

function M.GetCanSpawnPos()
    for i = 1,M.Max do
        if M.Hero_Wait[i] == nil then 
            return i
        end
    end
end

--获取当前的数量
function M.GetNum()
    local int = 0
    for k,v in pairs(M.Hero_Wait) do
        int = int + 1
    end
    return int
end
--获取正在使用的最后的位置
function M.GetLastUsePos()
    local max = 0
    for k,v in pairs(M.Hero_Wait) do
        if k.data.location > max then
            max = k
        end
    end
    return max
end

function M.RemoveAll()
    for k,v in pairs(M.Hero_Wait) do
        v:Exit()
        M.Hero_Wait[k] = nil
    end
    M.Hero_Wait = {}
    Event.Brocast("componse_remove_all_hero")
end

function M.Create_Wait(data)
    do return end
    local hero_data = GameConfigCenter.GetHeroConfigByType(data.type)
    if hero_data then
        for k ,v in pairs(hero_data) do
            data[k] = v
        end
        local hero = HeroWait.Create(ComponsePanel_New1.Pos[data.location],data)
        M.Hero_Wait[hero.data.heroId] = hero
        return hero
    end
end

function M.on_model_turret_change_msg()
    --添加一个英雄
    M.RefreshHero()
    M.RefreshHeroHead()
end

function M.GetHeroByLocation(location)
    for k ,v in pairs(M.Hero_Wait) do
        if v.data.location == location then
            return v
        end
    end
end

function M.GetMaxLocation()
    local max = 0
    for k, v in pairs(M.Hero_Wait) do
        if v.data.location > max then
            max = v.data.location
        end
    end
    return max
end

function M.GetHeroByHeroId(id)
    return M.Hero_Wait[id] 
end

function M.RefreshHero()
    --检查更新或者新建
    for k,v in pairs(GameInfoCenter.turret_list) do
        local id1 = v.heroId
        local hero = ComponseManager.GetHeroByHeroId(id1)
        if hero then
            hero:SetLocation(v.location)
            hero:SetLevel(v.level)         
        else
            local hero_data = GameInfoCenter.GetHeroDataByID(id1)
            M.Create_Wait(hero_data)
        end
    end
    --检查删除
    for k,v in pairs(M.Hero_Wait) do
        local id2 = v.data.heroId
        local hero_data = GameInfoCenter.GetHeroDataByID(id2)
        if hero_data then
        else
            M.Remove(id2)
        end
    end
    Event.Brocast("refresh_componse")
end 


function M.RefreshHeroHead()
    --检查更新或者新建
    for k,v in pairs(GameInfoCenter.turret_list) do
        local id1 = v.heroId
        local hero = GameInfoCenter.GetHeroByHeroId(id1)
        if hero then
            local location = v.location
            hero.data.locationOld = nil
            if location ~= hero.data.location then
                hero.data.locationOld = hero.data.location
                hero.data.location = location
                Event.Brocast("HeroChange",{hero = hero})
            else
                hero.data.location = location
            end
            local level = v.level
            if level ~= hero.cur_level then
                hero.cur_level = level
                Event.Brocast("HeroChange",{hero = hero,change_level = level})
            else
                hero.cur_level = level
            end
        else
            local hero_data = GameInfoCenter.GetHeroDataByID(id1)
            hero = CreateFactory.CreateHero(hero_data)
            Event.Brocast("HeroCreate",{hero = hero})
        end
    end

    --检查删除
    for k,v in pairs(GameInfoCenter.GetAllHero()) do
        local id2 = v.data.heroId
        local hero_data = GameInfoCenter.GetHeroDataByID(id2)
        if not hero_data then
            GameInfoCenter.RemoveHeroById(id2)
            Event.Brocast("HeroDestroy", v.data)
        end
    end

    GameInfoCenter.RefreshHeroList()
    Event.Brocast("HeroRefresh")
end

function M.Remove(id)
    if  M.Hero_Wait[id] then
        M.Hero_Wait[id]:Exit()
        M.Hero_Wait[id] = nil
    end
end

function M.on_new_hero_created(data)

end

--每次进入新的关卡会清零
--每次合成消耗同类型2个的1星炮台

function M.HeroComponse()
    local heroList = GameInfoCenter.GetAllHero()
    local curr_check_hero = nil
    local componse_func = function(hero1,hero2,hero3)
        if hero1.data.star < 4 then
            hero1:RefreshAll({ level = hero1.data.level,star =  hero1.data.star + 1, type = hero1.data.type})
            -- Event.Brocast("HeroDestroy", hero2.data)
            -- Event.Brocast("HeroDestroy", hero3.data)
            --ClientAndSystemManager.SendRequest("cs_sale_turret",{id = hero2.data.heroId})
            --ClientAndSystemManager.SendRequest("cs_sale_turret",{id = hero3.data.heroId})
        end
    end
    for k ,v in pairs(heroList) do
        curr_check_hero = v
        local num = 0
        local hero_need = {}
        for k1,v2 in pairs(heroList) do
            if curr_check_hero.id ~= v2.id then
                if curr_check_hero.data.type == v2.data.type and v2.data.star == 1 then
                    num = num + 1
                    hero_need[#hero_need + 1] = v2
                end
            end
            if num == 2 then
                componse_func(curr_check_hero,hero_need[1],hero_need[2])
                break
            end
        end
    end
end

--关卡结束后，清空星级
function M.on_StagFinish(data)
    local heroList = GameInfoCenter.GetAllHero()
    for k ,v in pairs(heroList) do
        v:RefreshAll({ level = v.data.level,star = 1, type = v.data.type})
    end
end