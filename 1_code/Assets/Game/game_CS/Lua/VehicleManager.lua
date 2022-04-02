-- 创建时间:2019-03-07
require "Game.game_CS.Lua.Vehicle"

VehicleManager = {}

local vehicle_map = {}

local NextID = 0
function VehicleManager.GetNextID()
    NextID = NextID + 1
    return NextID
end

function VehicleManager.FrameUpdate(time_elapsed)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if not v.is_stop then
				v.vehicle:FrameUpdate(time_elapsed)
			end
		end
	end
end
function VehicleManager.Create(parm, _obj)
	parm.m_vHeading = parm.m_vHeading or {x=1,y=0}
	parm.m_vSide = parm.m_vSide or {x=0,y=1}
	parm.ID = VehicleManager.GetNextID()
	local vehicle = Vehicle.Create(parm)
	vehicle:SetInstantiate(_obj)
	vehicle_map[parm.ID] = {vehicle=vehicle, is_stop = false}
	return vehicle
end

---- 蛇头的力模式
function VehicleManager.CreateHero(parm, _obj)
	parm.m_vHeading = parm.m_vHeading or {x=1,y=0}
	parm.m_vSide = parm.m_vSide or {x=0,y=1}
	parm.ID = VehicleManager.GetNextID()
	local vehicle = Vehicle.Create(parm)
	vehicle:SetInstantiate(_obj)
	vehicle:SetOnOff(Vehicle.SteerType.Sin, false)
	vehicle:SetOnOff(Vehicle.SteerType.Disperse, false)
	vehicle:SetOnOff(Vehicle.SteerType.Flee, false)
	vehicle:SetOnOff(Vehicle.SteerType.Arrive, false)
	vehicle:SetOnOff(Vehicle.SteerType.HeadCrash, false)
	vehicle:SetOnOff(Vehicle.SteerType.FleeBarrier, false)

	vehicle:SetSteeringValue(Vehicle.SteerType.Border , "screen_size", GetSceenSize( MapManager.GetCurRoomAStar() ) ) -- MapManager.GetMapSize() )

	vehicle:SetVehiclePattern("grid")
	vehicle:SetSteeringValue(Vehicle.SteerType.FixedPointPath , "obj_name", "hero" )

	vehicle_map[parm.ID] = {vehicle=vehicle, is_stop = false}
	return vehicle
end

function VehicleManager.CreateMonster(parm, _obj)
	parm.m_vHeading = parm.m_vHeading or {x=1,y=0}
	parm.m_vSide = parm.m_vSide or {x=0,y=1}
	parm.ID = VehicleManager.GetNextID()
	local vehicle = Vehicle.Create(parm)
	vehicle:SetInstantiate(_obj)
	vehicle:SetOnOff(Vehicle.SteerType.Sin, false)
	vehicle:SetOnOff(Vehicle.SteerType.Forward, false)
	vehicle:SetOnOff(Vehicle.SteerType.ArriveByAngle, false)
	vehicle:SetOnOff(Vehicle.SteerType.Circle, false)
	--vehicle:SetOnOff(Vehicle.SteerType.Flee, false)

	vehicle:SetRadar(Vehicle.SteerType.Disperse, GameInfoCenter.ScanTarget)
	vehicle:SetSteeringValue(Vehicle.SteerType.Border , "screen_size", GetSceenSize( MapManager.GetCurRoomAStar() ) ) -- MapManager.GetMapSize() )

	--vehicle:SetVehiclePattern("grid")
	vehicle:SetSteeringValue(Vehicle.SteerType.FixedPointPath , "obj_name", "monster" )

	vehicle_map[parm.ID] = {vehicle=vehicle, is_stop = false}
	return vehicle
end


function VehicleManager.AddLeaderChild(leader, vehicle)
	if not leader.child_map then
		leader.child_map = {}
	end
	leader.child_map[vehicle.ID] = {vehicle=vehicle, is_stop = false}
end

function VehicleManager.SetInstantiate(id, obj)
	local vehicle = VehicleManager.GetVehicleByID(id)
	if vehicle then
		vehicle.vehicle:SetInstantiate(obj)
	end
end

function VehicleManager.Exit()
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			v.vehicle:Exit()
		end
	end
	vehicle_map = {}
end

function VehicleManager.GetSteerings(parm)	
	local steerings
	if parm.type == 1 then
		steerings = SteeringForFollowPath.New(parm)
	elseif parm.type == 2 then
		steerings = SteeringForCircle.New(parm)
	elseif parm.type == 3 then
		steerings = SteeringForWait.New(parm)
	elseif parm.type == 4 then
		steerings = SteeringForArrive.New(parm)
	else
		steerings = SteeringForOffsetPursuit.New(parm)
	end

	return steerings
end

function VehicleManager.AddSteerings(vehicle, parm)
	local list = {}
	for k,v in ipairs(parm) do
		v.m_pVehicle = vehicle
		list[#list + 1] = VehicleManager.GetSteerings(v)
	end
	vehicle:AddSteerings(list)
end

function VehicleManager.GetVehicleByID(id)
	if vehicle_map[id] then
		return vehicle_map[id]
	end
end

function VehicleManager.RemoveVehicle(id)
	if id then
		local fish = FishManager.GetFishByID(id)
		if not fish or not fish.data.status or fish.data.status <= 1 then
			vehicle_map[id] = nil
		end
	end
end

function VehicleManager.RemoveAll()
	vehicle_map = {}
end

local flee_list = {}
local flee_leader_list = {}
function VehicleManager.RemoveAllFlee()
	for k,v in ipairs(flee_list) do
		vehicle_map[v] = nil
	end
	flee_list = {}
end
function VehicleManager.PlayFlee(clear_level)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if v.vehicle.game_entity and clear_level >= v.vehicle.game_entity.data.clear_level then
				v.vehicle:PlayFlee()
				flee_list[#flee_list + 1] = k
			end
		end
	end
end

-- 暂停移动
function VehicleManager.Stop(id)
	if id < 0 then -- 特殊鱼，场景创建做表现用的
		return
	end
	if vehicle_map[id] then
		vehicle_map[id].is_stop = true
	end
end
-- 恢复移动
function VehicleManager.Recover(id, pos)
	if vehicle_map[id] then
		vehicle_map[id].is_stop = false
		local _pos = {x=pos.x, y=pos.y}
		vehicle_map[id].vehicle:SetPos(_pos)
	end
end
-- 播放加速游动
function VehicleManager.PlaySpeedUp(id, velocity_scale)
	if vehicle_map[id] then
		vehicle_map[id].vehicle:PlayFlee(velocity_scale)
	end
end

function VehicleManager.SetIceState(b)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if k > 0 then
				v.is_stop = b
			end
		end
	end
end
