-- 创建时间:2021-07-01
ExtRequire("Game.CommonPrefab.Lua.SteeringForArrive")

local basefunc = require "Game/Common/basefunc"

LocomotionController = basefunc.class()
local C = LocomotionController

function C.Create(transform)
	return C.New(transform)
end

function C:Ctor(transform)
	self.transform = transform
	self.currentForce = Vector3.zero
	self.acceleration = Vector3.zero
	self.maxSpeed = 5
	self.rotationSpeed = 10

	self.steerings = {}
	self.mass = 1
	self.maxForce = 10
	self:AddSteering()
end

function C:AddSteering()
	self.steerings[#self.steerings + 1] = SteeringForArrive.Create()
end

function C:SetTargetPos(pos)
	for i,v in ipairs(self.steerings) do
    	v.target = pos
    end
end
function C:FinishStep()
	Event.Brocast("vehicle_finish_step", self.ID)
end


function C:FrameUpdate(time_elapsed)
	self:ComputeAcceleration()
	self:Movement(time_elapsed)
	self:LookAt(time_elapsed)
end

--移动
function C:Movement(time_elapsed)

    --当前操控力+加速度*deltaTime
    self.currentForce = self.currentForce + self.acceleration * time_elapsed
    --限制当前操控力大小
    self.currentForce = Vector3.ClampMagnitude(self.currentForce, self.maxSpeed)
    --位移
    self.transform.position = self.transform.position + self.currentForce * time_elapsed

end

--转向
function C:LookAt(time_elapsed)

    if (self.currentForce == Vector3.zero) then
    	return 
    end

    local targetRotation = Quaternion.LookRotation(self.currentForce )

    self.transform.rotation = targetRotation--Quaternion.Lerp(self.transform.rotation, targetRotation, self.rotationSpeed * time_elapsed)
end


function C:ComputeAcceleration()

    local finalForce = Vector3.zero
    for i,v in ipairs(self.steerings) do
    	if (v.enabled) then --判断组件是否启用,启用才计算
            finalForce = finalForce + v:ComputeForce(self)
		end
    end
    --限制模长
    finalForce = Vector3.ClampMagnitude(finalForce, self.maxForce);

    --合力为零时重置当前合力为零
    if (finalForce == Vector3.zero) then
    	self.currentForce = Vector3.zero
	end


    self.acceleration = finalForce / self.mass
end