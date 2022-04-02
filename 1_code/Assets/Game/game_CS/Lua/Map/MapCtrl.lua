local basefunc = require "Game/Common/basefunc"

MapCtrl = basefunc.class()
local M = MapCtrl

function M.Init(data)
    return M.New(data)
end

function M:Ctor(data)
    -- dump(data,"<color=white>data</color>")
    data.mapCtrl = self
    self.mapModel = MapModel.Init(data)
    self.mapView = MapView.Init(data)
end

function M:Start()
    self.mapModel:Start()
    self.mapView:Start()

    self:DebugShowGrid()
    self:DebugShowGridNotPass()
end

function M:Exit()
    self.mapModel:Exit()
    self.mapView:Exit()
end

function M:FrameUpdate(time_elapsed)
    self.mapView:FrameUpdate(time_elapsed)
end

function M:GetMpaSize()
    if not self.mapModel.mapInfo then
        return {w = 32,h = 48,width = 32,height = 48}
    end
    return {w = self.mapModel.mapInfo.mapSize.w,h = self.mapModel.mapInfo.mapSize.h,width = self.mapModel.mapInfo.mapSize.w,height = self.mapModel.mapInfo.mapSize.h}
end

function M:GetGridSize()
    return self.mapModel.mapInfo.gridSize.w
end

function M:GetRoomCenterPos()
    return self.mapModel.mapInfo.centerPos
end

function M:GetMapNode()
    return self.mapView:GetMapNode()
end

function M:GetNotPassGrid()
    if not self.mapModel.mapInfo.grid or not next(self.mapModel.mapInfo.grid) then
        return {}
    end

    local offestPos = { x = -math.fmod( GameInfoCenter.map.sceen_size.width / 2 , GameInfoCenter.map.grid_size ) ,
                        y = -math.fmod( GameInfoCenter.map.sceen_size.height / 2 , GameInfoCenter.map.grid_size ) }

    local grids = {}
    for i, v in ipairs(self.mapModel.mapInfo.grid) do
        if not v.isPass then
            local pos = self:GridToPos(v.pos)
            pos.x = pos.x + offestPos.x 
            pos.y = pos.y + offestPos.y

            pos.posX = v.pos.x 
            pos.posY = v.pos.y 
            grids[#grids+1] = pos
        end
    end
    dump(grids,"<color=yellow>当前不能通过的格子</color>")
    return grids
end

function M:DebugShowGrid()
    local isShow = false
    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
        isShow = false
    end
    if not isShow then
        local csgp = CSGamePanel.Instance()
        if csgp then
            csgp.grid_btn.gameObject:SetActive(false)
        end
        return
    end
    if not self.mapModel.mapInfo.grid or not next(self.mapModel.mapInfo.grid) then
        return
    end
    
    local parent = MapManager.GetMapNode()
    local go = parent.transform:Find("GridNode")
    if not IsEquals(go) then
        go = GameObject.New("GridNode")
        go.transform:SetParent(parent)
    end
    parent = go.transform
    DestroyChildren(parent)

    for i, v in ipairs(self.mapModel.mapInfo.grid) do
        local pos = self:GridToPos(v.pos)
        local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
        obj.transform.position = pos
        obj.gameObject.name = "GridBack_" .. v.pos.x .. "_" .. v.pos.y
    end

    local csgp = CSGamePanel.Instance()
    if csgp then
        csgp.grid_btn.onClick:AddListener(function ()
            local parent = MapManager.GetMapNode()
            local go = parent.transform:Find("GridNode")
            go.gameObject:SetActive(not go.gameObject.activeSelf)

            go = parent.transform:Find("GridNotPassNode")
            go.gameObject:SetActive(not go.gameObject.activeSelf)
        end)
    end
end

function M:DebugShowGridNotPass()
    local isShow = false
    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
        isShow = false
    end
    if not isShow then
        return
    end
    if not self.mapModel.mapInfo.grid or not next(self.mapModel.mapInfo.grid) then
        return
    end

    local parent = MapManager.GetMapNode()
    local go = parent.transform:Find("GridNotPassNode")
    if not IsEquals(go) then
        go = GameObject.New("GridNotPassNode")
        go.transform:SetParent(parent)
    end
    parent = go.transform
    DestroyChildren(parent)
    local grids = {}
    for i, v in ipairs(self.mapModel.mapInfo.grid) do
        local pos = self:GridToPos(v.pos)
        if not v.isPass then
            local obj = GameObject.Instantiate(GetPrefab("GridNotPass"),parent.transform)
            obj.transform.position = pos
            obj.gameObject.name = "GridNotPass" .. v.pos.x .. "_" .. v.pos.y
            grids[#grids+1] = pos
        end
    end

    dump(grids,"<color=green>Debug当前不能通过的格子</color>")
end

function M:GetSkillByKey(key)
	return self.mapModel.Key2Skill[key]
end

function M:GetLayerByCfgLayer(layer)
	return self.mapModel.LayerCfg2Set[layer]
end

function M:GetMapGameObject()
    return self.mapView:GetMapGameObject()
end

function M:GetBuildingObjByName(name)
    return self.mapView:GetBuildingObjByName(name)
end

function M:GetBuildingObjByGameObject(gameObject)
    return self.mapView:GetBuildingObjByGameObject(gameObject)
end

function M:GridToPos(gPos)
	return MapLib.GridToPos(gPos,self.mapModel.mapInfo)
end

function M:PosToGrid(pos)
    return MapLib.PosToGrid(pos,self.mapModel.mapInfo)
end

function M:BindingGameObjectMapInfo(gameObject,property,obj)
    if not self.mapView then
        return
    end
    return self.mapView:BindingGameObjectMapInfo(gameObject,property,obj)
end

function M:BindingGameObjectChildsMapInfo(gameObject)
    self.mapModel:BindingGameObjectChildsMapInfo(gameObject)
end

function M:TidBuildingGrid(data)
    if not self.mapView then
        return
    end
    return self.mapView:TidBuildingGrid(data)
end

function M:GetMapInfo()
    return self.mapModel.mapInfo
end

function M:GetMapModel()
    return self.mapModel
end

function M:GetMapView()
    return self.mapView
end

function M:GetNotPassData()
    return self.mapView:GetNotPassData()
end

--[[function M:GetNotPassDataByPos(pos, len)
    return self.mapView:GetNotPassDataByPos(pos, len)
end--]]

--[[function M:GetNotPassDataByPos2(pos, len)
    return self.mapView:GetNotPassDataByPos2(pos, len)
end--]]

function M:GetWaveNumberAllItems(wn,types)
    return self.mapView:GetWaveNumberAllItems(wn,types)
end