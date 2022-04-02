local basefunc = require "Game/Common/basefunc"

SkillHeroSuperLaserAttack = basefunc.class(Skill)
local M = SkillHeroSuperLaserAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)

    self.data = data or self.data

    self.effect_time = 3
    self:CD()
end


function M:Ready(data)
    M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end
    self:GetAttackTarget()
    --瞄准
    self:Aim()

    --攻击
    self:AttackTarget()

    self.effect_time = self.effect_time - dt
    if self.effect_time <= 0 then
        --攻击完成
        self:After()
    end
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
    local range = 8
    if self.attackTargetId then
        local target = ObjectCenter.GetObj(self.attackTargetId)
        if target and target.isLive then
            if tls.pGetDistanceSqu(self.object.transform.position,target.transform.position) <= range then
                return self.attackTargetId
            end
        end
    end
    local md = GameInfoCenter.GetMonsterDisMin(self.object.transform.position)
    if md then
        self.attackTargetId = md.id
        return self.attackTargetId
    end
    self.attackTargetId = nil
    return nil
end

function M:AttackTarget()
    local hit_data = {}
    local extra_hit_cfg = GameConfigCenter.GetHeroExtraConfigByType(self.object.config.type)
    for k, v in pairs(extra_hit_cfg) do
        hit_data[k] = v
    end
    local damage = {}
    hit_data.hitOrgin = {id = self.object.id}

    --#按照英雄目前的转向发射子弹
    if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
        hit_data.hitTarget = {id = self.attackTargetId}
    else
        hit_data.hitTarget = {angel = math.random(0,360)}
    end

    for i = 1, #self.object.config.damage do
        damage[i] = self.object.config.damage[i] + (self.object.data.level - 1) * self.object.config.damage[i] * 0.1
    end
    hit_data.damage = damage
    if self.object.config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[self.object.config.audio_name].audio_name)
    end
    hit_data.fire_pos = self.object.canno_pre.transform:Find("@fire_target").transform.position
    hit_data.start_pos = self.object.transform.position

    -- dump(hit_data,"<color=yellow>发起攻击</color>")
    Event.Brocast("hero_attack_monster", hit_data)
end
function M:OnExtraSkillTrigger(data)
    if self.object and self.object.data then
        if data.hero_color == self.object.config.hero_color then
            self:Ready()
        end
    end
end