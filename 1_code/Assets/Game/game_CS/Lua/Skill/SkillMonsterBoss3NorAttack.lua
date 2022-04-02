local basefunc = require "Game/Common/basefunc"

SkillMonsterBoss3NorAttack = basefunc.class(Skill)
local M = SkillMonsterBoss3NorAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data

	self:AttackTarget()
end

function M:AttackTarget()
	--[[local hit_data = 
		{
			hitOrgin = {id = self.object.id},
			attackFrom = "monster",
			damage = {self.object.config.damage,},
			hitTarget = {angel = 0},

			bulletPrefabName = {"BulletPrefab_duhua_super"},
			moveWay = {"GQMoveWithSelf"},
			hitStartWay = {"IsHitSome"},
			hitEffect = {"ExtraPenetrateHit"},
			hitType = {"SectorShoot"},
			speed = {5,},
			bulletNumDatas = {1,},
			bulletLifeTime = 99999,
			shouji_pre = "xx_shouji",
			attr = {"Poisoning#100"},
			audio_name = "battle_snow",
			
		}--]]

	local hit_data = {}
	--- 从子弹配置中
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    basefunc.merge( bullet_config , hit_data )

    hit_data.hitOrgin = {id = self.object.id}
    hit_data.attackFrom = "monster"
    hit_data.hitTarget = {angel = 0}
    hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) } -- {self.object.config.damage,}


	Event.Brocast("monster_attack_hero", hit_data)

	--ExtendSoundManager.PlaySound(audio_config.cs.boss_attack3.audio_name)
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
	end

	
end
