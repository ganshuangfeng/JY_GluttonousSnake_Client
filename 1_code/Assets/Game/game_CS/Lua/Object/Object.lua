local basefunc = require "Game/Common/basefunc"

Object = basefunc.class(Base)
local M = Object

function M:Ctor(data)
	M.super.Ctor( self , data )

	self.tag = data.tag or {}
	self.group = data.group

	self.isLive = true
	self.is_debug = false

	self.lister = {}
	self.enabled = false
	self.time_scale = 1
	self.gameObject = nil
	self.transform = nil

	self.config = basefunc.deepcopy(data.config)

	self:SetRoomNo( data.roomNo)

end

function M:SetRoomNo(roomNo)
	if roomNo then
		if self.data then 
			self.data.roomNo = roomNo
		end
		self.aStar = MapManager.GetAStar(roomNo)
		--dump(self.aStar , "xxx-----------------self.aStar" .. roomNo )
		if not self.aStar then
			--error( "xxxx---------------object SetRoomNo error " )
		else
			self.aStar = self.aStar.aStar

		end
	end
end

function M:Init( data )


end

function M:Refresh()

end

function M:Exit()

end

function M:FrameUpdate(dt)

end

function M:MakeLister()

end

function M:AddMsgListener()

end

function M:RemoveListener()

end



