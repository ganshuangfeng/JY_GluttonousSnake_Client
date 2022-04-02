-- 创建时间:2021-06-25

SpawnBulletManager = {}
local M = SpawnBulletManager
ExtRequire("Game.CommonPrefab.Lua.BaseBullet")
ExtRequire("Game.CommonPrefab.Lua.BaseMoveFunc")
ExtRequire("Game.CommonPrefab.Lua.BaseEffectFunc")
local basefunc = require "Game/Common/basefunc"
local Bullets = {}
M.config = {}
M.HitHistroy = {}
local Curr_ID = 0
local Curr_Num = 0

function M.InitOneBuild(data)
    Curr_ID = Curr_ID + 1
    data.bullet_id = Curr_ID
    M.HitHistroy[data.Attack_ID] = M.HitHistroy[data.Attack_ID] or {}
    M.HitHistroy[data.Attack_ID][data.stage] = M.HitHistroy[data.Attack_ID][data.stage] or {}
    --基础子弹
    data = M.AnalyseData(data)
    local base_bullet = BaseBullet.Create(data)
    --刚创建的时候暂时隐藏，避免闪烁
    --构建成功
    if base_bullet.gameObject then
        base_bullet.gameObject:SetActive(false)
        Curr_Num = Curr_Num + 1
        --子弹移动方法
        local move_func = BaseMoveFunc.Create(data)
        --触发后的攻击效果
        local hit_effect = BaseEffectFunc.Create(data)
        
        Bullets[Curr_ID] = {bullet_id = Curr_ID,
                            base_bullet = base_bullet,
                            data = data,
                            move_func = move_func,
                            endCall = data.endCall,
                            isLive = true,
                            hit_effect = hit_effect}
        if data.startCall then
            data.startCall(Bullets[Curr_ID])
        end
    end
end

function M.RemoveByHeroID(id)
    for k ,v in pairs(Bullets) do
        if v.data and v.data.start_hero_id and v.data.start_hero_id == id then
            M.SetBulletFinsh(k)
        end
    end
end

function M.Fire(data)
    local num = data.bulletNumDatas[data.stage]
    --第一个阶段并且只有一颗子弹的情况下，直接调用就可以了
    data = M.AnalyseData(data)
    if num == 1 and data.stage == 1 and data.hitType[data.stage] ~= "SkillRocketSmallShoot" and data.hitType[data.stage] ~= "SkillTankShoot" then
        M.InitOneBuild(data)
        return
    end
    local func_name = data.hitType[data.stage]
    local ab = StringHelper.Split(func_name,"#")
    local hitType,extend_config_data = ab[1],{ab[2],ab[3],ab[4],ab[5],ab[6],ab[7]}
    if hitType == "Lock" then
        if data.attackFrom == "hero" then
            --如果不需要这里帮忙寻找目标，而且已经只需要一个目标并且已经有一个目标
            if num == 1 and data.hitTarget.id then
                local new_data = basefunc.deepcopy(data)
                new_data.hitTarget = {id = data.hitTarget.id}
                M.InitOneBuild(new_data)
                return
            end

            local monsters = GameInfoCenter.GetMonstersRangePos(data.start_pos,100)
            local num = #monsters < num and #monsters or num
            for i = 1,num do
                local new_data = basefunc.deepcopy(data)
                new_data.hitTarget = {id = monsters[i].id}
                M.InitOneBuild(new_data)
            end
        elseif data.attackFrom == "monster" then
            --如果不需要这里帮忙寻找目标，而且已经只需要一个目标并且已经有一个目标
            if num == 1 and data.hitTarget.id then
                local new_data = basefunc.deepcopy(data)
                new_data.hitTarget = {id = data.hitTarget.id}
                M.InitOneBuild(new_data)
                return
            end

            local heros = GameInfoCenter.GetHeroRangePos(data.start_pos,100)
            local num = #heros < num and #heros or num
            for i = 1,num do
                local new_data = basefunc.deepcopy(data)
                new_data.hitTarget = {id = heros[i].id}
                M.InitOneBuild(new_data)
            end
        end
    elseif hitType == "CircleShoot" then
        local angel = 360 / num
        local base_angle = M.GetBaseAngel(data)
        for i = 1,num do
            local new_data = basefunc.deepcopy(data)
            new_data.hitTarget = {angel = angel * i + base_angle}
            M.InitOneBuild(new_data)
        end
    elseif hitType == "SectorShoot" then
        local angel = (data.angle or tonumber(extend_config_data[1]) or 30) / num
        local base_angle = M.GetBaseAngel(data)
        for i = 1,num do
            local new_data = basefunc.deepcopy(data)
            local xishu = 1
            if i % 2 == 0 then
                xishu = -1
            end
            new_data.hitTarget = {angel = angel * math.floor(i/2) * xishu + base_angle + 90}
            M.InitOneBuild(new_data)
        end
    elseif hitType == "VolleyShoot" then
        local angel = M.GetBaseAngel(data) + 90
        local space = 1
        for i = 1,num do
            local xishu = 1
            if i % 2 == 0 then
                xishu = -1
            end
            local start_pos = {z = 0}
            local new_data = basefunc.deepcopy(data)
            local length = space * xishu * math.floor(i/2)
            local y_offset = MathExtend.Sin(angel - 270) * length
            local x_offset = MathExtend.Cos(angel - 270) * length
            start_pos.x = x_offset + data.start_pos.x
            start_pos.y = y_offset + data.start_pos.y
            new_data.hitOrgin = {pos = start_pos}
            new_data.hitTarget = {angel = angel}
            M.InitOneBuild(new_data)
        end
        
    elseif hitType == "DartleShoot" then    
        local time_space = tonumber(extend_config_data[1]) or 0.06
        local seq = DoTweenSequence.Create()
        for i = 1,num do
            seq:AppendCallback(function()
                local new_data = basefunc.deepcopy(data)
                M.InitOneBuild(new_data)
            end)
            seq:AppendInterval(time_space)
        end
    elseif hitType == "GQShoot" then
        local angel = 45 / num
        local base_angle = M.GetBaseAngel(data)
        local seq = DoTweenSequence.Create()
        for i = 1,num do
            local new_data = basefunc.deepcopy(data)
            new_data.hitTarget = {angle = base_angle}
            -- new_data.hitOrgin = {pos = data.start_pos}
            seq:AppendCallback(function()
                M.InitOneBuild(new_data)
            end)
            seq:AppendInterval(0.15)
        end
    elseif hitType == "SectorAndDartleShoot" then
        local angel = 160 / num
        local base_angle = M.GetBaseAngel(data)
        local seq = DoTweenSequence.Create()
        local time_space = 0.06
        for i = 1,num do
            local new_data = basefunc.deepcopy(data)
            local xishu = 1
            if i % 2 == 0 then
                xishu = -1
            end
            new_data.hitTarget = {angel = angel * math.floor(i/2) * xishu + base_angle + 90}
            seq:AppendCallback(function()
                M.InitOneBuild(new_data)
            end)
            seq:AppendInterval(time_space)
        end
    -------------------↑-公用------------------------
    -------------------分界线----------------------------
    -------------------↓-私用-----------------------------    
    elseif hitType == "SkillRocketSmallShoot" then
        --火箭技能的发射，均匀在发射点的多个方向投射
        local angle = 360/num
        local radius = 6
        --火箭的高度(可能需要在屏幕外)
        local height = 30
        local seq = DoTweenSequence.Create()
        local monsters
        if data.hero_tran then
            monsters = GameInfoCenter.GetMonstersRangePos(data.hero_tran.transform.position,radius)
        end
        for i = 1,num do
            local interval_rdn = 0
            local for_angle = tls.pForAngle(math.rad(angle * i))
            if num == 1 then
                for_angle = Vector3.zero
            end
            local target_pos = data.start_pos
            if monsters and next(monsters) then
                target_pos = monsters[math.random(1,#monsters)].transform.position
            else
                if data.hero_tran then
                    target_pos = tls.pAdd(data.hero_tran.transform.localPosition,tls.pMul(for_angle,radius)) 
                else
                    target_pos = tls.pAdd(data.start_pos,tls.pMul(for_angle,radius))
                end
            end
            target_pos = Vector3.New(target_pos.x,target_pos.y,data.start_pos.z)
            local origin_pos = Vector3.New(target_pos.x,target_pos.y + height,data.start_pos.z)
            local new_data = basefunc.deepcopy(data)
            new_data.hitTarget = {pos = target_pos}
            new_data.hitOrgin = {pos = origin_pos}
            -- new_data.speed[data.stage] = math.random() * 20 + new_data.speed[data.stage]
            seq:InsertCallback(math.random() * 2.4,function()
                local prefab = CachePrefabManager.Take("daodan_yz",nil,10)
                prefab.prefab:SetParent(GameObject.Find("3DNode/map").transform)
                prefab.prefab.prefabObj.transform.position = target_pos
                new_data.prefab = prefab
                M.InitOneBuild(new_data)
                local _seq = DoTweenSequence.Create()
                _seq:AppendInterval(1.5)
                _seq:AppendCallback(function()
                    CachePrefabManager.Back(prefab)
                end)
            end)
        end
        seq:AppendInterval(3)
    elseif hitType == "SkillTankShoot" then
        local new_data = basefunc.deepcopy(data)
        local camera_origin = CSModel.GetUITo3DPoint(Vector3.zero)
        local origin_pos = camera_origin + Vector3.New(5,-5,0)
        new_data.hitOrgin = {pos = origin_pos}
        new_data.hitTarget = {pos = camera_origin}
        M.InitOneBuild(new_data)
    elseif hitType == "SkillCrabRollDownShoot"then
        --boss的范围落石技能 在一个方形区域内随机落下
        if not data.rect then
            data.rect = {x = 5,y = 5}
        end
        --下落时间段
        local interval_max = 0.3
        local seq = DoTweenSequence.Create()
        for i = 1,num do
            local new_data = basefunc.deepcopy(data)
            local _rdn_area = i % 4
            local rdn_x = math.random() * new_data.rect.x / 2
            local rdn_y = math.random() * new_data.rect.y / 2
            local start_pos
            if _rdn_area == 1 then
                start_pos = Vector3.New(rdn_x,rdn_y,0)
            elseif _rdn_area == 2 then
                start_pos = Vector3.New(rdn_x,-rdn_y,0)
            elseif _rdn_area == 3 then
                start_pos = Vector3.New(-rdn_x,rdn_y,0)
            elseif _rdn_area == 0 then
                start_pos = Vector3.New(-rdn_x,-rdn_y,0)
            end
            new_data.hitTarget = {pos = data.start_pos + start_pos}
            local height = 3
            new_data.hitOrgin = {pos = data.start_pos + start_pos + Vector3.New(0,height,0)}
            seq:InsertCallback(math.random() * interval_max, function()
                M.InitOneBuild(new_data)
            end)
        end
    end
end

function M.FrameUpdate(time_elapsed)
    for k,v in pairs(Bullets) do
        if v.isLive then
            v.move_func:Go(v.base_bullet,time_elapsed)
            if Bullets[k] and Bullets[k].isLive then
                v.base_bullet.gameObject:SetActive(true)
                local hit_info = v.base_bullet:CheckIsHitSome(time_elapsed)
                if hit_info and Bullets[k] then
                    v.hit_effect:Go(hit_info,v.bullet_id)
                end
            end
        end
    end
end

function M.GetBulletData(ID)
    return Bullets[ID]
end

function M.GetBulletAllData()
    return Bullets
end

function M.SetBulletFinsh(ID)
    if Bullets[ID] and Bullets[ID].isLive then
        Curr_Num = Curr_Num - 1
        if Bullets[ID].endCall then
            Bullets[ID].endCall(Bullets[ID])
        end
        Bullets[ID].move_func:Exit()
        Bullets[ID].base_bullet:Exit()
        Bullets[ID].hit_effect:Exit()
        Bullets[ID].isLive = false
    end
end

function M.RemoveById(ID)
    M.SetBulletFinsh(ID)
end

function M.RemoveAll()

    for id,v in pairs(Bullets) do
        M.SetBulletFinsh(id)
    end
    Bullets = {}
end

function M.GetCurNum()
    return Curr_Num
end

function M.GetBaseAngel(data)
    local base_angle = data.hitTarget.angel
    if not base_angle and data.end_pos then
        base_angle = Vec2DAngle(Vector3.New(data.end_pos.x-data.start_pos.x,data.end_pos.y - data.start_pos.y,data.end_pos.z-data.start_pos.z)) - 90
    end
    base_angle = base_angle or 0
    return base_angle
end
--筛选一遍数据，如果目标已经不存在的，重新制定一个目标，将攻击源头和攻击目标的信息整合为不移动的点，
--如果子弹是锁定的，而目标会移动（如激光），同时保留了目标的ID信息，可以通过ID获取目标实时的位置。

function M.AnalyseData(data)
    data.start_hero_id = nil
    data.end_hero_id = nil
    data.start_monster_id = nil
    data.end_monster_id = nil
    local Vec2toVec3 = function(vec)
        return Vector3.New(vec.x,vec.y,vec.z or 0)
    end
    if data.attackFrom == "hero" then
        --子弹来自于英雄
        if data.hitOrgin.id then
            data.start_hero_id = data.hitOrgin.id
            local hero = ObjectCenter.GetObj(data.start_hero_id)
            if hero then
                data.start_pos = hero.transform.position
            end
        elseif data.hitOrgin.pos then
            data.start_pos = Vec2toVec3(data.hitOrgin.pos)
        end
        if data.hitTarget.id then
            data.end_monster_id = data.hitTarget.id
            local monster = ObjectCenter.GetObj(data.end_monster_id)
            if monster then
                data.end_pos = monster.transform.position
            else
                if GameInfoCenter.GetMonsterDisMin(data.start_pos) then
                    data.end_pos = GameInfoCenter.GetMonsterDisMin(data.start_pos).transform.position
                    data.end_monster_id = GameInfoCenter.GetMonsterDisMin(data.start_pos).id
                end
            end
        elseif data.hitTarget.pos then
            data.end_pos = Vec2toVec3(data.hitTarget.pos)
        elseif data.hitTarget.angel then
            data.fireAngle = data.hitTarget.angel
        end

        --最高优先级
        if data.fire_pos then
            data.start_pos = data.fire_pos
        end

    elseif data.attackFrom == "monster" then
        --子弹来自于怪物
        if data.hitOrgin.id then
            data.start_monster_id = data.hitOrgin.id
            local monster = ObjectCenter.GetObj(data.start_monster_id)
            if monster then
                if not data.hitOrgin.pos then
                    data.start_pos = monster.transform.position
                else
                    data.start_pos = Vec2toVec3(data.hitOrgin.pos)
                end
            end
        elseif data.hitOrgin.pos then
            data.start_pos = Vec2toVec3(data.hitOrgin.pos)
        end
        if data.hitTarget.id then
            data.end_hero_id= data.hitTarget.id
            local hero = ObjectCenter.GetObj(data.end_hero_id)
            if hero then
                data.end_pos = hero.transform.position
            else
                data.end_pos = GameInfoCenter.GetMonsterDisMin(data.start_pos).transform.position
                data.end_hero_id = GameInfoCenter.GetMonsterDisMin(data.start_pos).data.heroId
            end
        elseif data.hitTarget.pos then
            data.end_pos = Vec2toVec3(data.hitTarget.pos)
        elseif data.hitTarget.angel then
            data.fireAngle = data.hitTarget.angel
        end 

        --最高优先级
        if data.fire_pos then
            data.start_pos = data.fire_pos
        end
    end
    return data
end