-- 创建时间:2021-08-17
local basefunc = require "Game/Common/basefunc"

HeadManualCtrl = basefunc.class(BaseCtrl)

local M = HeadManualCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    --self.left = GameInfoCenter.map.sceen_size.width * -0.5 + GameInfoCenter.map.grid_size/2 - 0.01
    --self.right = GameInfoCenter.map.sceen_size.width * 0.5 - GameInfoCenter.map.grid_size / 2 + 0.01
    --self.up = GameInfoCenter.map.sceen_size.height * 0.5 - GameInfoCenter.map.grid_size / 2 + 0.01
    --self.down = GameInfoCenter.map.sceen_size.height * -0.5 + GameInfoCenter.map.grid_size / 2 - 0.01

	self.targetData = {}

    self.debug_obj = nil

    self.lister = {}

    self.initDir = data and data.initDir

end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready

	self:MakeLister()
end

---- 获得地图尺寸
function M:GetScreenSize()
	return GetSceenSize( self.object )
end

---- 获得格子大小
function M:GetGridSize()
	return GetGridSize( self.object )
end

function M:GetBorder(_type)
	local screenSize = self:GetScreenSize()
	local gridSize = self:GetGridSize()

	if _type == "left" then
		return screenSize.width * -0.5 + gridSize/2 - 0.01
	elseif _type == "right" then
		return screenSize.width * 0.5 - gridSize/2 + 0.01
	elseif _type == "up" then
		return screenSize.height * 0.5 - gridSize/2 + 0.01
	elseif _type == "down" then
		return screenSize.height * -0.5 + gridSize/2 - 0.01
	end
end

--- 状态开始时调用
function M:Begin()
	-- 默认先去第一个目标点
	if not self.targetData.pos then
		local td = basefunc.deepcopy( GameInfoCenter.GetHeroHeadTargetData() )
		if td and td.pos then
			self.targetData.pos = td.pos
			self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.targetData.pos )
		else
			self:UpdateTargetPos(0)
		end
	end

	self.ctrlState = StateType.running

	self.object.vehicle:SetVehiclePattern( CSModel.heroHeadPattern )

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPoint, true )

	self:AddListener()

	self.object.vehicle:SetSteeringValue( Vehicle.SteerType.FixedPointPath , "finishStepCallback", function() self:OnFinishStep() end )

	if self.initDir then
		print("xxx---------------self.initDir:" , self.initDir)
		self:on_head_manual_change_target_dir( self.initDir )
	end

end

---------------------------------- 消息监听相关 ↓ -------------------------
function M:MakeLister()
	self.lister = {}
	self.lister["head_manual_change_target_dir"] = basefunc.handler(self, self.on_head_manual_change_target_dir)
	self.lister["head_manual_change_target_pos"] = basefunc.handler(self, self.on_head_manual_change_target_pos)
	self.lister["head_manual_change_move_onoff"] = basefunc.handler(self, self.on_head_manual_change_move_onoff)
	self.lister["head_manual_change_target_rot"] = basefunc.handler(self, self.on_head_manual_change_target_rot)
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
function M:on_head_manual_change_target_pos(pos)
	self.targetData.pos = pos
	self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.targetData.pos )
end
function M:on_head_manual_change_move_onoff(b)
	if b then
		self.object.vehicle:SetVehiclePattern( CSModel.heroHeadPattern )
		self.object.vehicle:Start()
	else
		self.object.vehicle:Stop()
	end
end
function M:on_head_manual_change_target_dir(dir)
	--print("xxx--------------on_head_manual_change_target_dir:" , dir)
	local curDir = self:GetCurDir()
	-- if curDir == dir then  --or ( curDir + dir ) % 2 == 0 then
	-- 	return

	-- end

	local grid_size = self:GetGridSize()

	local yPos = ConvertToGrid( self.object , self.object.transform.position )
	if dir == 0 then
		if math.abs(yPos.x- self:GetBorder("right") ) < grid_size then
			return
		end
	elseif dir == 1 then
		if math.abs(yPos.y- self:GetBorder("up") ) < grid_size then
			return
		end
	elseif dir == 2 then
		if math.abs(yPos.x- self:GetBorder("left") ) < grid_size then
			return
		end
	else
		if math.abs(yPos.y- self:GetBorder("down") ) < grid_size then
			return
		end
	end
	self:on_head_manual_change_move_onoff(true)
	self:UpdateTargetPos(dir)
end

function M:on_head_manual_change_target_rot(rot , disPercent )
	self:on_head_manual_change_move_onoff(true)
	self.object.vehicle:SetRot(rot)

	disPercent = 100

	if not disPercent then
		disPercent = 100
	end

	if disPercent < 30 then
		disPercent = 30
	elseif disPercent > 100 then
		disPercent = 100
	end

	self.object.vehicle:SetSpeedValueByMaxSpeedPercent( disPercent , disPercent )
end
function M:on_head_manual_change_target_rot___(rot)
	self:on_head_manual_change_move_onoff(true)
	local call = function(delta_pos)
		-- local delta_pos = 0.2
		local nor = {x = MathExtend.Cos(rot), y = MathExtend.Sin(rot), z = 0}
		local pos = Vec2DAdd({x=nor.x*delta_pos, y=nor.y*delta_pos, z=0}, self.object.transform.position)

		local notGrid = GameInfoCenter.GetMapNotPassGridData()
		if not notGrid or not notGrid[ GetMapNoByPos( get_grid_pos(pos) ) ] then
			self.object.vehicle:SetTargetPos(Vehicle.SteerType.FixedPoint , pos )
		else
			if math.abs(nor.x) > math.abs(nor.y) then
				local pos = Vec2DAdd({x=nor.x*delta_pos, y=0, z=0}, self.object.transform.position)
				if not notGrid or not notGrid[ GetMapNoByPos( get_grid_pos(pos) ) ] then
					self.object.vehicle:SetTargetPos(Vehicle.SteerType.FixedPoint , pos )
					return
				end
				local pos = Vec2DAdd({x=0, y=nor.y*delta_pos, z=0}, self.object.transform.position)
				if not notGrid or not notGrid[ GetMapNoByPos( get_grid_pos(pos) ) ] then
					self.object.vehicle:SetTargetPos(Vehicle.SteerType.FixedPoint , pos )
				end
			else
				local pos = Vec2DAdd({x=0, y=nor.y*delta_pos, z=0}, self.object.transform.position)
				if not notGrid or not notGrid[ GetMapNoByPos( get_grid_pos(pos) ) ] then
					self.object.vehicle:SetTargetPos(Vehicle.SteerType.FixedPoint , pos )
				end
				local pos = Vec2DAdd({x=nor.x*delta_pos, y=0, z=0}, self.object.transform.position)
				if not notGrid or not notGrid[ GetMapNoByPos( get_grid_pos(pos) ) ] then
					self.object.vehicle:SetTargetPos(Vehicle.SteerType.FixedPoint , pos )
					return
				end
			end
		end
	end
	--速度不能给的太大
	local cur_speed = self.object.vehicle:Speed()
	local default_speed = 7
	local defaultDeltaPos = 0.2
	call(cur_speed / default_speed * defaultDeltaPos)
end

local dirStep = {
	[0] = {x=1, y=0},
	[1] = {x=0, y=1},
	[2] = {x=-1, y=0},
	[3] = {x=0, y=-1},
}
function M:UpdateTargetPos_Old(dir)
	local curDir = self:GetCurDir()
	local grid_size = self:GetGridSize()

	local yPos = self.object.transform.position
	self.targetData.pos = self.targetData.pos or {x=0, y=0, z=0 , isGrid = true }

	local targetList = {}
	--local notGrid = GameInfoCenter.GetMapNotPassGridData()
	local notGrid = GetMapNotPassGridData( self.object )
	dump(notGrid, "<color=red>AAAAAAAAAAAAAAAAAAA 11</color>")
	local bPos = get_grid_pos(self.object , yPos )
	for i = 1, 100 do
		bPos.x = bPos.x + dirStep[dir].x * grid_size
		bPos.y = bPos.y + dirStep[dir].y * grid_size
		if self:GetBorder("left") <= bPos.x and bPos.x <= self:GetBorder("right") and self:GetBorder("down") <= bPos.y and bPos.y <= self:GetBorder("up") then
			if notGrid and notGrid[ GetMapNoByPos( self.object , bPos ) ] then
				targetList[#targetList + 1] = {x=bPos.x - dirStep[dir].x * grid_size,
											   y=bPos.y - dirStep[dir].y * grid_size,
											   z = 0}
			end
		end
	end
	if dir == 0 then
		self.targetData.pos.x = self:GetBorder("right") -- self.right
		self.targetData.pos.y = yPos.y
	elseif dir == 1 then
		self.targetData.pos.x = yPos.x
		self.targetData.pos.y = self:GetBorder("up") -- self.up
	elseif dir == 2 then
		self.targetData.pos.x = self:GetBorder("left") -- self.left
		self.targetData.pos.y = yPos.y
	else
		self.targetData.pos.x = yPos.x
		self.targetData.pos.y = self:GetBorder("down") -- self.down
	end
	self.targetData.pos = get_grid_pos(self.object , self.targetData.pos , true )

	-- if #targetList < 1 then
		targetList[#targetList + 1] = self.targetData.pos
	-- end
	-- dump(targetList, "<color=red>AAAAAAAAAAAAAAAAAAA 2222</color>")
	self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, targetList[1] )
end

function M:UpdateTargetPos(dir)
	local curDir = self:GetCurDir()
	local grid_size = self:GetGridSize()

	local yPos = self.object.transform.position
	self.targetData.pos = self.targetData.pos or {x=0, y=0, z=0 , isGrid = true }

	local targetList = {}
	--local notGrid = GameInfoCenter.GetMapNotPassGridData()
	local notGrid = GetMapNotPassGridData( self.object )
	-- dump(notGrid, "<color=red>AAAAAAAAAAAAAAAAAAA 11</color>")
	local bPos = get_grid_pos(self.object , yPos )
	-- dump({bPos, GetMapNoByPos(bPos)}, "11111111111111111111")
	for i = 1, 100 do
		bPos.x = bPos.x + dirStep[dir].x * grid_size
		bPos.y = bPos.y + dirStep[dir].y * grid_size
		if self:GetBorder("left") <= bPos.x and bPos.x <= self:GetBorder("right") and self:GetBorder("down") <= bPos.y and bPos.y <= self:GetBorder("up") then
			if notGrid and notGrid[ GetMapNoByPos( self.object , bPos ) ] then
				targetList[#targetList + 1] = {x=bPos.x - dirStep[dir].x * grid_size,
											   y=bPos.y - dirStep[dir].y * grid_size,
											   z = 0}
			end
		end
	end
	-- dump(targetList, "2222222222222222222")
	if dir == 0 then
		self.targetData.pos.x = self:GetBorder("right") -- self.right
		self.targetData.pos.y = yPos.y
	elseif dir == 1 then
		self.targetData.pos.x = yPos.x
		self.targetData.pos.y = self:GetBorder("up") --self.up
	elseif dir == 2 then
		self.targetData.pos.x = self:GetBorder("left") --self.left
		self.targetData.pos.y = yPos.y
	else
		self.targetData.pos.x = yPos.x
		self.targetData.pos.y = self:GetBorder("down") --self.down
	end
	self.targetData.pos = get_grid_pos(self.object , self.targetData.pos , true )

	-- if #targetList < 1 then
		targetList[#targetList + 1] = self.targetData.pos
	-- end
	-- dump(targetList, "<color=red>AAAAAAAAAAAAAAAAAAA 2222</color>")
	self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, targetList[1] )
end


--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPoint, false )

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

function M:GetCurDir()
	local headDir = self.object.vehicle.m_vHeading
	local r = Vec2DAngle( Vec2DNormalize( headDir ) )
	local d = math.floor( ( r % 360 + 45 ) / 90 ) % 4
	return d
end

function M:OnFinishStep()
	do return end

	local isAuto = AutoControlModelManager.GetIsEnable()

	if isAuto then
		return
	end

	local curDir = self:GetCurDir()
	local dir = 0
	if curDir == 0 or curDir == 2 then
		if self.targetData.pos.y < 0 then
			dir = 1
		else
			dir = 3
		end
	else
		if self.targetData.pos.x < 0 then
			dir = 0
		else
			dir = 2
		end
	end
	-- dump(self.targetData, "<color=red>AAAAAAAAAAAAAAAAAA </color>")
	self:UpdateTargetPos(dir)
end




