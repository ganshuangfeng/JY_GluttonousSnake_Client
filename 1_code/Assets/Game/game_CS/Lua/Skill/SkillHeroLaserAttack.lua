local basefunc = require "Game/Common/basefunc"

SkillHeroLaserAttack = basefunc.class(Skill)
local M = SkillHeroLaserAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)

    self.data = data or self.data
    self.data.cd = self.data.object.config.hit_space
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
    self.attackTargetId = self:GetAttackTarget()
    -- dump(self.attackTargetId,"<color=yellow>攻击目标？？？？？？？？？？</color>")
    if not self.attackTargetId then
        return
    end

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
        self:AttackTarget()
        --攻击完成
        self:After()
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
    self.cd = self.data.cd
end

--自己的逻辑------
function M:Aim(dt)
    self.aimRotSpeed = 6
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
    local hit_data = self.object.data
    for k, v in pairs(self.object.config) do
        hit_data[k] = v
    end
    local damage = {}
    hit_data.hitOrgin = {id = self.object.id}

    if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
        hit_data.hitTarget = {id = self.attackTargetId}
    else
        hit_data.hitTarget = {angel = math.random(0, 360)}
    end

    for i = 1, #self.object.config.damage do
        damage[i] = self.object.config.damage[i] + (self.object.data.level - 1) * self.object.config.damage[i] * 0.1
    end
    hit_data.damage = damage
    if self.object.config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[self.object.config.audio_name].audio_name)
    end
    hit_data.fire_pos = self.object.canno_pre.transform:Find("@fire_target").transform.position

    -- dump(hit_data,"<color=yellow>发起攻击</color>")
    Event.Brocast("hero_attack_monster", hit_data)
end
