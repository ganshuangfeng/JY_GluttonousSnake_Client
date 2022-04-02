--[[ 攻击模块
    控制攻击 属性攻击 等
]]


local M = {}



function M.Hit(data)
    if data.target.OnHit then
        if data.damage > 0 then
            data.target:OnHit(data)
        end
        if data.target.tag == "Building" or
            data.target.isUnderFloor
            then
            return
        end
    else
       -- print(string.format("<color=red>%s</color>",debug.traceback()))
        return
    end

    if data.attr then

        local ab = StringHelper.Split(data.attr,"#")

        local type,cfg = ab[1],{ab[2],ab[3],ab[4],ab[5],ab[6],ab[7]}

        if type == "Ice" then
            local p = tonumber(cfg[1])
            if math.random(100) <= p then
                if not GetTag(data.target,"immune_stationary") then
                    data.target.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = tonumber(cfg[2]) or 3,form = data.from_id,tag = "frozen",})
                end
            end
        end

        if type == "Dizziness" then
            local p = tonumber(cfg[1])
            if math.random(100) <= p then
                if not GetTag(data.target,"immune_stationary") then
                    data.target.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = tonumber(cfg[2]) or 3,form = data.from_id,prefabName="BOOS_xuanyun",tag = "dizziness",})
                end
            end
        end

        if type == "Paralysis" then
            local p = tonumber(cfg[1])
            if math.random(100) <= p then
                if not GetTag(data.target,"immune_stationary") then
                    data.target.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = tonumber(cfg[2]) or 3,form = data.from_id,tag = "paralysis",})
                end
            end
        end

        -- 持续伤害类型
        if type == "Poisoning" or type == "Firing" or type == "Bursting" then
            local damage,duringTime = tonumber(cfg[1]), tonumber(cfg[2]) or 3

            local skill = GameInfoCenter.GetObjSkillByType(data.target, type)
            if skill then
                skill:Refresh({damage = damage, duringTime = duringTime,from_id = data.from_id})
            else

                skill = CreateFactory.CreateSkill({type = type,
                                                    object = data.target,
                                                    damage = damage,
                                                    duringTime = duringTime,
                                                    from_id = data.from_id
                                                    })
                data.target.skill[skill.id] = skill

            end

        end
        if type == "HitBack" then
            local p = tonumber(cfg[1])
            if math.random(100) <= p then
                if data.target.PlayHitBackAnim then
                    local bullet = SpawnBulletManager.GetBulletData(data.bullet_id)
                    if bullet then
                        data.target:PlayHitBackAnim(bullet.base_bullet.gameObject)
                    end
                end
            end
        end
        if type == "Slow" then
            local speed_size,duringTime = tonumber(cfg[1]), tonumber(cfg[2]) or 3
            local skill = GameInfoCenter.GetObjSkillByType(data.target, type)
            if skill then
                skill:Refresh({speed_size = speed_size, duringTime = duringTime,})
            else
                skill = CreateFactory.CreateSkill({type = type,
                                                    object = data.target,
                                                    speed_size = speed_size,
                                                    duringTime = duringTime,
                                                    })
                data.target.skill[skill.id] = skill
            end
        end
    end

end



function M.HitMonster(data)

end




function M.HitHero(data)
    
end




return M