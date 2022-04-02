-- 创建时间:2021-06-25
-- LotteryManager 管理器

local basefunc = require "Game/Common/basefunc"
LotteryManager = {}
local M = LotteryManager
M.key = "LotteryManager"

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
    lister["hero_change"] = this.OnHeroChange
end

function M.Init()
	M.Exit()

	this = LotteryManager
	this.m_data = {}
    --#测试数据
    this.m_data.lottery_data = {
        [1] = {
            [1] = {
                name = "1",
                type = 1,
            },
            [2] = {
                name = "2",
                type = 2,
            },
            [3] = {
                name = "3",
                type = 3,
            },
            [4] = {
                name = "0",
                type = 0,
            },
        },
        [2] = {
            [1] = {
                name = "1",
                type = 1,
            },
            [2] = {
                name = "2",
                type = 2,
            },
            [3] = {
                name = "3",
                type = 3,
            },
            [4] = {
                name = "4",
                type = 4,
            },
        },
        [3] = {
            [1] = {
                name = "1",
                type = 1,
            },
            [2] = {
                name = "2",
                type = 2,
            },
            [3] = {
                name = "3",
                type = 3,
            },
            [4] = {
                name = "4",
                type = 4,
            },
        },
    }
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnHeroChange()
    --当英雄数据改变时作处理
end