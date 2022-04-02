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

SkillComponseRocket = basefunc.class()
local M = SkillComponseRocket
M.name = "SkillComponseRocket"

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
end

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
    self.skillCfg = {
		[1] = {
			prefabName = {"daodan_xiao"},
			attackFrom = "hero",
			moveWay = {"LineMove"},
			hitStartWay = {"IsHitPlane"},
			hitEffect = {"RocketBombHit"},
			hitType = {"SkillRocketSmallShoot"},
			speed = {20,},
			bulletNumDatas = {3,},
			damage = {300,},
			bulletLifeTime = 6,
			remark = "火箭1",
			shouji_pre = "baozha_xiao",
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
    self.state = skillStates.ready
end

function M:OnTrigger()
	if self.state ~= skillStates.ready then return end
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    --技能效果
    local shootData = basefunc.deepcopy(self.skillCfg[1])
    shootData.fire_pos = heroQueuePrefab.transform.position
    shootData.hitOrgin = {pos = heroQueuePrefab.transform.position}
    shootData.hitTarget = {pos = heroQueuePrefab.transform.position}
    shootData.hero_tran = heroQueuePrefab.transform
    ExtendSoundManager.PlaySound(audio_config.cs.battle_rocket.audio_name)
    Event.Brocast("hero_attack_monster",shootData)
end

function M:OnClose()
	
end

function M:OnChange()
	
end

function M:on_merge_hero()
    SkillManager.SkillTrigger(self.data)
end