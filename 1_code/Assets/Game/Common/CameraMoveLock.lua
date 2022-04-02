-- 创建时间:2021-07-19
local basefunc = require "Game/Common/basefunc"

CameraMoveLock = basefunc.class()

local M = CameraMoveLock
local instance

function M.Start()
    instance = M.New()
    return instance
end

function M:Ctor()
end

function M:FrameUpdate(time_elapsed)
	local pos = GameInfoCenter.GetHeroHeadAveragePos()
    if not pos then return end
    return pos
end
