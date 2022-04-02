local basefunc = require "Game/Common/basefunc"

SkillHeroShanDianAttack = basefunc.class(Skill)
local M = SkillHeroShanDianAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)
    LuaHelper.GeneratingVar(self.object.canno_pre.transform,self)
    
    --self.data = data or self.data
    --self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")

    self:InitData(data)

    self:CD()
end

---- 初始化数据，refresh 也会调用这个
function M:InitData(data)
    M.super.InitData(self , data)

    self.data = data or self.data
    self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")
end
    

function M:CD()
    self.skillState = SkillState.cd
    self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")
    self.cd = self.data.hit_space
end

function M:Ready(data)
    M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

--CD中
function M:OnCD(dt)
    if self.skillState ~= SkillState.cd then
        return
    end

    --当object的攻击发生变化时，刷新CD
    local object_speed = ModifierSystem.GetObjProp(self.object,"hit_space")
    if object_speed ~= self.data.hit_space then
        self.data.hit_space = object_speed
        self.cd = self.data.hit_space
    end
    self.cd = self.cd - dt

    if self.cd <= 0 then
        self:Active()
    end
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
    -- 一直找目标，找到后切换到ready状态
    local targetId = self:GetAttackTarget()
    if not targetId then
        return
    end

	local target = ObjectCenter.GetObj(targetId)
	if not target or not target.isLive then
		return
	end
	self.targetMonster = target
    self.targetPos = self.targetMonster.transform.position
    self:Ready()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end

    --瞄准
    if self:Aim(dt) then
        --攻击
        if  self:AttackTarget() then
            --攻击完成
            self:After()
        end
    end
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("attack", {skillObject = self}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("norAttack", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.hit_space
end

function M:OnAni(dt)
	if true then return end
	if not self.targetPos then return end
	AxisLookAt(self.object.turret,self.targetPos,Vector3.right)
end

--自己的逻辑------
function M:Aim(dt)
    self.aimRotSpeed = 16
	-- AxisLookAt(self.object.turret,self.targetPos,Vector3.right)
	-- return true

	local tpos = self.targetPos
	local old_rotation = self.object.turret.transform.rotation
	AxisLookAt(self.object.turret,tpos,Vector3.right)
	local tar_rotation = self.object.turret.transform.rotation
	self.object.turret.transform.rotation = old_rotation
	self.object.turret.transform.rotation = Quaternion.Lerp(old_rotation, tar_rotation, dt * self.aimRotSpeed)
	if Quaternion.Angle(self.object.turret.transform.rotation,tar_rotation) <= 4 then
		return true
	end
end

function M:GetAttackTarget()
    if self.object.checkMonsterType == "random" then
        local monsters = GameInfoCenter.GetMonstersRangePos(self.object.transform.position, self.object.attack_range)
        if next(monsters) then
            local mi = math.random(#monsters)
            local mid = monsters[mi].id
            return mid
        end
    elseif self.object.checkMonsterType == "nearest" then
        local md = GameInfoCenter.GetMonsterDisMin(self.object.transform.position)
        if md then
            return md.id
        end
    end

    return nil
end


--再瞄准完成后，对某一个方向一定角度的怪物进行不断切换的攻击
function M:AttackTarget()
    --[[local hit_data = self.object.data
    for k, v in pairs(self.object.config) do
        hit_data[k] = v
    end--]]

    local hit_data = {}
    --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetBulletConfig(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

    
    hit_data.hitOrgin = {id = self.object.id}
    local radius = 20
    local cheak_angle = 30
    if self.targetMonster then
        local monsters = GameInfoCenter.GetMonstersRangePos(self.targetMonster.transform.position,radius)
        local result = {}
        for i = 1,#monsters do
            local dir = monsters[i].transform.position - self.object.turret.transform.position
            if Vector3.Angle(dir,self.object.turret.transform.up) < cheak_angle/2 then
                result[#result + 1] = monsters[i].id
            end
        end
        dump(monsters)
        dump(result)
        hit_data.hitTarget = {id = self.targetMonster.id} -- result[math.random(1,#result)]
    else
        return
    end

    --[[local damage = {}
    for i = 1, #self.object.config.damage do
        damage[i] =  ModifierSystem.GetObjProp(self.object,"damage",self.object.config.damage[i] + (self.object.data.level - 1) * self.object.config.damage[i] * 0.1)
    end--]]
    hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[bullet_config.audio_name].audio_name)
    end
    hit_data.fire_pos = self:FindFirePos()
    hit_data.start_pos = self.object.transform.position

    dump(hit_data,"<color=yellow>发起攻击</color>")
    Event.Brocast("hero_attack_monster", hit_data)
    return true
end

function M:FindFirePos()
    local firePos = {}
    for i = 1,10 do
        if self["fire_target"..i] then
            firePos[#firePos + 1] = self["fire_target"..i]
        end
    end
    if #firePos == 0 then
        return self.fire_target.transform.position
    else
        return firePos[math.random(1,#firePos)].transform.position
    end
end