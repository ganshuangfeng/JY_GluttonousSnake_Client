local basefunc = require "Game/Common/basefunc"

SkillMonsterBoss3SuperAttack = basefunc.class(Skill)
local M = SkillMonsterBoss3SuperAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

	self.at_range = self.object.config.attack_range
    self.at_range_squ = self.at_range * self.at_range
    self.at_range_squ = 16
    self.targetV = nil
    self.posList = {}
    self.posList["myPos"] = {key="myPos", pos=Vector3.New(self.object.transform.position.x, self.object.transform.position.y, 0)}
    self.superRandom = 0


    ---- 处理多个子弹
    if type(self.data.bullet_id) ~= "table" then
        self.data.bullet_id = { self.data.bullet_id }
    end
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:CD()
end


function M:CD()
	M.super.CD(self)
	self.data.cd = 5
	self.cd = self.data.cd
	
end

function M:Active(data)
	M.super.Active(self)
    self.attType = data.attType
end

function M:Ready(data)
	M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end


function M:FrameUpdate(dt)
	if not self.object or not self.object.isLive then 
		self:Exit()
		return 
	end
    M.super.FrameUpdate(self, dt)
    
    self.superRandom = self.superRandom + math.random(1, 100)
end

--技能CD
function M:OnCD(dt)
    if self.skillState ~= SkillState.cd then
        return
    end
    self.cd = self.cd - dt

    if self.cd <= 0 then
        self:Active({attType = self.superRandom%2 })
    end

end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end
    --攻击
    if not self.attType or self.attType == 1 then
        self:AttackTarget1()
    else
        self:AttackTarget2()
    end
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("superAttack", {skillObject = self , animName="attack2"}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("superAttackSkill", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
    self.targetV = nil
end

function M:GetTargetPos()
	local maxRandomNum = 10
	local pos = {x=0, y=0}
	local RandomPos = function ()
		pos.x = math.random(1, 24) - 12
		pos.y = math.random(1, 40) - 20
	end
	local Check = function ()
		for k,v in pairs(self.posList) do
			if ((v.pos.x-pos.x)*(v.pos.x-pos.x) + (v.pos.y-pos.y)*(v.pos.y-pos.y)) < self.at_range_squ then
				return false
			end
		end
		return true
	end
	if self.posList then
		while ( not Check() and maxRandomNum > 0 ) do
			RandomPos()
			maxRandomNum = maxRandomNum - 1
		end
	end

	return {key=pos.x.."_"..pos.y, pos=Vector3.New(pos.x, pos.y, 0)}
end

function M:AttackTarget1()
	local tp = self:GetTargetPos()
	self.posList[tp.key] = tp

    local bullet_id = self.data.bullet_id[1]
    if not bullet_id then
        return
    end

	local hit_data = {}
	local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(bullet_id)
    basefunc.merge( bullet_config , hit_data )

    hit_data.damage = {self.object.config.damage}
	hit_data.hitOrgin = { pos = tp.pos }
    hit_data.hitTarget = {angel = 0}
    hit_data.attackFrom = "monster"

    --[[hit_data.bulletPrefabName = {"BulletPrefab_duhua_super"}
    hit_data.moveWay = {"BossWaveMove",}
    hit_data.hitEffect = {"ExtraPenetrateHit",} 
    hit_data.hitStartWay = {"IsHitSome"}
    hit_data.hitType = {"SectorShoot"}
    hit_data.bulletLifeTime = 10
    hit_data.speed = {10}
    hit_data.bulletNumDatas = {1}
    hit_data.attr = {"Poisoning#100"}
--]]
    hit_data.posKey = tp.key
    hit_data.endCall = function (data)
    	self.posList[data.data.posKey] = nil
    end

    self.object.anim_pay.speed = 0
    CSEffectManager.PlayShowAndHideAndCall(
                                CSPanel.map_node,
                                "BossWarning1",
                                nil,
                                tp.pos,
                                2,
                                1.6,
                                function ()
                                    self.object.anim_pay.speed = 1
                                    Event.Brocast("monster_attack_hero", hit_data)
                                end, 
                                function (obj)
                                    obj.transform.localScale = Vector3.New(0.4, 0.8, 0)
                                end)

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end

	--攻击完成
    self:After()
end

function M:AttackTarget2()
    self.isForceOffset = false

    local bullet_id = self.data.bullet_id[2]
    if not bullet_id then
        return
    end

    local hit_data = {}
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(bullet_id)
    basefunc.merge( bullet_config , hit_data )


    hit_data.damage = {self.object.config.damage}
    hit_data.hitOrgin = { pos = self.object.transform.position }
    hit_data.hitTarget = {angel = 0}
    hit_data.attackFrom = "monster"

    --[[hit_data.bulletPrefabName = {"jg_she_hongse"}
    hit_data.moveWay = {"LineCrossMove",}
    hit_data.hitEffect = {"ExtraPenetrateHit",} 
    hit_data.hitStartWay = {"HitLineCross"}
    hit_data.hitType = {"SectorShoot"}
    hit_data.bulletLifeTime = 0.5
    hit_data.speed = {20}
    hit_data.bulletNumDatas = {1}
    hit_data.attr = {"Poisoning#100"}--]]

    hit_data.endCall = function (data)
        if not self.isForceOffset then
            self.isForceOffset = true
            local head = GameInfoCenter.GetHeroHead()
            if head then
                head.fsmLogic:addWaitStatusForUser( "forceOffset" , {pos=self.object.transform.position, speed = 20})
            end
        end
    end

    local angel = math.random(0, 120)
    self.angel = {angel, angel+120, angel+240}
    for i = 1, 3 do
        CSEffectManager.PlayShowAndHideAndCall(
                                    CSPanel.map_node,
                                    "BossWarning2",
                                    nil,
                                    self.object.transform.position+Vector3.New(0, -2, 0),
                                    2,
                                    1.6,
                                    function ()
                                        hit_data.hitTarget = {angel = self.angel[i]}
                                        Event.Brocast("monster_attack_hero", hit_data)
                                    end, 
                                    function (obj)
                                        obj.transform.rotation = Quaternion.Euler(0, 0, self.angel[i])
                                    end)
    end

    --ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end

    
    --攻击完成
    self:After()
end
