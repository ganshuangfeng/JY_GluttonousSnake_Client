---- 集群移动的个体移动
local basefunc = require "Game/Common/basefunc"

BoidsMoveDriver = basefunc.class()
local C = BoidsMoveDriver

function C:Ctor( _game_obj , _data )
	--- 游戏obj
	self.game_obj = _game_obj

	--- 质量
	self.mass = _data and _data.mass or 1
	--- 最大速度 , 绝对值
	self.max_speed = _data and _data.max_speed or 5
	--- 当前速度,向量
	self.speed = _data and _data.speed or Vector2.New(0 , 0)

	--- 受力，向量列表 , key 自己定义一个名字，和别的不重复就行 ， value 是一个力向量
	self.force_vec = {}

end

--- 添加力
function C:set_force( _key , _force )
	self.force_vec[_key] = _force
end

function C:delete_force( _key )
	self.force_vec[_key] = nil
end

function C:Update( _dt )
	--- 计算合力
	local total_force = Vector2.New(0,0)
	for key,force in pairs( self.force_vec ) do
		total_force:Add( force )
	end

	--- 计算合力的加速度
	local a = total_force:Div( self.mass )

	--- 计算速度改变
	local dv = a:Mul( _dt )

	--- 限制速度最大绝对值
	self.speed:Add( dv )

	local speed_value = self.speed:Magnitude()
	if speed_value > self.max_speed then
		self.speed:Set( self.speed.x / speed_value * self.max_speed  , self.speed.y / speed_value * self.max_speed )
	end

	--- 改变位移
	local ds = Vector2.New( self.speed.x * _dt , self.speed.y * _dt )

	local pos = self.game_obj.transform.position
	local end_pos = Vector3.New( pos.x + ds.x , pos.y + ds.y , pos.z )

	self.game_obj.transform.position = end_pos

	--- 角度朝着速度的方向
	self.game_obj.transform.localEulerAngles = Vector3.New( 0 , 0 , -self.speed:Angle( Vector2.New( 0,1 ) ) )

end



return C