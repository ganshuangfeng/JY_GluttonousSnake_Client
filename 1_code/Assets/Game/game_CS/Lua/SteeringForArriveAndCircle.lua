-- 创建时间:2019-03-07
--- 移动到 并且 旋转

local basefunc = require "Game/Common/basefunc"

SteeringForArriveAndCircle = basefunc.class(Steering)
local C = SteeringForArriveAndCircle

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	-- 到达区半径
	self.radius = parm and parm.radius or 5

	self.force = 10000

	--- 转目标圈数
	self.total_angle = 360
	self.now_angle = 0

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

end

function C:setTargetPos(_pos , vehicle)
	if _pos then
		C.super.setTargetPos(self,_pos)

		--vehicle:set_stop_steer_sin(false)
	else
		--vehicle:set_stop_steer_sin(true)
		self.TargetPos = nil
	end

end

function C:ComputeForce(vehicle)
	if not self.TargetPos then
		
		return {x=0, y=0}
	end
	print("<color=red> xxxx--------------circleMove ComputeForce </color>")
	local ToTarget = Vec2DSub(self.TargetPos , vehicle:Pos())
	
	-- 计算到目标位置的距离
	local dist = Vec2DLength(ToTarget)
	
	--- 偏转角度 , 大于半径的两倍角度就是指向目标点，从两倍到0就是从 指向到背向的过程，当在半径长度时，就是指向圆弧上的方向
	local offset_angle = (dist - self.radius) / self.radius * 90
	if offset_angle > 90 then
		offset_angle = 90
	end

	--- 0 到 180 ， 很远是0度 (相对于目标点到当前点的向量的角度) 0度是吸引 , 到达目标半径是 90 ，180度是排斥
	local tar_rotate_angle = 90 - offset_angle


	--- 角度偏转太大得限制一下
	local heading = vehicle:Heading()
	local tar_head_change_angle = Vec2DAngle2( heading , Vec2DRotate(ToTarget , tar_rotate_angle) )
	if tar_head_change_angle > 90 then
		tar_rotate_angle = tar_rotate_angle - ( tar_head_change_angle - 90 )
	end
	
	---- 从0到180度转成 向心力 2倍向心力 到 0
	local nowSpeed = vehicle:Speed()

	--local circleForce = vehicle.m_dMass * nowSpeed * nowSpeed / self.radius
	--local tarForce = (180 - tar_rotate_angle ) / 180 * 2 * circleForce


	--return Vec2DMultNum( Vec2DRotate( heading , tar_head_change_angle)  , self.force )

	return Vec2DMultNum( Vec2DNormalize( Vec2DRotate(ToTarget , tar_rotate_angle) )  , self.force * nowSpeed  )
end