-- 创建时间:2021-08-17
local basefunc = require "Game/Common/basefunc"

HeadForceOffsetCtrl = basefunc.class(BaseCtrl)

local M = HeadForceOffsetCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
	self.targetPos = data.pos or Vector3.zero
	self.speed = data.speed or 10

    self.lister = {}
end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready

	self:MakeLister()
end

--- 状态开始时调用
function M:Begin()

	self.ctrlState = StateType.running

	self:AddListener()

	self.old_vehicle_data = {}
	self.old_vehicle_data.m_dMaxSpeed = self.object.vehicle.m_dMaxSpeed
	self.old_vehicle_data.m_dMinSpeed = self.object.vehicle.m_dMinSpeed
	self.old_vehicle_data.m_dMaxForce = self.object.vehicle.m_dMaxForce

	self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.targetPos )
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )
	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", function() self:OnFinishStep() end )

	self.object.vehicle:SetMaxSpeed(self.speed)
	self.object.vehicle:SetMinSpeed(self.speed)
	self.object.vehicle.m_dMaxForce = self.speed
end

---------------------------------- 消息监听相关 ↓ -------------------------
function M:MakeLister()
	self.lister = {}
end

function M:AddListener()
	for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self.object.vehicle:SetMaxSpeed(self.old_vehicle_data.m_dMaxSpeed)
	self.object.vehicle:SetMinSpeed(self.old_vehicle_data.m_dMinSpeed)
	self.object.vehicle.m_dMaxForce = self.old_vehicle_data.m_dMaxForce

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", nil )

	self:RemoveListener()
end

--强制结束
function M:Stop()
	self:Finish()
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )
	self:RemoveListener()

	return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )
	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", function() self:OnFinishStep() end )
	self:AddListener()

	self:OnFinishStep()
end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
end

function M:OnFinishStep()
	self:Finish()
end




