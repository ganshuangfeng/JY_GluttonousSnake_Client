local basefunc = require "Game/Common/basefunc"
MapBinding = {}

local M = MapBinding

function M.InitMap(mapData)
    local mapInfo = {}

    MapLib.InitMapInfo(mapInfo,mapData)
    MapLib.InitGridInfo(mapInfo)

    dump(mapInfo,"<color=green>地图信息</color>")
    return mapInfo
end

function M.SetBuildingSize(building)
    local sr = building.gameObject:GetComponent("SpriteRenderer")
    -- dump(sr.bounds,"<color=white>图片大小</color>")
    local localRotation = building.gameObject.transform.localRotation
    if sr then
        local center = sr.bounds.center
        local extents = sr.bounds.extents
       
        building.pos = {x = center.x, y = center.y}
        if localRotation.z == 90 or localRotation.z == -90 then
            building.size = { w = extents.y * 2, h = extents.x * 2}
        else
            building.size = { w = extents.x * 2, h = extents.y * 2}
        end
    else
        local position = building.gameObject.transform.position
        building.pos = { x = position.x, y = position.y}
        --概念类的拖拽预制体没有事先的大小概念，比如怪物生成器。
        building.size = building.size or {w = 1,h = 1}
        building.size = {w = building.size.w, h = building.size.h}
    end

    local coll = building.gameObject:GetComponent("Collider2D")
    -- dump(coll.bounds,"<color=yellow>碰撞器大小</color>")
    if IsEquals(coll) then
        local center = coll.bounds.center
        local extents = coll.bounds.extents
        building.collPos = {x = center.x, y = center.y}
        if localRotation.z == 90 or localRotation.z == -90 then
            building.collSize = { w = extents.y * 2, h = extents.x * 2}
        else
            building.collSize = { w = extents.x * 2, h = extents.y * 2}
        end
    end
end

function M.BindingGameObject(gameObject,property,mapInfo)
    if not property then return end
    if property.keyType ~= "building" then
        --不是建筑不需要绑定地图
        return
    end
    local building = basefunc.deepcopy(property)
    building.gameObject = gameObject;
    building.id = MapLib.GetBuildingId(mapInfo)
    building.scale = 1
    M.SetBuildingSize(building)
    mapInfo.building[building.id] = building
    MapLib.BindBuildingGrid(mapInfo,building)
    return building
end

--绑定预制体和地图信息, 会先生成格子
function M.BindingPrefabMapInfo(prefab,mapInfo)
    --生成格子
    MapLib.BuildGrid(mapInfo)
    mapInfo.building = {}

    M.BindingGameObjectChildsMapInfo(prefab.gameObject,mapInfo)
end

local function buiningGO(go,mapInfo)
    UnityEngine.Profiling.Profiler.BeginSample("MapView BindingGameObjectChildsMapInfo 1 " .. go.name)
    local property = GetDataInfo(go)
    UnityEngine.Profiling.Profiler.EndSample();

    if not property then
        return
    end
    UnityEngine.Profiling.Profiler.BeginSample("MapView BindingGameObjectChildsMapInfo 2 " .. go.name)
    M.BindingGameObject(go,property,mapInfo)
    UnityEngine.Profiling.Profiler.EndSample();
end

--绑定GameObject的子节点
function M.BindingGameObjectChildsMapInfo(gameObject,mapInfo)
    mapInfo.building = mapInfo.building or {}

    buiningGO(gameObject,mapInfo)

    local dataInfos = gameObject:GetComponentsInChildren(typeof(DataInfo),true)

    for i = 0, dataInfos.Length - 1 do
        buiningGO(dataInfos[i].gameObject,mapInfo)
    end
end

--绑定GameObject, property:建筑的属性
function M.BindingGameObjectMapInfo(gameObject, property, mapInfo)
    mapInfo.building =  mapInfo.building or {}
    return M.BindingGameObject(gameObject,property,mapInfo)
end