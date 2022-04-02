-- 创建时间:2021-07-02

local basefunc = require "Game/Common/basefunc"

SteeringForSin = basefunc.class(Steering)

function SteeringForSin:Ctor(parm)
	SteeringForSin.super.Ctor(self,parm)

	-- 时间
	self.time = 1
	
	self.runTime = self.time * 0.5
	-- 力
	self.force_value = 16
	self.force = self.force_value
	
	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForSin:reset_time()
	self.runTime = self.time * 0.5
	self.force = self.force_value
end

function SteeringForSin:ComputeForce(vehicle, time_elapsed)
	self.runTime = self.runTime + time_elapsed
	if self.runTime >= self.time then
		self.runTime = 0
		self.force = -1 * self.force
	end
	
	--return Vec2DAdd(Vec2DMultNum(vehicle.m_vSide, self.force), vehicle.m_vHeading)

	return Vec2DMultNum(vehicle.m_vSide, self.force)
end
