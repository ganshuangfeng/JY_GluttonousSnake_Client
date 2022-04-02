--[[
	--不允许通过抛消息的方式对技能进行操作，所有操作必须由SkillManager调用
]]

--[[
    data = {
        id = 1, --唯一标识
        type = 1, --技能类型
        release = { --释放者
            type = 1,
            id = 1,
        }
        receive = { --接收者，多个接收者，（外部传入或技能内部确定）
            type = 1,
            id = 1,
        }
        state = 1, --状态
        action = 1, --动作
    }
]]
--攻速buff
local basefunc = require "Game/Common/basefunc"

SkillAttackPowerBuff = basefunc.class(SkillBuffBase)
local M = SkillAttackPowerBuff
M.name = "SkillAttackPowerBuff"


function M.Create(data)
	return M.New(data)
end

function M:Ctor(data)
    SkillAttackPowerBuff.super.Ctor(self,data)
    self.grid_fx = "hero_attack_power_up_fx"
    self.tx_word = "2d_word_pz_3"
    self.hero_wait_fx = "hero_attack_power_up_fx_1"
end


function M:SetAttribute()
    for k,hero in pairs(self.effecters) do 
        if hero.base_damage then
            for i = 1,#hero.base_damage do 
                hero.base_damage[i] = hero.base_damage[i] * self.skill_cfg.change_value
            end
        end
    end
end

function M:ResetAttribute()
    for k,hero in pairs(self.effecters) do 
        if hero.base_damage then
            for i = 1,#hero.base_damage do 
                hero.base_damage[i] = hero.base_damage[i] / self.skill_cfg.change_value
            end
        end
    end
end