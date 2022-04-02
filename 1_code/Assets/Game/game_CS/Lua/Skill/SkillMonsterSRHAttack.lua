local basefunc = require "Game/Common/basefunc"

SkillMonsterSRHAttack = basefunc.class(SkillMonsterNorAttack)
local M = SkillMonsterSRHAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
end

function M:Before()
	if self.data.beforeCd then
		self.cd = self.data.beforeCd
		self.skillState = SkillState.before
		self.cd = self.data.beforeCd
		self.object.anim_pay.speed = 0
		self.attackWarningPre = MonsterComAttackWarningPrefab.Create(self.object,self.cd,function()
		end,
		function()
			self.object.anim_pay.speed = 1
			self.attackWarningPre = nil    
		end,self.data.flashTime)
		self.warningEffectSeq = CSEffectManager.PlayBossWarning("BossWarning5",self.object.transform.position,self.data.beforeCd,0,function(tran)
			tran.transform:SetParent(self.object.transform)
			tran.transform.localScale =  Vector3.New(2/tran.transform.parent.localScale.x,2/tran.transform.parent.localScale.y,2/tran.transform.parent.localScale.z)
		end)
	else
		self:Trigger()
	end
end

function M:Exit(data)
    M.super.Exit(self)

    self:ClearResources()
end

---- 清理资源
function M:ClearResources()
	if self.create_bullet_id then
        --print("<color=yellow>xxx-------------SetBulletFinsh</color>")
        SpawnBulletManager.SetBulletFinsh( self.create_bullet_id )
    end

    if self.warningEffectSeq then
        self.warningEffectSeq:Kill()
        self.warningEffectSeq = nil
    end

    if self.attackWarningPre then
        self.attackWarningPre:Exit()
        self.attackWarningPre = nil
    end
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
    --- ���ӵ�������
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

	hit_data.hitOrgin = {id = self.object.id}

	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {id = self.attackTargetId}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end

	--local damage = {}
	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }  --{self.object.config.damage}
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[bullet_config.audio_name].audio_name)
	end
	
	--[[if self.data.bullet_id then
		local config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
		for k ,v in pairs(config) do
			hit_data[k] = v
		end
	end--]]

	hit_data.startCall = function(bullet_data)
        --print("<color=yellow>xxx-------------call_startCall</color>")
		self.create_bullet_id = bullet_data.bullet_id
	end
	
	hit_data.bind_object_id = {self.object.id}
	
	Event.Brocast("monster_attack_hero", hit_data)
end
