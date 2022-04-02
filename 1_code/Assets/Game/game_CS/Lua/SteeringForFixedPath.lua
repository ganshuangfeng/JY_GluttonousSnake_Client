-- 创建时间:2021-07-20

local basefunc = require "Game/Common/basefunc"

SteeringForFixedPath = basefunc.class(Steering)
local C = SteeringForFixedPath

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 当前巡逻点
	self.currentWPIndex = 1
	-- 是否结束巡逻
	self.isPatrolComplete = true
	-- 巡逻方式1一次 2循环 3往返
	self.patroMode = 1
	-- 巡逻点
	self.WayPoints = {}
	-- 目标点
	self.target_pos_list = {}

	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

	self.steering = SteeringForFixedPoint.New(parm)



end

function C:setTargetPos(pos, vehicle)
	--if self.obj_name == "hero" then
	--	print("xxx--------------fixpath  setTargetPos 1 ")
	--end
	if not pos.x then
		self.target_pos_list = {}
		for i = 2, #pos do
			self.target_pos_list[#self.target_pos_list + 1] = pos[i]
		end
		self:setTargetPos(pos[1], vehicle)
		return
	end
	--if self.obj_name == "hero" then
	--	print("xxx--------------fixpath  setTargetPos 2 ")
	--end
	local ll = {}
	local hero_pos = {}
	if self.obj_name == "hero" then
		hero_pos = {} -- { pos_list = GameInfoCenter.GetHeroPosList() }
	end

	--if self.obj_name == "hero" then
	--	print("xxx--------------fixpath  setTargetPos 3 ")
		--dump(vehicle.m_vHeading , "xxxx-------------vehicle.m_vHeading:")
		-- dump( { self.obj_name , vehicle.m_vPos , Vec2DAngle(vehicle.m_vHeading) , pos , hero_pos } , "xxx-------GetGridMovePath 22222" )
	--end
	
	

	local b , ll = GetGridMovePath( vehicle.game_entity , "4_dir" , vehicle.m_vPos , Vec2DAngle(vehicle.m_vHeading) , pos , hero_pos , true )
	-- local b = nil
	--if self.obj_name == "hero" then
	--	print("xxx--------------fixpath  setTargetPos 4 ")
	--end
	if self.obj_name == "hero" then
		-- dump({b, ll , vehicle.m_vPos , pos }, "<color=red>WWWWWWWWWWWWWWWWWWWWWWWWWWWW </color>")

		-- dump(hero_pos , "xxx----------------------hero_pos：")
	end

	if b and #ll > 0 then
		self.isPatrolComplete = false
		self.WayPoints = ll
		self.currentWPIndex = 1
		if self.WayPoints[self.currentWPIndex] then
			self.steering:setTargetPos( self.WayPoints[self.currentWPIndex] )
		end
	else
    	if #self.target_pos_list > 0 then
    		local _pos = self.target_pos_list[1]
    		table.remove(self.target_pos_list, 1 )
    		self:setTargetPos(_pos, vehicle)
    	else
			self.isPatrolComplete = true
    	end
	end
end

function C:FrameUpdate(vehicle, time_elapsed)
	if self.isPatrolComplete then return false end

	local _b = self.steering:FrameUpdate(vehicle, time_elapsed)
	if not _b then
	    if self.currentWPIndex > #self.WayPoints then
	        if self.patroMode == 1 then
	        	if #self.target_pos_list > 0 then
	        		local _pos = self.target_pos_list[1]
	        		table.remove(self.target_pos_list, 1 )
	        		self:setTargetPos(_pos, vehicle)
	        		if self.WayPoints[self.currentWPIndex] then
	        			self.steering:setTargetPos( self.WayPoints[self.currentWPIndex] )
	        		end
	        		return false
	        	end
                self.isPatrolComplete = true
                vehicle:FinishStep()

                if self.finishStepCallback and type(self.finishStepCallback) == "function" then
                	self.finishStepCallback()
                end

                return false
	        elseif self.patroMode == 3 then
	        	local data = {}
	        	for i=#self.WayPoints, 1, -1 do
	        		data[#data + 1] = self.WayPoints[i]
	        	end
	        	self.WayPoints = data
	        end
	    end

		if self.WayPoints[self.currentWPIndex] then
			self.steering:setTargetPos( self.WayPoints[self.currentWPIndex] )
		end

	    self.currentWPIndex = self.currentWPIndex + 1
	    if self.currentWPIndex > #self.WayPoints and self.patroMode ~= 1 then
	    	self.currentWPIndex = 1
	    end
	end
    return true
end

