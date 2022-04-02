local basefunc = require "Game/Common/basefunc"
local monsterFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterFsmTable"

MonsterTotem = basefunc.class(Monster)
local M = MonsterTotem
function M:Ctor(data)
	data.fsmTable = monsterFsmSRHTable
	M.super.Ctor( self , data )
end
function M:UpdateTransform()
	--这里什么都不需要做，固定方向即可
end