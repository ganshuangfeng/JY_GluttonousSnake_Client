local basefunc = require "Game/Common/basefunc"

SkillMonsterDetonate = basefunc.class(Skill)
local M = SkillMonsterDetonate

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range = self.object.attack_range or 4
    self.range2 = self.range * self.range
    self.damage = self.object.damage
    self.data.shouji_pre = self.data.shouji_pre or "BOOS_liusha_zadi"
end

function M:Exit(data)

	-- 自爆
	if self.object.hp < 1 then
		
		CSEffectManager.PlayBulletBoom({position = self.object.transform.position},self.data.shouji_pre)

		-- local ms = GameInfoCenter.GetHeroRangePos(self.object.transform.position,self.range)
		-- for i,v in ipairs(ms) do
		-- 	Event.Brocast("hit_hero",{damage = self.damage, id = ms.id})
		-- end

		local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
		if _obj then
			local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
		    if dis < self.range2 then
				Event.Brocast("hit_hero",{damage = self.damage, id = _obj.id})
		    end
		end

	end


    M.super.Exit(self)
end

