--[[
    skill_data = {
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
    }
]]

SkillManager = {}
local M = SkillManager
local _basefunc = require "Game/Common/basefunc"
ExtRequire("Game.CommonPrefab.Lua.SkillBase")                      --技能基类
ExtRequire("Game.CommonPrefab.Lua.SkillRocket")                    --车头 释放火箭技能
ExtRequire("Game.CommonPrefab.Lua.SkillAttackSpeed")               --车头 增加攻速技能
ExtRequire("Game.CommonPrefab.Lua.SkillDizziness")                 --Boss技能 眩晕
ExtRequire("Game.CommonPrefab.Lua.SkillComponseRocket")            --合成技能 释放火箭
ExtRequire("Game.CommonPrefab.Lua.SkillComponseAttackSpeed")       --合成技能 加攻速
ExtRequire("Game.CommonPrefab.Lua.SkillComponseAttack")            --合成技能 合成后根据合成的炮台触发对应的攻击
ExtRequire("Game.CommonPrefab.Lua.SkillBuffBase")                  --buff技能基类
ExtRequire("Game.CommonPrefab.Lua.SkillAttackSpeedBuff")           --buff技能 增加攻速
ExtRequire("Game.CommonPrefab.Lua.SkillAttackPowerBuff")           --buff技能 增加攻击力
ExtRequire("Game.CommonPrefab.Lua.SkillAddGoldBuff")               --buff技能 增加金币掉落
ExtRequire("Game.CommonPrefab.Lua.SkillMoveSpeedBuff")             --buff技能 加移速
ExtRequire("Game.CommonPrefab.Lua.SkillHeadRocket")  --车头技能 火箭攻击
ExtRequire("Game.CommonPrefab.Lua.SkillHeadSpeed")   --车头技能 加攻速



local _this
local _listener
local _id = 0
--技能类型到类的映射
local TypeClass = {
    base = "SkillBase",
    rocket = "SkillRocket",
    attack_speed = "SkillAttackSpeed",
    dizziness = "SkillDizziness",
    componse_rocket = "SkillComponseRocket",
    componse_attack_speed = "SkillComponseAttackSpeed",
    componse_attack = "SkillComponseAttack",
    attack_speed_buff = "SkillAttackSpeedBuff",
    attack_power_buff = "SkillAttackPowerBuff",
    componse_attack_head_rocket = "SkillHeadRocket",
    componse_attack_head_speed = "SkillHeadSpeed",
    move_speed_buff = "SkillMoveSpeedBuff"
}

local function MakeListener()
    _listener = {}
end

local function AddListener()
    for msg,cbk in pairs(_listener) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if _listener then
        for msg,cbk in pairs(_listener) do
            Event.RemoveListener(msg, cbk)
        end
    end
    _listener=nil
end

local function CheckSkillIsNull()
    if not _this or not _this.mData or not _this.mData.skills or not next(_this.mData.skills) then return true end
end

local function BuildSkillId()
    _id = _id + 1
    return _id
end

function M.FrameUpdate(timeElapsed)
    if CheckSkillIsNull() then return end
    for k, v in pairs(_this.mData.skills) do
        v:FrameUpdate(timeElapsed)
    end
end

function M.Init()
    if not _this then
        M.Exit()
        _this = SkillManager
        _this.mData = {}
        MakeListener()
        AddListener()
    end
end

function M.Exit()
    if _this then
        RemoveLister()
        M.RemoveAll()
        _this.mData = nil
    end
    _this = nil
end

function M.Get(id)
    if not id then return end
    if CheckSkillIsNull() then return end
    return _this.mData.skills[id]
end

function M.Add(data)
    data.heroId = BuildSkillId()
    if not data or not data.heroId or not data.type or not TypeClass[data.type] or not _G[TypeClass[data.type]] then
        dump(data,"<color=red>error AddSkill data :</color>")
        return
    end
    local class = _G[TypeClass[data.type]]

    --创建前的一些操作
    if class.CreateBefore and type(class.CreateBefore) == "function" then
        if not class.CreateBefore(data) then
            return
        end
    end

    local skill = class.Create(data)
    _this.mData.skills = _this.mData.skills or {}
    _this.mData.skills[data.heroId] = skill
    return skill
end

function M.Remove(id)
    local skill = M.Get(id)
    if not skill then return end
    skill:Exit()
    _this.mData.skills[id] = nil
end

function M.GetAll()
    if not _this then return end
    return _this.mData.skills or {}
end

function M.AddAll(data)
    local d = _basefunc.deepcopy(data)
    for k,v in pairs(d) do
        M.Add(v)        
    end
end

function M.RemoveAll()
    if CheckSkillIsNull() then return end
    for k,v in pairs(_this.mData.skills) do
        v:Exit()
    end
    _this.mData.skills = {}
end

function M.Refresh()
    if CheckSkillIsNull() then return end
    for k,v in pairs(_this.mData.skills) do
        v:Refresh()
    end
end

function M.RefreshByID(id)
    if not id then return end
    if CheckSkillIsNull() then return end
    if not _this.mData.skills[id] then return end
    _this.mData.skills[id]:Refresh()
end

function M.SkillCreate(data)
    dump(data,"<color=yellow>on_skill_create</color>")
    if not data then return end
    local skill = M.Get(data.heroId)
    if not skill then
        skill = M.Add(data)
    end
    if not skill then return end
    skill:OnCreate()
    return skill
end

function M.SkillTrigger(data,trigger_data)
    dump(data,"<color=yellow>on_skill_trigger</color>")
    if not data then return end
    local skill = M.Get(data.heroId)
    if not skill then return end
    skill:OnTrigger(trigger_data)
end

function M.SkillClose(data)
    dump(data,"<color=yellow>on_skill_close</color>")
    if not data then return end
    local skill = M.Get(data.heroId)
    if not skill then return end
    skill:OnClose()
    M.Remove(data.heroId)
end

function M.SkillChange(data)
    dump(data,"<color=yellow>on_skill_change</color>")
    if not data then return end
    local skill = M.Get(data.heroId)
    if not skill then return end
    skill:OnChange()
end
