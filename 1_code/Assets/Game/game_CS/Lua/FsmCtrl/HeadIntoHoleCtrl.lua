---- 蛇进洞 状态


local basefunc = require "Game/Common/basefunc"

HeadIntoHoleCtrl = basefunc.class(BaseCtrl)

local M = HeadIntoHoleCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    ---- 洞的位置
    self.holePos = data.holePos
    ---- 要移动的两个点，即门前一个点 和 门前沿着门直线很远的一个点
    self.movePosVec = {}

end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready

	self:MakeLister()
end

--- 状态开始时调用
function M:Begin()
	self.ctrlState = StateType.running

	self:getHolePos()

	self:onStateActive()

end

function M:onStateActive()
	--self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )

	--self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", function() self:OnFinishStep() end )

	self:AddListener()

	--self:dealHolePos()

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPoint, true )

	self.object.vehicle:Start()
	self.object.vehicle:SetVehiclePattern("point")
end

function M:onStateDisable()
	self:RemoveListener()

	--[[self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", nil )

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", {} )--]]

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPoint, false )
end

function M:getHolePos()
	if self.holePos and not next(self.movePosVec) then
		--local gridNoCoord = GetMapNoCoordByPos( self.holePos )
		local gridNoCoord = GetMapNoCoordByPos( self.object , self.holePos )


		local startPos = { x = self.holePos.x , y = self.holePos.y - GameInfoCenter.map.grid_size }
		local endPos = { x = self.holePos.x , y = self.holePos.y + 30 * GameInfoCenter.map.grid_size }

		local sceen_size = GameInfoCenter.map.sceen_size
		local borderPoint = { 
			{ x = sceen_size.width/2 - GameInfoCenter.map.grid_size/2 , y = sceen_size.height/2 - GameInfoCenter.map.grid_size/2 } , 
			{ x = sceen_size.width/2 - GameInfoCenter.map.grid_size/2 , y = -sceen_size.height/2 + GameInfoCenter.map.grid_size/2 } , 
			{ x = -sceen_size.width/2 + GameInfoCenter.map.grid_size/2 , y = -sceen_size.height/2 + GameInfoCenter.map.grid_size/2 } , 
			{ x = -sceen_size.width/2 + GameInfoCenter.map.grid_size/2 , y = sceen_size.height/2 - GameInfoCenter.map.grid_size/2 } , 
		}

		if math.abs( endPos.y ) > GameInfoCenter.map.sceen_size.height / 2 then
			--endPos.y = endPos.y > 0 and GameInfoCenter.map.sceen_size.height / 2 - GameInfoCenter.map.grid_size/2 or -GameInfoCenter.map.sceen_size.height / 2 + GameInfoCenter.map.grid_size/2
		
			endPos.y = endPos.y / math.abs(endPos.y) * (GameInfoCenter.map.sceen_size.height / 2 - GameInfoCenter.map.grid_size/2)
		end
		------------------------------------------------------------------ 处理找门口是哪一边，然后把 不能过的点打开
		--local grid_num = MoveAlgorithm.GetGridNum()
		local grid_num = GetGridNum( self.object )
		local tarDir = 1
		local min = 9999
		if math.abs(gridNoCoord.y - grid_num.y) < min then
			min = math.abs(gridNoCoord.y - grid_num.y)
			tarDir = 1
		end
		if math.abs(gridNoCoord.x - grid_num.x) < min then
			min = math.abs(gridNoCoord.x - grid_num.x)
			tarDir = 2
		end
		if gridNoCoord.y - 0 < min then
			min = gridNoCoord.y
			tarDir = 3
		end
		if gridNoCoord.x - 0 < min then
			min = gridNoCoord.x
			tarDir = 4
		end

		local offset = {
			[1] = { x = 0 , y = 1 } ,
			[2] = { x = 1 , y = 0 } ,
			[3] = { x = 0 , y = -1 } ,
			[4] = { x = -1 , y = 0 } ,
		}

		----- 设置边缘 astar 不能通过打开
		local tarOffset = offset[tarDir]
		if tarOffset.x ~= 0 then
			for x = gridNoCoord.x , (tarOffset.x > 0 and grid_num.x or 0) , tarOffset.x do
				--local no = GetMapNoByCoord( x , gridNoCoord.y )
				local no = GetMapNoByCoord( self.object , x , gridNoCoord.y )
				GameInfoCenter.forceMapNotPassGridData[ no ] = false

				SetMapCantPassGrid()
			end
		end
		if tarOffset.y ~= 0 then
			for y = gridNoCoord.y , (tarOffset.y > 0 and grid_num.y or 0) , tarOffset.y do
				--local no = GetMapNoByCoord( gridNoCoord.x , y )
				local no = GetMapNoByCoord( self.object , gridNoCoord.x , y )
				GameInfoCenter.forceMapNotPassGridData[ no ] = false

				SetMapCantPassGrid()
			end
		end



		endPos = { x = self.holePos.x + 30 * tarOffset.x * GameInfoCenter.map.grid_size , y = self.holePos.y + 30 * tarOffset.y * GameInfoCenter.map.grid_size }

		self.movePosVec = { endPos } -- { endPos , borderPoint[1] , borderPoint[2] , borderPoint[3] , borderPoint[4] , endPos } --{ startPos , self.holePos , endPos }

		--self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath , self.movePosVec )

		self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPoint , endPos )

		

	end
end

function M:dealHolePos()
	if self.movePosVec and next(self.movePosVec) then
		local hero_pos = {} -- { pos_list = GameInfoCenter.GetHeroPosList() }
		local path = {}

		--print("xxx----------------- call GetMapNotPassGridData 1 ")
		--[[local cannot_move_pos_vec = basefunc.deepcopy( GameInfoCenter.GetMapNotPassGridData() )
		if #self.movePosVec == 3 then
			cannot_move_pos_vec[ GetPosTagKeyStr(self.holePos) ] = true 
		end--]]
		dump( {"4_dir" , self.object.vehicle.m_vPos , Vec2DAngle(self.object.vehicle.m_vHeading) , self.movePosVec[1] , hero_pos} , "xxx-------GetGridMovePath 33333 " )
		local is_true , path = GetGridMovePath( self.object , "4_dir" , self.object.vehicle.m_vPos , Vec2DAngle(self.object.vehicle.m_vHeading) , self.movePosVec[1] , hero_pos , true )
		
		dump( path , "xx----------------dealHolePos:" .. #self.movePosVec )
		if is_true then
			self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "WayPoints", path )
			self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "isPatrolComplete", false )
			self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "currentWPIndex", 1 )
		end

	end

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


---------------------------------- 消息监听相关 ↑ -------------------------

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self:onStateDisable()

end

--强制结束
function M:Stop()
	self:Finish()
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause

	self:onStateDisable()

end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

	self:onStateActive()

end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	
	if not next(self.movePosVec) then
		self.ctrlState = StateType.finish
	end

end


function M:OnFinishStep()
	table.remove( self.movePosVec , 1 )

	self:dealHolePos()
end
