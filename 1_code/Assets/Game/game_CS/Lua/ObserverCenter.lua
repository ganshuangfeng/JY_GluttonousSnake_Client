--[[ 观察者中心 - 观天下
    
]]
ObserverCenter = {}
local M = ObserverCenter
local basefunc = require "Game/Common/basefunc"
local HitModule = require "Game.game_CS.Lua.HitModule"
local lister
function M.Init()
	
    M.lister = {
        "hit_monster",
        "hit_hero",
        "hit", -- 通用
        "SkillHeadTrigger",
        "ExtraSkillTrigger",
        "ui_game_get_jin_bi_msg",
	    "StageFinish",
        "monster_die",
    }
    M.MakeLister()
    M.AddMsgListener()

end
function M.MakeLister()
    lister = {}
    for k,v in pairs(M.lister) do
        lister[v] = function(...)
            M.OnMsg(v,...)
        end
    end
end

function M.AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.Exit()

    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg,cbk)
    end

end


--[[
    简单的事情这里直接做
    复杂的事情交给专门的模块
]]
function M.OnMsg(msg,...)

    if msg == "hit" or msg == "hit_monster" or msg == "hit_hero" then

        local args = {...}
        local data = args[1]
        local m,t = ObjectCenter.GetObj(data.id)

        if t == "monster" then

            -- 非死亡状态才行
            if m and m.state ~= "die" then

                data.target = m
                HitModule.Hit(data)

                -- boss hit die
                local bossObj
                for k,v in pairs(GameInfoCenter.BossIds) do
                    if v == data.id then
                        bossObj = GameInfoCenter.GetMonsterById(data.id)
                    end
                end
                if bossObj and bossObj.id == data.id then
                    Event.Brocast("hit_boss",m)
                    if bossObj.hp < 1 then
                        Event.Brocast("boss_die", m)
                        GameInfoCenter.RemoveAllSmallMonster()
                        SpawnBulletManager.RemoveAll()
                    end
                else
                    Event.Brocast("hit_monster_over",m)
                    if m.hp and m.hp < 1 then
                        Event.Brocast("monster_die", m)
                    end
                end

            end

        else

            data.target = m
            HitModule.Hit(data)

        end

    elseif msg == "SkillHeadTrigger" then

        GameInfoCenter.SetHeroHeadSkillProgress(0)

    elseif msg == "ui_game_get_jin_bi_msg" then
        --通过掉落物品来做这件事情
        --GameInfoCenter.AddHeroHeadSkillProgress()

    elseif msg == "ExtraSkillTrigger" then

        GameInfoCenter.AddHeroHeadSkillProgress()

    elseif msg == "monster_die" then
        local args = {...}
        local data = args[1]

        task_mgr.TriggerMsg( "kill_monster_msg" , data.config.type )
	
    elseif msg == "StageFinish" then    
        local args = {...}
        local data = args[1]
        dump( data , "<color=red>xxxxx------------ on__StageFinish: </color>" )
        if data.state == 1 then
            task_mgr.TriggerMsg( "pass_stage_msg" , data.stageData.curLevel )
        end
	
    else

        print("ObserverCenter not deal msg" , msg)

    end

end
