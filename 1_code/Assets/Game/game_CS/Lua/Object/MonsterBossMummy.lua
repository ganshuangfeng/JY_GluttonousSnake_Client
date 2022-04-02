---- 木乃伊怪物

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"

MonsterBossMummy = basefunc.class(MonsterBoss)
local M = MonsterBossMummy

function M:Ctor(data)
	data.fsmTable  = monsterBossFsmTable

	M.super.Ctor( self , data )
end

function M:Init()

	self:CreateUI()

	self:MakeLister()
	self:AddMsgListener()

	self.fsmLogic:addWaitStatusForUser( "create"  )

	---- 加一个免疫 冰冻，驱散冰冻的 标签
	AddTag( self , "immune_stationary" )
	AddTag( self , "break_stationary" )

	self:InitSkill()
end
