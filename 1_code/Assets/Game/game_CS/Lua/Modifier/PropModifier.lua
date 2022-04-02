
local basefunc = require "Game/Common/basefunc"


PropModifier = basefunc.class()
local C = PropModifier

function C:Ctor( data )

	self.id = data.id
	--- 拥有者
	self.object = data.object
	---- 创建的技能
	self.skill = data.skill
	----
	self.config = data

	---- 类型
	self.type = "prop_modifier"

	---------------------------- 通用属性 ↑

	--------------- 特有属性
	--- 编辑的属性的字段名
	self.modify_key_name = data.modify_key_name
	--- 编辑的类型
	self.modify_type = data.modify_type
	--- 编辑多少值
	self.modify_value = data.modify_value
	--- 百分比编辑模式 的 依赖的值的类型
	self.percent_base_type = data.percent_base_type
	--- 百分比编辑模式 的 依赖的值
	self.percent_base_value = data.percent_base_value
end

function C:Init()

	---- 这个到时候写一个函数，加到object的 modifier中去
	self.object.modifier = self.object.modifier or {}
	self.object.modifier[self.type] = self.object.modifier[self.type] or {}
	local tar_data = self.object.modifier[self.type]
	tar_data[#tar_data + 1] = self


end

function C:Exit()
	--- 从object 修改器里面删除
	self.object.modifier = self.object.modifier or {}
	self.object.modifier[self.type] = self.object.modifier[self.type] or {}
	local tar_data = self.object.modifier[self.type]
	for key,data in pairs(tar_data) do
		if data == self then
			tar_data[key] = nil
			break
		end
	end
end

function C:work( _prop_type , _real_prop_value  )
	local real_prop_value = _real_prop_value

	---- 值针对 这个属性key的有用
	if self.modify_key_name ~= _prop_type then
		return real_prop_value
	end


	if self.modify_type == 1 then
		---- 固定值
		real_prop_value = _real_prop_value + self.modify_value
	elseif self.modify_type == 2 then
		---- 百分比
		local base_value = real_prop_value
		--- 可以用其他数据作为 基础值 加百分比
		if self.percent_base_value and type(self.percent_base_value) == "number" then
			base_value = self.percent_base_value
		elseif self.percent_base_type and self.object[self.percent_base_type] and type(self.object[self.percent_base_type]) == "number" then
			base_value = self.object[self.percent_base_type]     ----- PS: modifier 里面不能再调 用 modifier 的获取值，可能会死循环
		end

		real_prop_value = real_prop_value + base_value * ( self.modify_value / 100 )
	elseif self.modify_type == 3 then
		---- 设置
		real_prop_value = self.modify_value
	elseif self.modify_type == 4 then
		--直接翻倍
		real_prop_value = real_prop_value * (self.modify_value / 100)
	end
	
	
	return real_prop_value
end
