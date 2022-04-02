-- 创建时间:2021-07-22

local basefunc = require "Game/Common/basefunc"

SteeringForFixedPoint = basefunc.class(Steering)
local C = SteeringForFixedPoint

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 是否结束巡逻
	self.isPatrolComplete = true
	-- 停止巡逻距离
	self.patrolArrivalDistance = 0.1

	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function C:setTargetPos(pos)
	self.TargetPos = pos
	self.isPatrolComplete = false
end

function C:FrameUpdate(vehicle, time_elapsed)
	if self.isPatrolComplete then return false end

	local old_pos = vehicle.m_vPos
	local ToTarget = Vec2DSub(self.TargetPos, old_pos)

	local len = Vec2DLength(ToTarget)
	if len < self.patrolArrivalDistance then
        self.isPatrolComplete = true
		vehicle.m_vPos = self.TargetPos
        -- vehicle:FinishStep()
        return false
	end

	-- 更新速度
	vehicle.m_vVelocity = ToTarget
	-- 确保交通工具不超过最大速度
	vehicle.m_vVelocity = Vec2DTruncateToLen(vehicle.m_vVelocity, vehicle.m_dMaxSpeed)

	local vec = Vec2DMultNum(vehicle.m_vVelocity, vehicle.velocity_scale)
	--更新位置
	vehicle.m_vPos = Vec2DAdd(vehicle.m_vPos, Vec2DMultNum(vec , time_elapsed))

	local len1 = Vec2DLength( Vec2DSub(vehicle.m_vPos , old_pos) )
	if len < len1 or len < self.patrolArrivalDistance then
        self.isPatrolComplete = true
		vehicle.m_vPos = self.TargetPos
	end

	vehicle.m_vHeading = Vec2DNormalize(vehicle.m_vVelocity)
	vehicle.m_vSide = Vec2DPerp(vehicle.m_vHeading)

    return true
end
