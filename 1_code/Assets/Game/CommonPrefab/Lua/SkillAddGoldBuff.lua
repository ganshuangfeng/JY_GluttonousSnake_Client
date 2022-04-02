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
--攻速buff
local basefunc = require "Game/Common/basefunc"

SkillAddGoldBuff = basefunc.class()
local M = SkillAddGoldBuff
M.name = "SkillAddGoldBuff"


function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
    if self.effect_time and self.effect_time > 0 then
        self.effect_time = self.effect_time - time_elapsed
        if self.effect_time <= 0 then
            SkillManager.SkillClose(self.data)
        end
    end
end

function M:Ctor(data)
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
	ClearTable(self)
end

--初始化相关
function M:Init(data)
	self.data = data
    self.skill_cfg = {
        effect_hero = "all", -- all 全部 random_one 随机一个 random_grid 随机一个格子
        change_value = 10, -- 改变值
        effect_time = 2,
    }
end

function M:Refresh(data)
end

function M:OnCreate()
    self.effecters = {}
    if self.skill_cfg.effect_hero == "all" then
        self.effecters = GameInfoCenter.GetAllHero()
    elseif self.skill_cfg.effect_hero == "random_one" then
        local all_heros = GameInfoCenter.GetAllHero()
        local rdn = math.random(1,#all_heros)
        local i = 1
        for k,v in pairs(HeroTable) do
            if i == rdn then
                self.effecters[#self.effecters + 1] = v
                break
            end
            i = i + 1
        end
    end
end

function M:OnTrigger()
    if self.effecters and next(self.effecters) then
        for k,hero in pairs(self.effecters) do
            hero.data.hit_space = hero.data.hit_space / self.skill_cfg.change_value
        end
        self.effect_time = self.skill_cfg.effect_time
    end
end


function M:OnClose()
    for k,hero in pairs(self.effecters) do
        hero.data.hit_space = hero.data.hit_space * self.skill_cfg.change_value
    end
end

function M:OnChange()
	
end