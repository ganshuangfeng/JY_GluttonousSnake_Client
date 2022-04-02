----- 英雄的超能时刻技能 

local basefunc = require "Game/Common/basefunc"

SkillPlayerGoldRush = basefunc.class(Skill)
local M = SkillPlayerGoldRush
local defaultEffectTime = 20
function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data

    self.heroHeadSpModifier = nil
    self.effectTime = defaultEffectTime + TechnologyManager.GoldRushTimeUp()
    self.effectCount = 0
    self.data.cd = 0.5
    self.max_progress = 100
    self.progress = GameInfoCenter.heroHeadSkillProgress or 0
end

function M:Init(data)
    M.super.Init(self)

    self.data = data or self.data
    self:InitSkillPreTblUI()

    self:CD()
end

function M:InitSkillPreTblUI()
    --创建预制体
    local parent =  CSPanel.goldRushNode or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("GoldRushPanel",parent)
    LuaHelper.GeneratingVar(self.skillPre.transform,self)
    self.jb_node.gameObject:SetActive(false)
end


function M:Ready(data)
    M.super.Ready(self)

    self:Trigger()
end


function M:Finish(data)
    if ExtendSoundManager.oldAudioName ~= audio_config.cs.gold_rush_bgm.audio_name then
        ExtendSoundManager.PlayOldBGM()
    end
    self.progress_fx.gameObject:SetActive(false)
    M.super.Finish(self)
    self:SetMonsterGoldRushState(false)
    self.effectTime = defaultEffectTime + TechnologyManager.GoldRushTimeUp()
    self:DelTX()
    if self.stateVec then
        for key, obj in pairs(self.stateVec) do
            obj:Stop()
        end
    end
    self.jb_node.gameObject:SetActive(false)
    self.cur_get_jb = 0

    self:ResetData()

    ---- 状态重新回到 cd状态
    self:CD()
end

function M:CD()
    M.super.CD(self,dt)
    self:OnHeroHeadSkillProgressChange()
end

function M:OnCD(dt)
    if self.skillState == SkillState.cd then
        if self.progress >= self.max_progress then
            self:Active()
        end
    end
end

function M:Active()
    M.super.Active(self)
    self:Ready()
end

--------update中持续做的事--------------------

function M:Trigger()
    self.super.Trigger(self)
    self.progress_fx.gameObject:SetActive(true)
    GameInfoCenter.heroHeadSkillProgress = 0
    self.progress = 0
    
    self:SetMonsterGoldRushState(true)
    self:AddTX()
    ExtendSoundManager.PlaySceneBGM(audio_config.cs.gold_rush_bgm.audio_name)
end

--触发中
function M:OnTrigger(dt)
    if self.skillState == SkillState.trigger then
        self.effectTime = self.effectTime - dt
        if IsEquals(self.UI_fx) then
            self.UI_fx.transform.localPosition = CSModel.GetUITo3DPoint(Vector3.zero)
        else
            self.UI_fx = nil
        end
        self:RefreshSkillTblOnTrigger(dt)
        if self.effectTime > 0 then
            self:SetMonsterGoldRushState(true)
        else
            self:After()
        end
    end
end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
    self.lister["HeroHeadSkillProgressChange"] = basefunc.handler(self,self.OnHeroHeadSkillProgressChange)
    self.lister["ui_game_get_jin_bi_msg"] = basefunc.handler(self,self.on_ui_game_get_jin_bi_msg)
end


--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

--增加和检测特效存不存在
function M:AddTX()
    --头和尾巴
    local heroHead = GameInfoCenter.GetHeroHead()

    if not self.tx_tou then 
        local data = {}
        local tx = NewObject("CN_huangse_YX",heroHead.transform)
        tx.transform.localScale = Vector3.New(0.6,0.6,0.6)
        self.tx_tou = tx
    end

    --身体
    self.tx_shenti = self.tx_shenti or {}
    local all_hero = GameInfoCenter.GetAllHero()

    for key , h in pairs(all_hero) do
        --local h = HeroManager.GetHeroByLocation(i)
        if not self.tx_shenti[h.data.id] then
            local tx_name = "CN_huangse_YX"
            local tx = NewObject(tx_name,h.body)
            self.tx_shenti[h.data.heroId] = tx
            tx.transform.localPosition = Vector3.New(0,0,0)
            tx.transform.localScale = Vector3.New(0.46749,0.46749,0.46749)
        end
    end
    self.UI_fx = NewObject("CN_CNSK_ZITI",MapManager.GetMapNode())
    CSEffectManager.PlayAllScreenEffect("Boss_fighting_02")
    GameObject.Destroy(self.UI_fx,2)
end

function M:DelTX()
    if self.tx_tou then
        GameObject.Destroy(self.tx_tou)
        self.tx_tou = nil
    end
    if self.tx_wei then
        GameObject.Destroy(self.tx_wei)
        self.tx_wei = nil
    end
    if self.tx_shenti then
        for k , v in pairs(self.tx_shenti) do
            if IsEquals(v) then
                GameObject.Destroy(v)
            end
        end
        self.tx_shenti = {}
    end
    CSEffectManager.CloseAllScreenEffect("Boss_fighting_02")
end

function M:on_ui_game_get_jin_bi_msg(jb)
    if self.skillState == SkillState.trigger then
        self.cur_get_jb = self.cur_get_jb or 0
        self.cur_get_jb = self.cur_get_jb + jb
        self.jb_txt.text = self.cur_get_jb
    end
end

function M:OnHeroHeadSkillProgressChange(data)
    if data and data.progress then
        if data.progress > self.progress then
            local fx = NewObject("CT_NL_lg_L",self.object.transform)
            fx.transform.localScale = Vector3.New(0.46749,0.46749,0.46749)
            self.progress_fx.gameObject:SetActive(true)
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(1)
            seq:AppendCallback(function()
                if self.skillState ~= SkillState.trigger then
                    self.progress_fx.gameObject:SetActive(false)
                end
                if IsEquals(fx.gameObject) then
                    Destroy(fx.gameObject)
                end
            end)            
        end
        self.progress = data.progress
    end
    if self.skillState == SkillState.trigger then
        GameInfoCenter.heroHeadSkillProgress = 0
        if self.progress > 0 then
            self.progress = 0
            self.effectTime = self.effectTime + 1
            self:RefreshSkillTblOnTrigger()
        end
    else
        if self.progress <= 0 then
            self.progress_fx.gameObject:SetActive(false)
        end
        if self.progress > self.max_progress then
            self.progress = self.max_progress
            GameInfoCenter.heroHeadSkillProgress = self.progress
        end
        self:RefreshSkillTbl()
    end
end

local max_width = 810
local height = 36
function M:RefreshSkillTbl()
    self.progress_img.transform:GetComponent("RectTransform").sizeDelta = {
        x = (self.progress / self.max_progress) * max_width,
        y = height,
    }
end

function M:RefreshSkillTblOnTrigger(dt)
    self.cur_get_jb = self.cur_get_jb or 0
    self.jb_node.gameObject:SetActive(true)
    self.jb_txt.text = self.cur_get_jb
    self.progress_img.transform:GetComponent("RectTransform").sizeDelta = {
        x = (self.effectTime /( defaultEffectTime + TechnologyManager.GoldRushTimeUp())) * max_width,
        y = height,
    }
end

function M:Exit(data)
    if self.skillPre then
        Destroy(self.skillPre)
        self.skillPre = nil
    end
    self:DelTX()
    M.super.Exit(self,data)
end

function M:SetMonsterGoldRushState(bool)
    local monsters = GameInfoCenter.GetAllMonsters()
    for k,monster in pairs(monsters) do
        if bool then
            if not monster.goldRushState then
                monster:SetGoldRushState(true,{drop_frequence = self.data.drop_frequence,gold_value = self.data.gold_value})
            end
        else
            monster:SetGoldRushState(false)
        end
    end
end