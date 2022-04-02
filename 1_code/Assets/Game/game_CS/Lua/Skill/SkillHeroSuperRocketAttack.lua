--火箭是超级技能

local basefunc = require "Game/Common/basefunc"

SkillHeroSuperRocketAttack = basefunc.class(Skill)
local shootSeq
local M = SkillHeroSuperRocketAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)

    --self.data = data or self.data
    self:InitData(data)

    self:CD()
end

---- 初始化数据，refresh 也会调用这个
function M:InitData(data)
    M.super.InitData(self , data)

    self.data = data or self.data
end

function M:Exit(data)
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    M.super.Exit(self)
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
    if shootSeq then 
        self:Finish()
        return 
    end

    self:CastRocket()

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
    --[[local extra_hit_cfg = GameConfigCenter.PretreatmentBulletData(self.object.config.ext_bullet_id,"hero")
    for k, v in pairs(extra_hit_cfg) do
        hit_data[k] = v
    end--]]

     --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetBulletConfig(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end


    
    hit_data.hitOrgin = {id = self.object.id}

    --#按照英雄目前的转向发射子弹
    if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
        hit_data.hitTarget = {id = self.attackTargetId}
    else
        hit_data.hitTarget = {angel = 0}
    end
    
    --[[local damage = {}
    for i = 1, #self.object.config.damage do
        damage[i] = self.object.config.damage[i] + (self.object.data.level - 1) * self.object.config.damage[i] * 0.1
    end--]]
    hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[bullet_config.audio_name].audio_name)
    end
    hit_data.fire_pos = self.object.canno_pre.transform:Find("@fire_target").transform.position
    hit_data.start_pos = self.object.transform.position

    hit_data.extendData =  {
        color = self.object.data.hero_color,
        tag = "HeroSuperSkill",
    }

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

function M:CastRocket()
    local skillCfg
    if self.object.data.star and self.object.data.star >= 2 then
        skillCfg = {
            [1] = {
                bulletPrefabName = {"daodan_xiao"},
                attackFrom = "hero",
                moveWay = {"LineMove"},
                hitStartWay = {"IsHitPlane"},
                hitEffect = {"RocketBombHit"},
                hitType = {"SkillRocketSmallShoot"},
                speed = {20,},
                bulletNumDatas = {16,},
                damage = {300,},
                bulletLifeTime = 6,
                remark = "火箭1",
                shouji_pre = "baozha_xiao",
                attr = {},
            },
            [2] ={
                bulletPrefabName = {"daodan_da","daodan_xiao"},
                attackFrom = "hero",
                moveWay = {"LineMove","LineMove"},
                hitStartWay = {"IsHitPlane","IsHitSomeOne"},
                hitEffect = {"RocketBombHit","PenetrateHit"},
                hitType = {"SkillRocketSmallShoot","CircleShoot"},
                speed = {30,10},
                bulletNumDatas = {1,30},
                damage = {300,300},
                bulletLifeTime = 6,
                remark = "火箭2",
                shouji_pre = {"baozha_da","baozha_xiao",},
                attr = {},
            },
        }
    else
        skillCfg = {
            [1] = {
                bulletPrefabName = {"daodan_xiao"},
                attackFrom = "hero",
                moveWay = {"LineMove"},
                hitStartWay = {"IsHitPlane"},
                hitEffect = {"RocketBombHit"},
                hitType = {"SkillRocketSmallShoot"},
                speed = {20,},
                bulletNumDatas = {16,},
                damage = {300,},
                bulletLifeTime = 6,
                remark = "火箭1",
                shouji_pre = "baozha_xiao",
                attr = {},
            },
        }
    end
    
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    local allHero = GameInfoCenter.GetAllHero()
    local fx_guangs = {}
    for k,hero in pairs(allHero) do
        local fx_guang = NewObject("GX_guang",hero.transform)
        fx_guangs[#fx_guangs + 1] = fx_guang
    end
    local HeroHead = GameInfoCenter.GetHeroHead()
    local fx_guang = NewObject("GX_guang",HeroHead.transform:Find("@head_img"))
    fx_guangs[#fx_guangs + 1] = fx_guang

    shootSeq = DoTweenSequence.Create()
	for i = 1,#skillCfg do
		shootSeq:AppendCallback(function()
			local shootData = basefunc.deepcopy(skillCfg[i])
			shootData.fire_pos = heroQueuePrefab.transform.localPosition
			if i == 1 then
				shootData.hitOrgin = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hitTarget = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hero_tran = heroQueuePrefab.transform
			else
				local pos = CSModel.GetUITo3DPoint(Vector3.zero)

				pos = Vector3.New(pos.x,pos.y + 3,pos.z)
				shootData.hitOrgin = {pos = pos}
				shootData.hitTarget = {pos = pos}
			end
			ExtendSoundManager.PlaySound(audio_config.cs.battle_rocket.audio_name)
			Event.Brocast("hero_attack_monster",shootData)
		end)
		if i == 1 then
			shootSeq:AppendInterval(2)
		end
	end
	shootSeq:AppendInterval(4)
	shootSeq:OnForceKill(function()
        --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 0.2})
        if fx_guangs then
            for k,v in ipairs(fx_guangs) do
                Destroy(v)
            end
            fx_guangs = nil
        end
        CSModel.camera2d.transform.localPosition = Vector3.zero
        CSPanel.map.transform.localPosition = Vector3.zero
        shootSeq = nil
        self:After()
	end)

end
