-- 创建时间:2019-03-07
--- 通过改方向，快速转向

local basefunc = require "Game/Common/basefunc"

SteeringForArriveByAngle = basefunc.class(Steering)
local C = SteeringForArriveByAngle

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 到达区半径
	self.arriveRadius = 1.5
	-- 减速区半径，到达半径外的附加半径
	self.decelerateRadius = 0.5

	--- 结束模式，有到达范围结束，有指向就结束
	self.over_module = "dis"  -- point 指向
 
	self.force = 8

	self.is_dis_condtion = false

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function C:setTargetPos(_pos , vehicle)
	if _pos then
		self.is_dis_condtion = false

		C.super.setTargetPos(self,_pos)

		vehicle:set_stop_steer_sin(false)
	else
		vehicle:set_stop_steer_sin(true)
		self.TargetPos = nil
	end

end

function C:ComputeForce(vehicle)
	if not self.TargetPos then
		
		return {x=0, y=0}
	end
	
	local ToTarget = Vec2DSub(self.TargetPos , vehicle:Pos())
	
	-- 计算到目标位置的距离
	local dist = Vec2DLength(ToTarget)
	if dist < self.arriveRadius then
		vehicle:FinishStep()
		vehicle:set_stop_steer_sin(true)
		self.TargetPos = nil
		return {x=0, y=0}
	end

	if not self.is_dis_condtion and dist < 2 * vehicle.m_dMaxSpeed * (180 / ( vehicle.m_dMaxTurnRate * math.pi ) ) then
		return {x=0, y=0}
	end
	self.is_dis_condtion = true

	local heading = vehicle:Heading()
	

	local angle = Vec2DAngle2( heading , ToTarget )
	
	--angle = angle
	--print("xxx-------------------arriveByangle:" , angle)
	if math.abs(angle) < 1 then
		--vehicle:FinishStep()
		vehicle:set_stop_steer_sin(true)
		-- self.TargetPos = nil
		return {x=0, y=0}
	end

	local side = vehicle:Side()
	local ret = Vec2DXMult( heading , ToTarget )
	---如果X乘 为正， 则是逆时针，因为side垂直方向是在heading的顺时针方向，所以得反向一下
	if ret > 0 then
		side = { x = -side.x , y = -side.y }
	end

	return Vec2DMultNum(side , self.force )

	
end