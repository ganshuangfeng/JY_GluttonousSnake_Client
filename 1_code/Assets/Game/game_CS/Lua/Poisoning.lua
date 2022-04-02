--不同单位的每层中毒单独计算
--每隔几秒显示一次伤害特效
local basefunc = require "Game/Common/basefunc"

Poisoning = basefunc.class(Skill)
local M = Poisoning

function M:Ctor(data)
	M.super.Ctor( self , data )
    self.data = data
end


function M:Init(data)
	M.super.Init( self )

	self.durCt = 0

	self.damageCt = 0
	self.damageCd = 0.5

	self.tx = NewObject("DY_shouji")
	-- local scale = self.object.config.size
	self.tx.transform.parent = self.object.transform
	self.tx.transform.localPosition = Vector3.zero
	self:AddDamageData(data)
	-- self.tx.transform.localScale = Vector3.New(scale,scale,scale)
end


function M:Refresh(data)
	M.super.Refresh(self)
	self:AddDamageData(data)
end


function M:FrameUpdate(timeElapsed)
	self.damageCt = self.damageCt + timeElapsed

	if self.damageCt >= self.damageCd then
		local all_damage = 0
		for k , v in pairs(self.DamageData) do
			if v.duringTime - self.damageCd >= 0 then
				v.duringTime = v.duringTime - self.damageCd
				all_damage = all_damage + v.damage
			else
				local d = v.damage * v.duringTime / self.damageCd
				all_damage = all_damage + math.floor(d)
				v.duringTime = v.duringTime - self.damageCd
			end
		end
		self:HitDamage(all_damage)

		for k , v in pairs(self.DamageData) do
			if v.duringTime <= 0 then
				self.DamageData[k] = nil
			end
		end
	end
end


function M:HitDamage(all_damage)
	if all_damage > 0 and IsEquals(self.object) and self.object.hp and self.object.hp > 0 then
		self.object:DamageTxt(all_damage,"Damage_Green")
		Event.Brocast("hit",{id = self.object.id , damage = all_damage , extra=true})
	end
	self.damageCt = self.damageCt - self.damageCd
end


function M:Exit()

	-- self:HitDamage(self.damageCt)

	Destroy(self.tx)
	if IsEquals(self.object) and self.object.isLive then
		self.object.skill[self.id] = nil
	end
	self.DamageData = {}
	M.super.Exit(self)
end

function M:AddDamageData(data)
	self.DamageData = self.DamageData or {}
	data.from_id = data.from_id or 9999
	self.DamageData[data.from_id] = data
end

