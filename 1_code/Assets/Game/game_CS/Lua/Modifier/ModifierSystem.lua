---- modifier 系统  ,  修改器系统

local basefunc = require "Game/Common/basefunc"


ModifierSystem = {}
local C = ModifierSystem


--- 获得 属性值 ，没有buff 的时候就直接是 at 属性
function C.GetObjProp( _obj , _prop_type , _org_value )


	local org_value = _org_value
	if not org_value then
		org_value = _obj[_prop_type]
	end
	if not org_value then
		error("xxxx--------get_obj_prop no org_value:" .. _prop_type )
	end

	local real_value = org_value

	---- 应用 修改属性 modifier
	if _obj.modifier and _obj.modifier[ "prop_modifier" ] then
		for key,modifier_obj in ipairs( _obj.modifier[ "prop_modifier" ] ) do
			real_value = modifier_obj:work( _prop_type , real_value )
		end
	end

	return real_value
end

---- 获得一个 对象的 技能的 暴击率 or 连击率
function C.GetSkillPropValue(  _skill_obj , _prop_type , _org_value )
	local org_value = _org_value
	if not org_value then
		org_value = _skill_obj.buff_prop[_prop_type] or 0
	end

	if not org_value then
		error("xxxx--------get_skill_buff_value no org_value:" , _prop_type )
	end

	local real_value = org_value

	local _obj = _skill_obj.object

	---- 应用 modifier
	if _obj and _obj.modifier and _obj.modifier[ "skill_prop_modifier" ] then
		for key,buff_obj in ipairs( _obj.modifier[ "skill_prop_modifier" ] ) do
			real_value = buff_obj:work( _skill_obj , _prop_type , real_value )
		end
	end
	
	return real_value
end
