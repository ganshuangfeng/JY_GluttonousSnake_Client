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

SkillComponseAttack = basefunc.class()
local M = SkillComponseAttack
M.name = "SkillComponseAttack"

local default_componse_count = 10

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["use_extra_skill"] = basefunc.handler(self,self.on_use_extra_skill)
	-- self.lister["hero_prefab_level_up"] = basefunc.handler(self,self.on_hero_prefab_level_up)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
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
end

function M:Refresh(data)
	self.data = data or self.data
    self.attack_cfg = {
        [1] = {
            type = 1,
			prefabName = {"B_kuosan"},
			attackFrom = "hero",
			moveWay = {"BossWaveMove"},
			hitStartWay = {"HitOnSelfPos"},
			hitEffect = {"PenetrateBombHit"},
			hitType = {"SectorShoot"},
			speed = {5,},
			bulletNumDatas = {1,},
			damage = {50,},
			bulletLifeTime = 2,
			remark = "星星子弹2",
			shouji_pre = "xx_shouji",
			attr = {"Ice#100"},
			audio_name = "battle_snow",
        	hit_range = 8
        },
        [2] = {
            type = 2,
			prefabName = {"BulletPrefab4"},
			attackFrom = "hero",
			moveWay = {"LineMove"},
			hitStartWay = {"IsHitSomeOne"},
			hitEffect = {"SampleHit"},
			hitType = {"CircleShoot"},
			speed = {6,},
			bulletNumDatas = {40,},
			damage = {30,},
			bulletLifeTime = 6,
			remark = "弓箭2",
			shouji_pre = "Gj_shoji",
			attr = {},
			audio_name = "battle_arrow",
        },
        [3] = {
            type = 3,
			prefabName = {"LaserPrefab1"},
			attackFrom = "hero",
			moveWay = {"BigLaserMove"},
			hitStartWay = {"IsLockBigLaser"},
			hitEffect = {"BigLaserHit"},
			hitType = {"Lock"},
			speed = {20,},
			bulletNumDatas = {1,},
			damage = {100,},
			bulletLifeTime = 3,
			remark = "激光2",
			shouji_pre = "Gj_shoji",
			attr = {},
			audio_name = "battle_laser",
        },
        [4] = {
            type = 4,
			prefabName = {"BulletPrefab6"},
			attackFrom = "hero",
			moveWay = {"LineMove"},
			hitStartWay = {"IsHitSomeOne"},
			hitEffect = {"SampleHit"},
			hitType = {"GQShoot"},
			speed = {10,},
			bulletNumDatas = {8,},
			damage = {50,},
			bulletLifeTime = 6,
			remark = "毒液2",
			shouji_pre = "duye_shouji",
			attr = {},
			audio_name = "battle_syringe",
        },
    }
end

function M:OnCreate()
end

function M:OnTrigger(data)
    local hero_data = data.hero
    local type_cfg = self.attack_cfg[hero_data.type]
    if type_cfg and next(type_cfg) then
        local attack_data = basefunc.deepcopy(type_cfg)
        attack_data.hitOrgin = {hero_id = hero_data.heroId}
        if hero_data.hitTarget then
            attack_data.hitTarget = basefunc.deepcopy(hero_data.hitTarget)
        else
            local hero = GameInfoCenter.GetHeroByHeroId(hero_data.heroId)
			local near_monster = GameInfoCenter.GetMonsterDisMin(hero.transform.position)
			if near_monster then
            	attack_data.hitTarget = {id = near_monster.id} 
			end
		end
		if attack_data.hitTarget then
			Event.Brocast("hero_attack_monster",attack_data)
		end
    end
end

function M:OnClose()
	
end

function M:OnChange()
	
end

function M:on_hero_prefab_level_up(data)
    SkillManager.SkillTrigger(self.data,data)
end

function M:on_use_extra_skill(data)
	SkillManager.SkillTrigger(self.data,data)
end