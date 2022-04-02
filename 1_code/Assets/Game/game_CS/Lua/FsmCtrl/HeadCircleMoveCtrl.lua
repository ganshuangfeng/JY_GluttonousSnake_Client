local basefunc = require "Game/Common/basefunc"

HeadCircleMoveCtrl = basefunc.class(BaseCtrl)

local M = HeadCircleMoveCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    --- 围绕的旋转点
    self.circleTargetObj = data.circleTargetObj

    --- 半径大小
    self.radius = data.radius

    self.test_time = 5

    self.circlePosSetDelay = 0.1
    self.circlePosSetCount = self.circlePosSetDelay

end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready

	self:MakeLister()
end

function M:OnStateActive()
	self.object.vehicle:SetVehiclePattern("grid")

	self.object.vehicle:SetOnOff( Vehicle.SteerType.Circle, true )
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.Circle , "radius" , self.radius )
	self.object.vehicle:SetTargetPos( Vehicle.SteerType.Circle , self.circleTargetObj.transform.position )

	self:AddListener()
end

function M:OnStateDisable()
	self.object.vehicle:SetVehiclePattern("grid")
	self.object.vehicle:SetOnOff( Vehicle.SteerType.Circle, false )
	self.object.vehicle:SetTargetPos( Vehicle.SteerType.Circle , nil )

	self:RemoveListener()
end

---------------------------------- 消息监听相关 ↓ -------------------------
function M:MakeLister()
	self.lister = {}
	self.lister["boss_die"] = basefunc.handler(self, self.on_boss_die)
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

function M:on_boss_die( bossObj )
	self:Stop()
end


---------------------------------- 消息监听相关 ↑ -------------------------

--- 状态开始时调用
function M:Begin()
	print("<color=red>xxxx---------------circleMoveCtrl</color>")
	self.ctrlState = StateType.running

	self:OnStateActive()
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self:OnStateDisable()
end

--强制结束
function M:Stop()
	self.ctrlState = StateType.finish
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause

	self:OnStateDisable()
	return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

	self:OnStateActive()
end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	
	self.circlePosSetCount = self.circlePosSetCount + dt
	if self.circlePosSetCount > self.circlePosSetDelay then
		self.circlePosSetCount = 0

		self.object.vehicle:SetTargetPos( Vehicle.SteerType.Circle , self.circleTargetObj.transform.position )

	end

	--[[self.test_time = self.test_time - dt
	if self.test_time <= 0 then
		self.ctrlState = StateType.finish
	end--]]

end



