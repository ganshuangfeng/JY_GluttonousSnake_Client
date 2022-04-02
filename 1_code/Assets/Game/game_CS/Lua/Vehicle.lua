-- 创建时间:2019-03-06
require "Game.CommonPrefab.Lua.Vector2D"

require "Game.game_CS.Lua.Steering"
require "Game.game_CS.Lua.SteeringForArrive"
require "Game.game_CS.Lua.SteeringForFollowPath"
require "Game.game_CS.Lua.SteeringForOffsetPursuit"
require "Game.game_CS.Lua.SteeringForCircle"
require "Game.game_CS.Lua.SteeringForWave"
require "Game.game_CS.Lua.SteeringForWait"
require "Game.game_CS.Lua.SteeringForFlee"
require "Game.game_CS.Lua.SteeringForDisperse"
require "Game.game_CS.Lua.SteeringForSin"
require "Game.game_CS.Lua.SteeringForForward"
require "Game.game_CS.Lua.SteeringForBorder"
require "Game.game_CS.Lua.SteeringForArriveByAngle"
require "Game.game_CS.Lua.SteeringForHeadCrash"
require "Game.game_CS.Lua.SteeringForFleeBarrier"
require "Game.game_CS.Lua.SteeringForArriveAndCircle"
require "Game.game_CS.Lua.SteeringForArriveAndCircleGrid"

require "Game.game_CS.Lua.SteeringForFixedPoint"
require "Game.game_CS.Lua.SteeringForFixedPath"
require "Game.game_CS.Lua.SteeringForFixedDir"


-- require "Game.game_CS.Lua.VehicleSpeed"

local basefunc = require "Game/Common/basefunc"

Vehicle = basefunc.class()

Vehicle.SteerType = {
	Border = "border",     --- 边界限制力
	Forward = "forward",   --  前向力
	HeadCrash = "headCrash",
	Circle = "circle",
	FleeBarrier = "fleeBarrier",
	Arrive = "arrive",
	ArriveByAngle = "arriveByAngle" ,   --- 只通过改角度来到达
	Flee = "flee",
	Disperse = "disperse",
	Sin = "sin",
	Path = "path",
	ForCircle = "forCircle",
	FixedPointPath = "fixedPointPath", -- 定点移动
	FixedPoint = "fixedPoint", -- 定点移动
	FixedDir = "fixedDir", -- 定向移动
}

local function InitBaseGameEntity()
	local data = {}
	data.ID = 0
	data.Type = 0
	data.m_vPos = {x=0,y=0}
	data.radius = 0
	data.scale = 0
	data.m_bTag=0

	return data
end

local function InitMovingEntity()
	local data = {}
	-- 当前速率
	data.m_vVelocity = {x=1, y=0}
	-- 当前速度
	data.m_vSpeed = 0
	-- 一个标准化向量，指向实体的朝向
	data.m_vHeading = {x=1, y=0}
	-- 垂直于朝向向量的向量
	data.m_vSide = {x=0, y=-1}
	-- 实体的质量
	data.m_dMass = 1
	-- 实体的速度上限
	data.m_dUpperLimitSpeed = 9999999 -- 默认无限制
	-- 实体的最大速度
	data.m_dMaxSpeed = 3
	-- 实体的最小速度
	data.m_dMinSpeed = 1
	-- 实体产生的供以自己动力的最大力（想一下火箭和发动机推力）
	data.m_dMaxForce = 5
	-- 交通工具能旋转的最大速率（弧度每秒）
	data.m_dMaxTurnRate = 90

	return data
end

-- 智能体所在环境的所有数据和对象
local function InitGameWorld()
	local data = {}
	data.cxClient = 1
	data.cyClient = 1
	return data
end

local C = Vehicle
C.name = "Vehicle"
local Rad2Deg = 180 / math.pi

function C.Create(parm)
	return C.New(parm)
end

function C:Ctor(parm)
	self.pattern = "grid"
	local data = {}
	data = InitBaseGameEntity()
	for k,v in pairs(data) do
		self[k] = v
	end
	data = InitMovingEntity()
	for k,v in pairs(data) do
		self[k] = v
	end

	data = InitGameWorld()
	for k,v in pairs(data) do
		self[k] = v
	end

	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
	self.m_recMass = 1 / self.m_dMass

	self.m_vVelocity = Vec2DTruncateToLen(self.m_vHeading, self.m_dMaxSpeed)

	self.steerings = {}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Forward , steer=SteeringForForward.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Border , steer=SteeringForBorder.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.HeadCrash , steer=SteeringForHeadCrash.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.FleeBarrier , steer=SteeringForFleeBarrier.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Circle , steer=SteeringForArriveAndCircleGrid.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Arrive, steer=SteeringForArrive.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key= Vehicle.SteerType.ArriveByAngle , steer=SteeringForArriveByAngle.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Flee, steer=SteeringForFlee.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Disperse, steer=SteeringForDisperse.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Sin, steer=SteeringForSin.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.Path, steer=SteeringForFollowPath.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.ForCircle, steer=SteeringForCircle.New(), is_on_off = false}

	-- 永远关闭
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.FixedPointPath, steer=SteeringForFixedPath.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.FixedPoint, steer=SteeringForFixedPoint.New(), is_on_off = false}
	self.steerings[#self.steerings + 1] = {key=Vehicle.SteerType.FixedDir, steer=SteeringForFixedDir.New(), is_on_off = false}
	self.steerings_map = {}
	for k,v in ipairs(self.steerings) do
		self.steerings_map[v.key] = v
	end

	self:UpdateEntity(time_elapsed)

	self.velocity_scale = 1
	self.isStart = false
	self.isFinish = false
end
function C:Exit()
	self.isStart = false
end

function C:Start()
	self.isStart = true
end
function C:Stop()
	self.isStart = false
end

-- 设置速度通过方法实现，可限制住速度不会超过上限
function C:SetMaxSpeed(max_speed)
	if max_speed > self.m_dUpperLimitSpeed then
		self.m_dMaxSpeed = self.m_dUpperLimitSpeed
	else
		self.m_dMaxSpeed = max_speed
	end
	self.m_vVelocity = Vec2DTruncateToLen(self.m_vHeading, self.m_dMaxSpeed)
end

function C:SetMinSpeed(_speed)
	if _speed > self.m_dUpperLimitSpeed then
		self.m_dMinSpeed = self.m_dUpperLimitSpeed
	else
		self.m_dMinSpeed = _speed
	end
end

function C:FinishStep()
	--if self.FinishStepCall then
	--	self.FinishStepCall()
	--end	
	Event.Brocast("vehicle_finish_step", self.ID)
end

function C:AddSteerings(steerings)
	self.steerings[#self.steerings+1] = steerings
end
function C:UpdateEntity(time_elapsed)
    local r = Vec2DAngle(self.m_vHeading)
	-- 实体存在
	if self.game_entity then
		self.game_entity:UpdateTransform(self.m_vPos, r)
	end	
end

local FrameTime = 0.02
function C:FrameUpdate(time_elapsed)
	self.time_elapsed = time_elapsed

	if not self.isStart then
		return
	end

	if self.isFinish then
		return
	end

    FrameTime = 0.05 / self:Speed()

	local ct = self.time_elapsed
	local out = nil
	while (true) do
        if ct >= FrameTime then
            out = self:RunCalc(FrameTime)
            ct = ct - FrameTime
            if out then
                break
            end
        else
            out = self:RunCalc(ct)
            break
        end
    end
	self:UpdateEntity(time_elapsed)

	return out
end

function C:RunCalc(time_elapsed)
 	if self.pattern == "normal" then
 		return self:RunCalcNormal(time_elapsed)
 	elseif self.pattern == "grid" then
 		return self:RunCalcGrid(time_elapsed)
 	elseif self.pattern == "point" then
 		return self:RunCalcFixedPoint(time_elapsed)
 	elseif self.pattern == "dir" then
 		return self:RunCalcFixedDir(time_elapsed)
 	else
 		return true
 	end
end

function C:RunCalcGrid(time_elapsed)
	local grid = self.steerings_map[Vehicle.SteerType.FixedPointPath]
	if grid and grid.is_on_off then
		local _b = grid.steer:FrameUpdate(self, time_elapsed)
		if not _b then
			return true
		else
			return false
		end		
	else
		return true
	end
end

function C:RunCalcFixedPoint(time_elapsed)
	local grid = self.steerings_map[Vehicle.SteerType.FixedPoint]
	if grid then
		local _b = grid.steer:FrameUpdate(self, time_elapsed)
		if not _b then
			return true
		else
			return false
		end		
	else
		return true
	end
end

function C:RunCalcFixedDir(time_elapsed)
	local grid = self.steerings_map[Vehicle.SteerType.FixedDir]
	if grid then
		local _b = grid.steer:FrameUpdate(self, time_elapsed)
		if not _b then
			return true
		else
			return false
		end		
	else
		return true
	end
end

function C:RunCalcNormal(time_elapsed)
	-- 计算操控行为的合力
	local SteeringForce = {x=0, y=0}
	if self.steerings and next(self.steerings) then
		for k,v in ipairs(self.steerings) do
			if v.is_on_off then
				if v.steer.ComputeForce then
					local force = v.steer:ComputeForce(self, time_elapsed)
					if force then
						SteeringForce = Vec2DAdd(SteeringForce, force)
					end
				end
			end
		end

		if SteeringForce then
			-- 增加的速度
			local add_v = Vec2DMultNum(SteeringForce , self.m_recMass * time_elapsed)
			local v1 = Vec2DAdd( self.m_vVelocity , add_v )

			local max_change_angle = self.m_dMaxTurnRate * time_elapsed
			local change_angle = Vec2DAngle2(self.m_vVelocity, v1)
			if max_change_angle < change_angle then
				v1 = Vec2DAdd( self.m_vVelocity , Vec2DMultNum(add_v, max_change_angle / change_angle ) )
				--if self.is_sin_path_on_off then
				--	self.steerings_map[Vehicle.SteerType.Sin].is_on_off = false
				--end
			else
				--if self.is_sin_path_on_off then
				--	self.steerings_map[Vehicle.SteerType.Sin].is_on_off = true
				--end

			end

			-- 更新速度
			self.m_vVelocity = v1
			-- 确保交通工具不超过最大速度
			self.m_vVelocity = Vec2DTruncateRange(self.m_vVelocity, self.m_dMinSpeed, self.m_dMaxSpeed) -- Vec2DTruncate(self.m_vVelocity, self.m_dMaxSpeed)

			local vec = Vec2DMultNum(self.m_vVelocity, self.velocity_scale)
			--更新位置
			self.m_vPos = Vec2DAdd(self.m_vPos, Vec2DMultNum(vec , time_elapsed))
			-- 如果速度远大于一个很小值，那么更新朝向
			if (Vec2DLength(self.m_vVelocity) > 0.1) then
				self.m_vHeading = Vec2DNormalize(self.m_vVelocity)
				self.m_vSide = Vec2DPerp(self.m_vHeading)
			end

			-- self:UpdateEntity(time_elapsed)
		end
	end
	return self.isFinish
end

-- 设置移动模式 -- 普通：normal  格子：grid
function C:SetVehiclePattern(_pattern)
	if self.pattern ~= _pattern then
		self.pattern = _pattern
	end
end

-- 播放逃离
function C:PlayFlee(_velocity_scale)
	if not _velocity_scale then
		_velocity_scale = 15
	end
	self.velocity_scale = _velocity_scale
end

-- 设置实体
function C:SetInstantiate(entity)
	self.game_entity = entity
	if self.game_entity then
	    local r = Vec2DAngle(self.m_vHeading)
		self.game_entity:UpdateTransform(self.m_vPos, r)
	end
end
function C:SetTargetPos(key, TargetPos)
	if self.steerings_map
		and next(self.steerings_map)
		and self.steerings_map[key]
		and self.steerings_map[key].steer
		and self.steerings_map[key].steer.setTargetPos then
		
		self.steerings_map[key].steer:setTargetPos( TargetPos , self)

	end
end
function C:SetRadar(key, radar)
	if self.steerings_map
		and next(self.steerings_map)
		and self.steerings_map[key] then
		
		self.steerings_map[key].steer.radar = radar

	end
end

function C:SetSteeringValue(st_key, key, value)
	if self.steerings_map
		and next(self.steerings_map)
		and self.steerings_map[st_key] then
		
		self.steerings_map[st_key].steer[key] = value

	end
end


function C:SetOnOff(key, _is_on_off)
	if self.steerings_map
		and next(self.steerings_map)
		and self.steerings_map[key] then
		
		self.steerings_map[key].is_on_off = _is_on_off
		if key == Vehicle.SteerType.Flee then
			-- dump(key,"<color=red>FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
			-- dump(self.steerings_map[key])
		end
		if key == Vehicle.SteerType.Sin then
			self.is_sin_path_on_off = _is_on_off
		end
	end
end

function C:CloseAllSteerings()
	for k,v in pairs(self.steerings_map) do
		v.is_on_off = false
	end
end
function C:GetAllOnOff()
	local map = {}
	for k,v in pairs(self.steerings_map) do
		map[k] = v.is_on_off
	end
	return map
end

---add by wss
function C:set_stop_steer_sin(_bool)
	--- 必须是sin曲线开了，才能 设置 sin移动的暂时开关
	if self.is_sin_path_on_off then
		self.steerings_map[Vehicle.SteerType.Sin].is_on_off = _bool
		if not _bool then
			self.steerings_map[Vehicle.SteerType.Sin].steer:reset_time()
		end
	end
end

function C:Heading()
	return self.m_vHeading
end

function C:Side()
	return self.m_vSide
end
function C:SetPos(pos)
	self.m_vPos = pos
end



function C:Pos()
	return self.m_vPos
end
function C:Speed()
	return Vec2DLength(self.m_vVelocity)
end

function C:SetSpeedValueByMaxSpeedPercent( percent )
	self.velocity_scale = percent / 100 
	--print("xxx-------SetSpeedValueByMaxSpeedPercent:" , percent , self.m_vVelocity.x , self.m_vVelocity.y )
end

function C:MaxSpeed()
	return self.m_dMaxSpeed
end
function C:MaxForce()
	return self.m_dMaxForce
end
function C:Velocity()
	return self.m_vVelocity
end

function C:SetRot(rot)
	self.m_vHeading = {x = MathExtend.Cos(rot), y = MathExtend.Sin(rot), z = 0}
	self.m_vSide = Vec2DPerp(self.m_vHeading)
end


