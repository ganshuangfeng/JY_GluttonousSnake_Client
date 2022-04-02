local basefunc = require "Game/Common/basefunc"

SkillDemonVampireSuperAttack = basefunc.class(Skill)
local M = SkillDemonVampireSuperAttack

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
	local isCan = self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) and ObjectCenter.GetObj(self.attackTargetId).isLive
	if not isCan then
		return
	end
    local hit_data = {}
    hit_data.speed = 30
    hit_data.bullet_num = 1
    hit_data.bullet_prefab_name = "YX_zidna_huo"
    hit_data.move = "LineMove"
    hit_data.hit_start = "IsReachTarget"
    hit_data.shouji_pre = "YX_zidan_huo_shouji"
    hit_data.hit_effect = "BombHit#4"
    hit_data.hit_type = "SectorShoot"
    hit_data.bullet_life_time = 3
    hit_data = GameConfigCenter.PretreatmentBulletData(nil,"hero",hit_data)
    hit_data.damage = { GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }

    hit_data.extendData =  {
        color = self.object.data.hero_color,
        tag = "HeroSuperSkill",
    }
	local base_pos = ObjectCenter.GetObj(self.attackTargetId).transform.position
    hit_data.hitOrgin = {pos = base_pos + Vector3.New(3,40,0)}
    local seq = DoTweenSequence.Create()
    local time_space = 0.3
    for i = 1,8 do        
        seq:AppendCallback(function()
			local target_pos = base_pos + Vector3.New(math.random(-2,2),math.random(-2,2),0)
			hit_data.hitTarget = {pos = target_pos}
            Event.Brocast("hero_attack_monster", hit_data)
        end)
        seq:AppendInterval(time_space)
    end
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