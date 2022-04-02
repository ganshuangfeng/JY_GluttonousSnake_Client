local basefunc = require "Game/Common/basefunc"

SkillHeroSuperHealAttack = basefunc.class(Skill)
local M = SkillHeroSuperHealAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)

    --self.data = data or self.data
    self:InitData(data)

    self:CD()
end

---- 初始化数据，refresh 也会调用这个
function M:InitData(data)
    M.super.InitData(self , data)

    self.data = data or self.data
end

function M:Exit(data)
    if self.fxs then
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
        self.fxs = nil
    end
    M.super.Exit(self)
end

function M:Ready(data)
    M.super.Ready(self)
    self:Trigger()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end
    local seq = DoTweenSequence.Create()
    local all_heros = GameInfoCenter.GetAllHero()
    if self.fxs then
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
    end
    self.fxs = {}
    for k,v in pairs(all_heros) do
        local fx_pre = NewObject("ZL_zhiliao",GameObject.Find("3DNode/map").transform)
        fx_pre.transform.position = v.transform.position
        self.fxs[#self.fxs + 1] = fx_pre
        v.fsmLogic:addWaitStatusForUser("idel", {skillObject = self}, nil, self)
    end
    seq:AppendInterval(1)
    seq:AppendCallback(function()
        for k,v in ipairs(self.fxs) do
            Destroy(v)
        end
        self.fxs = {}
    end)
    
    GameInfoCenter.AddPlayerHp(1000)

    --加血完成
    self:After()
end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
    self.lister["ExtraSkillTrigger"] = basefunc.handler(self,self.OnExtraSkillTrigger)
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

--自己的逻辑------
function M:OnExtraSkillTrigger(data)
    if self.object and self.object.data then
        if data.hero_color == self.object.config.hero_color then
            self:Ready()
        end
    end
end