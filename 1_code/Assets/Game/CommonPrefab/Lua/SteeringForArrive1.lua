-- 创建时间:2021-07-01

local basefunc = require "Game/Common/basefunc"

SteeringForArrive1 = basefunc.class()
local C = SteeringForArrive1

function C.Create()
	return C.New()
end

function C:Ctor()

	self.target = Vector3.zero
	self.enabled = true
	--到达区半径
	self.arriveRadius = 1
	--减速区半径
	self.decelerateRadius = 2
	self.weight = 1

end


function C:ComputeForce(vehicle)

    local tempDistance = Vector3.Distance(self.target, vehicle.transform.position) - self.arriveRadius
    --到达目标
    if (tempDistance <= 0) then
		vehicle:FinishStep()
        return Vector3.zero
	end

    --当前速度
    local realSpeed = vehicle.currentForce.magnitude

    --在减速区
    if (tempDistance < self.decelerateRadius) then
    
        realSpeed = tempDistance / self.decelerateRadius * realSpeed
        realSpeed = realSpeed < 1 and 1 or realSpeed
    --减速区外
    else
        realSpeed = 1--speed
    end

    local expectForce = (self.target - vehicle.transform.position).normalized * realSpeed
    return (expectForce - vehicle.currentForce) * self.weight

end

