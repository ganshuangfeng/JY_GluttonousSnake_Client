-- 创建时间:2021-07-6 , 边界的力，避免出界

local basefunc = require "Game/Common/basefunc"

SteeringForBorder = basefunc.class(Steering)
local C = SteeringForBorder

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 最大的力
	self.force = 60
	-- 有力的距离范围
	self.force_check_dis = 6
	--- 屏幕宽高
	self.screen_size = {width = 108 , height = 230 }


	if parm and type(parm) == "table" then
		basefunc.merge(parm , self)
	end
end

function C:ComputeForce(vehicle, time_elapsed)

	---当前位置
	local he_force = {x = 0, y = 0}
	local now_pos = vehicle:Pos()
	local dir_x = (now_pos.x > 0) and 1 or -1
	local dir_y = (now_pos.y > 0) and 1 or -1


	local over_dis_x = dir_x * now_pos.x - (self.screen_size.width/2 - self.force_check_dis)
	if over_dis_x > 0 then
		--- 超出的距离
		he_force = Vec2DAdd( he_force , { x = -dir_x * over_dis_x / self.force_check_dis * self.force  , y = 0 } )
	end

	--- 超出的距离
	local over_dis_y = dir_y * now_pos.y - (self.screen_size.height/2 - self.force_check_dis)
	if over_dis_y > 0 then
		he_force = Vec2DAdd( he_force , { x = 0 , y = -dir_y * over_dis_y / self.force_check_dis * self.force } )
	end

	if he_force.x == 0 and he_force.y == 0 then
		return he_force
	end

	--- 判断合力，如果是和前进方向 叉乘大于0(因为满足右手螺旋定理)大于0的，两向量的夹角是逆时针
	local heading = vehicle:Heading()
	local side = vehicle:Side()
	local ret = Vec2DXMult( heading , he_force )
	if ret > 0 then
		side = { x = -side.x , y = -side.y }
	end

	return Vec2DMultNum(side , Vec2DLength( he_force ) )
end
