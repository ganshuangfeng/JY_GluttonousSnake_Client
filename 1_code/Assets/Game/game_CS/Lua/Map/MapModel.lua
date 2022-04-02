
local basefunc = require "Game/Common/basefunc"
MapModel = basefunc.class()
local M = MapModel

--配置的层和设置的层的映射表
M.LayerCfg2Set = {
	hero_head = "hero_head",
	hero = "Hero",
	hero_bullet = "hero_zd",
	monster = "Monster",
	monster_bullet = "monster_zd"
}

--建筑key和技能映射表
M.Key2Skill = {
    
}

function M.Init(data)
    return MapModel.New(data)
end

function M:Ctor(data)
    self.mapCtrl = data.mapCtrl
    self.mapView = self.mapCtrl:GetMapView()
end

function M:Exit()
    self.mapInfo = nil
end

function M:CreateMapData(gameObject)
    local dataInfo = GetDataInfo(gameObject)
    -- dump(dataInfo,"<color=yellow>地图DataInfo</color>")
    local mapData = {
        map = {
            mapSize = dataInfo.size,
            centerPos = gameObject.transform.position
        }
    }
    -- dump(mapData,"<color=yellow>地图mapData</color>")
    return mapData
end

function M:Start()
    self.mapInfo = MapBinding.InitMap(M:CreateMapData(self.mapView.gameObject))
    -- dump(self.mapInfo,"<color=yellow>地图mapInfo</color>")
end

function M:GetMapSize()
    return {w=self.mapInfo.mapSize.w, h=self.mapInfo.mapSize.h, width=self.mapInfo.mapSize.w, height=self.mapInfo.mapSize.h}
end

--绑定GameObject, property为nil是将按照gameObject 自动获取property
function M:BindingGameObjectMapInfo(gameObject,property)
    if not property then
        property = GetDataInfo(gameObject)
    end
    if not property then
        return
    end
    local obj = MapBinding.BindingGameObjectMapInfo(gameObject,property,self.mapInfo)
    
    --刷新显示
    if not property.isPass then
        self.mapCtrl:DebugShowGridNotPass()
    end
    return obj
end

--绑定GameObject的子节点, property:建筑的属性
function M:BindingGameObjectChildsMapInfo(gameObject)
    MapBinding.BindingGameObjectChildsMapInfo(gameObject,self.mapInfo)
    self.mapCtrl:DebugShowGridNotPass()
end

--绑定预制体和地图信息
function M:BindingPrefabMapInfo(prefab)
    MapBinding.BindingPrefabMapInfo(prefab,self.mapInfo)
    self.mapCtrl:DebugShowGridNotPass()
end

function M:TidBuildingGrid(bId)
    MapLib.TidBuildingGrid(self.mapInfo,self.mapInfo.building[bId])
    if not self.mapInfo.building[bId].isPass then
        self.mapCtrl:DebugShowGridNotPass()
    end
end

function M:GetMapInfo()
    return self.mapInfo
end