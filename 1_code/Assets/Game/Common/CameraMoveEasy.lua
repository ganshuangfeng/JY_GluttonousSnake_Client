-- 创建时间:2021-07-19
local basefunc = require "Game/Common/basefunc"

CameraMoveEasy = basefunc.class()
local M = CameraMoveEasy
local is_debug = true
local instance

local base_size = 11.7
local base_show_size = {min_x=-5.4, max_x=5.4, min_y=-7, max_y=9.2,} -- 显示区域大小
local base_move_size = {min_x=-3, max_x=3, min_y=-6, max_y=8,} -- 移动区域大小
local base_show_rect = {x=32, y=38,} -- 移动区域 显示

function M.Start(data)
    instance = M.New(data)
    return instance
end

function M:Awake()
	local s = GetSceenSize( MapManager.GetCurRoomAStar() )
	base_show_rect.x = s.w
	base_show_rect.y = s.h

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
	if data and data.roomNo and data.roomNo > 0 then
		self.camOffset = MapManager.GetRoomOffsetByNo(data.roomNo)
	else
		self.camOffset = {x=0, y=0}
	end

    local py_x = 1
    local py_y = 0
    self.map_size = {min_x=-0.5*map.w + py_x, max_x=0.5*map.w - py_x, min_y=-0.5*map.h + py_y, max_y=0.5*map.h - py_y,} -- 地图大小
	base_show_rect.x = map.w
	base_show_rect.y = map.h
	self:ChangeCameraSize()
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
end

function M:FrameUpdate(time_elapsed)
	local ypos = GameInfoCenter.GetHeroHeadAveragePos()
	local pos = {x=ypos.x - self.camOffset.x, y=ypos.y - self.camOffset.y}
	local cam_pos = {	x=CSPanel.camera3d.transform.position.x - self.camOffset.x,
						y=CSPanel.camera3d.transform.position.y - self.camOffset.y,
						z=0}

	local loc_pos_x = pos.x-cam_pos.x
	local loc_pos_y = pos.y-cam_pos.y

	-- 在自由移动区域
	if loc_pos_x < self.move_size.max_x
		and loc_pos_x > self.move_size.min_x
		and loc_pos_y < self.move_size.max_y
		and loc_pos_y > self.move_size.min_y then
			-- dump(loc_pos_x, "<color=red>aaaaaaaaaaaaaaaa </color>")
			-- dump(self.move_size)
		return
	end
	local dd = ""
	-- dump({loc_pos_x=loc_pos_x, loc_pos_y = loc_pos_y}, "2323232323232")
	-- dump({pos=pos, cam_pos=cam_pos, map_size=self.map_size, move_size=self.move_size}, "34444444444")
	local x1 = self.show_size.min_x + cam_pos.x
	local x2 = self.show_size.max_x + cam_pos.x
	local y1 = self.show_size.min_y + cam_pos.y
	local y2 = self.show_size.max_y + cam_pos.y
	local x = cam_pos.x
	local y = cam_pos.y
	local oldx = x
	local oldy = y
	if pos.x < self.map_size.min_x then
		x = self.map_size.min_x - self.show_size.min_x
		dd = dd .. "+1"
	elseif pos.x > self.map_size.max_x then
		x = self.map_size.max_x - self.show_size.max_x
		dd = dd .. "+2"
	else
		if loc_pos_x < self.move_size.min_x then
			x = cam_pos.x + loc_pos_x - self.move_size.min_x
			dd = dd .. "+3"
		elseif loc_pos_x > self.move_size.max_x then
			x = cam_pos.x + loc_pos_x - self.move_size.max_x
			dd = dd .. "+4"
		else		
			if (x + self.show_size.min_x) < self.map_size.min_x then
				x = self.map_size.min_x - self.show_size.min_x
				dd = dd .. "+5"
			elseif (x + self.show_size.max_x) > self.map_size.max_x then
				x = self.map_size.max_x - self.show_size.max_x
				dd = dd .. "+6"
			end
		end
	end

	if pos.y < self.map_size.min_y then
		y = self.map_size.min_y - self.show_size.min_y
		dd = dd .. "+7"
	elseif pos.y > self.map_size.max_y then
		y = self.map_size.max_y - self.show_size.max_y
		dd = dd .. "+8"
	else
		if loc_pos_y < self.move_size.min_y then
			y = cam_pos.y + loc_pos_y - self.move_size.min_y
			dd = dd .. "+9"
		elseif loc_pos_y > self.move_size.max_y then
			y = cam_pos.y + loc_pos_y - self.move_size.max_y
			dd = dd .. "+10"
		else
			if (y + self.show_size.min_y) < self.map_size.min_y then
				y = self.map_size.min_y - self.show_size.min_y
				dd = dd .. "+11"
			elseif (y + self.show_size.max_y) > self.map_size.max_y then
				y = self.map_size.max_y - self.show_size.max_y
				dd = dd .. "+12"
			end
		end
	end

	if CameraMoveBase.IsDebug then
		local _ppp = {x = x+self.camOffset.x, y = y+self.camOffset.y, z = 0}
		if Vec2DLength( {x=_ppp.x-CSPanel.camera3d.transform.position.x, y=_ppp.y-CSPanel.camera3d.transform.position.y} ) > 2 then
			print("<color=red><size=16>AAAAAAAAAAAAAAAAAAAAA </size></color>")
			dump({
				len=Vec2DLength( {x=_ppp.x-CSPanel.camera3d.transform.position.x, y=_ppp.y-CSPanel.camera3d.transform.position.y} ),
				camOffset=self.camOffset,
				camPos = CSPanel.camera3d.transform.position,
				ypos = ypos,
				show_size = self.show_size,
				move_size = self.move_size,
				map_size = self.map_size,
				dd = dd,
				_ppp = _ppp,
				oldxy={x=oldx, y=oldy},
				loc_pos={x=loc_pos_x, y=loc_pos_y},

			}, "1111")
			print("<color=red><size=16>BBBBBBBBBBBBBBBBBBBBB </size></color>")
		end
	end

	return {x = x+self.camOffset.x, y = y+self.camOffset.y, z = 0}
end

