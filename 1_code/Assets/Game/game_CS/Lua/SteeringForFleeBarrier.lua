-- 创建时间:2021-07-08
---- 躲避障碍


local basefunc = require "Game/Common/basefunc"

SteeringForFleeBarrier = basefunc.class(Steering)
local C = SteeringForFleeBarrier

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 安全距离 , 的平方
	self.safeDistacne = 1.5
	self.safeDistacneSq = self.safeDistacne * self.safeDistacne

	-- 最大的力
	self.max_force = 30

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function C:ComputeForce(vehicle)
	local he_force = {x=0, y=0}
	local my_pos = vehicle:Pos()
	local heading = vehicle:Heading()
	local side = vehicle:Side()

	local total_barrier = {}

	local out_x_left = my_pos.x - self.safeDistacne
	local out_x_right = my_pos.x + self.safeDistacne
	local out_y_down = my_pos.y - self.safeDistacne
	local out_y_up = my_pos.y + self.safeDistacne

	--print("xxx---------------------total_barrier:",#total_barrier)

	for k,v in pairs(total_barrier) do
		repeat
			local tar_pos = v
			
			--if math.abs(tar_pos.x - my_pos.x) > self.safeDistacne or math.abs(tar_pos.y - my_pos.y) > self.safeDistacne then
			--	break
			--end

			if tar_pos.x > out_x_right or tar_pos.x < out_x_left or tar_pos.y > out_y_up or tar_pos.y < out_y_down then
				break
			end

			local ToTarget = Vec2DSub( my_pos , tar_pos )
			-- 计算到目标位置的距离
			local distSq = Vec2DDistanceSq(ToTarget)

		    if distSq < self.safeDistacneSq then
		        --he_force = Vec2DAdd( he_force, Vec2DMultNum(Vec2DSub(vehicle:Pos(), v), 5) )
		        --local normalize = Vec2DNormalize(ToTarget)
		        he_force = Vec2DAdd( he_force, Vec2DMultNum( ToTarget , (self.safeDistacneSq - distSq) / self.safeDistacneSq *  self.max_force ) )

		    end

		until true
	end

	if he_force.x ~= 0 or he_force.y ~= 0 then

		local ret = Vec2DXMult( heading , he_force )
		if ret > 0 then
			side = { x = -side.x , y = -side.y }
		end

		return Vec2DMultNum(side , Vec2DLength( he_force ) )
	end

    return he_force
end