--[[
	作者：隆元线 2015-10-29

	控制器基类
--]]
local basefunc = require "Game/Common/basefunc"

BaseCtrl = basefunc.class(Base)
local M = BaseCtrl

function M:Ctor(object, data)
	
    self.object = object

    self.ctrlState = StateType.none
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
function M:Refresh(data)
    return true
end

function M:Update(dt)
    if self.ctrlState ~= StateType.running then
        return
    end
end

--[[function M:CheckDead()
	if not self.isLive then 
		return true 
	end

	if not self.object or not self.object.isLive then
		self:Clear()
		return true
	end

	return false
end--]]