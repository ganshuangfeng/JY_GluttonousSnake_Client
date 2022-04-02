-- 创建时间:2021-07-19
local basefunc = require "Game/Common/basefunc"

CameraMoveHigh = basefunc.class()
local M = CameraMoveHigh
local instance

local base_size = 11.7
local base_show_size = {min_x=-5.4, max_x=5.4, min_y=-11.7, max_y=11.7,} -- 显示区域大小
-- local base_move_size = {min_x=-2.7, max_x=2.7, min_y=-6, max_y=6,} -- 移动区域大小
local base_move_size = {min_x=-0, max_x=0, min_y=0, max_y=0,} -- 移动区域大小

function M.Start(data)
    instance = M.New(data)
    return instance
end

function M:Awake()
	local s = GetSceenSize( MapManager.GetCurRoomAStar() )

	self.camOffset = MapManager.GetRoomOffsetByNo( GameInfoCenter.GetCurRoomNo() )
end

function M:Ctor(data)

    self:MakeLister()
	self:AddMsgListener()

    self:OnHeroHeadRoomNoChange()
end

function M:Exit()
    self:RemoveListener()
    instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:OnHeroHeadRoomNoChange(data)
	local map = GetSceenSize( MapManager.GetCurRoomAStar() )
	if data and data.roomNo then
		if data.roomNo > 0 then
			self.camOffset = MapManager.GetRoomOffsetByNo(data.roomNo)
		else
			-- self.camOffset = MapManager.GetRoomOffsetByNo(data.roomNo)
		end
	else
		self.camOffset = {x=0, y=0}
	end

	if data and data.roomNo and data.roomNo < 0 then
		return
	end

    local py_x = 1
    local py_y = 0
    -- 地图大小
    self.map_size = { 
    					min_x=-0.5*map.w + self.camOffset.x,
    					max_x=0.5*map.w + self.camOffset.x,
    					min_y=-0.5*map.h + self.camOffset.y,
    					max_y=0.5*map.h + self.camOffset.y
    				}
    
    -- 地图隐形墙大小
    self.outer_wall_size = 
    					{
    						min_x=self.map_size.min_x - 3.7,
    						max_x=self.map_size.max_x + 3.7,
    						min_y=self.map_size.min_y - 1,
    						max_y=self.map_size.max_y + 3.7
    					}
	self:ChangeCameraSize()

	self:Debug()
end

function M:ChangeCameraSize(size)
    size = size or CameraMoveBase.base_size
	local ss = size / base_size
    self.show_size = {min_x=base_show_size.min_x * ss,
					max_x=base_show_size.max_x * ss,
					min_y=base_show_size.min_y * ss,
    				max_y=base_show_size.max_y * ss}
    self.move_size = {min_x=base_move_size.min_x * ss,
					max_x=base_move_size.max_x * ss,
					min_y=base_move_size.min_y * ss,
    				max_y=base_move_size.max_y * ss}

    self:Debug()
end

function M:Debug(x, y)
	if CameraMoveBase.IsDebug then
		if not self.debugPre then
			self.debugPre = CameraMoveDebug.Create()
		end
	end
	if self.debugPre then
		local camPos = CSPanel.camera3d.transform.position
		if x and y then
			camPos = {x=x, y=y}
		end
		self.debugPre:MyRefresh(
			{
				outer_wall_size = self.outer_wall_size,
				show_size = self.show_size,
				map_size = self.map_size,
				move_size = self.move_size,
				camOffset = self.camOffset,
				camPos = camPos,
			}
		)
	end
end

-- 设置模式
function M:SetPattern(pattern)
	local ypos = GameInfoCenter.GetHeroHeadAveragePos()

	local ss = CameraMoveBase.base_size / base_size

	if pattern == "enter_room" then
	elseif pattern == "enter_door" then

	elseif pattern == "top" then
		self.outer_wall_size.min_y = ypos.y - 4
		self.outer_wall_size.max_y = 9999999
	    self.move_size.min_x = 0
	    self.move_size.max_x = 0
	    self.move_size.min_y = base_move_size.min_y * ss
	    self.move_size.max_y = self.move_size.min_y
	elseif pattern == "left" then
		self.outer_wall_size.min_x = ypos.x + 4
		self.outer_wall_size.max_x = -9999999
	    self.move_size.min_x = 0
	    self.move_size.max_x = 0
	    self.move_size.min_y = 0
	    self.move_size.max_y = 0
	elseif pattern == "right" then
		self.outer_wall_size.min_x = ypos.x - 4
		self.outer_wall_size.max_x = 9999999
	    self.move_size.min_x = 0
	    self.move_size.max_x = 0
	    self.move_size.min_y = 0
	    self.move_size.max_y = 0
	else
		dump(pattern, "<color=red>AAAAAAAAAAAAAAAAAA ============= </color>")
	end

	self:Debug()
end

function M:FrameUpdate(time_elapsed)
	local pos = GameInfoCenter.GetHeroHeadAveragePos()
	local cam_pos = CSPanel.camera3d.transform.position
	if not pos or not cam_pos then
		return
	end

	local loc_pos_x = pos.x-cam_pos.x
	local loc_pos_y = pos.y-cam_pos.y

	-- 视口在地图隐形墙内并且物体在自由移动区域
	if (cam_pos.x + self.show_size.min_x) > (self.outer_wall_size.min_x - 0.0001)
		and (cam_pos.x + self.show_size.max_x) < (self.outer_wall_size.max_x - 0.0001)
		and (cam_pos.y + self.show_size.min_y) > (self.outer_wall_size.min_y - 0.0001)
		and (cam_pos.y + self.show_size.max_y) < (self.outer_wall_size.max_y - 0.0001)
		and loc_pos_x < self.move_size.max_x
		and loc_pos_x > self.move_size.min_x
		and loc_pos_y < self.move_size.max_y
		and loc_pos_y > self.move_size.min_y then
		return
	end
	local x = cam_pos.x
	local y = cam_pos.y

	if loc_pos_x < self.move_size.min_x then
		x = cam_pos.x + loc_pos_x - self.move_size.min_x
	elseif loc_pos_x > self.move_size.max_x then
		x = cam_pos.x + loc_pos_x - self.move_size.max_x
	end

	if loc_pos_y < self.move_size.min_y then
		y = cam_pos.y + loc_pos_y - self.move_size.min_y
	elseif loc_pos_y > self.move_size.max_y then
		y = cam_pos.y + loc_pos_y - self.move_size.max_y
	end



	-- 矫正 x
	if self.map_size.min_x >= self.outer_wall_size.min_x
		and (x + self.show_size.min_x) <= (self.outer_wall_size.min_x + 0.0001) then

		x = self.outer_wall_size.min_x - self.show_size.min_x

	elseif self.map_size.max_x <= self.outer_wall_size.max_x
		and (x + self.show_size.max_x) >= (self.outer_wall_size.max_x + 0.0001) then

		x = self.outer_wall_size.max_x - self.show_size.max_x

	end
	-- 矫正 y
	if self.map_size.min_y >= self.outer_wall_size.min_y
		and (y + self.show_size.min_y) <= (self.outer_wall_size.min_y + 0.0001) then
			
		y = self.outer_wall_size.min_y - self.show_size.min_y

	elseif self.map_size.max_y <= self.outer_wall_size.max_y
		and (y + self.show_size.max_y) >= (self.outer_wall_size.max_y + 0.0001) then
		
		y = self.outer_wall_size.max_y - self.show_size.max_y
	end

	self:Debug(x, y)

	return {x = x, y = y, z = 0}
end

