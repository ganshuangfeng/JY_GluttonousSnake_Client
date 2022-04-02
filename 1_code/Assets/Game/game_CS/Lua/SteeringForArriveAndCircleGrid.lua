-- 创建时间:2019-03-07
--- 移动到 并且 旋转 , 按格子移动的方案

local basefunc = require "Game/Common/basefunc"

SteeringForArriveAndCircleGrid = basefunc.class(Steering)
local C = SteeringForArriveAndCircleGrid

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	self.vehicle = nil
	-- 到达区半径
	self.radius = parm and parm.radius or 5

	-- 当前要到的 方形点(四个点) 的哪一个
	self.posIndex = 0

	self.isInit = false

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

end

--- 设置 按格子移动的 路径
function C:setGridMovePath(vehicle)
	-- print("<color=red>xxxxxx------------setGridMovePath</color>")
	if not self.TargetPos then
		return
	end

	self.posIndex = self.posIndex + 1
	if self.posIndex > 4 then
		self.posIndex = 1
	end

	local tarPos = self.TargetPos

	local offsetX = (self.posIndex == 1 or self.posIndex == 4) and -self.radius or self.radius
	local offsetY = (self.posIndex == 1 or self.posIndex == 2) and self.radius or -self.radius

	local endPos = Vector3.New( tarPos.x + offsetX , tarPos.y + offsetY , tarPos.z )

	local path = {}
	local hero_pos = {} -- { pos_list = GameInfoCenter.GetHeroPosList() }

	dump({ path , {}, "4_dir" , self.vehicle.m_vPos , Vec2DAngle(self.vehicle.m_vHeading) , endPos , hero_pos } , "xxx-------GetGridMovePath 11111:" )

	local is_true , path = GetGridMovePath( vehicle.game_entity , "4_dir" , self.vehicle.m_vPos , Vec2DAngle(self.vehicle.m_vHeading) , endPos , hero_pos , true )
	--dump( path , "xx----------------dealHolePos:" )
	if is_true then
		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", path )
		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", false )
		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )
	end

end

function C:setTargetPos(_pos , vehicle)
	-- print("<color=red>xxxx---------------gridCircle setPos</color>")
	if _pos then
		C.super.setTargetPos(self,_pos)
		self.vehicle = vehicle
		--vehicle:set_stop_steer_sin(false)
		--self.posIndex = 0

		if not self.isInit then
			self.isInit = true
			self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", function() self:OnFinishStep(vehicle) end )
			self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", {} )
			self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", false )
			self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )

			self:setGridMovePath( vehicle )
		end
	else
		--vehicle:set_stop_steer_sin(true)
		self.TargetPos = nil

		self.isInit = false

		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", nil )

		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", {} )
		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", false )
		self.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )
	end

end

function C:OnFinishStep(vehicle)
	self:setGridMovePath(vehicle)
end


function C:ComputeForce(vehicle)
	
end