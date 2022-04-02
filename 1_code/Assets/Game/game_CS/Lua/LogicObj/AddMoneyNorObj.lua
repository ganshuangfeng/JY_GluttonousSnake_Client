------

local basefunc = require "Game/Common/basefunc"

AddMoneyNorObj = basefunc.class(Base)
local M = AddMoneyNorObj

function M:Ctor(data)
	M.super.Ctor( self , data )

	self.object = data.object

	self.jb = data.jb

end

--- 构造函数之后调用
function M:Init()

end

--- 当第一次执行时调用
function M:Awake()


end

function M:Exit()
	self.isLive = false


end

--- 每帧执行调用
function M:update(dt)

end
