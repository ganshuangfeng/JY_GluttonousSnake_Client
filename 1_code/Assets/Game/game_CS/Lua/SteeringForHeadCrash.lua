-- 创建时间:2019-03-07
-- 运动方式： 蛇头碰撞，

local basefunc = require "Game/Common/basefunc"

SteeringForHeadCrash = basefunc.class(Steering)
local C = SteeringForHeadCrash

function C:Ctor(parm)
	C.super.Ctor(self,parm)

	--- 被撞后的排斥方向 , 向量
	self.crash_angle_dir = nil

	--- 排斥力
	self.force = 8

	--- 碰撞距离
	self.dis = 0.05

	--- 持续时间
	self.reject_time = 0.01
	self.reject_time_count = self.reject_time

	if parm then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

	self.runA = 0
end

function C:set_crash_angle(_angle)
	self.crash_angle_dir = _angle
	self.reject_time_count = 0
end

---- 检查蛇头的位置距离自己是否
function C:check_head_crash(_vehicle)
	local head_pos = GameInfoCenter.GetHeroHeadAveragePos()
	local my_pos = _vehicle:Pos()

	---先简单判断
	if math.abs( my_pos.x - head_pos.x ) > self.dis or math.abs( my_pos.y - head_pos.y ) > self.dis then
		return false
	end

	local angle = Vec2DSub(my_pos , head_pos ) 
	print("<color=green>xxx---------------------check_head_crash__true</color>")
	return true , angle
end

function C:ComputeForce( _vehicle , _dt )
	--- 上次碰撞已经完毕
	if self.reject_time_count > self.reject_time then
		local is_crash , angle_dir = self:check_head_crash(_vehicle)

		if is_crash and angle_dir then
			
			print("xxx----------------------------crash___angle:" , angle_dir)
			self:set_crash_angle( Vec2DNormalize( angle_dir ) )
			_vehicle:SetMaxSpeed(self.force)
		else
			_vehicle:SetMaxSpeed(5)
			return { x = 0 , y = 0 }
		end
	end
	self.reject_time_count = self.reject_time_count + _dt

	if self.crash_angle_dir then
		print("<color=red>xxx---------------------check_head_crash__true22222 222</color>")
		return Vec2DMultNum(  self.crash_angle_dir , self.force )
	end
	return { x = 0 , y = 0 }
end
