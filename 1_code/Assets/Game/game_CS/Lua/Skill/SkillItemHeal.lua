--道具GoodsItem上的技能（治疗）
local basefunc = require "Game/Common/basefunc"

SkillItemHeal = basefunc.class(Skill)
local M = SkillItemHeal


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
        v.fsmLogic:addWaitStatusForUser("idel", {skillObject = self}, nil, self)
    end

    local fx_pre = NewObject("CT_jiaxue_huifu",GameInfoCenter.GetHeroHead().transform)
    self.fxs[#self.fxs + 1] = fx_pre

    seq:AppendInterval(1)
    seq:AppendCallback(function()
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
        self.fxs = {}
    end)
    
    GameInfoCenter.AddPlayerHp(300 + TechnologyManager.HealUp())

    --加血完成
    self:After()
end

function M:Finish()
    self:Exit()
end

function M:Exit()
    if self.object and self.object.skill and self.object.skill[self.id] then
        self.object.skill[self.id] = nil
    end
    M.super.Exit(self)
end