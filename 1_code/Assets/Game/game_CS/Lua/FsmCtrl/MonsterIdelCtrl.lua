local basefunc = require "Game/Common/basefunc"

MonsterIdelCtrl = basefunc.class(BaseCtrl)

local M = MonsterIdelCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
end

--强制结束
function M:Stop()
	self:Finish()
end



