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

local basefunc = require "Game/Common/basefunc"

local skillStates = {
    waitCreate = "waitCreate", --等待创建
    ready = "ready", --可以释放
    coolDown = "coolDown",  --冷却中
}

SkillRocket = basefunc.class()
local M = SkillRocket
M.name = "SkillRocket"

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
	if self.state and self.state == skillStates.coolDown then
        self.cdTime = self.cdTime - time_elapsed
        self.skillPreTbl.rocket_skill_img.fillAmount = self.cdTime / (self.data.cd or 10) 
        self.skillPreTbl.rocket_skill_txt.text = math.floor(self.cdTime) + 1
        self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(true)
        self.skillPreTbl.click_cffect_node.gameObject:SetActive(false)
        if self.cdTime <= 0 then
            --冷却结束
            self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(false)
            self.skillPreTbl.click_cffect_node.gameObject:SetActive(true)
            self.state = skillStates.ready
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
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
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
    self.skillCfg = {
		[1] = {
			prefabName = {"daodan_xiao"},
			attackFrom = "hero",
			moveWay = {"LineMove"},
			hitStartWay = {"IsHitPlane"},
			hitEffect = {"RocketBombHit"},
			hitType = {"SkillRocketSmallShoot"},
			speed = {20,},
			bulletNumDatas = {16,},
			damage = {300,},
			bulletLifeTime = 6,
			remark = "火箭1",
			shouji_pre = "baozha_xiao",
			attr = {},
		},
		[2] ={
			prefabName = {"daodan_da","daodan_xiao"},
			attackFrom = "hero",
			moveWay = {"LineMove","LineMove"},
			hitStartWay = {"IsHitPlane","IsHitSomeOne"},
			hitEffect = {"RocketBombHit","PenetrateHit"},
			hitType = {"SkillRocketSmallShoot","CircleShoot"},
			speed = {30,10},
			bulletNumDatas = {1,30},
			damage = {300,300},
			bulletLifeTime = 6,
			remark = "火箭2",
			shouji_pre = {"baozha_da","baozha_xiao",},
			attr = {},
		},
    }
    self.state = skillStates.waitCreate
end

function M:Refresh(data)
	self.data = data or self.data	
end

function M:OnCreate()
    if self.state ~= skillStates.waitCreate then return end
    --创建预制体
    local parent = self.data.parent or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillRocketUI",parent)
    self.skillPre.transform:GetComponent("Button").onClick:AddListener(function()
        SkillManager.SkillTrigger(self.data)
    end)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
    self.state = skillStates.ready
    self.skillPreTbl.click_cffect_node.gameObject:SetActive(true)
end

function M:OnTrigger()
	if self.state ~= skillStates.ready then return end
    --技能效果
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    local allHero = GameInfoCenter.GetAllHero()
    local fx_guangs = {}
    for k,hero in pairs(allHero) do
        local fx_guang = NewObject("GX_guang",hero.transform)
        fx_guangs[#fx_guangs + 1] = fx_guang
    end
    local HeroHead = GameInfoCenter.GetHeroHead()
    local fx_guang = NewObject("GX_guang",HeroHead.transform:Find("@head_img"))
    fx_guangs[#fx_guangs + 1] = fx_guang

    self.shootSeq = DoTweenSequence.Create()
    -- CameraMove.SetCanMove(false)
    -- local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    -- heroQueuePrefab:SetCircleMove({
    --     m_dMaxTurnRate = 360,
    --     m_dMaxSpeed = 90,
    --     m_dMinSpeed = 15,
    --     m_dMaxForce = 10,
    --     radius = 5,
    --     circle_move_time = self.data.effectTime or 5
    -- })
    self:SetQueueSerparentObjCircleMove()
	for i = 1,2 do
		self.shootSeq:AppendCallback(function()
			local shootData = basefunc.deepcopy(self.skillCfg[i])
			shootData.fire_pos = heroQueuePrefab.transform.localPosition
			if i == 1 then
				shootData.hitOrgin = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hitTarget = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hero_tran = heroQueuePrefab.transform
			else
				local pos = CSModel.GetUITo3DPoint(Vector3.zero)

				pos = Vector3.New(pos.x,pos.y + 3,pos.z)
				shootData.hitOrgin = {pos = pos}
				shootData.hitTarget = {pos = pos}
			end
			ExtendSoundManager.PlaySound(audio_config.cs.battle_rocket.audio_name)
			Event.Brocast("hero_attack_monster",shootData)
		end)
		if i == 1 then
			self.shootSeq:AppendInterval(2)
		end
	end
	self.shootSeq:AppendInterval(4)
	self.shootSeq:OnForceKill(function()
        --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 0.2})
        if fx_guangs then
            for k,v in ipairs(fx_guangs) do
                Destroy(v)
            end
            fx_guangs = nil
        end
        CSModel.camera2d.transform.localPosition = Vector3.zero
        CSPanel.map.transform.localPosition = Vector3.zero
        -- CameraMove.SetCanMove(true)
		-- if heroQueuePrefab and heroQueuePrefab.vehicle then
		-- 	heroQueuePrefab.vehicle:SetMaxSpeed(old_max_speed)
		-- 	heroQueuePrefab.vehicle.m_dMaxTurnRate = 90
		-- end
        self.shootSeq = nil
	end)
    
    --cd控制
    self.cdTime = self.data.cd or 10
    --切换状态
    self.state = skillStates.coolDown
    --修改服务器金币概率
    --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 1})
end

function M:OnClose()
	
end

function M:OnChange()
	
end

function M:SetQueueSerparentObjCircleMove()
    local circle_move_time = self.data.circle_move_time or 5
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