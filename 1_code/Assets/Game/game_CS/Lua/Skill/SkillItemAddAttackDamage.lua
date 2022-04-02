--道具GoodsItem上的技能（治疗）
local basefunc = require "Game/Common/basefunc"

SkillItemAddAttackDamage = basefunc.class(Skill)
local M = SkillItemAddAttackDamage


function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)


    self:Trigger()
end

function M:OnCD()

end

function M:Trigger()
    local seq = DoTweenSequence.Create()
    local all_heros = GameInfoCenter.GetAllHero()
    if self.fxs then
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
    end
    self.fxs = {}
    for k,v in pairs(all_heros) do
        local fx_pre = NewObject("CT_gj_buff",v.transform)
        fx_pre.transform.position = v.transform.position
        self.fxs[#self.fxs + 1] = fx_pre
        v.fsmLogic:addWaitStatusForUser("idel", {skillObject = self}, nil, self)
        local modifier = PropModifier.New(
            {
                id = self.id,
                skill = self,
                object = v,
                modify_key_name = "damage",
                modify_type = 3,
                modify_value = 100,
            })
        v.modifier["prop_modifier"] = v.modifier["prop_modifier"] or {}
        v.modifier["prop_modifier"][self.id] = modifier
        self.modifiers = self.modifiers or {}
        self.modifiers[#self.modifiers + 1] = modifier
    end
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
        self.fxs = {}
        for k,v in ipairs(self.modifiers) do
            v:Exit()
        end
        self.modifiers = {}
    end)

    --加血完成
    self:After()
end

function M:Finish()
    self:Exit()
end