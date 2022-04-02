-- 创建时间:2021-06-25
local basefunc = require "Game/Common/basefunc"

BaseBullet = basefunc.class()
local C = BaseBullet
function C.Create(data)
    return C.New(data)
end

function C:Ctor(data)
    self.data = data
    self.stage = data.stage
    self.speed = data.speed[self.stage]
    --检测周期计时器
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
    --当前的检测函数
    local func_name = data.hitStartWay[self.stage]
    local ab = StringHelper.Split(func_name,"#")
    local type,cfg = ab[1],{ab[2],ab[3],ab[4],ab[5],ab[6],ab[7]}
    self.curr_func = self[type]
    --从配置表来的扩展参数
    self.extend_config_data = cfg
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
    --结束的英雄
    self.end_hero_id = data.end_hero_id

    local check_func = self[data.hitStartWay[self.stage].."_Check"]
    self.curr_func_check = check_func and check_func or function()
        if self.start_pos and (self.end_pos or self.fireAngle) then
            return true
        end
    end
    if not self:curr_func_check(data) then
        self = nil
        return nil
    end
    self.prefab = CachePrefabManager.Take(data.bulletPrefabName[self.stage], nil,20)
    -- dump(self.prefab,"")
    self.gameObject = self.prefab.prefab.gameObject
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(false)
    self.transform.parent = data.bulletParent
    if self.fireAngle then
        self.angle = self.fireAngle - 90
    else
        self.angle = Vec2DAngle(Vector3.New(self.end_pos.x-self.start_pos.x,self.end_pos.y - self.start_pos.y,self.end_pos.z-self.start_pos.z)) - 90
    end
    self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
    self.transform.position = self.start_pos
    self.collider = self.gameObject:GetComponent("ColliderBehaviour")
    if not IsEquals(self.collider) then
        self.collider = self.gameObject:AddComponent(typeof(LuaFramework.ColliderBehaviour))
        self.collider.luaTableName = "BaseBullet"
    end
    self.collider:SetLuaTable(self)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.02)
    seq:AppendCallback(function()
        if IsEquals(self.gameObject) then
            self.gameObject:SetActive(true)
        end
        self.create_seq = nil
    end)
    self.create_seq = seq

    if self.attackFrom == "hero" then
        SetLayer(self.gameObject,"hero_zd")
    elseif self.attackFrom == "monster" then
        SetLayer(self.gameObject,"monster_zd")
    end

    self.colliderGameObjectIDList = {}
    self.colliderGameObjectIDListWithOutRepeat = {}
end
--检测此次攻击的某个阶段是否已经击中怪物
function C:CheckIsHadHit(id,stage)   
    if stage > 0 then
        local data = SpawnBulletManager.HitHistroy[self.data.Attack_ID][stage]
        for i = 1,#data do
            if data[i].id == id and os.clock() - data[i].time < 100 then
                return true
            end
        end
    end
end

function C:OnTriggerEnter2D(collision)
	-- dump(collision,"<color=red>555555555555555555555555555555</color>")
    self.colliderGameObjectIDList[#self.colliderGameObjectIDList + 1] = tonumber(collision.gameObject.name)
    local IsCanAdd = true
    for i = 1,#self.colliderGameObjectIDListWithOutRepeat do
        if self.colliderGameObjectIDListWithOutRepeat[i].id == tonumber(collision.gameObject.name) then
            IsCanAdd = false
            break
        end
    end
    if IsCanAdd then
        local closestPoint = collision.bounds:ClosestPoint(self.transform.position);
        self.colliderGameObjectIDListWithOutRepeat[#self.colliderGameObjectIDListWithOutRepeat + 1] = {id = tonumber(collision.gameObject.name),closestPoint = closestPoint}
    end
end

function C:OnTriggerStay2D(collision)
	-- dump(collision,"<color=red>555555555555555555555555555555</color>")
    self.colliderGameObjectIDList[#self.colliderGameObjectIDList + 1] = tonumber(collision.gameObject.name)
    local IsCanAdd = true
    for i = 1,#self.colliderGameObjectIDListWithOutRepeat do
        if self.colliderGameObjectIDListWithOutRepeat[i].id == tonumber(collision.gameObject.name) then
            IsCanAdd = false
            break
        end
    end
    if IsCanAdd then
        local closestPoint = collision.bounds:ClosestPoint(self.transform.position);
        self.colliderGameObjectIDListWithOutRepeat[#self.colliderGameObjectIDListWithOutRepeat + 1] = {id = tonumber(collision.gameObject.name),closestPoint = closestPoint} 
    end
end

function C:CheckIsHitSome(time_elapsed)
    self.check_space = self.check_space + time_elapsed
    self.curr_life_time = self.curr_life_time + time_elapsed
    if self.curr_life_time >= self.bulletLifeTime then
        SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        return
    end
    if self.check_space > 0.1 then 
        self.check_space = 0
        return self:curr_func(time_elapsed)
    end
end

function C:GetLifeTime()
    return {curr_life_time = self.curr_life_time,bullet_life_time = self.bulletLifeTime}
end

function C:Exit()
    if self.create_seq then
        self.create_seq:Kill()
        self.create_seq = nil
    end
    CachePrefabManager.Back(self.prefab)
    self = nil
end
---------------------------------------------------------------函数库
--只检测一个击中,不计算伤害,将这个值带入到effect处理
function C:IsHitSomeOne()
    if self.attackFrom == "monster" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local id = self.colliderGameObjectIDListWithOutRepeat[1].id
            if ObjectCenter.GetObj(id) and not self:CheckIsHadHit(id,self.stage - 1) then
                return {id = id,closestPoint = self.colliderGameObjectIDListWithOutRepeat[1].closestPoint}
            end
        end
        
    elseif self.attackFrom == "hero" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local id = self.colliderGameObjectIDListWithOutRepeat[1].id
            local monster = ObjectCenter.GetObj(id)
            if monster and not self:CheckIsHadHit(id,self.stage - 1) then
                return {id = id,closestPoint = self.colliderGameObjectIDListWithOutRepeat[1].closestPoint}
            end
        end
    end
end


function C:IsLockHit()
    if self.attackFrom == "hero" then
        local id = self.end_monster_id
        local monster = ObjectCenter.GetObj(id)
        if monster then
            if tls.pGetDistance(self.transform.position,monster.transform.position) < 0.1 then
                return {id = id}
            end
        end
    end
end


--判断光圈是否击中了某个敌人，判定范围跟子弹的生成时间有关
function C:IsGQHitSomeOne()
    if self.attackFrom == "monster" then
        
        local hero = GameInfoCenter.GetMonsterAttkByDisMin()
        if hero then
            local Min = 1 + (self.data.effect_speed or 1) * self.curr_life_time

            local v1 = hero.transform.position
            local v2 = self.transform.position
            local dis = tls.pGetDistanceSqu(v1,v2)
            if dis <= Min*Min then
                return {id = hero.id}
            end
        end

    elseif self.attackFrom == "hero" then
        local Monsters = GameInfoCenter.GetAllMonsters()
        local Min = 1 + (self.data.effect_speed or 1) * self.curr_life_time
        for k,v in pairs(Monsters) do
            local v1 = v.transform.position
            local v2 = self.transform.position
            local dis = tls.pGetDistanceSqu(v1,v2)
            if dis <= Min*Min then
                return {id = v.id}
            end
        end
    end
end

--接触地面就爆炸
function C:IsHitPlane()
    if CSModel.Is2D then
        if self.hitTarget and self.hitTarget.pos then
            if self.transform.position.y < self.hitTarget.pos.y then
                return {pos = self.transform.position}
            end
        end
    else
        if self.transform.position.z > -0.2 then
            return {pos = self.transform.position}
        end
    end
end

--接触地面就爆炸或者击中怪物爆炸
function C:IsHitPlaneOrIsHitSomeOne()
    return self:IsHitSomeOne() or self:IsHitPlane()
end

function C:IsReachTarget()
    local check_range = self.speed / 7
    if tls.pGetDistanceSqu(self.transform.position,self.end_pos) < check_range then
        return {pos = self.end_pos}
    end
end

function C:IsHitSomeOneOrIsReachTarget()
    return self:IsHitSomeOne() or self:IsReachTarget()
end

function C:IsTimeOver()
    --备注，这类数值如果能不走配置就不走配置，否则配置表会逐渐膨胀
    local max_time = 0.7
    if self.curr_life_time > max_time then
        return {pos = self.transform.position}
    end
end

--接触到地面或者时间到了
function C:IsHitSomeOneOrTimeOver()
    return self:IsHitSomeOne() or self:IsTimeOver()
end


--激光式的伤害，直接连接两端
function C:IsLockLaser()
    --判断英雄是否已经有激光了
    if self.attackFrom == "monster" then
        return {id = self.end_hero_id}
    elseif self.attackFrom == "hero" then
        local start_pos = self.start_pos
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        if monster and start_pos then
            --自动调整攻击目标
            local attack_range = 20
            local dis = tls.pGetDistanceSqu(start_pos,monster.transform.position)
            if dis > attack_range * attack_range then
                local monsters_in_range = GameInfoCenter.GetMonstersRangePos(start_pos,attack_range)
                if monsters_in_range and next(monsters_in_range) then
                    self.end_monster_id = GameInfoCenter.GetMonsterDisMin(start_pos).id
                    local BulletData = SpawnBulletManager.GetBulletData(self.bullet_id)
                    if BulletData then
                        BulletData.move_func.end_monster_id = self.end_monster_id
                        BulletData.hit_effect.end_monster_id = self.end_monster_id
                        BulletData.data.end_monster_id = self.end_monster_id
                        monster = ObjectCenter.GetObj(self.end_monster_id)
                    end
                else
                    self.end_monster_id = nil
                    local BulletData = SpawnBulletManager.GetBulletData(self.bullet_id)
                    if BulletData then
                        BulletData.move_func.end_monster_id = self.end_monster_id
                        BulletData.hit_effect.end_monster_id = self.end_monster_id
                        BulletData.data.end_monster_id = self.end_monster_id
                    end
                    return
                end
            end 
        end
        if monster then
            return {id = self.end_monster_id}
        end
    end
end
--激光武器的检查
function C:IsLockLaser_Check()
    if not self.end_pos then return false end
    for k,v in pairs(SpawnBulletManager.GetBulletAllData()) do
        if self.attackFrom == "monster" then
            if v.data.end_hero_id == self.end_hero_id and v.data.bullet_id ~= self.data.bullet_id and v.data.start_monster_id == self.start_monster_id then
                return false
            end
        end
        if self.attackFrom == "hero" then
            --这个炮塔正在释放大激光，就不再释放小激光
            if v.data.start_hero_id == self.start_hero_id and v.data.hitStartWay[1] == "IsLockBigLaser" then
                return false
            end
            -- 同一时间，一个对象攻击另外一个对象只能有一条激光，如果继续调用攻击，那么激光的时间会延长
            if v.data.start_hero_id == self.start_hero_id and v.data.bullet_id ~= self.data.bullet_id and v.data.end_monster_id == self.end_monster_id then
                SpawnBulletManager.SetBulletFinsh(v.data.heroId)

                return true
            end
        end
    end
    return true
end
--大激光式的伤害，直接连接两端
function C:IsLockBigLaser()
    --判断英雄是否已经有激光了
    if self.attackFrom == "monster" then
        return {id = self.end_hero_id}
    elseif self.attackFrom == "hero" then
        local start_pos = self.start_pos
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        if monster then
            return {id = self.end_monster_id}
        else
            if self.curr_life_time < self.bulletLifeTime then
                local new_max_life_time = self.bulletLifeTime - self.curr_life_time
                local new_data = basefunc.deepcopy(self.data)
                new_data.bulletLifeTime = new_max_life_time
                AttackManager.Create(new_data)
            end
            SpawnBulletManager.SetBulletFinsh(self.data.bullet_id)
        end
    end
end
--扇形范围的检测（类似喷射火焰的类型）
function C:IsSectorFire()
    local cheak_angle = 36
    local radius = 9
    if self.attackFrom == "monster" then
        local monster = ObjectCenter.GetObj(self.start_monster_id)
        if monster then
            self.start_pos = ObjectCenter.GetObj(self.start_monster_id).transform.position
            local heros = GameInfoCenter.GetHeroRangePos(self.start_pos,radius)
            local result = {}
            for i = 1,#heros do
                local dir = heros[i].transform.position - self.start_pos
                if Vector3.Angle(dir,self.transform.up) < cheak_angle/2 then
                    result[#result + 1] = heros[i]
                end
            end
            return {targets = result}
        end
    elseif self.attackFrom == "hero" then 
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            self.start_pos = ObjectCenter.GetObj(self.start_hero_id).transform.position
            local monsters = GameInfoCenter.GetMonstersRangePos(self.start_pos,radius)
            local result = {}
            for i = 1,#monsters do
                local dir = monsters[i].transform.position - self.start_pos
                if Vector3.Angle(dir,self.transform.up) < cheak_angle/2 then
                    result[#result + 1] = monsters[i]
                end
            end
            return {targets = result}
        end
    end
end

--持续时间内,持续计算伤害
function C:IsHitSome(not_once)
    if self.attackFrom == "monster" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local result = {}
            for i = 1,max do
                local id = self.colliderGameObjectIDListWithOutRepeat[i].id
                local closestPoint = self.colliderGameObjectIDListWithOutRepeat[i].closestPoint
                if ObjectCenter.GetObj(id) and not self:CheckIsHadHit(id,self.stage - 1) then
                    result[#result + 1] = {id = id,closestPoint = closestPoint}
                end
            end
            self.colliderGameObjectIDListWithOutRepeat = {}
            return {targets = result}
        end
        
    elseif self.attackFrom == "hero" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local result = {}
            for i = 1,max do
                local id = self.colliderGameObjectIDListWithOutRepeat[i].id
                local closestPoint = self.colliderGameObjectIDListWithOutRepeat[i].closestPoint
                local monster = ObjectCenter.GetObj(id)
                if monster and monster.state == "normal" and not self:CheckIsHadHit(id,self.stage - 1) then
                    result[#result + 1] = {id = id,closestPoint = closestPoint}
                end
            end
            self.colliderGameObjectIDListWithOutRepeat = {}
            return {targets = result}
        end
    end
end

--持续时间内,只计算一次伤害
function C:IsHitSomeOnce() 
    if self.attackFrom == "monster" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local result = {}
            for i = 1,max do
                local id = self.colliderGameObjectIDListWithOutRepeat[i].id
                local closestPoint = self.colliderGameObjectIDListWithOutRepeat[i].closestPoint
                if ObjectCenter.GetObj(id) and not self:CheckIsHadHit(id,self.stage) then
                    result[#result + 1] = {id = id,closestPoint = closestPoint}
                end
            end
            self.colliderGameObjectIDListWithOutRepeat = {}
            return {targets = result}
        end
        
    elseif self.attackFrom == "hero" then
        local max = #self.colliderGameObjectIDListWithOutRepeat
        if max >= 1 then
            local result = {}
            for i = 1,max do
                local id = self.colliderGameObjectIDListWithOutRepeat[i].id
                local closestPoint = self.colliderGameObjectIDListWithOutRepeat[i].closestPoint
                local monster = ObjectCenter.GetObj(id)
                if monster and monster.state == "normal" and not self:CheckIsHadHit(id,self.stage) then
                    result[#result + 1] = {id = id,closestPoint = closestPoint}
                end
            end
            self.colliderGameObjectIDListWithOutRepeat = {}
            return {targets = result}
        end
    end
end

--贯穿类的激光用这个
function C:HitLineCross()
    local radius = 300
    if self.attackFrom == "hero" then
        local monsters = GameInfoCenter.GetMonstersRangePos(self.start_pos,radius)
        self.start_pos = ObjectCenter.GetObj(self.start_hero_id).transform.position
        local result = {}
        for i = 1,#monsters do
            local dir = monsters[i].transform.position - self.start_pos
            local angle = Vector3.Angle(dir,self.transform.up)
            local dis = MathExtend.Sin(angle) * tls.pGetDistance(monsters[i].transform.position,self.start_pos)
            if dis < 1 then
                result[#result + 1] = monsters[i]
            end
        end
        return {targets = result}
    end
end


function C:HitOnSelfPos()
    return {pos = self.transform.position}
end

function C:IsRayCastLaserLock()
    local BulletData = SpawnBulletManager.GetBulletData(self.bullet_id)
    if BulletData.move_func and BulletData.move_func.dis and BulletData.move_func.hit_obj then
        local check_range = 1
        if math.abs(BulletData.move_func.dis - BulletData.move_func.cur_dis) < check_range then
            local ret = {id = BulletData.move_func.hit_obj.id}
            BulletData.move_func.hit_obj = nil
            return ret
        end 
    end
end

function C:TimeOver()
    local total_time = tonumber(self.extend_config_data[1])
    if not self.seq then
        
        self.warntx = NewObject("BossWarning_JiShi",self.transform) 
        self.warntx_node = self.warntx.transform:Find("node").transform
        self.warntx_warning_anim_node = self.warntx_node.transform:Find("@warning_anim_node").transform
        self.warntx.transform.localScale = Vector3.New(1/1.5,1/1.5,1/1.5)
        self.seq = DoTweenSequence.Create()
        self.seq:Append(self.warntx_warning_anim_node:DOScale(Vector3.one, total_time - 0.1))
    end
    
    if total_time - self.curr_life_time <= 0.1 then
        Destroy(self.warntx)
        return {pos = self.transform.position}
    end
end

