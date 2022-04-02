StageEditorModel = {}
local basefunc = require "Game/Common/basefunc"
ExtRequire "Game.game_CS.Lua.GameConfigCenter"
ExtRequire"Game.game_CS.Lua.CreateFactory"

local M = StageEditorModel
local this

function M.Init()
    this = M
    GameConfigCenter.Init()
    return this
end

function M.Exit()
	if this then
	    this = nil
    end
end


--[[
    stage =
    {
        stage = 1,
        room = {0,1,2,3,4,101,1001,3001},
        relation = {{2},{3},{4},{5,8},{6},{7},{},{4}},
    },
--]]
function M.GetStageConfig()
    --关卡房间个数
    local roomCount = math.random(1,10)
    --当前房间编号
    local roomNO = 0
    --房间库
    local roomNODic = {
        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,101,1001,1002,3001
    }

    local stage = {
    }
    local room = {}
    for i = 1, roomCount do
        if roomNO ~= 0 then
            --对当前房间进行检查，处理
            
        end
        room[#room+1] = roomNO
    end

end