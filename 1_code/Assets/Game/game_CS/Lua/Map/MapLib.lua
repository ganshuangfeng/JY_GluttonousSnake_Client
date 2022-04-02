
local basefunc = require "Game/Common/basefunc"
MapLib = {}

local M = MapLib

--格子坐标转换为像素坐标
function M.GridToPos(gPos,mapInfo)
    local pos = {
        x = gPos.x * mapInfo.gridSize.w - mapInfo.mapSize.w / 2 - mapInfo.gridSize.w / 2 + mapInfo.centerPos.x,
        y = gPos.y * mapInfo.gridSize.h - mapInfo.mapSize.h / 2 - mapInfo.gridSize.h / 2 + mapInfo.centerPos.y,
    }
    return pos
end

--像素坐标转换为格子坐标
function M.PosToGrid(pos,mapInfo)
    local gPos = {
        x = (pos.x + mapInfo.gridSize.w / 2 + mapInfo.mapSize.w / 2 - mapInfo.centerPos.x) / mapInfo.gridSize.w,
        y = (pos.y + mapInfo.mapSize.h / 2 + mapInfo.gridSize.h / 2 - mapInfo.centerPos.y) / mapInfo.gridSize.h,
    }
    return gPos
end

function M.GetPosInGrid(pos,mapInfo,type,ratio,isDebug)
    if isDebug then
        dump(pos,"<color=green>pos</color>")
    end
    local px = pos.x + mapInfo.mapSize.w / 2
    local py = pos.y + mapInfo.mapSize.h / 2

    if isDebug then
        dump({px,py},"<color=green>px py</color>")
    end

    local gx = px / mapInfo.gridSize.w
    local gy = py / mapInfo.gridSize.h

    if isDebug then
        dump({gx,gy},"<color=green>gx gy</color>")
    end

    if type == 1 then
        local a,b = math.modf(gx)
        b = 1 - b >= ratio and 1 or 2
        gx = a + b

        if isDebug then
            dump({gx,a,b},"<color=green>gx a b</color>")
        end

        a,b = math.modf(gy)
        b = 1 - b >= ratio and 1 or 2
        gy = a + b

        if isDebug then
            dump({gy,a,b},"<color=green>gy a b</color>")
        end
    elseif type == 2 then
        local a,b = math.modf(gx)
        b = b >=  ratio and 1 or 0
        gx = a + b

        if isDebug then
            dump({gx,a,b},"<color=green>gx a b</color>")
        end

        a,b = math.modf(gy)
        b = b >=  ratio and 1 or 0
        gy = a + b

        if isDebug then
            dump({gy,a,b},"<color=green>gy a b</color>")
        end
    end

    if isDebug then
        dump({x = gx,y = gy},"<color=green>gPos</color>")
    end
    return {x = gx,y = gy}
end

function M.CheckPass(building)
    if not building.isPass then
        --不可通过建筑所占的格子不能寻路
        return false
    end

    if not building.isPass and not building.isDestroy then
        --不可通过建筑且不能销毁建筑所占的格子不能寻路
        return false
    end

    return true
end

-- 绑定建筑和格子
function M.BindBuildingGrid(mapInfo,building)
    --建筑记录自己所占格子
    building.grid = {}
    local xMin = building.pos.x - mapInfo.centerPos.x - building.size.w / 2
    local xMax = building.pos.x - mapInfo.centerPos.x + building.size.w / 2
    local yMin = building.pos.y - mapInfo.centerPos.y - building.size.h / 2
    local yMax = building.pos.y - mapInfo.centerPos.y + building.size.h / 2

    --根据碰撞器决定占用格子
    if building.collPos then
        xMin = building.collPos.x - mapInfo.centerPos.x - building.collSize.w / 2
        xMax = building.collPos.x - mapInfo.centerPos.x + building.collSize.w / 2
        yMin = building.collPos.y - mapInfo.centerPos.y - building.collSize.h / 2
        yMax = building.collPos.y - mapInfo.centerPos.y + building.collSize.h / 2
    end

    local isDebug
    -- if building.gameObject.name == "spike_1" then
    --     isDebug = true
    --     dump({xMin,yMin,xMax,yMax},"<color=green>建筑像素范围</color>")
    -- end

    local gridMin = M.GetPosInGrid({x = xMin,y = yMin},mapInfo,1,0.333,isDebug)
    local gridMax = M.GetPosInGrid({x = xMax,y = yMax},mapInfo,2,0.333,isDebug)

    if isDebug then
        dump({gridMin,gridMax},"<color=green>建筑占的格子</color>")
    end

    local binding = function (x,y)
        local pos = {x = x,y = y}
        local grid = GridBuilder.GetGridByPos(mapInfo.grid,pos)
        if isDebug then
            dump({pos,grid},"<color=green>建筑占的格子11111</color>")
        end
        if grid then
            building.grid[grid.id] = grid.id
        end
    end

    if gridMin.x == gridMax.x and gridMin.y == gridMax.y then
        local x = gridMin.x
        local y = gridMin.y
        binding(x,y)
    elseif gridMin.x == gridMax.x and gridMin.y < gridMax.y then
        local x = gridMin.x
        for y = gridMin.y, gridMax.y do
            binding(x,y)
        end
    elseif gridMin.x < gridMax.x and gridMin.y == gridMax.y then
        local y = gridMin.y
        for x = gridMin.x, gridMax.x do
            binding(x,y)
        end
    elseif gridMin.x < gridMax.x and gridMin.y < gridMax.y then
        for x = gridMin.x, gridMax.x do
            for y = gridMin.y, gridMax.y do
                binding(x,y)
            end
        end
    else
        dump(building,"<color=red>error???????????????????</color>")
    end

    --格子记录建筑
    for k, gId in pairs(building.grid) do
        GridBuilder.AddBuilding(GridBuilder.GetGridById(mapInfo.grid,gId),building.id)
    end

    --设置格子能否通过
    if not M.CheckPass(building) then
        for k, gId in pairs(building.grid) do
            GridBuilder.SetPass(GridBuilder.GetGridById(mapInfo.grid,gId),false)
        end
    end
end

-- 解绑建筑和格子
function M.TidBuildingGrid(mapInfo,building)
    for k, gId in pairs(building.grid) do
        GridBuilder.RemoveBuilding(GridBuilder.GetGridById(mapInfo.grid,gId),building.id)
    end

    if not M.CheckPass(building) then
        for k, gId in pairs(building.grid) do
            M.SetGridIsPassByBuilding(mapInfo,gId)
        end
    end

    building.grid = nil
end

-- 根据格子上的建筑确定格子是否能够通过
function M.SetGridIsPassByBuilding(mapInfo,gId)
    local grid = GridBuilder.GetGridById(mapInfo.grid,gId)
    local isPass = true
    if not grid.building or not next(grid.building) then
        GridBuilder.SetPass(grid,isPass)
        return
    end
    for key, bId in pairs(grid.building) do
        if not M.CheckPass(mapInfo.building[bId]) then
            isPass = false
            break
        end
    end
    GridBuilder.SetPass(grid,isPass)
end

function M.InitMapInfo(mapInfo,mapData)
    if mapData then
        mapInfo.mapSize = {
            w = mapData.map.mapSize.w,
            h = mapData.map.mapSize.h,
        }
        mapInfo.centerPos = mapData.map.centerPos
    else
        mapInfo.mapSize = {
            w = 32,
            h = 48,
        }
    end
    mapInfo.mapArea = mapInfo.mapSize.w * mapInfo.mapSize.h
end

function M.InitGridInfo(mapInfo, mapData)
    --格子尺寸，可以根据地图大小动态调整
    mapInfo.gridSize = {
        w = 1.6,
        h = 1.6,
    }
    mapInfo.gridArea = mapInfo.gridSize.w * mapInfo.gridSize.h

    mapInfo.gridCount = {
        w = mapInfo.mapSize.w / mapInfo.gridSize.w,
        h = mapInfo.mapSize.h / mapInfo.gridSize.h,
    }
end

--生成格子
function M.BuildGrid(mapInfo)
    mapInfo.grid = GridBuilder.BuildGrid(mapInfo.gridCount.w,mapInfo.gridCount.h,mapInfo.gridSize.w,mapInfo.gridSize.h)
    -- dump(mapInfo.grid,"<color=green>生成的格子</color>")
end

--获取一个建筑id
function M.GetBuildingId(mapInfo)
    mapInfo.buildingId = mapInfo.buildingId or 0
    mapInfo.buildingId = mapInfo.buildingId + 1
    return mapInfo.buildingId
end