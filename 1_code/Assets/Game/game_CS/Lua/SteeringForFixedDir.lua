-- 创建时间:2021-07-22

local basefunc = require "Game/Common/basefunc"

SteeringForFixedDir = basefunc.class(Steering)
local C = SteeringForFixedDir

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	self.addV = 10
	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function C:FrameUpdate(vehicle, time_elapsed)

	local old_pos = vehicle.m_vPos

	vehicle.m_vVelocity = Vec2DMultNum(vehicle.m_vHeading, Vec2DLength(vehicle.m_vVelocity) + self.addV * time_elapsed)
	-- 确保交通工具不超过最大速度
	vehicle.m_vVelocity = Vec2DTruncateToLen(vehicle.m_vVelocity, vehicle.m_dMaxSpeed)

	local vec = Vec2DMultNum(vehicle.m_vVelocity, vehicle.velocity_scale)
	--更新位置
	vehicle.m_vPos = Vec2DAdd(vehicle.m_vPos, Vec2DMultNum(vec , time_elapsed))

	-- vehicle.m_vHeading = Vec2DNormalize(vehicle.m_vVelocity)
	-- vehicle.m_vSide = Vec2DPerp(vehicle.m_vHeading)

    return true
end
