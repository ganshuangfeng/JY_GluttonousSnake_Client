-- 创建时间:2021-06-23
ExtRequire("Game.CommonPrefab.Lua.BulletPrefab")
ExtRequire("Game.CommonPrefab.Lua.BombPrefab")

local basefunc = require "Game/Common/basefunc"

AttackManager = {}
local M = AttackManager

local AttackMap = {}
local node
local NextID = 0

local lister
local function AddLister()
    lister={}
    lister["hero_attack_monster"] = M.on_hero_attack_monster
    lister["monster_attack_hero"] = M.on_monster_attack_hero
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


function M.Init(_node)
    node = _node
    AddLister()
end

function M.Exit()
    M.RemoveAll()
    RemoveLister()
end

function M.FrameUpdate(time_elapsed)
    -- for k, v in pairs(AttackMap) do
    --     if v ~= nil then
    --         v.attackSpr:FrameUpdate(time_elapsed)
    --     end
    -- end
    SpawnBulletManager.FrameUpdate(time_elapsed)
end


function M.Print()
    local nn = 0
    for k,v in pairs(AttackMap) do
        dump(v, "attack data")
        nn = nn + 1
    end
    print("attack count = " .. nn)
end
-- 创建一个对象
function M.Create(data)
    NextID = NextID + 1
    data.bulletParent = node
    --配置类数据
    --传入类数据(仅在第一阶段时使用,随后阶段会根据具体子弹类型自动获取目标)
    data.stage = 1
    data.Attack_ID = NextID
    SpawnBulletManager.Fire(data)
end
-- 根据ID回收(或者清除)子弹
function M.DestoryAttack(id)
    SpawnBulletManager.SetBulletFinsh(id)
end

function M.RemoveAll()
    SpawnBulletManager.RemoveAll()
end 


function M.on_hero_attack_monster(data)
    M.Create(basefunc.deepcopy(data))
end 

function M.on_monster_attack_hero(data)
    M.Create(basefunc.deepcopy(data))
end