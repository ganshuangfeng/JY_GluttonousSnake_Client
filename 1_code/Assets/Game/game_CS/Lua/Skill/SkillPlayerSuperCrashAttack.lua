----- 英雄的 冲撞技能 , 加到蛇头上

local basefunc = require "Game/Common/basefunc"

SkillPlayerSuperCrashAttack = basefunc.class(Skill)
local M = SkillPlayerSuperCrashAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data


    self.heroHeadSpModifier = nil
    self.effectTime = 5
    self.effectCount = 0
    self.data.cd = 0.5
    self.max_progress = 100
    self.max_storage = 5
    ---- 要加的标签的名称
    self.addTagName = "crashState"
    self.storage = 0
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
    local parent =  CSPanel.st_skill_node or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillHeadCrash",parent)
    self.skillPre.gameObject:SetActive(true)
    self.skillPre.transform:Find("@icon_img"):GetComponent("Button").onClick:AddListener(function()
        if self.skillState ~= SkillState.active then return end
        self:Trigger()
    end)

    LuaHelper.GeneratingVar(self.skillPre.transform,self)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
end


function M:Ready(data)
    M.super.Ready(self)

    --print( "xxxx---------------Ready:1" ,self.skillState )
    self:Trigger()
    --print( "xxxx---------------Ready:2" , self.skillState )
end


function M:Finish(data)
    M.super.Finish(self)

    if self.stateVec then
        for key, obj in pairs(self.stateVec) do
            obj:Stop()
        end
    end

    self:ResetData()

    ---- 状态重新回到 cd状态
    self:CD()
end

function M:CD()
    M.super.CD(self,dt)
    self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(true)
    self.skillPreTbl.click_cffect_node.gameObject:SetActive(false)
    self:OnHeroHeadSkillProgressChange()
end

function M:OnCD(dt)
    if self.skillState == SkillState.cd then
    -- M.super.OnCD(self,dt) 
    -- self.skillPreTbl.rocket_skill_img.fillAmount = (self.data.cd - self.cd) / self.data.cd
        if self.storage > 0 then
            self:Active()
        end
    end
end

function M:Active()
    M.super.Active(self)
    self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(false)
    self.skillPreTbl.click_cffect_node.gameObject:SetActive(true)
end

--------update中持续做的事--------------------

function M:Trigger()
    self.super.Trigger(self)
    self.progress  = self.progress - self.max_progress
    self:OnHeroHeadSkillProgressChange()
end

--触发中
function M:OnTrigger(dt)
    --print("xxx----------crash_skill onTrigger1 " , self.skillState)
    if self.skillState ~= SkillState.trigger then
        return
    end
    --print("xxx----------crash_skill onTrigger")
    --- 创建 修改器
    if not self.heroHeadSpModifier then
        self:AddTX()
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()

        self.heroHeadSpModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
            object = heroHead , skill = self , 
            modify_key_name = "speed" , 
            modify_type = 2 , 
            modify_value = 0 , 
        } )

        --- 暂时这样写 ， 应该写成 自动修改的方式
        local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
        heroHead.vehicle:SetMinSpeed( now_speed  )
        heroHead.vehicle:SetMaxSpeed( now_speed  )
       -- heroHead

        ---- 加一个免疫 冰冻，驱散冰冻的 标签
        AddTag( heroHead , "immune_stationary" )
        for key,obj in pairs(all_hero) do
            AddTag( obj , "immune_stationary" )
        end
        AddTag( heroHead , "break_stationary" )
        for key,obj in pairs(all_hero) do
            AddTag( obj , "break_stationary" )
        end
        self.object.state = "invincible"

        ---- 加上特殊标签
        AddTag( heroHead , self.addTagName ) 
    end
    if self.tx_tou then
        self.tx_tou.transform.position = GameInfoCenter.GetHeroHead().transform.position
    end

    self.effectCount = self.effectCount + dt
    self.skillPreTbl.skill_mask_img.gameObject:SetActive(true)
    self.skillPreTbl.skill_mask_img.fillAmount = 1 - self.effectCount / self.effectTime
    self.cut_down_txt.text = math.floor(self.effectTime - self.effectCount + 1)
    self.cut_down_txt.gameObject:SetActive(true)
    if self.effectCount > self.effectTime then
        self.effectCount = 0
        self.heroHeadSpModifier:Exit()
        self.heroHeadSpModifier = nil
        self.cut_down_txt.gameObject:SetActive(false)
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()
        -- 暂时这样写 ， 应该写成 自动修改的方式
        local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
        --print( string.format( "<color=yellow>xxxx------------------------skill trigger xxxxxxxxxx now_speed22 : %s</color>" , now_speed) )
        heroHead.vehicle:SetMinSpeed( now_speed  )
        heroHead.vehicle:SetMaxSpeed( now_speed  )

        DeleteTag( heroHead , "immune_stationary" )
        for key,obj in pairs(all_hero) do
            DeleteTag( obj , "immune_stationary" )
        end

        DeleteTag( heroHead , "break_stationary" )
        for key,obj in pairs(all_hero) do
            DeleteTag( obj , "break_stationary" )
        end
        ---- 加上特殊标签
        DeleteTag( heroHead , self.addTagName ) 
        if self.object.state == "invincible" then
            self.object.state = "normal"
        end

        self:After()
        self:DelTX()
        self.skillPreTbl.skill_mask_img.gameObject:SetActive(false)
    end

end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
    self.lister["HeroHeadSkillProgressChange"] = basefunc.handler(self,self.OnHeroHeadSkillProgressChange)
    self.lister["ExtraSkillTrigger"] = basefunc.handler(self,self.OnExtraSkillTrigger)
end


--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

--自己的逻辑------
function M:OnExtraSkillTrigger(data)
    if data.skill_key == "crash_skill" then
        if self.skillState ~= SkillState.active then
            return
        end

        self:Ready()
    end
    
end
--增加和检测特效存不存在
function M:AddTX()
    --头和尾巴
    local heroHead = GameInfoCenter.GetHeroHead()

    if not self.tx_tou then 
        local data = {}
        local tx = NewObject("YX_tou_hudun",MapManager.GetMapNode())
        self.tx_tou = tx
    end

    if not self.tx_wei then
        local tx = NewObject("YX_jiasu_tuowei",heroHead.tail.transform)
        tx.transform:Rotate(0,0,-90)
        self.tx_wei = tx
    end

    --身体
    self.tx_shenti = self.tx_shenti or {}
    local all_hero = GameInfoCenter.GetAllHero()

    for key , h in pairs(all_hero) do
        --local h = HeroManager.GetHeroByLocation(i)
        if not self.tx_shenti[h.data.id] then
            local tx_name = {"YX_jiasu_qiliu_1","YX_jiasu_qiliu_2"}
            local tx = NewObject(tx_name[ h.data.location % 2 + 1],h.body)
            tx.transform:Rotate(0,0,-90)
            tx.transform.localPosition = Vector3.New(0,0,0)
            tx.transform.localScale = Vector3.New(0.46749,0.46749,0.46749)
            self.tx_shenti[h.data.heroId] = tx
        end
    end
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

    for k , v in pairs(self.tx_shenti) do
        if IsEquals(v) then
            GameObject.Destroy(v)
        end
    end
    self.tx_shenti = {}
end

function M:OnHeroHeadSkillProgressChange(data)
    if data and data.progress then
        self.progress = data.progress
    end
    if self.progress > self.max_progress * self.max_storage then self.progress = self.max_storage * self.max_progress end 
    self.storage = math.floor(self.progress / self.max_progress) 
    self.skillPreTbl.rocket_skill_img.fillAmount = (self.progress % self.max_progress) / self.max_progress
    if self.progress == self.max_storage * self.max_progress then
        self.skillPreTbl.rocket_skill_img.fillAmount = 1
    end
    self.skillPreTbl.storage_txt.text = self.storage .. "/" .. self.max_storage
    GameInfoCenter.heroHeadSkillProgress = self.progress

    if self.progress >= self.max_progress then
        self.texiao.gameObject:SetActive(true)
    else
        self.texiao.gameObject:SetActive(false)
    end
end

function M:Exit(data)
    if self.skillPre then
        Destroy(self.skillPre)
        self.skillPre = nil
    end
    M.super.Exit(self,data)
end