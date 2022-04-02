-- 创建时间:2021-10-18
-- ItemThreeChooseOneManager 管理器

local basefunc = require "Game/Common/basefunc"
ItemThreeChooseOneManager = {}
local M = ItemThreeChooseOneManager

local this
local lister
ItemThreeChooseOneManager.max_item = 2
M.isNotHeroOn = true
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
    lister["StageFinish"] = this.on_StageFinish
end

function M.Init()
	M.Exit()

	this = ItemThreeChooseOneManager
	this.m_data = {}
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.Create(config,from)
    ItemThreeChooseOnePanel.Create(config,from)
end

function M.on_StageFinish()
    M.SetOnOffNotHero(true)
    M.SetMaxItem(3)
end

--关闭或打开剔除炮台
function M.SetOnOffNotHero(istrue)
    M.isNotHeroOn = istrue
end

--最多设置最多选项
function M.SetMaxItem(max)
    M.max_item = max
end