local basefunc = require "Game/Common/basefunc"

SkillMonsterShiRenFlowerJYAttack = basefunc.class(Skill)
local M = SkillMonsterShiRenFlowerJYAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data

    self.range = self.object.attack_range + 0.5
    self.range2 = self.range * self.range
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:Active()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 3
    self.cd = self.data.cd
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
    if not self.attackTargetId then
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

    self:AttackTarget()

    --攻击完成
    self:After()
end

function M:Trigger(data)
	M.super.Trigger(self)
end

function M:Before()
    if self.data.beforeCd then
        self.cd = self.data.beforeCd
        self.skillState = SkillState.before

        if self.isBreak then
            self.object.anim_pay.speed = 0

            self.breakColor = math.random(1, 4)
        
            self.chargePre = ChargePrefab.Create(function ()
                self.object.anim_pay.speed = 1
                self.chargePre = nil            
            end
            ,function ()
                -- self:Trigger()
            end,
            self,
            self.object.node.transform)
        else
            self.cd = self.data.beforeCd
            self.object.anim_pay.speed = 0
            self.attackWarningPre = MonsterComAttackWarningPrefab.Create(self.object,self.cd,function()
                --在cd里面触发过了这里就不需要写了
                -- self:Trigger()
            end,
            function()
                self.object.anim_pay.speed = 1
                self.attackWarningPre = nil    
            end,self.data.flashTime)

			self.attackTargetPos1 = ObjectCenter.GetObj(self.attackTargetId).transform.position
            self.attackTargetPos2 = self.attackTargetPos1 + Vector3.New(math.random(-9,9),math.random(-9,9),0)
            self.attackTargetPos3 = self.attackTargetPos1 + Vector3.New(math.random(-6,6),math.random(-6,6),0)
            self.attackTargetPos4 = self.attackTargetPos1 + Vector3.New(math.random(-9,9),math.random(-9,9),0)
            self.attackTargetPos5 = self.attackTargetPos1 + Vector3.New(math.random(-6,6),math.random(-6,6),0)
            
            local seq = DoTweenSequence.Create()

            for i = 1,5 do
                seq:AppendInterval((i - 1) * 0.1)
                seq:AppendCallback(
                    function()
                        CSEffectManager.PlayBossWarning("BossWarning6",self["attackTargetPos"..i],1.9,0)
                    end
                )
            end
        end
    else
        self:Trigger()
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


function M:GetAttackTarget()
	-- 找最近的英雄
	local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
	if _obj then
		local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.range2 then
			return _obj.id
        end
	end
	return nil
end

function M:AttackTarget()
	--[[local hit_data = self.object.data
	for k,v in pairs(self.object.config) do
		hit_data[k] = v
	end--]]
	
	if self.object.anim_pay then
		self.object.anim_pay:Play("attack",0,0)
	end
    local hit_data = {}
    --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

    
	hit_data.hitOrgin = {id = self.object.id}

	

    --local damage = {}
	hit_data.damage = { GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }  --{self.object.config.damage}
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	end
	
	--[[if self.data.bullet_id then
		local config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
		for k ,v in pairs(config) do
			hit_data[k] = v
		end
	end--]]
	self.create_bullet_id = nil

	hit_data.startCall = function(bullet_data)
        --print("<color=yellow>xxx-------------call_startCall</color>")
		self.create_bullet_id = bullet_data.bullet_id
	end
	dump(hit_data,"<color=red> 食人花攻击+++++++ </color>")

    local seq = DoTweenSequence.Create()
    for i = 1,5 do
        
        seq:AppendInterval((i - 1) * 0.1)
        seq:AppendCallback(
            function()
                if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
                    hit_data.hitTarget = {pos = self["attackTargetPos"..i]}
                else
                    hit_data.hitTarget = {angel = math.random(0,360)}
                end
        
                Event.Brocast("monster_attack_hero", hit_data)
            end
        )
    end
end