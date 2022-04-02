-- 创建时间:2021-10-20
-- HeadSkillManager 管理器

local basefunc = require "Game/Common/basefunc"
HeadSkillManager = {}
local M = HeadSkillManager

local this
local lister
--序号对应的就是车头的type
local skill_config = {
    [1] = {skill = "SkillHeadChaoSuZhuangZhi",max = 5,init_time = 1,cd = 10,keep_time = 10},
    --临时技能
    [2] = {skill = "SkillHeadBaoLieHuoYan",max = 5,init_time = 5,cd = 1,keep_time = 10},

    [3] = {skill = "SkillHeadZuanTou",max = 5,init_time = 5,cd = 1,keep_time = 10},
}

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
    lister["stage_start"] = M.on_stage_start
end

function M.Init()
	M.Exit()

	this = HeadSkillManager
	MakeLister()
    AddLister()
    local head_type = MainModel.GetHeadType()
    M.curr_head_type_max_usetime = skill_config[head_type].max
    M.curr_head_type_usetime = skill_config[head_type].init_time
    M.curr_head_type_max_usetime = GameInfoCenter.GetPlayerSkillInfo().skill_num_max
    M.curr_head_type_usetime = GameInfoCenter.GetPlayerSkillInfo().skill_num
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.AddSkillUseTimes(time)
    M.curr_head_type_usetime = M.curr_head_type_usetime + time
    if M.curr_head_type_usetime > M.curr_head_type_max_usetime then
        M.curr_head_type_usetime = M.curr_head_type_max_usetime
    end
    Event.Brocast("head_skill_usetime_changed")
end

function M.CreateSkill(data,object)
    return CreateFactory.CreateSkill({keep_time = skill_config[data.type].keep_time,type = skill_config[data.type].skill,object = object,cd = skill_config[data.type].cd} )
end

function M.on_stage_start()
    --local head_type = MainModel.GetHeadType()
    M.curr_head_type_max_usetime = GameInfoCenter.GetPlayerSkillInfo().skill_num_max
    M.curr_head_type_usetime = GameInfoCenter.GetPlayerSkillInfo().skill_num
end

function M.GetMaxTime()
    return M.curr_head_type_max_usetime
end

function M.GetUseTime()
    return M.curr_head_type_usetime
end

function M.GetCD()
    local type = MainModel.GetHeadType()
    return skill_config[type].cd
end

function M.GetKeepTime()
    local type = MainModel.GetHeadType()
    return skill_config[type].keep_time or 0
end


function M.GetCurrHeadExtraSkillConfig()
    local type = MainModel.GetHeadType()
    return skill_config[type]
end
