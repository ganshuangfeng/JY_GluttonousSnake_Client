-- 创建时间:2021-07-02  ,一直向前的力

local basefunc = require "Game/Common/basefunc"

SteeringForForward = basefunc.class(Steering)
local C = SteeringForForward

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 力
	self.force = 3.5
	
	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function C:ComputeForce(vehicle, time_elapsed)

	
	return Vec2DMultNum(vehicle.m_vHeading, self.force)
end
