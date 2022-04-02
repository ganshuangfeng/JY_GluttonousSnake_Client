
local basefunc = require "Game/Common/basefunc"

Base = basefunc.class()
local M = Base

local base_id = 0

function M:Ctor( data )

	base_id = base_id + 1
	self.id = base_id
	self.type = data.type
	self.isLive = true
	self.name = data.name
	self.is_debug = false

end

function M:GetType()
	return self.type
end

function M:GetId()
	return self.id
end

function M:Exit()
	-- ClearTable(self)
end

function M:CheckDead()
	
end

-- 标记为死去：将被销毁或放回收池
function M:Clear()
	self.isLive = false
end