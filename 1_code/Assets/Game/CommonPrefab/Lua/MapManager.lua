-- 创建时间:2021-06-22
local basefunc = require "Game/Common/basefunc"

MapManager = {}
local M = MapManager

local node
local camera3d
local mapCtrls = {}
local mapAStar = {}

local lister
local function AddLister()
    lister={}
	lister["MapBuildingDestroy"] = M.OnMapBuildingDestroy

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

function M.FrameUpdate(time_elapsed)
	for k, v in pairs(mapCtrls) do
		v:FrameUpdate(time_elapsed)
	end
end

function M.Init(_node, _camera3d)
	node = _node
	camera3d = _camera3d
    AddLister()
end

function M.Exit()
    RemoveLister()
	M.ExitAllRoom()
end

function M.StartNewLevel(data)
	M.ExitAllRoom()
	M.level = data.level
	--开始新房间
	M.StartNewRoom(data)
end
function M.GetRoomOffsetByNo(no)
	if mapCtrls[no] then
		return mapCtrls[no]:GetRoomCenterPos()
	else
		return {x=0, y=0}
	end
end
function M.StartNewRoom(data)
	local levelCfg = GameConfigCenter.GetLevelConfig(data.level)
	M.roomNo = data.roomNo
	local mapCtrl = mapCtrls[data.roomNo]
	if mapCtrl then
		mapCtrl:Exit()
	end
	local mapData = {
		name = data.name,
		node = MapManager.GetMapNode(),
		roomGo = levelCfg.roomGos[data.roomNo],
	}
	mapCtrl = MapCtrl.Init(mapData)
	mapCtrl:Start()
	mapCtrls[data.roomNo] = mapCtrl

	M.SetGameInfoCenterMap(data.roomNo)

	local offset = M.GetMapGameObject(data.roomNo).transform.position - Vector3.zero
	local gridSize = M.GetGridSize(data.roomNo)
	local roomSize = M.GetMapSize(data.roomNo)
	mapAStar[data.roomNo] = { aStar = MoveAlgorithm.New(offset,gridSize,roomSize) }

	mapAStar[data.roomNo].aStar:SetNotPassForScreenRound()
	

	M.SetGameInfoCenterNotPass(data.roomNo)

	mapAStar[data.roomNo].aStar:ShowDebug()
end

function M.Start(data)
	dump(data,"<color=yellow>当前关卡房间数据</color>")
	if M.level ~= data.level then
		--过关了开始新关卡
		M.StartNewLevel(data)
	else
		--开始新的房间
		M.StartNewRoom(data)
	end
end

function M.Finish()
	M.ExitAllRoom()
	M.level = nil
	M.roomNo = nil
end

--退出所有房间
function M.ExitAllRoom()
	for k, v in pairs(mapCtrls) do
		v:Exit()
	end
	mapCtrls = {}

	for k, v in pairs(mapAStar) do
		v.aStar:Exit()
	end
	mapAStar = {}
end

function M.GetAStar(roomNo)
	return mapAStar[roomNo]
end

function M.SetAStar(roomNo,data)
	mapAStar[roomNo] = data
end


function M.GetCurRoomAStar()
	return M.GetAStar( GameInfoCenter.stageData.roomNo )
end

local function CheckRoomNo(roomNo)
	roomNo = roomNo or M.roomNo
	return roomNo
end

function M.GetMapSize(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetMpaSize(roomNo)
end

function M.GetGridSize(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetGridSize()
end

function M.GetMapGameObject(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetMapGameObject()
end

function M.GetBuildingObjByName(name,roomNo)
	roomNo = CheckRoomNo(roomNo)
    return mapCtrls[roomNo]:GetBuildingObjByName(name)
end

function M.GetBuildingObjByGameObject(gameObject,roomNo)
	roomNo = CheckRoomNo(roomNo)
    return mapCtrls[roomNo]:GetBuildingObjByGameObject(gameObject)
end

function M.GetMapCamera()
	return camera3d
end

function M.GetMapNode()
	return node
end

function M.GetNotPassGrid(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetNotPassGrid()
end

function M.CheckCollision(collision,building,roomNo)
	roomNo = CheckRoomNo(roomNo)
	local layer = collision.gameObject.layer
	for k, v in pairs(building.destroyType) do
		if layer == LayerMask.NameToLayer(mapCtrls[roomNo]:GetLayerByCfgLayer(v)) then
			return true
		end
	end
end

function M.GetSkillByKey(key,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetSkillByKey(key)
end

function M.GridToPos(gPos,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GridToPos(gPos)
end

function M.PosToGrid(pos,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:PosToGrid(pos)
end

function M.BindingGameObjectMapInfo(gameObject,property,obj,roomNo)
	roomNo = CheckRoomNo(roomNo)
	mapCtrls[roomNo]:BindingGameObjectMapInfo(gameObject,property,obj)
	if not property.isPass then
		M.SetGameInfoCenterNotPass(roomNo)
	end
end

function M.BindingGameObjectChildsMapInfo(gameObject,roomNo)
	roomNo = CheckRoomNo(roomNo)
	mapCtrls[roomNo]:BindingGameObjectChildsMapInfo(gameObject)
	M.SetGameInfoCenterNotPass(roomNo)
end

function M.GetMapInfo(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetMapInfo(roomNo)
end

function M.SetGameInfoCenterMap(roomNo)
	roomNo = CheckRoomNo(roomNo)
	local mapInfo = M.GetMapInfo(roomNo)
    GameInfoCenter.map = {}
    --GameInfoCenter.map.sceen_size = { width = mapInfo.mapSize.w , height = mapInfo.mapSize.h }
    --GameInfoCenter.map.grid_size = mapInfo.gridSize.w

    GameInfoCenter.SetMapInfo( mapInfo.gridSize.w , { width = mapInfo.mapSize.w , height = mapInfo.mapSize.h } )

    --GameInfoCenter.map.mapSize = mapInfo.mapSize
    --GameInfoCenter.map.gridSize = mapInfo.gridSize
end

-- 刷新GameInfoCenter中的格子信息
function M.SetGameInfoCenterNotPass(roomNo)
	roomNo = CheckRoomNo(roomNo)
    local list = MapManager.GetNotPassGrid(roomNo)
    local data = {}
    for k,v in pairs(list) do
        --data[GetPosTagKeyStr( get_grid_pos( v ) )] = true

        data[#data + 1] = v
    end
    --GameInfoCenter.SetMapNotPassGridData(data)

    SetMapNotPassGridData( MapManager.GetAStar( roomNo ) , data)
end

function M.OnMapBuildingDestroy(data,roomNo)
	roomNo = CheckRoomNo(roomNo)
	mapCtrls[roomNo]:TidBuildingGrid(data)
	local mapInfo = M.GetMapInfo(roomNo)
	if mapInfo.building and mapInfo.building[data.id] and not mapInfo.building[data.id].isPass then
        M.SetGameInfoCenterNotPass(roomNo)
    end
end

function M.GetBuildingProperty(gameObject,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetBuildingProperty(gameObject)
end

function M.GetNotPassData(roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetNotPassData()
end

--[[function M.GetNotPassDataByPos(pos, len,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetNotPassData()
end--]]

--[[function M.GetNotPassDataByPos2(pos, len,roomNo)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetNotPassDataByPos2(pos, len)
end--]]


function M.GetWaveNumberAllItems(roomNo,wn,types)
	roomNo = CheckRoomNo(roomNo)
	return mapCtrls[roomNo]:GetWaveNumberAllItems(wn,types)
end