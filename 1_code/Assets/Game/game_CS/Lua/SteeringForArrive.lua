-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

SteeringForArrive = basefunc.class(Steering)

function SteeringForArrive:Ctor(parm)
	SteeringForArrive.super.Ctor(self,parm)

	-- 到达区半径
	self.arriveRadius = 1.5
	-- 减速区半径，到达半径外的附加半径
	self.decelerateRadius = 0.5

	--- 结束模式，有到达范围结束，有指向就结束
	self.over_module = "dis"  -- point 指向

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForArrive:ComputeForce(vehicle)
	if not self.TargetPos then
		vehicle:set_stop_steer_sin(true)
		return {x=0, y=0}
	end
	vehicle:set_stop_steer_sin(false)

	local ToTarget = Vec2DSub(self.TargetPos , vehicle:Pos())
	-- 计算到目标位置的距离
	local dist = Vec2DLength(ToTarget)
	local tempDistance = dist - self.arriveRadius

	if self.over_module == "dis" and tempDistance <= 0 then
		vehicle:FinishStep()

		self.TargetPos = nil
		return {x=0, y=0}
	elseif self.over_module == "point" then
		--- 如果指向角度和 目标减启动位置的角度大小差不多
		if Vec2DAngle2( vehicle:Heading() , ToTarget ) < 3 then
			vehicle:FinishStep()

			self.TargetPos = nil
			return {x=0, y=0}
		end
	end


	local realSpeed = Vec2DLength(vehicle:Velocity())
    -- 在减速区
    if (tempDistance < self.decelerateRadius) then

        realSpeed = realSpeed * tempDistance / self.decelerateRadius
        if realSpeed < 1 then
        	realSpeed = 1
        end
    else--减速区外
		--确保这个速度不超过最大值
		realSpeed = math.min(dist, vehicle:MaxSpeed())
    end
	-- 这边的处理和Seek一样，除了不需要标准化ToTarget向量
	--因为我们已经费力地计算了它的长度：dist
	realSpeed = Vec2DMultNum(ToTarget , realSpeed / dist)

	return Vec2DSub(realSpeed , vehicle:Velocity())
end