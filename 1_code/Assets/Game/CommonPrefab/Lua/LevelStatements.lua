-- 创建时间:2021-09-14
-- LevelStatements 管理器

local basefunc = require "Game/Common/basefunc"
LevelStatements = {}
local M = LevelStatements
local this
local lister

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
    lister["MapBuildingDestroy"] = this.MapBuildingDestroy
end

function M.Init()
	M.Exit()
	this = LevelStatements
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end


local base_score = 1000
function M.GetScore()
    local hp_score = 0
    local percent  = GameInfoCenter.playerDta.hp / GameInfoCenter.playerDta.hpMax * 100
    if percent == 100 then  
        hp_score = math.random(141,200) / 100 * base_score
    elseif percent >= 71 then
        hp_score = math.random(81,140) / 100 * base_score
    else
        hp_score = math.random(60,80) / 100 * base_score
    end

    result_score = hp_score
    return result_score
end

function M.GetPercent(score)
    return score / base_score * 100
end

function M.GetAward()

end
M.BoxDestroyNum = 0
function M.MapBuildingDestroy(data)
    M.BoxDestroyNum = M.BoxDestroyNum + 1
end

function M.ClearBoxDestroyNum()
    M.BoxDestroyNum = 0
end

function M.GetBoxDestroyNum()
    return M.BoxDestroyNum
end

function M.GetHeroLengthAward()
    return GameInfoCenter.GetHeroNum() * M.OneHeroAward()
end 

function M.OneBoxAward()
    local curr_config = GameConfigCenter.GetCurrStateConfig()
    if not curr_config then
        return 0
    end
    return curr_config.box_value
end

function M.OneHeroAward()
    local curr_config = GameConfigCenter.GetCurrStateConfig()
    if not curr_config then
        return 0
    end
    return curr_config.hero_value
end

function M.GetThisAwardData()
    local re = {}
    local score =  M.GetScore()
    local percent_score = M.GetPercent(score)
    local score_level = GameConfigCenter.GetCurrScoreLevel(percent_score)
    local hero_fragment_data = GameConfigCenter.GetHeroFragment(percent_score)
    re.percent_score = percent_score
    re.score_level = score_level
    re.hero_fragment_data = hero_fragment_data
    return re
end
