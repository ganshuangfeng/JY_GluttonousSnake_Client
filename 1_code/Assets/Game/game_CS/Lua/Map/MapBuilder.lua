
local basefunc = require "Game/Common/basefunc"
MapBuilder = {}

local M = MapBuilder

function M.InitMap(mapData)
    local mapInfo = {}

    MapLib.InitMapInfo(mapInfo,mapData)
    MapLib.InitGridInfo(mapInfo,mapData)
    dump(mapInfo,"<color=green>mapInfo????</color>")
    return mapInfo
end

function M.BuildMap(mapInfo,mapData)
    --生成格子
    MapLib.BuildGrid(mapInfo)
    --生成地图
    M.BuildBuilding(mapInfo, mapData)
    return mapInfo
end

-- 生成建筑
function M.BuildBuilding(mapInfo, mapData)
    mapInfo.building = {}
    M.BuildFix(mapInfo, mapData)
    M.BuildRandom(mapInfo, mapData)
end

-- 固定建筑生成
function M.BuildFix(mapInfo, mapData)

    local function getFixBuilding(buildings, fixBuilding)
        for k, v in pairs(buildings) do
            if v.fixPos and next(v.fixPos) then
                fixBuilding[#fixBuilding+1] = v
            end
        end
    end

    local fixBuilding = {}
    getFixBuilding(mapData.building,fixBuilding)

    if not fixBuilding or not next(fixBuilding) then
        return
    end

    dump(fixBuilding,"<color=white>强制位置的建筑？？？？？</color>")

    for index1, v in ipairs(fixBuilding) do
        for fixIndex, pos in ipairs(v.fixPos) do
            local building = basefunc.deepcopy(v)
            building.id = MapLib.GetBuildingId(mapInfo)
            mapInfo.building[building.id] = building
            building.pos = pos
            building.scale = building.fixScale[fixIndex]
            MapLib.BindBuildingGrid(mapInfo,building)
            M.SetAllAreaOnLayer(mapInfo,building.layer)
            M.SetOverlappingAreaOnLayer(mapInfo,building.layer)
        end
    end

    dump(mapInfo,"<color=yellow>固定建筑生成完成？？？？？</color>")
end

-- 随机建筑生成
function M.BuildRandom(mapInfo, mapData)

    local function getRandomBuilding(buildings, randomBuilding)
        for k, v in pairs(buildings) do
            if not v.fixPos or not next(v.fixPos) then
                randomBuilding[#randomBuilding+1] = v
            end
        end
    end

    local randomBuilding = {}
    getRandomBuilding(mapData.building,randomBuilding)

    if not randomBuilding or not next(randomBuilding) then
        return
    end

    dump(randomBuilding,"<color=yellow>随机建筑？？？</color>")

    local function createBuild(v)
        --先确定大小，再确定位置
        local building = basefunc.deepcopy(v)
        building.scale = M.GetBuildingScale(mapInfo,building)
        if not building.scale then
            return
        end
        building.id = MapLib.GetBuildingId(mapInfo)
        mapInfo.building[building.id] = building
        building.pos = M.GetBuildingPos(mapInfo,building)
        MapLib.BindBuildingGrid(mapInfo,building)
        M.SetAllAreaOnLayer(mapInfo,building.layer)
        M.SetOverlappingAreaOnLayer(mapInfo,building.layer)
        if M.CheckBuildEnd(mapInfo,building) then
            return
        else
            createBuild(v)
        end
    end

    -- createBuild(randomBuilding[1])

    for k, v in pairs(randomBuilding) do
        createBuild(v)
    end
end

-- 检查同一类建筑是否创建完成
function M.CheckBuildEnd(mapInfo,building)
    local allArea = M.GetAllAreaOnLayer(mapInfo,building.layer)
    local maxArea = building.area * mapInfo.mapArea - allArea
    dump({allArea,building.area, mapInfo.mapArea},"<color=white>面积比较？？？</color>")
    --没有必要生成建筑了
    if maxArea <= 0 then
        return true
    end
end

-- 计算建筑位置
function M.GetBuildingPos(mapInfo,building)
    -- 可以生成随机地图的位置
    local function getRandomPos()
        local posMap = {}
        for x = 1, mapInfo.gridCount.w do
            posMap[x] = posMap[x] or {}
            for y = 1, mapInfo.gridCount.h do
                posMap[x][y] = true
            end
        end

        --排除同层中的固定建筑的位置
        for bId, bObj in pairs(mapInfo.building) do
            if bObj.fixPos and next(bObj.fixPos) and bObj.layer == building.layer then
                for key, gId in pairs(bObj.grid) do
                    posMap[mapInfo.grid[gId].x][mapInfo.grid[gId].y] = false
                end
            end
        end

        --配置限定了位置
        if building.randomPos then
            local randomPosMap = {}
            for i, v in ipairs(building.randomPos) do
                local minX = M.XToGrid(v.minX,mapInfo)
                local maxX = M.XToGrid(v.maxX,mapInfo)
                local minY = M.XToGrid(v.minY,mapInfo)
                local maxY = M.XToGrid(v.maxY,mapInfo)
                for x = minX, maxX do
                    randomPosMap[x] = randomPosMap[x] or {}
                    for y = minY, maxY do
                        randomPosMap[x][y] = true
                    end
                end
            end
            for x, value in pairs(posMap) do
                for y, v in pairs(value) do
                    if not randomPosMap[x] or not randomPosMap[x][y] then
                        posMap[x][y] = false
                    end
                end
            end
        end

        local posList = {}
        for x, value in pairs(posMap) do
            for y, v in pairs(value) do
                if v then
                    posList[#posList+1] = {x = x, y = y}
                end
            end
        end
        return posList
    end

    -- 对当前位置进行打分，打分规则看整个占地面积和覆盖面积各自完成率和的权重平均值
    local function getPosScore()
        local weight = 2
        local areaWeight = 1.25
        local overWeight = weight - areaWeight

        local allArea =  M.GetAllAreaOnLayer(mapInfo,building.layer)
        local overArea = M.GetOverlappingAreaOnLayer(mapInfo,building.layer)

        local areaRate = allArea / mapInfo.mapArea
        local overRate = overArea / mapInfo.mapArea

        local scroe = (areaWeight * areaRate + overWeight * overRate) / weight
        return scroe
    end

    local randomPos = getRandomPos()
    dump(randomPos,"<color=green>可以随机放置的位置</color>")
    -- 计算一个最合适的pos
    local function getPos()
        --对每一个位置打分
        local scoreList = {}
        for i, pos in ipairs(randomPos) do
            building.pos = pos
            MapLib.BindBuildingGrid(mapInfo,building)
            M.SetAllAreaOnLayer(mapInfo,building.layer)
            M.SetOverlappingAreaOnLayer(mapInfo,building.layer)
            scoreList[i] = getPosScore()
            MapLib.TidBuildingGrid(mapInfo,building)
            M.SetAllAreaOnLayer(mapInfo,building.layer)
            M.SetOverlappingAreaOnLayer(mapInfo,building.layer)
        end

        --取分数最高的位置
        local score = -9999
        local maxIndex = 1
        for i, s in ipairs(scoreList) do
            if s > score then
                maxIndex = i
            end
        end
        dump(randomPos[maxIndex],"<color=yellow>分数最高的位置</color>")
        return randomPos[maxIndex]
    end

    return getPos()
end

--计算建筑可以生成的合适尺寸
function M.GetBuildingScale(mapInfo,building)
    local allArea =  M.GetAllAreaOnLayer(mapInfo,building.layer)
    allArea = allArea or 0
    local maxArea = building.area * mapInfo.mapArea - allArea
    --没有必要生成建筑了
    if maxArea <= 0 then
        return
    end
    local bArea = building.w * building.h
    local maxScale = maxArea / bArea
    local scale = 1
    if building.randomScale and next(building.randomScale) then
        scale = math.random(building.randomScale[1] * 10,building.randomScale[2] * 10) / 10
        if scale > maxScale then
            scale = maxScale
        end
    else
        scale = math.random(0,maxScale * 10) / 10
    end
    return scale
end

--设置某一层元素的重叠面积
function M.SetOverlappingAreaOnLayer(mapInfo,layer)
    local area = 0
    for gId, grid in pairs(mapInfo.grid) do
        local c = 0
        for index, bId in pairs(grid.building or {}) do
            if mapInfo.building[bId].layer == layer then
                c = c + 1
            end
        end
        if c > 1 then
            area = area + mapInfo.gridArea
        end
    end

    mapInfo.layerOverArea = mapInfo.layerOverArea or {}
    mapInfo.layerOverArea[layer] = area
    return area
end

--获取某一层元素的重叠面积
function M.GetOverlappingAreaOnLayer(mapInfo,layer)
    local area = mapInfo.layerOverArea[layer] or 0
    return area
end

--设置某一层元素占地图面积
function M.SetAllAreaOnLayer(mapInfo, layer)
    dump(layer,"<color=green>层？？？</color>")
    dump(mapInfo.grid,"<color=green>地图格子</color>")
    dump(mapInfo.building,"<color=green>地图建筑</color>")
    local area = 0
    for gId, grid in pairs(mapInfo.grid) do
        for index, bId in pairs(grid.building or {}) do
            if mapInfo.building[bId].layer == layer then
                area = area + mapInfo.gridArea
                break
            end
        end
    end

    mapInfo.layerArea = mapInfo.layerArea or {}
    mapInfo.layerArea[layer] = area
    return area
end

--获取某一层元素占地图面积
function M.GetAllAreaOnLayer(mapInfo, layer)
    local allArea =  mapInfo.layerArea[layer] or 0
    return allArea
end