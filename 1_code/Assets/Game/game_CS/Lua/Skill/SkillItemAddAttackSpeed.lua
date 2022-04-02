--道具GoodsItem上的技能（治疗）
local basefunc = require "Game/Common/basefunc"

SkillItemAddAttackSpeed = basefunc.class(Skill)
local M = SkillItemAddAttackSpeed

local default_time = 15
function M:Ctor(data)
    M.super.Ctor(self, data)
    self.name = "SkillItemAddAttackSpeed"
    self.data = data
    self.attack_speed_modifiers = {}
end

function M:Init(data)
    M.super.Init(self)
    self.left_time = default_time

    self:Trigger()
end

function M:OnCD()

end

function M:Trigger()
    local seq = DoTweenSequence.Create()
    local all_heros = GameInfoCenter.GetAllHero()
    if self.fxs then
        for k,v in ipairs(self.fxs) do
            CachePrefabManager.Back(v)
        end
    end
    self.fxs = {}
    self.chuxian_tx = CachePrefabManager.Take("tb_chuxian_chuxian",GameInfoCenter.GetHeroHead().transform)
    self.chuxian_tx.prefab.prefabObj.transform.localPosition = Vector3.zero
    self.chuxian_tx.prefab.prefabObj.transform.eulerAngles = Vector3.New(0,0,0)
    self.chuxian_tx.prefab.prefabObj.transform.localScale = Vector3.one
    local timer = Timer.New(function ()
        CachePrefabManager.Back(self.chuxian_tx)
        self.chuxian_tx = nil
    end,2,1)
    timer:Start()
    self.icon_prefab = CachePrefabManager.Take("hit_speed_up_icon",GameInfoCenter.GetHeroHead().buff_node)
    self.icon_prefab.prefab.prefabObj.transform.localPosition = Vector3.zero
    self.icon_prefab.prefab.prefabObj.transform.localScale = Vector3.one

    self.icon = self.icon_prefab.prefab.prefabObj.transform:Find("icon")

    for k,v in pairs(all_heros) do
        local fx_pre = CachePrefabManager.Take("HC_guangxiao_YX_1",v.transform)
        fx_pre.prefab.prefabObj.transform.position = v.transform.position
        self.fxs[#self.fxs + 1] = fx_pre
        v.fsmLogic:addWaitStatusForUser("idel", {skillObject = self}, nil, self)
        
        local attack_speed_modifiers = CreateFactory.CreateModifier( { className = "PropModifier" , 
            object = v , skill = self , 
            modify_key_name = "hit_space" , 
            modify_type = 2 , 
            modify_value = -50,       
        } )
        self.attack_speed_modifiers = self.attack_speed_modifiers or {}
        self.attack_speed_modifiers[#self.attack_speed_modifiers + 1] = attack_speed_modifiers

    end
    -- self:After()
end

function M:FrameUpdate(dt)
    M.super.FrameUpdate(self, dt)

    self.left_time = self.left_time - dt

    if self.left_time < 0 then
        for k,v in ipairs(self.fxs) do
            CachePrefabManager.Back(v)
        end
        self.fxs = {}
        for k,v in ipairs(self.attack_speed_modifiers) do
            v:Exit()
        end
        self.attack_speed_modifiers = {}
        if self.icon_prefab then
            local xiaoshi_tx = CachePrefabManager.Take("tb_bao_xiaoshi",self.icon_prefab.prefab.prefabObj.transform)
            xiaoshi_tx.prefab.prefabObj.transform.parent = self.icon_prefab.prefab.prefabObj.transform.parent
            xiaoshi_tx.prefab.prefabObj.transform.localPosition = Vector3.zero
            local timer = Timer.New(function ()
                CachePrefabManager.Back(xiaoshi_tx)
            end,1,1)
            timer:Start()
            CachePrefabManager.Back(self.icon_prefab)
            self.icon_prefab = nil
        end
        self:Exit()
        return
    end

    if self.chuxian_tx then
        self.chuxian_tx.prefab.prefabObj.transform.eulerAngles = Vector3.New(0,0,0)
    end
    self:IconShanSuo(dt)
end

function M:Finish()
    self:Exit()
end

function M:ReSetTime()
    self.left_time = default_time
end

function M:IconShanSuo(dt)
    if not IsEquals(self.icon) then return end
    self.time_cut = self.time_cut or 0.2
    if self.left_time < 2 then
        self.time_cut = self.time_cut - dt
        if self.time_cut < 0 then
            self.icon.gameObject:SetActive(not self.icon.gameObject.activeSelf)
            self.time_cut = 0.2
        end
    else
        self.icon.gameObject:SetActive(true)
    end
end

function M:Exit()
    if self.object and self.object.skill and self.object.skill[self.id] then
        self.object.skill[self.id] = nil
    end
    M.super.Exit(self)
end