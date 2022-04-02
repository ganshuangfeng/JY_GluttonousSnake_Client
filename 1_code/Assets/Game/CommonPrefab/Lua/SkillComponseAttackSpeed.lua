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

SkillComponseAttackSpeed = basefunc.class()
local M = SkillComponseAttackSpeed
M.name = "SkillComponseAttackSpeed"

local default_componse_count = 10

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["merge_hero"] = basefunc.handler(self,self.on_merge_hero)
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
	-- if self.state and self.state == skillStates.coolDown then
    --     self.cdTime = self.cdTime - time_elapsed
    --     self.skillPreTbl.attack_speed_img.fillAmount = self.cdTime / (self.data.cd or 15) 
    --     self.skillPreTbl.attack_speed_txt.text = math.floor(self.cdTime) + 1
    --     self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(true)
    --     if self.cdTime <= 0 then
    --         --冷却结束
    --         self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(false)
    --         self.state = skillStates.ready
    --     end
    -- end
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

function M:OnCreate()
    if self.state ~= skillStates.waitCreate then return end
    --创建预制体
    local parent = self.data.parent or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("AttackSpeedUI",parent)
    self.skillPre.transform:GetComponent("Button").onClick:AddListener(function()
        SkillManager.SkillTrigger(self.data)
    end)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
    self.state = skillStates.coolDown
    self.componse_count = 0
    self.require_componse_count = self.data.require_componse_count or default_componse_count
    self:RefreshSkillPreTblUI()
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
    -- local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    -- heroQueuePrefab:SetCircleMove({
    --     m_dMaxTurnRate = 360,
    --     m_dMaxSpeed = 90,
    --     m_dMinSpeed = 15,
    --     m_dMaxForce = 10,
    --     radius = 5,
    --     circle_move_time = self.data.effectTime or 10
    -- })
    self:SetQueueSerparentObjCircleMove()
    --cd控制
    self.cdTime = self.data.cd or 15
    --效果时间控制
    self.is_on_effect = true
    self.effectTime = self.data.effectTime or 10
    --切换状态
    self.state = skillStates.coolDown
    self.componse_count = 0
    self:RefreshSkillPreTblUI()
    --设置服务器金币获取概率
    --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 1})
end

function M:RefreshSkillPreTblUI()
    if self.componse_count >= self.require_componse_count then
        self.state = skillStates.ready
        self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(false)
    else
        self.state = skillStates.coolDown
        self.skillPreTbl.attack_speed_img.fillAmount = (self.require_componse_count - self.componse_count) / self.require_componse_count
        self.skillPreTbl.attack_speed_txt.text = self.componse_count .. "/" .. self.require_componse_count
        self.skillPreTbl.attack_speed_cold_node.gameObject:SetActive(true)
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

function M:on_merge_hero()
    if self.componse_count < self.require_componse_count then
        self.componse_count = self.componse_count + 1
    end
    self:RefreshSkillPreTblUI()
end