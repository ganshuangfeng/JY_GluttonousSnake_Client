local basefunc = require "Game/Common/basefunc"

MonsterBossIdelCtrl = basefunc.class(BaseCtrl)

local M = MonsterBossIdelCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
end

--强制结束
function M:Stop()
	self:Finish()
end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	--- 直接切换 到攻击状态
	Event.Brocast( "monsterBossNorAttack",{object_id = self.object.id} )
	
end



