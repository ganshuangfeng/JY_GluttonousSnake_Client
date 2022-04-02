-- 创建时间:2021-06-25
local basefunc = require "Game/Common/basefunc"

BaseEffectFunc = basefunc.class()
local C = BaseEffectFunc

function C.Create(data)
    return C.New(data)
end

function C:Ctor(data)
    self.attackFrom = data.attackFrom
    self.data = data
    self.check_space = 0
    --生命周期计时器
    self.curr_life_time = 0
    --攻击源头方式
    self.hitOrgin = data.hitOrgin
    --攻击目标方式
    self.hitTarget = data.hitTarget
    --当前攻击阶段
    self.stage = data.stage
    --子弹存在时间
    self.bulletLifeTime = data.bulletLifeTime
    --攻击的来源
    self.attackFrom = data.attackFrom
    
    --当前的子弹ID
    self.bullet_id = data.bullet_id
    --子弹角度
    self.fireAngle = data.fireAngle
    --开始的位置
    self.start_pos = data.start_pos
    --结束的位置 
    self.end_pos = data.end_pos
    
    --开始的英雄
    self.start_hero_id = data.start_hero_id
    --结束的怪物
    self.end_monster_id = data.end_monster_id
    
    --开始的怪物
    self.start_monster_id = data.start_monster_id

    self.data.attr = self.data.attr or {}
    --受击效果
    if  data.shouji_pre then
        if type(data.shouji_pre) == "string" then
            self.shouji_pre = data.shouji_pre
        else
            if data.shouji_pre[self.stage] == "nil" then
                self.shouji_pre = nil
            else
                self.shouji_pre = data.shouji_pre[self.stage]
            end
        end
    end
    --结束的英雄
    self.end_hero_id = data.end_hero_id
    self.bulletNum = data.bulletNumDatas[self.stage]


    --当前的检测函数
    local func_name = data.hitEffect[self.stage]
    local ab = StringHelper.Split(func_name,"#")
    local type,cfg = ab[1],{ab[2],ab[3],ab[4],ab[5],ab[6],ab[7]}
    self.curr_func = self[type]
    --从配置表来的扩展参数
    self.extend_config_data = cfg
end

function C:Go(hit_info,ID)
    self:curr_func(hit_info,ID)
end
--记录已经攻击的对象（id可以使怪物ID或者英雄ID）
function C:AddHadHit(id)
    SpawnBulletManager.HitHistroy[self.data.Attack_ID][self.stage][#SpawnBulletManager.HitHistroy[self.data.Attack_ID][self.stage] + 1] = {id = id,time = os.clock()}
end

function C:GoNextStage(ID,hitOrgin,hitTarget)
    if ID then
        self.stage = self.stage + 1
        self.data.stage = self.stage
        if self.stage <= #self.data.bulletNumDatas then
            local new_data = basefunc.deepcopy(self.data)
            new_data.fire_pos = nil
            new_data.hitOrgin = hitOrgin or {pos = Vector3.New(self.last_hit_pos.x,self.last_hit_pos.y,self.last_hit_pos.z)}
            if self.data.hitType[self.stage] == "Lock" then
                new_data.hitTarget = self:FindTarget()
            else
                new_data.hitTarget = hitTarget or {angel = Vec2DAngle(Vector3.New(self.end_pos.x-self.start_pos.x,self.end_pos.y - self.start_pos.y,self.end_pos.z-self.start_pos.z)) - 90}
            end            
            SpawnBulletManager.Fire(new_data)
        end
        SpawnBulletManager.SetBulletFinsh(ID)
    end
end

--寻找下一个目标 这个目标不能是自己
function C:FindTarget()
    local hitTarget = nil
    if self.attackFrom == "hero" then
        local data = GameInfoCenter.GetMonstersRangePos(self.last_hit_pos,100)
        local m = nil
        for k ,v in pairs(data) do
            if v.id ~= self.end_monster_id then
                m = v
                break
            end
        end
        if m then
            hitTarget = {id = m.id}
        else
            hitTarget = {angel = math.random(0,360)}
        end
    elseif self.attackFrom == "monster" then
        local data = GameInfoCenter.GetHeroRangePos(self.last_hit_pos,100)
        local h = nil
        for k ,v in pairs(data) do
            if v.id ~= self.end_hero_id then
                h = v
                break
            end
        end
        if h then
            hitTarget = {id = m.id}
        else
            hitTarget = {angel = math.random(0,360)}
        end
    end
    return hitTarget
end

function C:HitHero(ID,hit_info)
    Event.Brocast("hit_hero",{from_id = self.start_monster_id,vampire_percent = self.data.vampire_percent,bullet_id = ID,damage = self.data.damage[self.stage] or self.data.damage[1], id = hit_info.id,attr = self.data.attr[self.stage]})
end

function C:HitMonster(ID,hit_info)
    Event.Brocast("hit_monster",{from_id = self.start_hero_id,vampire_percent = self.data.vampire_percent,bullet_id = ID,damage = self.data.damage[self.stage] or self.data.damage[1], id = hit_info.id,attr = self.data.attr[self.stage], extendData=self.data.extendData})

end

function C:Exit()
    self = nil
end

---------------------------------------------------------------函数库

--接触》消失》反馈伤害 （名字暂定）
function C:SampleHit(hit_info,ID)
    self.last_hit_pos = hit_info.pos
    local effect_flag = false
    --最终导致的结果
    if hit_info.pos then
        self.last_hit_pos = hit_info.pos
    end

    if self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(hit_info.id)
        if monster then
            local bullet = SpawnBulletManager.GetBulletData(ID)
            if bullet then
                if bullet.base_bullet then
                    self.last_hit_pos = bullet.base_bullet.transform.position
                end
            end
            if not self.last_hit_pos then
                self.last_hit_pos = monster.transform.position
            end
            self:AddHadHit(hit_info.id)
            self:HitMonster(ID,hit_info)
            if self.shouji_pre and not effect_flag then
                if IsEquals(monster.transform) then
                    if self.shouji_pre then
                        local tx_pos = hit_info.closestPoint or self.last_hit_pos
                        if type(self.shouji_pre) == "string" then
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                        else
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                        end
                    end
                    effect_flag = true
                end
            end
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
    elseif self.attackFrom == "monster" then
        local hero = ObjectCenter.GetObj(hit_info.id)
        if hero then
            local bullet = SpawnBulletManager.GetBulletData(ID)
            if bullet then
                if bullet.base_bullet then
                    self.last_hit_pos = bullet.base_bullet.transform.position
                end
            end
            if not self.last_hit_pos then
                self.last_hit_pos = hero.transform.position
            end
            self:AddHadHit(hit_info.id)
            self:HitHero(ID,hit_info)
            if self.shouji_pre and not effect_flag then
                if IsEquals(hero.transform) then
                    if self.shouji_pre then
                        local tx_pos = hit_info.closestPoint or self.last_hit_pos
                        if type(self.shouji_pre) == "string" then
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                        else
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                        end
                    end
                    effect_flag = true
                end
            end
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
    end
    if self.last_hit_pos then
        -- local boom = CachePrefabManager.Take("Boom", nil, 10)
        -- boom.prefab.gameObject.transform.parent = self.bullet_parent
        -- boom.prefab.gameObject.transform.position = self.last_hit_pos
        local tx_pos = hit_info.closestPoint or self.last_hit_pos
        if self.shouji_pre and not effect_flag then
            local tx_pos = hit_info.closestPoint or self.last_hit_pos
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
            else
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
            end
        end
    -- Timer.New(function() CachePrefabManager.Back(boom) end,0.5,1):Start()
        self:GoNextStage(ID)
    else
        SpawnBulletManager.SetBulletFinsh(ID)
    end
end

--接触》爆炸》消失》反馈伤害 （名字暂定）
function C:BombHit(hit_info,ID)
    -- dump(self.extend_config_data,"<color=red>爆炸++++++++++++++++++++++++</color>")
    self.last_hit_pos = nil
    if self.attackFrom == "monster" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos  
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
        if self.last_hit_pos then
            local hit_range = tonumber(self.extend_config_data[1]) or 3
            local heros = GameInfoCenter.GetHeroRangePos(self.last_hit_pos,hit_range)
            for i = 1,#heros do
                self:AddHadHit(heros[i].id)
                self:HitHero(ID,{id = heros[i].id})
            end
        end
    elseif self.attackFrom == "hero" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
        if self.last_hit_pos then
            local hit_range = tonumber(self.extend_config_data[1]) or 3
            local id_list = FindTargetFunc.FindAllMonsterAndBoxWithID(hit_range,self.last_hit_pos)-- GameInfoCenter.GetMonstersRangePos(self.last_hit_pos,hit_range)
            for i = 1,#id_list do
                self:AddHadHit(id_list[i])
                self:HitMonster(ID,{id = id_list[i]})
            end
        end
    end

    if self.last_hit_pos then
        -- local boom = CachePrefabManager.Take("Boom1", nil, 10)
        -- boom.prefab.gameObject.transform.parent = self.bullet_parent
        -- boom.prefab.gameObject.transform.position = hit_info.pos
        -- boom.prefab.gameObject.transform.localScale = Vector3.New(2,2,2)
        -- Timer.New(function() CachePrefabManager.Back(boom) end,0.5,1):Start()
        --受击的特效大小，默认是以半径为3为标准
        if self.shouji_pre then
            local tx_pos = hit_info.closestPoint or self.last_hit_pos
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre,nil,self.extend_config_data[1] / 3)
            else
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage],nil,self.extend_config_data[1] / 3)
            end
        end
        self:GoNextStage(ID)
    end
end

--接触》爆炸》反馈伤害 （名字暂定）
function C:PenetrateBombHit(hit_info,ID)
    if self.bomb_hitted then return end
    self.last_hit_pos = nil
    if self.attackFrom == "monster" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos  
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        end
        if self.last_hit_pos then
            local heros = {}
            local heroHead = GameInfoCenter.GetHeroHead(self.last_hit_pos,3)
            if tls.pGetDistanceSqu(heroHead.transform.position,self.last_hit_pos) <= 3 then
                heros[#heros + 1] = heroHead
            end
            for i = 1,#heros do
                self:AddHadHit(heros[i].id)
                self:HitHero(ID,{id = heros[i].id})
            end
        end
    elseif self.attackFrom == "hero" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
        if self.last_hit_pos then
            local hit_range =  self.data.hit_range or 3
            local monsters = GameInfoCenter.GetMonstersRangePos(self.last_hit_pos,hit_range)
            dump(monsters,"<color=red>怪物+++++++++++++</color>")
            for i = 1,#monsters do
                self:AddHadHit(monsters[i].id)
                self:HitMonster(ID,{id = monsters[i].id})
            end
            self.bomb_hitted = true
        end
    end

    if self.last_hit_pos then
        -- local boom = CachePrefabManager.Take("Boom1", nil, 10)
        -- boom.prefab.gameObject.transform.parent = self.bullet_parent
        -- boom.prefab.gameObject.transform.position = hit_info.pos
        -- boom.prefab.gameObject.transform.localScale = Vector3.New(2,2,2)
        -- Timer.New(function() CachePrefabManager.Back(boom) end,0.5,1):Start()
        if self.shouji_pre then
            local tx_pos = hit_info.closestPoint or self.last_hit_pos
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
            else
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
            end
        end
    end
end
--直接传递收到攻击者的ID列表 集体简单攻击
function C:ExtraSampleHit(hit_info,ID)
    if self.attackFrom == "monster" then

    elseif self.attackFrom == "hero" then
        for i = 1,#hit_info.targets do
            self:SampleHit({id = hit_info.targets[i].id,closestPoint = hit_info.targets[i].closestPoint})
        end
    end
end

--#火箭的爆炸逻辑震屏和特效
function C:RocketBombHit(hit_info,ID)
    self.last_hit_pos = nil
    if self.attackFrom == "monster" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos  
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
        if self.last_hit_pos then
            local heros = {}
            local heroHead = GameInfoCenter.GetHeroHead(self.last_hit_pos,3)
            if tls.pGetDistanceSqu(heroHead.transform.position,self.last_hit_pos) <= 3 then
                heros[#heros + 1] = heroHead
            end
            for i = 1,#heros do
                self:AddHadHit(heros[i].id)
                self:HitHero(ID,{id = heros[i].id})
            end
        end
    elseif self.attackFrom == "hero" then
        if hit_info.pos then
            self.last_hit_pos = hit_info.pos
        elseif hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
        if self.last_hit_pos then
            -- if self.data.prefab then
            --     CachePrefabManager.Back(self.data.prefab)
            --     self.data.prefab = nil
            -- end
            local hit_range = 3
            local monsters = GameInfoCenter.GetMonstersRangePos(self.last_hit_pos,hit_range)
            for i = 1,#monsters do
                self:AddHadHit(monsters[i].id)
                self:HitMonster(ID,{id = monsters[i].id})
            end
        end
    end

    if self.last_hit_pos then
        -- local boom = CachePrefabManager.Take("Boom1", nil, 10)
        -- boom.prefab.gameObject.transform.parent = self.bullet_parent
        -- boom.prefab.gameObject.transform.position = hit_info.pos
        -- boom.prefab.gameObject.transform.localScale = Vector3.New(2,2,2)
        -- Timer.New(function() CachePrefabManager.Back(boom) end,0.5,1):Start()
        if self.shouji_pre then
            local tx_pos = hit_info.closestPoint or self.last_hit_pos
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
            else
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
            end
        end
        ExtendSoundManager.PlaySound(audio_config.cs.battle_rocket_boom.audio_name)
        Event.Brocast("ui_shake_screen_msg", {t=0.3, range=0.6,})
        CSEffectManager.PlayAllScreenEffect("JS_liangguang")
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(0.5)
        seq:AppendCallback(function()
            CSEffectManager.CloseAllScreenEffect("JS_liangguang")
        end)
        self:GoNextStage(ID)
    end
end
--普通激光
function C:LaserHit(hit_info,ID)

    --不需要清空self.last_hit_pos
    if self.attackFrom == "monster" then
        if hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
            self:AddHadHit(hit_info.id)
            self:HitHero(ID,hit_info)
        else
            if self.last_hit_pos then
                self:GoNextStage(ID)
            end
        end
    elseif self.attackFrom == "hero" then
        if hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
            self:AddHadHit(hit_info.id)

            if self.shouji_pre then
                if not IsEquals(self.TXprefab) then
                    self.TXprefab = NewObject(self.shouji_pre[self.stage],ObjectCenter.GetObj(hit_info.id).transform)
                    GameObject.Destroy(self.TXprefab,0.5)
                end
            end
            self:HitMonster()
        else
            if self.last_hit_pos then
                self:GoNextStage(ID)
            end
        end
    end
end
--大激光
function C:BigLaserHit(hit_info,ID)

    --不需要清空self.last_hit_pos
    if self.attackFrom == "monster" then
        if hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
            self:AddHadHit(hit_info.id)
            self:HitHero(ID,hit_info)
        else
            if self.last_hit_pos then
                -- self:GoNextStage(ID)
            end
        end
    elseif self.attackFrom == "hero" then
        if hit_info.id and ObjectCenter.GetObj(hit_info.id) then
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
            self:AddHadHit(hit_info.id)
            self:HitMonster(ID,hit_info)
        else
            if self.last_hit_pos then
                if self.shouji_pre then
                    local tx_pos = hit_info.closestPoint or self.last_hit_pos
                    if type(self.shouji_pre) == "string" then
                        CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                    else
                        CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                    end
                end
                self:GoNextStage(ID)
            end
        end
    end
end
--集体攻击穿透 接触不消失
function C:ExtraPenetrateHit(hit_info,ID)
    --用于范围伤害 一个子弹可以命中多次
    if self.attackFrom == "monster" then
        for i = 1,#hit_info.targets do
            self:PenetrateHit({id = hit_info.targets[i].id,closestPoint = hit_info.targets[i].closestPoint})
            self.had_hit_map = {}
        end
    elseif self.attackFrom == "hero" then
        for i = 1,#hit_info.targets do
            self:PenetrateHit({id = hit_info.targets[i].id,closestPoint = hit_info.targets[i].closestPoint})
            self.had_hit_map = {}
        end
    end
end

--穿透(接触不消失)
function C:PenetrateHit(hit_info,ID)
    self.had_hit_map = self.had_hit_map or {}
    if self.attackFrom == "hero" then
        if self.had_hit_map[hit_info.id] == true then

        else
            self.had_hit_map[hit_info.id] = true
            if ObjectCenter.GetObj(hit_info.id) and ObjectCenter.GetObj(hit_info.id).isLive then
                self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
                self:AddHadHit(hit_info.id)
                self:HitMonster(ID,hit_info)
                if self.shouji_pre then
                    local tx_pos = hit_info.closestPoint or self.last_hit_pos
                    if type(self.shouji_pre) == "string" then
                        CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                    else
                        CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                    end
                end
            end
        end
    
    elseif self.attackFrom == "monster" then
        if self.had_hit_map[hit_info.id] == true then
        else
            self.had_hit_map[hit_info.id] = true
            self.last_hit_pos = ObjectCenter.GetObj(hit_info.id).transform.position
            self:AddHadHit(hit_info.id)
            self:HitHero(ID,hit_info)
            if self.shouji_pre then
                local tx_pos = hit_info.closestPoint or self.last_hit_pos
                if type(self.shouji_pre) == "string" then
                    CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                else
                    CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                end
            end
        end
    end

    if self.last_hit_pos then

    end
end

--接触》消失》反馈伤害 (蛇王专用 击中敌人后不会进入第二阶段)
function C:SnakeSampleHit(hit_info,ID)
    self.last_hit_pos = hit_info.pos
    local effect_flag = false
    --最终导致的结果
    if hit_info.pos then
        self.last_hit_pos = hit_info.pos
    end

    if self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(hit_info.id)
        if monster then
            local bullet = SpawnBulletManager.GetBulletData(ID)
            if bullet then
                if bullet.base_bullet then
                    self.last_hit_pos = bullet.base_bullet.transform.position
                end
            end
            if not self.last_hit_pos then
                self.last_hit_pos = monster.transform.position
            end
            self:AddHadHit(hit_info.id)
            Event.Brocast("hit_monster",{bullet_id = ID,damage = self.data.damage[self.stage], id = hit_info.id,attr = self.data.attr[self.stage], extendData=self.data.extendData})
            if self.shouji_pre and not effect_flag then
                if IsEquals(monster.transform) then
                    if self.shouji_pre then
                        local tx_pos = hit_info.closestPoint or self.last_hit_pos
                        if type(self.shouji_pre) == "string" then
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                        else
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                        end
                    end
                    effect_flag = true
                end
            end
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
    elseif self.attackFrom == "monster" then
        local hero = ObjectCenter.GetObj(hit_info.id)
        if hero then
            local bullet = SpawnBulletManager.GetBulletData(ID)
            if bullet then
                if bullet.base_bullet then
                    self.last_hit_pos = bullet.base_bullet.transform.position
                end
            end
            if not self.last_hit_pos then
                self.last_hit_pos = hero.transform.position
            end
            self:AddHadHit(hit_info.id)
            Event.Brocast("hit_hero",{bullet_id = ID,damage = self.data.damage[self.stage], id = hit_info.id,attr = self.data.attr[self.stage]})
            if self.shouji_pre and not effect_flag then
                if IsEquals(hero.transform) then
                    if self.shouji_pre then
                        local tx_pos = hit_info.closestPoint or self.last_hit_pos
                        if type(self.shouji_pre) == "string" then
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
                        else
                            CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
                        end
                    end
                    effect_flag = true
                end
            end
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
    end
    if self.last_hit_pos then
        -- local boom = CachePrefabManager.Take("Boom", nil, 10)
        -- boom.prefab.gameObject.transform.parent = self.bullet_parent
        -- boom.prefab.gameObject.transform.position = self.last_hit_pos
        if self.shouji_pre and not effect_flag then
            local tx_pos = hit_info.closestPoint or self.last_hit_pos
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre)
            else
                CSEffectManager.PlayBulletBoom({position = tx_pos},self.shouji_pre[self.stage])
            end
        end
    -- Timer.New(function() CachePrefabManager.Back(boom) end,0.5,1):Start()
        if hit_info.pos then
            self:GoNextStage(ID)
        else
            SpawnBulletManager.SetBulletFinsh(ID)
        end
    else
        SpawnBulletManager.SetBulletFinsh(ID)
    end
end