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

--合成调用技能
local basefunc = require "Game/Common/basefunc"

local skillStates = {
    waitCreate = "waitCreate", --等待创建
    ready = "ready", --可以释放
    coolDown = "coolDown",  --冷却中
}

SkillHeadSpeed = basefunc.class()
local M = SkillHeadSpeed
M.name = "SkillHeadSpeed"

local defaultTriggerCount = 60

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["HeroHeadSkillProgressChange"] = basefunc.handler(self,self.OnMgrSkillHeadCountChange)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

-- 加速技能会顶掉眩晕技能
function M.CreateBefore(data)
    local skills = SkillManager.GetAll()
    if skills and next(skills) then
        for k,skill in pairs(skills) do
            dump(skill)
            if skill.data.type == "dizziness" then
                SkillManager.SkillClose(skill.data)
            end
        end
    end
    return true
end

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
    if self.is_on_effect then
        self.effectTime = self.effectTime - time_elapsed
        if self.effectTime<= 0 then
            GameInfoCenter.hero_attack_speed_size = 1
            if self.fx_guangs then
                for k,v in ipairs(self.fx_guangs) do
                    if IsEquals(v) then
                        Destroy(v.gameObject)
                    end
                end
            end
            CSEffectManager.CloseSpeedUpLines()
            self.is_on_effect = false
            --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 0.2})
        end
    end
    if self.circle_move_state then
        self.circle_move_time = self.circle_move_time - time_elapsed
        if self.circle_move_time <= 0 then
            self:StopCircleMove()
        end
    end
end

function M:Ctor(data)
	self:MakeLister()
	self:AddMsgListener()
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
    if self.setParentTimer then
        self.setParentTimer:Stop()
        self.setParentTimer = nil
    end
    self:RemoveListener()
    if IsEquals(self.skillPre) then
        Destroy(self.skillPre.gameObject)
        self.skillPre = nil
    end
    if self.shootSeq then
        self.shootSeq:Kill()
        self.shootSeq = nil
    end
	ClearTable(self)
end

--初始化相关
function M:Init(data)
	self.data = data
    self.state = skillStates.waitCreate
end

function M:Refresh(data)
	self.data = data or self.data	
end

function M:SetParent()
    local parent
	local timer 
    timer = Timer.New(function ()
        parent = GameObject.Find("Canvas/GUIRoot/CSGamePanel/ComponsePanel_New1/@Hero_Pos_Node/@head_pos")
        if IsEquals(parent) then
            self.skillPre.transform.parent = parent.transform
            self.skillPre.transform.localPosition = Vector3.zero
            self.skillPre.gameObject:SetActive(true)
            timer:Stop()
        end
    end,0.1,-1)
    timer:Start()
    self.setParentTimer = timer
end

function M:OnCreate()
    if self.state ~= skillStates.waitCreate then return end
    --创建预制体
    local parent = self.data.parent or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillHeadSpeed",parent)
    self.skillPre.gameObject:SetActive(false)
    self.skillPre.transform:Find("@icon_img"):GetComponent("Button").onClick:AddListener(function()
        if self.triggerCount < self.requireTriggerCount then return end
        SkillManager.SkillTrigger(self.data)
    end)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
    self.state = skillStates.coolDown
    self.triggerCount = GameInfoCenter.GetHeroHeadSkillProgress()
    self.requireTriggerCount = self.data.requireTriggerCount or defaultTriggerCount
    self:RefreshSkillPreTblUI()
    self:SetParent()
end

function M:OnTrigger()
	if self.state ~= skillStates.ready then return end
    --技能效果
    local attack_speed_size = self.data.attack_speed_size or 0.167
    GameInfoCenter.hero_attack_speed_size = attack_speed_size

    if self.fx_guangs then
        for k,v in ipairs(self.fx_guangs) do
            if IsEquals(v) then
                Destroy(v.gameObject)
            end
        end
    end
    self.fx_guangs = {}
    local allHero = GameInfoCenter.GetAllHero()
    for k,hero in pairs(allHero) do
        local fx_guang = NewObject("GX_guang",hero.transform)
        self.fx_guangs[#self.fx_guangs + 1] = fx_guang
    end
    local HeroHead = GameInfoCenter.GetHeroHead()
    local fx_guang = NewObject("GX_guang",HeroHead.transform:Find("@head_img"))
    self.fx_guangs[#self.fx_guangs + 1] = fx_guang
    CSEffectManager.PlaySpeedUpLines()
    self:SetQueueSerparentObjCircleMove()
    --效果时间控制
    self.is_on_effect = true
    self.effectTime = self.data.effectTime or 10
    --切换状态
    self.state = skillStates.coolDown
    self.triggerCount = 0
    self:RefreshSkillPreTblUI()
    --设置服务器金币获取概率
    --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 1})

    Event.Brocast("SkillHeadTrigger")
end

function M:RefreshSkillPreTblUI()
    if self.triggerCount >= self.requireTriggerCount then
        self.state = skillStates.ready
        self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(false)
        self.skillPreTbl.click_cffect_node.gameObject:SetActive(true)
    else
        self.state = skillStates.coolDown
        self.skillPreTbl.attack_speed_img.fillAmount = self.triggerCount / self.requireTriggerCount
        self.skillPreTbl.attack_speed_txt.text = self.triggerCount .. "/" .. self.requireTriggerCount
        self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(true)
        self.skillPreTbl.click_cffect_node.gameObject:SetActive(false)
    end
end

function M:OnClose()
	
end

function M:OnChange()
	
end

function M:SetQueueSerparentObjCircleMove()
    local circle_move_time = self.data.circle_move_time or 10
    local skills = SkillManager.GetAll()
    for k,skill in pairs(skills) do
        --当有其他技能在调用转圈时
        if skill.circle_move_state and skill.circle_move_time ~= 0 then
            if skill.circle_move_time > circle_move_time and skill.data.heroId ~= self.data.heroId then
                self.circle_move_time = 0
                return
            else
                skill:StopCircleMove()
            end
        end
    end
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    local vehicle = heroQueuePrefab.vehicle
	if not self.old_vehicle_data then
		self.old_vehicle_data = {}
		self.old_vehicle_data.m_dMaxSpeed = vehicle.m_dMaxSpeed
		self.old_vehicle_data.m_dMinSpeed = vehicle.m_dMinSpeed
		self.old_vehicle_data.m_dMaxForce = vehicle.m_dMaxForce
		self.old_vehicle_data.on_off = vehicle:GetAllOnOff()
		self.old_vehicle_data.is_sin_path_on_off = vehicle.is_sin_path_on_off
	end
	vehicle.m_dMaxTurnRate = 360
    vehicle:SetMinSpeed(15)
    vehicle:SetMaxSpeed(90)
	vehicle.m_dMaxForce = 10
	vehicle.is_sin_path_on_off = false
	vehicle:CloseAllSteerings()
	vehicle:SetOnOff(Vehicle.SteerType.ForCircle, true)

	vehicle:SetSteeringValue(Vehicle.SteerType.ForCircle , "radius", 5)
	
	--记录转圈移动的时间
    self.circle_move_time = circle_move_time
    --记录转圈移动状态
    self.circle_move_state = true
end

function M:StopCircleMove()
    if self.circle_move_state then
        self.circle_move_state = false
        self.circle_move_time = 0
    end
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    local vehicle = heroQueuePrefab.vehicle
	if self.old_vehicle_data then
		for k,v in pairs(self.old_vehicle_data) do
			if k == "on_off" then
				for kk,vv in pairs(v) do
					vehicle:SetOnOff(kk, vv)
				end
			else
				vehicle[k] = v
			end
		end
		self.old_vehicle_data = nil
	end
end

function M:OnMgrSkillHeadCountChange(data)
    self.triggerCount = data.progress
    self:RefreshSkillPreTblUI()
end