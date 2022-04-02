-- 创建时间:2021-09-22
-- FindTargetFunc 管理器

local basefunc = require "Game/Common/basefunc"
FindTargetFunc = {}
local M = FindTargetFunc

-------------------------------------------for common--------------------------------------------
--寻找一个最近的箱子(返回实例)
function M.FindOneNearBox(range,selfPos)
    local min = 999999999
    local data = GameInfoCenter.GetAllGoods()
    local the_box = nil
    --箱子属于类型1
    for k , v in pairs(data[1]) do
        if v.data.building.key == "box" and IsEquals(v.gameObject) then
            local dis_squ = tls.pGetDistanceSqu(selfPos,v.gameObject.transform.position)
            if dis_squ <= range * range and dis_squ <= min then
                the_box = v
                min = dis_squ
            end
        end
    end
    return the_box
end
--寻找所有符合范围内的箱子(返回实例)
function M.FindNearBox(range,selfPos)
    local min = 999999999
    local data = GameInfoCenter.GetAllGoods()
    local box_list = {}
    --箱子属于类型1
    for k , v in pairs(data[1]) do
        if v and v.data.building.key == "box" and IsEquals(v.gameObject) then
            local dis_squ = tls.pGetDistanceSqu(selfPos,v.gameObject.transform.position)
            if dis_squ <= range * range  then
                box_list[#box_list + 1] = v
            end
        end
    end
    return box_list
end
--寻找所有符合范围内的箱子(返回ID)
function M.FindNearBoxWithID(range,selfPos)
    local box_list = M.FindNearBox(range,selfPos)
    local id_list = {}
    for i = 1,#box_list do
        id_list[#id_list + 1] = box_list[i].id
    end
    return id_list
end
--寻找一个最近的箱子(返回ID)
function M.FindOneNearBoxWithID(range,selfPos)
    local the_box = M.FindOneNearBox(range,selfPos)
    if the_box then
        return the_box.id
    end
end

-------------------------------------------for hero--------------------------------------------
--寻找符合范围内最近的一个怪物，没找到就找箱子(返回ID)
function M.FindOneNearMonsterOrBoxWithID(range,selfPos)
    return M.FindOneNearMonsterWithID(range,selfPos) or M.FindOneNearBoxWithID(range,selfPos)
end

--寻找符合范围内所有箱子和怪物
function M.FindAllMonsterAndBoxWithID(range,selfPos)
    local id_1 = M.FindNearMonsterWithID(range,selfPos)
    local id_2 = M.FindNearBoxWithID(range,selfPos)
    for i = 1,#id_2 do
        id_1[#id_1 + 1] = id_2[i] 
    end
    return id_1
end

--寻找一个最近的怪物（返回ID）
function M.FindOneNearMonsterWithID(range,selfPos)
    local the_monster = M.FindOneNearMonster(range,selfPos)
    if the_monster then
        return the_monster.id
    end 
end
--寻找一个最近的怪物(返回实例)
function M.FindOneNearMonster(range,selfPos)
    local min = 999999999
    local data = GameInfoCenter.GetAllMonsters()
    local the_monster = nil
    for k , v in pairs(data) do
        if v and v.isLive and v.state ~= "die" then
            local dis_squ = tls.pGetDistanceSqu(selfPos,v.gameObject.transform.position)
            if dis_squ <= range * range and dis_squ <= min then
                the_monster = v
                min = dis_squ
            end
        end
    end
    return the_monster
end
--寻找最近的怪物(返回实例)
function M.FindNearMonster(range,selfPos)
    local min = 999999999
    local data = GameInfoCenter.GetAllMonsters()
    local monster_list = {}
    for k , v in pairs(data) do
        if v and v.isLive then
            local dis_squ = tls.pGetDistanceSqu(selfPos,v.gameObject.transform.position)
            if dis_squ <= range * range then
                monster_list[#monster_list + 1] = v
            end
        end
    end
    return monster_list
end
--寻找最近的怪物(返回实例)
function M.FindNearMonsterWithID(range,selfPos)
    local monster_list = M.FindNearMonster(range,selfPos)
    local id_list = {}
    for i = 1,#monster_list do
        id_list[#id_list + 1] = monster_list[i].id
    end
    return id_list
end

-------------------------------------------for monster--------------------------------------------
