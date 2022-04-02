------- 技能辅助的函数

--- 获取子弹的 伤害列表
--[[
	如果子弹里面有伤害数值，自己用子弹的，如果没有就用技能的实体对象的
--]]
function GetBulletDamageList( skillObj , bullet_config )
	local damageList = {}

	local baseDamage = ModifierSystem.GetObjProp( skillObj.object , "damage" )

	if bullet_config and bullet_config.damage and type(bullet_config.damage) == "table" then
		for key,data in pairs(bullet_config.damage) do
			--- 是否加 基础值，如果是 字符串，并以#开始，则是固定值，否则就要加基础值
			--固定值
			local isAddBaseDamage = true
			local tarNum = tonumber( data )

			if type(data) == "string" then

				if string.find( data , "^#" ) then
					isAddBaseDamage = false
					local num = tonumber( string.sub( data , 2 , -1 ) )
					tarNum = num
				end
			end

			----------
			local endVaule = 0

			if isAddBaseDamage then
				endVaule = baseDamage + tarNum
			else
				endVaule = tarNum
			end

			table.insert( damageList , endVaule )
		end
	end
	--- 没有 就拿技能的实体对象的伤害
	if not next(damageList) then
		damageList = { GetSkillOneDamage( skillObj , "damage_bei" , "damage_fix" ) }

	end

	return damageList
end

--- 获取一个 技能对象的 伤害值
function GetSkillOneDamage( skillObj , damageBeiKey , damageFixKey )
	local objDamage = ModifierSystem.GetObjProp( skillObj.object , "damage" )

    local damageBei = skillObj.data[damageBeiKey] or 0
    local damageFix = skillObj.data[damageFixKey] or 0
    
    -- print("<color=yellow>xxx------obj_damage</color>" , objDamage , damageBei , damageFix )

    return  objDamage * damageBei + damageFix 

end
