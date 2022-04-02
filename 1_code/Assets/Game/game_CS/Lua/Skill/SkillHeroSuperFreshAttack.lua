local basefunc = require "Game/Common/basefunc"

SkillHeroSuperFreshAttack = basefunc.class(Skill)
local M = SkillHeroSuperFreshAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data


    self.heroHeadSpModifier = nil
    self.effectTime = 3
    self.effectCount = 0


end

function M:Init(data)
    M.super.Init(self)

    --self.data = data or self.data
    self:InitData(data)
    -- self:InitSkillPreTblUI()

    self:CD()
end

---- 初始化数据，refresh 也会调用这个
function M:InitData(data)
    M.super.InitData(self , data)

    self.data = data or self.data
end


function M:InitSkillPreTblUI()
    dump(debug.traceback(),"<color=red>？？？？？？？？？？？？？？？？？</color>")
    --创建预制体
    local parent = CSPanel.st_skill_node or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillHeadRocket",parent)
    self.skillPre.gameObject:SetActive(true)
    self.skillPre.transform:Find("@icon_img"):GetComponent("Button").onClick:AddListener(function()
        if self.skillState ~= SkillState.active then return end
        self:Trigger()
    end)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
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
    --- 创建 修改器
    if not self.heroHeadSpModifier then
        self:AddTX()
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()

        self.heroHeadSpModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
            object = heroHead , skill = self , 
            modify_key_name = "speed" , 
            modify_type = 2 , 
            modify_value = 100 , 
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
    end

    self.effectCount = self.effectCount + dt
    if self.effectCount > self.effectTime then
        self.effectCount = 0
        self.heroHeadSpModifier:Exit()
        self.heroHeadSpModifier = nil
        
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()
        -- 暂时这样写 ， 应该写成 自动修改的方式
        local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
        print( string.format( "<color=yellow>xxxx------------------------skill trigger xxxxxxxxxx now_speed22 : %s</color>" , now_speed) )
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

        self:After()
        self:DelTX()
    end

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
            if not data.hero_id or data.hero_id == self.object.data.heroId then
                
                if self.skillState ~= SkillState.active then
                    return
                end
                self:Ready()
            end
        end
    end
end
--增加和检测特效存不存在
function M:AddTX()
    --头和尾巴
    local heroHead = GameInfoCenter.GetHeroHead()

    if not self.tx_tou then 
        local data = {}
        local tx = NewObject("YX_jiasu_tou_gx",heroHead.transform)
        tx.transform:Rotate(0,0,-90)
        tx.transform.localScale = Vector3.New(0.6,0.6,0.6)
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