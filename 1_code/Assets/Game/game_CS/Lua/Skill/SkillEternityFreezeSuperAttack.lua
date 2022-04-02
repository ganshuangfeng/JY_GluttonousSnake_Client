local basefunc = require "Game/Common/basefunc"

SkillEternityFreezeSuperAttack = basefunc.class(Skill)
local M = SkillEternityFreezeSuperAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)

    self.data = data or self.data

    self:CD()
end


function M:Ready(data)
    M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end


--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
    -- 一直找目标，找到后切换到ready状态
    -- #这里有问题 这个技能不能一直找目标 而是应该直接使用当前英雄的目标
    self.attackTargetId = self:GetAttackTarget()
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end
    --不需要瞄准
    -- self:Aim()

    --攻击
    self:AttackTarget()

    --攻击完成
    self:After()
end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
    self.lister["ExtraSkillTrigger"] = basefunc.handler(self,self.OnExtraSkillTrigger)
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("attack", {skillObject = self}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

--自己的逻辑------
function M:Aim()
    if not self.attackTargetId then
        return
    end

    local target = ObjectCenter.GetObj(self.attackTargetId)
    if not target or not target.isLive then
        return
    end

    AxisLookAt(self.object.turret, target.transform.position, Vector3.right)
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


function M:AttackTarget()
    local hit_data = {}

    -- 从子弹配置中
    local bullet_config = GameConfigCenter.GetBulletConfig(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

    local damage = {}
    hit_data.attackFrom = "hero"
    hit_data.hitOrgin = {id = self.object.id}

    --#按照英雄目前的转向发射子弹
    if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
        hit_data.hitTarget = {id = self.attackTargetId}
    else
        hit_data.hitTarget = {angel = math.random(0,360)}
    end

    hit_data.damage = GetBulletDamageList( self , bullet_config ) -- { GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end
    hit_data.fire_pos = self:FindFirePos()
    hit_data.start_pos = self.object.transform.position

    hit_data.extendData =  {
        color = self.object.data.hero_color,
        tag = "HeroSuperSkill",
    }

    dump(hit_data,"<color=yellow>发起攻击</color>")
    Event.Brocast("hero_attack_monster", hit_data)
end

function M:OnExtraSkillTrigger(data)
    if self.object and self.object.data then
        if data.hero_color == self.object.config.hero_color then
            self:Ready()
        end
    end
end

function M:FindFirePos()
    local firePos = {}
    for i = 1,10 do
        if self["fire_target"..i] then
            firePos[#firePos + 1] = self["fire_target"..i]
        end
    end
    if #firePos == 0 then
        return self.object.transform.position
    else
        return firePos[math.random(1,#firePos)].transform.position
    end
end