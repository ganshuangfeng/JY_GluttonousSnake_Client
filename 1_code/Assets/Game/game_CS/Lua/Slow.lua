--减速不可叠加
--持续时间刷新
--单层

local basefunc = require "Game/Common/basefunc"

Slow = basefunc.class(Skill)
local M = Slow

function M:Ctor(data)
	M.super.Ctor( self , data )
    self.data = data

end


function M:Init(data)
	M.super.Init( self )

	self.durCt = 0

	self.damageCt = 0
	self.damageCd = 0.1

	self:SetSlow()
end


function M:Refresh(data)
	M.super.Refresh(self)

	if data.speed_size ~= self.data.speed_size then
		self.data = data
		self:SetSlow()
	end
	self.data = data


end


function M:FrameUpdate(timeElapsed)
	self.durCt = self.durCt + timeElapsed
	if self.durCt >= self.data.duringTime then
		self:Exit() 
	end
end


function M:SetSlow(t)
	
	local heroHead = GameInfoCenter.GetHeroHead()
	self.heroHeadSpModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
	object = heroHead , skill = self , 
	modify_key_name = "speed" , 
	modify_type = 4 , 
	modify_value = self.data.speed_size , 
	} )

	--- 暂时这样写 ， 应该写成 自动修改的方式
	local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
	heroHead.vehicle:SetMinSpeed( now_speed  )
	heroHead.vehicle:SetMaxSpeed( now_speed  )
end


function M:Exit()
	self.heroHeadSpModifier:Exit()
	local heroHead = GameInfoCenter.GetHeroHead()
	if  heroHead then
		--- 暂时这样写 ， 应该写成 自动修改的方式
		local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
		heroHead.vehicle:SetMinSpeed( now_speed  )
		heroHead.vehicle:SetMaxSpeed( now_speed  )
	
	end
	Destroy(self.tx)

	self.object.skill[self.id] = nil

	M.super.Exit(self)
end

