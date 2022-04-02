-- 创建时间:2021-06-30

ComponseManager = {}

local M = ComponseManager

local lister
local function AddLister()
    lister={}
    lister["new_hero_created"] = M.on_new_hero_created
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function M.Init()
    AddLister()
    M.Hero_Wait = {}
end

function M.Exit()
    RemoveLister()
end

function M.on_new_hero_created(data)
    dump(data,"<color=red>1111111111111111111111111111111111111111111111111111111111111</color>")
end

M.Init()