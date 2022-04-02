-- 创建时间:2019-03-07
-- 运动方式：绕圆圈

local basefunc = require "Game/Common/basefunc"

SteeringForCircle = basefunc.class(Steering)

function SteeringForCircle:Ctor(parm)
	SteeringForCircle.super.Ctor(self,parm)

	-- 到达区半径
	self.radius = 200
	-- 旋转方向
	self.isPerp = true
	-- 旋转总角度
	self.angle = 360
	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

	self.runA = 0
end

function SteeringForCircle:ComputeForce(vehicle , time_elapsed )
	local a = 180 * Vec2DLength(vehicle:Velocity()) * time_elapsed / (math.pi * self.radius)
	self.runA = self.runA + a
	if self.runA >= self.angle then
		vehicle:FinishStep()
	end

	if self.isPerp then
		a = -a
	end
	local ToTarget = Vec2DRotate(vehicle:Velocity(), a)
	return Vec2DMultNum(Vec2DSub(ToTarget , vehicle:Velocity()), 1/ time_elapsed ) 
end
