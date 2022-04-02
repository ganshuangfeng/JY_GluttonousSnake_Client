-- 创建时间:2021-07-01

local basefunc = require "Game/Common/basefunc"

SteeringForFlee = basefunc.class(Steering)

function SteeringForFlee:Ctor(parm)
	SteeringForFlee.super.Ctor(self,parm)

	-- 安全距离
	self.safeDistacne = 8

	-- 最大的力
	self.max_force = 5

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForFlee:ComputeForce(vehicle)
	local _t = {x=0, y=0}
	local my_pos = vehicle:Pos()

	if self.TargetPos then
		for k,v in pairs(self.TargetPos) do
			repeat
				local tar_pos = v

				if math.abs(my_pos.x - tar_pos.x) > self.safeDistacne or math.abs(my_pos.y - tar_pos.y) > self.safeDistacne then
					break
				end

				local ToTarget = Vec2DSub(tar_pos , my_pos)

				-- 计算到目标位置的距离
				local dist = Vec2DLength(ToTarget)

			    if dist < self.safeDistacne then
			        --_t = Vec2DAdd( _t, Vec2DMultNum(Vec2DSub(vehicle:Pos(), v), 5) )
			        local normalize = Vec2DNormalize(ToTarget)
			        _t = Vec2DAdd( _t, Vec2DMultNum( { x = -normalize.x , y = -normalize.y } , ((self.safeDistacne - dist) / self.safeDistacne ) * self.max_force ) )

			    end

			until true
		end
	end
    return _t
end