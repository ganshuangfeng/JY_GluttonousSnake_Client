-- 创建时间:2021-09-26

local basefunc = require "Game/Common/basefunc"

CameraMoveDebug = basefunc.class()
local M = CameraMoveDebug
M.name = "CameraMoveDebug"

function M.Create()
	return M.New()
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:Ctor()
	local obj = NewObject(M.name, CSPanel.map_node)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
end

function M:MyRefresh(data)
	if data.outer_wall_size then
		local x = (data.outer_wall_size.max_x + data.outer_wall_size.min_x) * 0.5
		local y = (data.outer_wall_size.max_y + data.outer_wall_size.min_y) * 0.5
		local h = data.outer_wall_size.max_y - data.outer_wall_size.min_y
		local w = data.outer_wall_size.max_x - data.outer_wall_size.min_x

		self.outer_wall_left.position = Vector3.New(data.outer_wall_size.min_x, y, 0)
		self.outer_wall_left.localScale = Vector3.New(100/30 * h, 50, 1)

		self.outer_wall_right.position = Vector3.New(data.outer_wall_size.max_x, y, 0)
		self.outer_wall_right.localScale = Vector3.New(100/30 * h, 50, 1)

		self.outer_wall_up.position = Vector3.New(x, data.outer_wall_size.max_y, 0)
		self.outer_wall_up.localScale = Vector3.New(100/30 * w, 50, 1)

		self.outer_wall_down.position = Vector3.New(x, data.outer_wall_size.min_y, 0)
		self.outer_wall_down.localScale = Vector3.New(100/30 * w, 50, 1)
	end

	if data.map_size then
		self.map.position = Vector3.New(0.5*(data.map_size.max_x+data.map_size.min_x), 
										0.5*(data.map_size.max_y+data.map_size.min_y), 0)
		self.map.localScale = Vector3.New(data.map_size.max_x-data.map_size.min_x, data.map_size.max_y-data.map_size.min_y, 1)
	end

	if data.show_size then
		self.show.position = Vector3.New(data.camPos.x+0.5*(data.show_size.max_x+data.show_size.min_x), 
										data.camPos.y+0.5*(data.show_size.max_y+data.show_size.min_y), 0)
		self.show.localScale = Vector3.New(data.show_size.max_x-data.show_size.min_x, data.show_size.max_y-data.show_size.min_y, 1)
	end

	if data.move_size then
		self.move.position = Vector3.New(data.camPos.x+0.5*(data.move_size.max_x+data.move_size.min_x), 
										data.camPos.y+0.5*(data.move_size.max_y+data.move_size.min_y), 0)
		if data.move_size.max_y-data.move_size.min_y <= 0.5 then
			self.move.localScale = Vector3.New(data.move_size.max_x-data.move_size.min_x, 1, 1)
		else
			self.move.localScale = Vector3.New(data.move_size.max_x-data.move_size.min_x, data.move_size.max_y-data.move_size.min_y, 1)
		end
	end
end
