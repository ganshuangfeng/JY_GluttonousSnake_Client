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
--buff基类 所有类型的buff都可以继承此基类
local basefunc = require "Game/Common/basefunc"

SkillBuffBase = basefunc.class()
local M = SkillBuffBase
M.name = "SkillBuffBase"


function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
    if self.effect_time and self.effect_time > 0 then
        self.effect_time = self.effect_time - time_elapsed
        if self.tx_map then
            for k,v in ipairs(self.tx_map) do
                if IsEquals(v.fx_pre) then
                    v.effect_time = self.effect_time
                    v.guangquan.fillAmount = self.effect_time / self.skill_cfg.effect_time
                else
                    table.remove(self.tx_map,k)
                end
            end 
        end
        if self.effect_time <= 0 then
            SkillManager.SkillClose(self.data)
        end
    end
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["refresh_componse"] = basefunc.handler(self,self.RefreshHeroOnLocation)
    -- self.lister["pass_stage_msg"] = basefunc.handler(self,self.on_stage_win)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Ctor(data)
	self:MakeLister()
	self:AddMsgListener()
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
    self:RemoveListener()
	ClearTable(self)
end

--初始化相关
function M:Init(data)
	self.data = data
    self.skill_cfg = self.data.cfg or {
        effect_hero = "random_grid", -- all 全部 random_one 随机一个 random_grid 随机一个格子 random_type 随机一类
        change_value = 10, -- 改变值
        effect_time = 30,
    }
    
end

function M:Refresh(data)
end

function M:OnCreate()
    self.effecters = {}
    if self.skill_cfg.effect_hero == "all" then
        self.effecters = GameInfoCenter.GetAllHero()
        self:RefreshHeroOnLocation()
    elseif self.skill_cfg.effect_hero == "random_one" then
        local all_heros = GameInfoCenter.GetAllHero()
        local rdn = math.random(1,#all_heros)
        local i = 1
        for k,v in pairs(all_heros) do
            if i == rdn then
                self.effecters[#self.effecters + 1] = v
                break
            end
            i = i + 1
        end
        self:RefreshHeroOnLocation()
    elseif self.skill_cfg.effect_hero == "random_grid" then
        local all_heros = GameInfoCenter.GetAllHero()
        local hero_count = 0
        for k,v in pairs(all_heros) do
            hero_count = hero_count + 1
        end
        if hero_count <= 0 then hero_count = 1 end
        math.randomseed(os.time())
        self.random_grid = math.random(1,hero_count)
        self:SetComponsePanelTX(self.random_grid,self.grid_fx or "hero_attack_speed_up_fx","on_panel")
        local hero_wait = ComponseManager.GetHeroByLocation(self.random_grid)
        if hero_wait then
            self.effecters[1] = ObjectCenter.GetObj(hero_wait.id)
        end
        self:Set3DTx()
    elseif self.skill_cfg.effect_hero == "random_type" then
        --从当前有的类型里选取一个
        local all_heros = GameInfoCenter.GetAllHero()
        if all_heros and next(all_heros) then
            local type_list = {}
            for k,v in pairs(all_heros) do
                if v.data then
                    if not type_list[v.data.type] then
                        type_list[v.data.type] = v.data.type
                    end
                end
            end
            local rdn = math.random(1,#type_list)
            local i = 1
            for k,v in pairs(type_list) do
                if i == rdn then
                    self.random_type = v
                    break
                end
                i = i + 1
            end
            for k,v in pairs(all_heros) do
                if v.data.type == self.random_type then
                    self.effecters[#self.effecters + 1] = v
                end
            end
        end
        self:RefreshHeroOnLocation()
    end
    SkillManager.SkillTrigger(self.data)
end

function M:OnTrigger()
    local hero_queue = GameInfoCenter.GetHeroHead()
    local fx_pre = NewObject("GSSS_Font",GameObject.Find("Canvas/LayerLv5").transform)
    fx_pre.transform:GetComponent("Image").sprite = GetTexture(self.tx_word or "2d_word_pz_1")
    fx_pre.transform.position = CSModel.Get3DToUIPoint(hero_queue.transform.position)
    local seq = DoTweenSequence.Create()
    seq:Append(fx_pre.transform:DOLocalMoveY(fx_pre.transform.localPosition.y + 100,1))
    seq:AppendCallback(function()
        if IsEquals(fx_pre) then
            Destroy(fx_pre)
        end
    end)
    if self.effecters and next(self.effecters) then
        self:SetAttribute()
        self.effect_time = self.skill_cfg.effect_time
    end
end


function M:OnClose()
    self.effect_time = nil
    self:CloseAllComponsePanelTX()
    self:ResetAttribute(self.effecters)
end

function M:SetAttribute()
end

function M:ResetAttribute()
end

function M:RefreshHeroOnLocation()
    if self.random_grid then
        local hero_wait =  ComponseManager.GetHeroByLocation(self.random_grid)
        local effecter = self.effecters[1]
        
        if self.tx_3d_map and next(self.tx_3d_map) then
            for k,v in pairs(self.tx_3d_map) do
                if v and IsEquals(v.gameObject) then
                    Destroy(v.gameObject)
                end
            end
        end
        self.tx_3d_map = {}
        
        if not hero_wait then
            self:ResetAttribute()
            self.effecters = {}
            return
        end
        if (not effecter or not effecter.data) or effecter.id ~= hero_wait.id then
            self:ResetAttribute()
            self.effecters[1] = ObjectCenter.GetObj(hero_wait.id)
            self:Set3DTx()
            self:SetAttribute()
        end
    else
        self:CloseAllComponsePanelTX()
        for k,v in pairs(self.effecters) do
            if v.data then
                local hero_wait = ComponseManager.GetHeroByHeroId(v.data.heroId)
                if hero_wait then
                    self:SetComponsePanelTX(hero_wait,self.hero_wait_fx or "hero_attack_speed_up_fx_1","on_hero")
                end
            end
        end
    end
end

function M:SetComponsePanelTX(pos,pre_name,type)
    self.tx_map = self.tx_map or {}
    self:Set3DTx()
    if type == "on_hero" then
        local hero_wait = pos
        local m_effect_time = self.effect_time or self.skill_cfg.effect_time
        if hero_wait.speed_up_fx_pre then
            if hero_wait.speed_up_fx_pre.effect_time > m_effect_time then
                return 
            end
        end
        local m_pos = hero_wait.data.location
        local componse_panel = CSPanel.componse_pre
        if componse_panel.speed_up_fx_pres and next(componse_panel.speed_up_fx_pres) and componse_panel.speed_up_fx_pres[m_pos] then
            if componse_panel.speed_up_fx_pres[m_pos].effect_time > m_effect_time then
                return
            end
        end
        local fx_pre = NewObject(pre_name,hero_wait.transform)
        local parent_scale= hero_wait.transform.localScale
        fx_pre.transform.localScale = Vector3.New(1/parent_scale.x,1/parent_scale.y,1/parent_scale.z)
        local obj = {
            hero_wait = hero_wait,
            pre_name = pre_name,
            fx_pre = fx_pre,
            guangquan = fx_pre.transform:Find("guangquan"):GetComponent("Image"),
            effect_time = m_effect_time
        }
        hero_wait.speed_up_fx_pre = obj
        self.tx_map[#self.tx_map + 1] = obj
    elseif type == "on_panel" then
        local componse_panel = CSPanel.componse_pre
        local m_effect_time = self.effect_time or self.skill_cfg.effect_time
        if componse_panel.speed_up_fx_pres and next(componse_panel.speed_up_fx_pres) and componse_panel.speed_up_fx_pres[pos] then
            if componse_panel.speed_up_fx_pres[pos].effect_time > m_effect_time then
                return
            end
        end
        local hero_wait = ComponseManager.GetHeroByLocation(pos)
        if hero_wait and hero_wait.speed_up_fx_pre then
            if hero_wait.speed_up_fx_pre.effect_time > m_effect_time then
                return 
            end
        end
        local fx_pre = NewObject(pre_name,componse_panel["pos" .. pos].transform)
        local obj = {
            hero_wait = hero_wait,
            pre_name = pre_name,
            fx_pre = fx_pre,
            guangquan = fx_pre.transform:Find("guangquan"):GetComponent("Image"),
            effect_time = m_effect_time
        }
        self.tx_map[#self.tx_map + 1] = obj
    end
end

function M:Set3DTx()
    self.tx_3d_map = self.tx_3d_map or {}
    if self.effecters and next(self.effecters) then
        for k,v in pairs(self.effecters) do
            if v and v.data then
                if not self.tx_3d_map[v.id] then
                    self.tx_3d_map[v.id] = NewObject("GX_guang",v.transform)
                end
            end
        end
    end
end

function M:CloseAllComponsePanelTX()
    if self.tx_map and next(self.tx_map) then
        for k,v in ipairs(self.tx_map) do
            Destroy(v.fx_pre)
            if v.hero_wait then
                v.hero_wait.speed_up_fx_pre = nil
            end
            if v.pos then
                local componse_panel = CSPanel.componse_pre
                if componse_panel.speed_up_fx_pres and componse_panel.speed_up_fx_pres[pos] then
                    componse_panel.speed_up_fx_pres[pos] = nils
                end
            end
        end
    end
    self.tx_map = {}
    if self.tx_3d_map and next(self.tx_3d_map) then
        for k,v in pairs(self.tx_3d_map) do
            if v and IsEquals(v.gameObject) then
                Destroy(v.gameObject)
            end
        end
    end
    self.tx_3d_map = {}
end

function M:OnChange()
	
end

function M:on_stage_win()
    SkillManager.SkillClose(self.data)
end