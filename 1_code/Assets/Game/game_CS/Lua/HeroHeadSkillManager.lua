-- 创建时间:2021-09-09
-- HeroHeadSkillManager 管理器

local basefunc = require "Game/Common/basefunc"
HeroHeadSkillManager = {}
local M = HeroHeadSkillManager
local this
local lister
-- 活动的提示状态
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end

local function MakeLister()
    lister = {}
    lister["PlayAngelSkill"] = M.PlayAngelSkill
    lister["PlayDemonSkill"] = M.PlayDemonSkill
end

function M.Init()
	M.Exit()
    MakeLister()
    AddLister()
	this = HeroHeadSkillManager
end

function M.Exit()
    M.KillAngelSkill()
    M.KillDemonSkill()
	if this then
		RemoveLister()
		this = nil
	end
end
--当前天使skill的技能杀掉
function M.KillAngelSkill()
    if M.CurrAngelSkill then
        M.CurrAngelSkill:Exit()
    end
end
--当前恶魔的skill的技能杀掉
function M.KillDemonSkill()
    if M.CurrDemonSkill then
        M.CurrDemonSkill:Exit()
    end
end

function M.SetCurrAngelSkill(skill)
    M.KillAngelSkill()
    local head = GameInfoCenter.GetHeroHead()
    M.CurrAngelSkill = CreateFactory.CreateSkillById(skill.skill_id,{object = head})
    head.skill[#head.skill + 1] = M.CurrDemonSkill
end

function M.SetCurrDemonSkill(skill)
    M.KillDemonSkill()
    local head = GameInfoCenter.GetHeroHead()
    
    M.CurrDemonSkill = CreateFactory.CreateSkillById(skill.skill_id,{object = head})
    head.skill[#head.skill + 1] = M.CurrDemonSkill
end

function M.PlayAngelSkill()
    if M.CurrAngelSkill then
        M.CurrAngelSkill:Ready()
    end
end

function M.PlayDemonSkill()
    if M.CurrDemonSkill then
        M.CurrDemonSkill:Ready()
    end
end

function M.InitDefaultSkill()
    local head = GameInfoCenter.GetHeroHead()
    M.CurrAngelSkill = CreateFactory.CreateSkillById(55,{object = head})
    M.CurrDemonSkill = CreateFactory.CreateSkillById(53,{object = head})
end