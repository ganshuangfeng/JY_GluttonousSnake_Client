--增加200点最大生命值上限
local basefunc = require "Game/Common/basefunc"

SkillItemHpMaxUp = basefunc.class(Skill)
local M = SkillItemHpMaxUp


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

    local fx_pre = NewObject("ZL_zhiliao",GameObject.Find("3DNode/map").transform)
    fx_pre.transform.position = GameInfoCenter.GetHeroHead().transform.position
    fx_pre.transform.parent = GameInfoCenter.GetHeroHead().buff_node
    self.fxs[#self.fxs + 1] = fx_pre

    seq:AppendInterval(1)
    seq:AppendCallback(function()
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
        self.fxs = {}
    end)
    
    GameInfoCenter.AddPlayerHpMax(200)

    --完成
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