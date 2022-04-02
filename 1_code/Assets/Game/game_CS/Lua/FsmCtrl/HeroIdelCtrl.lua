local basefunc = require "Game/Common/basefunc"

HeroIdelCtrl = basefunc.class(BaseCtrl)

local M = HeroIdelCtrl

function M:Ctor( object , data )
	-- print("xxx---------------------idel  object :" , object )

	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none

    self.time = 0
    self.change_time = 3

    self.tar_angle = nil

end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready
end

--- 状态开始时调用
function M:Begin()
	self.ctrlState = StateType.running
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

end

--强制结束
function M:Stop()

end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause
	return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	

end



