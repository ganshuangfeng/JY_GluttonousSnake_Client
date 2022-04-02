-- 创建时间:2021-07-01

local basefunc = require "Game/Common/basefunc"

SteeringForDisperse = basefunc.class(Steering)

function SteeringForDisperse:Ctor(parm)
	SteeringForDisperse.super.Ctor(self,parm)

	-- 最小相距距离
	self.minApartDistance = 3

	--- 最大的力
	self.max_force = 10

	-- 雷达
	self.radar = nil

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForDisperse:ComputeForce(vehicle)
	if not self.radar then
		return
	end
	local array = self.radar(vehicle:Pos(), self.minApartDistance)
	if not array or #array == 0 then
		return
	end

	local my_pos = vehicle:Pos()

	local expectForce = {x=0, y=0}
	for i = 1, #array do
		repeat

			local tar_pos = array[i]:Pos()

			if math.abs(my_pos.x - tar_pos.x) > self.minApartDistance or math.abs(my_pos.y - tar_pos.y) > self.minApartDistance then
				break
			end

			local ToTarget = Vec2DSub( my_pos , tar_pos )

			local dis = Vec2DLength( ToTarget )
	        if (array[i].ID ~= vehicle.ID
	            and dis < self.minApartDistance ) then

	        	local normalize = Vec2DNormalize(ToTarget)

	            expectForce = Vec2DAdd(expectForce, Vec2DMultNum( normalize , self.max_force ) ) --(self.minApartDistance - dis)/self.minApartDistance * self.max_force ) )

	        end

    	until true
    end
	return expectForce -- Vec2DMultNum(expectForce, 10)
end
