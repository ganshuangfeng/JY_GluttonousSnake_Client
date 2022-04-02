local basefunc = require "Game/Common/basefunc"

SkillHeroBuffAttackPower = basefunc.class(SkillHeroBuffBase)
local M = SkillHeroBuffAttackPower


function M:Ctor(data)
    self.super.Ctor(self,data)
    self.skill_cfg = data.cfg
    self.data = data
    self.grid_fx = "hero_attack_power_up_fx"
    self.tx_word = "2d_word_pz_3"
    self.hero_wait_fx = "hero_attack_power_up_fx_1"
end

--自己的逻辑(继承)------
function M:SetAttribute()
    for k,hero in pairs(self.effecters) do
        local modifier = PropModifier.New(
            {
                id = self.id,
                skill = self,
                object = hero,
                modify_key_name = "damage",
                modify_type = 3,
                modify_value = 100,
            })
        hero.modifier["prop_modifier"] = hero.modifier["prop_modifier"] or {}
        hero.modifier["prop_modifier"][self.id] = modifier
    end
end

function M:ResetAttribute()
    for k,hero in pairs(self.effecters) do
        if hero.modifier["prop_modifier"] and hero.modifier["prop_modifier"][self.id] then
            hero.modifier["prop_modifier"][self.id] = nil
        end
    end
end