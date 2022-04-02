-- 创建时间:2019-03-06

Vector2D = {}
Rad2Deg = 180 / math.pi
-- 转化为单位向量
function Vec2DNormalize(vec)
	local len = Vec2DLength(vec)
	if len > 0 then
		return {x=vec.x/len, y=vec.y/len}
	else
		return {x=0, y=0}
	end
end

-- 向量长度
function Vec2DLength(vec)
	return math.sqrt(vec.x*vec.x + vec.y*vec.y)
end
-- 长度的平方
function Vec2DDistanceSq(vec)
	return (vec.x*vec.x + vec.y*vec.y)
end
-- 向量夹角角度
--[[function Vec2DAngle2(vec1, vec2)
	local a = Vec2DDotMult(vec1, vec2)
	local b = Vec2DLength(vec1) * Vec2DLength(vec2)
	local r = math.acos( a/b ) * (180 / math.pi)
	return r
end--]]
--  向量夹角角度 , 范围 0~180 , 两向量的夹角求法： a.b = |a||b|cos(angle)  --> angle = acos( a.b / (|a||b|) )  --> 如果|a|==|b|==1 , angle = acos( a.b )
function Vec2DAngle2(from, to)
	local x1,y1 = from.x, from.y
	local d = math.sqrt(x1 * x1 + y1 * y1)

	if d > 1e-5 then
		x1 = x1/d
		y1 = y1/d
	else
		x1,y1 = 0,0
	end

	local x2,y2 = to.x, to.y
	d = math.sqrt(x2 * x2 + y2 * y2)

	if d > 1e-5 then
		x2 = x2/d
		y2 = y2/d
	else
		x2,y2 = 0,0
	end

	d = x1 * x2 + y1 * y2

	if d < -1 then
		d = -1
	elseif d > 1 then
		d = 1
	end

	return math.acos(d) * 57.29578
end

-- 向量角度 , 范围 0~360
function Vec2DAngle(vec)
	local r = Vec2DAngle2(vec , {x=1,y=0} ) --math.acos( Vec2DDotMult(vec, {x=1,y=0}) / Vec2DLength(vec) ) * (180 / math.pi)
	if vec.y < 0 then
		r = 360 - r
	end
	return r
end

-- 向量X积
-- ()
function Vec3DXMult(vec1, vec2)
	local x = vec1.y*vec2.z - vec1.z*vec2.y
	local y = vec1.z*vec2.x - vec1.x*vec2.z
	local z = vec1.x*vec2.y - vec1.y*vec2.x
	return {x=x,y=y,z=z}
end

-- 向量减法
function Vec2DSub(vec1, vec2)
	return {x=vec1.x-vec2.x, y=vec1.y-vec2.y}
end

-- 向量加法
function Vec2DAdd(vec1, vec2)
	return {x=vec1.x+vec2.x, y=vec1.y+vec2.y}
end

-- 向量点积
-- (返回第二个向量在第一个向量上的投影，向量可交换)
function Vec2DDotMult(vec1, vec2)
	return vec1.x*vec2.x + vec1.y*vec2.y
end

function Vec2DXMult(vec1, vec2)
	return vec1.x*vec2.y - vec2.x*vec1.y
end

-- 向量除标量
function Vec2DDivNum(vec, num)
	if num == 0 then
		return vec
	end
	return {x=vec.x/num, y=vec.y/num}
end

-- 向量乘标量
function Vec2DMultNum(vec, num)
	return {x=vec.x*num, y=vec.y*num}
end

function Vec2DTruncateRange(vec, min, max)
	local len = Vec2DLength(vec)
	if len > max then
		return {x=vec.x * max / len, y=vec.y * max / len}
	elseif len < min then
		return {x=vec.x * min / len, y=vec.y * min / len}
	else
		return {x=vec.x, y=vec.y}
	end
end

function Vec2DTruncate(vec, num)
	local len = Vec2DLength(vec)
	if len > num then
		return {x=vec.x * num / len, y=vec.y * num / len}
	else
		return {x=vec.x, y=vec.y}
	end
end

function Vec2DTruncateToLen(vec, len)
	local len1 = Vec2DLength(vec)
	if len1 > 0 then
		return {x=vec.x * len / len1, y=vec.y * len / len1}
	else
		return vec
	end
end

function Vec2DPerp(vec)
	local cosB = 0
	local sinB = -1
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=x1, y=y1}
end
function Vec2DReversePerp(vec)
	local cosB = 0
	local sinB = -1
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=-x1, y=-y1}
end
function Vec2DRotate(vec, a)
	local rad = math.rad(a)
	local cosB = math.cos(rad)
	local sinB = math.sin(rad)
	local x1 = vec.x * cosB - vec.y * sinB
	local y1 = vec.x * sinB + vec.y * cosB
	return {x=x1, y=y1}
end

function PointToWorldSpace(point, AgentHeading, AgentSide, AgentPosition)
	local x = point.x * AgentHeading.x + point.y * AgentSide.x + AgentPosition.x
	local y = point.x * AgentHeading.y + point.y * AgentSide.y + AgentPosition.y
	return {x=x ,y=y}
end