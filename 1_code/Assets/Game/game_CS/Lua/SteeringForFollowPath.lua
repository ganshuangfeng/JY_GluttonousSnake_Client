-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

SteeringForFollowPath = basefunc.class(Steering)

function SteeringForFollowPath:Ctor(parm)
	SteeringForFollowPath.super.Ctor(self,parm)

	-- 当前巡逻点
	self.currentWPIndex = 1
	-- 是否结束巡逻
	self.isPatrolComplete = false
	-- 停止巡逻距离
	self.patrolArrivalDistance = 3
	-- 巡逻方式1一次 2循环 3往返
	self.patroMode = 1
	-- 巡逻点
	self.WayPoints = {}
	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForFollowPath:ComputeForce(vehicle, time_elapsed)
	local ToTarget = Vec2DSub(self.WayPoints[self.currentWPIndex] , vehicle:Pos())

	local len = Vec2DLength(ToTarget)
    print("<color=red>SteeringForFollowPath </color>"..self.currentWPIndex.."  " .. len)

    if len < self.patrolArrivalDistance then
        if self.currentWPIndex == #self.WayPoints then
            if self.patroMode == 1 then
                    self.isPatrolComplete = true
                    vehicle:FinishStep()
                    return {x=0,y=0}
            elseif self.patroMode == 3 then
            	local data = {}
            	for i=#self.WayPoints, 1, -1 do
            		data[#data + 1] = self.WayPoints[i]
            	end
            	self.WayPoints = data
            end
        end
        self.currentWPIndex = self.currentWPIndex + 1
        if self.currentWPIndex > #self.WayPoints then
        	self.currentWPIndex = 1
        end
    end
    self.expectForce = Vec2DMultNum(Vec2DNormalize(ToTarget) , vehicle:MaxSpeed())
    return Vec2DSub(self.expectForce , vehicle:Velocity())

end

