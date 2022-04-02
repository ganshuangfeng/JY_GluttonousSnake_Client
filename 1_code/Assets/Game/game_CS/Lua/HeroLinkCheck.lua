-- 创建时间:2021-09-14
-- HeroLinkCheck 管理器

local basefunc = require "Game/Common/basefunc"
HeroLinkCheck = {}
local M = HeroLinkCheck

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
    lister["model_turret_change_msg"] = M.on_model_turret_change_msg
end

function M.Init()
	M.Exit()
	this = HeroLinkCheak
	MakeLister()
    AddLister()
    M.CheakLink()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.on_model_turret_change_msg(data)
    M.CheakLink()
end

function M.CheakLink_old()
    local hero_map =  GameInfoCenter.GetAllHero()
    local max = GameInfoCenter.GetHeroNum()
    local link_times = 0
    local last_check_type = nil
    local hero_list_location = M.GetHeroListLocation()
    local re = {}

    local stop_data = {}
    stop_data.data = {}
    stop_data.data.type = "stop"
    stop_data.id = "?"
    hero_list_location[#hero_list_location + 1] = stop_data
    for i = 1,#hero_list_location  do

        if last_check_type == nil then
            last_check_type = hero_list_location[i].data.type
            link_times = link_times + 1
            re[#re  + 1] = hero_list_location[i].id
        else
            if last_check_type == hero_list_location[i].data.type then
                link_times = link_times + 1
                re[#re  + 1] = hero_list_location[i].id
            end
        end

        if last_check_type ~= hero_list_location[i].data.type then
            for j = 1,#re do
                M.SetID2Star(re[j],link_times)
            end
            link_times = 1
            re = {}
            last_check_type = hero_list_location[i].data.type
            re[#re + 1] = hero_list_location[i].id
        end
    end
end

function M.CheckLinkTimes(type)
    local hero_list_location = M.GetHeroListLocation()
    local link_times = 0
    local max = GameInfoCenter.GetHeroNum()
    for i = 1,#hero_list_location do
        local hero = hero_list_location[i]
        local heroType = hero.data.type
        if heroType == type then
            link_times = link_times + 1
        end
    end
    return link_times
end

function M.GetHeroListLocation()
    local max = GameInfoCenter.GetHeroNum()
    local hero_list_location = {}
    local hero_map =  GameInfoCenter.GetAllHero()
    local get_hero_by_location = function(location)
        for k , v in pairs(hero_map) do
            if v.data.location == location then 
                return v
            end
        end
    end
    
    for i = 1,max do
        hero_list_location[#hero_list_location + 1] = get_hero_by_location(i)
    end
    return hero_list_location
end


function M.CheakLink()
    local hero_map =  GameInfoCenter.GetAllHero()
    local max = GameInfoCenter.GetHeroNum()
    local link_times = 0
    local last_check_type = nil
    local hero_list_location = M.GetHeroListLocation()
    local re = {}

    for i = 1,#hero_list_location do
        local hero = hero_list_location[i]
        local type = hero.data.type

        re[type] = re[type] or {}
        re[type][#re[type] + 1] = hero.id 
    end

    for k , v in pairs(re) do
        for i = 1,#v do
            M.SetID2Star(v[i],#v)
        end
    end
end

M.isFirst = true
function M.SetID2Star(ID,star)
    M.ID2Star = M.ID2Star or {}
    if not M.ID2Star[ID] or M.ID2Star[ID] ~= star then
        Event.Brocast("hero_link_change",{id = ID,star = star})
    end
    M.ID2Star[ID] = star
end