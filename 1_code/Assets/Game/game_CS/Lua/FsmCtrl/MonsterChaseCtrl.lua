local basefunc = require "Game/Common/basefunc"

MonsterChaseCtrl = basefunc.class(BaseCtrl)

local M = MonsterChaseCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    self.range = self.object.attack_range
    self.range2 = self.range * self.range
    self.chase_cd = 0
end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready
	self:MakeLister()
end

--- 状态开始时调用
function M:Begin()
	self.ctrlState = StateType.running
	self.object.enableMove = true

	---- begin 开始的时候，得把 固定移动模式打开
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )
	self:AddListener()
end

function M:MakeLister()
	self.lister = {}
	self.lister["vehicle_finish_step"] = basefunc.handler(self, self.on_vehicle_finish_step)
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
	self.object.enableMove = false
	self.ctrlState = StateType.finish
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )

	
	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", {} )
	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", true )
	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )
	

	self:RemoveListener()
end

--强制结束
function M:Stop()
	self:Finish()
end
-- 暂停时调用
function M:Pause()
	self.object.enableMove = false
	self.ctrlState = StateType.pause
	self:RemoveListener()

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", {} )
   	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", true )
   	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )

	return true
end
-- 继续时调用
function M:Resume()
	self.object.enableMove = true
	self.ctrlState = StateType.running
	self:AddListener()
end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	
	if self.chase_cd < 0 then
		self:ChaseHeroPos()
	else
		self.chase_cd = self.chase_cd - dt
	end

end

function M:ChaseHeroPos()
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
        local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis > self.range2 then
        	--- 找一个 同心环，避免 和蛇头重叠
        	local rAngle = math.random(360)
        	local r1 = 1.6
        	local r2 = math.floor(self.range)
        	local rRadius = math.random( math.min(r1,r2) , math.max(r1,r2) )

        	local canMoveGrid = GetMapCanPassGridData( self.object )

        	local tarPos = _obj.transform.position

        	for i = 0 , 360 , 30 do
        		local tarAngle = rAngle + i
        		local pos = { x = _obj.transform.position.x + rRadius * math.cos( tarAngle * math.pi / 180 ) , y = _obj.transform.position.y + rRadius * math.sin( tarAngle * math.pi / 180 ) , z = _obj.transform.position.z }
        	
        		local no = GetMapNoByPos( self.object , pos )
        		if canMoveGrid[no] then
        			tarPos = pos
        			break
        		end
        	end

        	--dump( { self.object.transform.position , _obj.transform.position , dis , self.range2 } , "<color=yellow>xxx----------------ChaseHeroPos:</color>"  )

        	self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, tarPos )
			self.chase_cd = 2
			return
        end
	end
end

function M:on_vehicle_finish_step( id )
	if id == self.object.vehicle.ID then
		self.chase_cd = 0
	end
end
