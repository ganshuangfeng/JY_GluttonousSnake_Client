local basefunc = require "Game/Common/basefunc"
HeroDataManager = {}
local M = HeroDataManager

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

end

function M.Init()
	M.Exit()
	this = HeroDataManager
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

local default_type = {2,4}

--根据类型获取一个英雄的等级
function M.GetHeroLevelByType(hero_type)
    local default_level = 0
    for i = 1,#default_type do
        if hero_type == default_type[i] then
            default_level = 1
        end
    end

    --local l = PlayerPrefs.GetInt(hero_type.."_hero_level"..MainModel.UserInfo.user_id,default_level)
    local data = MainModel.QueryHeroInfo()
    local find_by_type = function(type)
        for k , v in pairs(data) do
            if v.type == hero_type then
                return v.level
            end
        end
    end

    return find_by_type(hero_type) or default_level
end

--使某一个具体的英雄升级
function M.UpHeroLevelByType(hero_type)
    local level = M.GetHeroLevelByType(hero_type)
    local need_data = M.GetUnlockNeed(hero_type,level)

    if level >= 20 then
        return
    end

    if need_data.gold_need <= MainModel.UserInfo.Asset.prop_jin_bi then
        if need_data.fragment_need <= M.GetHeroFragmentNumByType(hero_type) then
            -- --ClientAndSystemManager.SendRequest("cs_add_gold",{jb = -need_data.gold_need})
            --PlayerPrefs.SetInt(hero_type.."_hero_level"..MainModel.UserInfo.user_id,level + 1)
            MainModel.UpgradeHero(hero_type,{[1] = {
                asset_type = "prop_jin_bi",
                asset_value = need_data.gold_need,
            },
            [2] = {
                asset_type = "prop_hero_fragment_"..hero_type,
                asset_value = need_data.fragment_need,
            }
            },function(data)
                if data.result == 0 then
                    if level > 0 then
                        task_mgr.TriggerMsg( "upgrade_hero_msg" , hero_type )
                        LittleTips.Create("升级成功")
                    else
                        task_mgr.TriggerMsg( "unlock_hero_msg" , hero_type )
                        LittleTips.Create("解锁成功")
                    end
                    Event.Brocast("hero_level_changed",{hero_type = hero_type,level = level + 1})
                    Event.Brocast("HeroDataChange")
                elseif data.result == 1002 then
                    LittleTips.Create("材料不足！")
                else
                    LittleTips.Create(errorCode[data.result])
                end
            end)
            return true
        end
    end
    return false
end

--获取某一种英雄的碎片数量
function M.GetHeroFragmentNumByType(hero_type)
    --local n = PlayerPrefs.GetInt("prop_hero_fragment_"..hero_type..MainModel.UserInfo.user_id,0)
    local n = MainModel.GetAssetValueByKey("prop_hero_fragment_"..hero_type)
    return n
end

--改变某一个英雄的碎片数量
function M.ChangeHeroFragmentNumByType(hero_type,num)
    local curr = M.GetHeroFragmentNumByType(hero_type)
    curr = curr + num
    --PlayerPrefs.SetInt("prop_hero_fragment_"..hero_type..MainModel.UserInfo.user_id,curr)
    MainModel.AddAsset("prop_hero_fragment_"..hero_type,num)
    Event.Brocast("prop_hero_fragment_num_changed",{hero_type = hero_type,fragment_num = curr})
end
--判断一个英雄是否已经解锁
function M.IsHeroUnlock(hero_type)
    for i = 1,#default_type do
        if default_type[i] == hero_type then
            return true
        end
    end

    if M.GetHeroLevelByType(hero_type) > 0 then
        return true
    end
    return false
end
--随机获取一个已经解锁的英雄type
function M.GetRandomHeroTypeUnLock()
    local func = nil
    func = function()
        local r = math.random(1,20)
        if M.IsHeroUnlock(r) then
            return r
        else
            return func()
        end
    end
    return func()
end

local unlock_hero_config = ExtRequire "Game.game_CS.Lua.unlock_hero_config"
local hero_base_config = ExtRequire("Game.CommonPrefab.Lua.hero_base_config")

function M.GetUnlockNeed(hero_type,level)
    local need = {}
    need.fragment_need = 0
    need.gold_need = 0

    need.fragment_need = unlock_hero_config["hero_"..hero_type][level].fragment_need
    need.gold_need = unlock_hero_config["hero_"..hero_type][level].gold_need
    return need
end

function M.GetUnlockConfig()
    return unlock_hero_config
end

function M.GetHeroBaseConfig()
    return hero_base_config
end


local hero_type_config = {
    1,2,3,4,7,13,14,15
}
function M.GetUnlockHeroType()
    local ret = {}
    for i,v in ipairs(hero_type_config) do
        if M.IsHeroUnlock(v) then
            table.insert(ret,v)
        end
    end
    return ret
end

--上阵某个英雄(同类型只能上阵一个英雄)
function M.SetGoIntoBattle(hero_type)
    local attack_type = GameConfigCenter.GetHeroAttackType(hero_type)
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id..attack_type,hero_type)
    Event.Brocast("battle_data_changed")
end
--获取某个类型上证的英雄，如果没有,默认上阵这个种类的某一个解锁的，如果没有解锁任何英雄，则值为-1
function M.GetGoIntoBattle(attack_type)
    local v = PlayerPrefs.GetInt(MainModel.UserInfo.user_id..attack_type,-1)
    
    if v == -1 then
        local hero_list = GameConfigCenter.GetHeroListByAttackType(attack_type)
        for i = 1,#hero_list do
            local isture = M.IsHeroUnlock(hero_list[i])
            if isture then
                M.SetGoIntoBattle(hero_list[i])
                return hero_list[i]
            end
        end
    end
    return v
end

--初始化上阵数据，英雄种类至少上阵一个
function M.InitGoIntoBattleData()
    this.GoIntoBattleData = {}
    local totable = function(data)
        if type(data) ~= "table" then
            return {data}
        end
        return data
    end


    local config = GameConfigCenter.GetHeroAttackTypeConfig()
    for i = 1,#config do
        this.GoIntoBattleData[config[i].attack_type] = this.GoIntoBattleData[config[i].attack_type] or {}
        local data = totable(config[i].hero_type_list)
        for ii = 1,#data do
            this.GoIntoBattleData[config[i].attack_type][data[ii]] = false
        end
    end
    --这个表存了当前所有的英雄是否上阵的数据，目前默认不上阵
    --this.GoIntoBattleData = this.GoIntoBattleData
    --获取存在本地的上阵数据
    for k ,v in pairs(this.GoIntoBattleData) do
        local battle_hero_type =  M.GetGoIntoBattle(k)
        if battle_hero_type > 0 and v[battle_hero_type] ~= nil then
            v[battle_hero_type] = true
        end
    end

    return this.GoIntoBattleData
end

--检查一个英雄上没有上阵
function M.IsHeroGoBattle(hero_type)
    local attack_type = GameConfigCenter.GetHeroAttackType(hero_type)

    if hero_type == M.GetGoIntoBattle(attack_type) then
        return true
    end
    return false
end