local basefunc = require "Game/Common/basefunc"

SkillMonsterNorLaserAttack = basefunc.class(SkillMonsterNorAttack)
local M = SkillMonsterNorLaserAttack

function M:Before()
	M.super.Before(self)
	
	self.warning_obj = NewObject("BossWarning7",MapManager.GetMapNode())
	self.warning_mask = self.warning_obj.transform:Find("@Mask")
	self.warning_obj.transform.position = self.object.transform.position
	self.warning_cd = self.data.beforeCd - 0.4
	self:RefreshWarning()
end

function M:AttackTarget()
	--播放攻击动画
	self.object.anim_pay:Play("attack",0,0)

	local hit_data = {}
	--- 从子弹配置中
    local bullet_config = GameConfigCenter.GetMonsterBulletConfigByID(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

	local damage = {}
	hit_data.hitOrgin = {id = self.object.id,pos = self.object.attack_node.position}
	if self.attackTargetId and ObjectCenter.GetObj(self.attackTargetId) then
		hit_data.hitTarget = {pos = self.target_pos}
	else
		hit_data.hitTarget = {angel = math.random(0,360)}
	end
	
	-- hit_data.hitTarget = {angel = 90}

	hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) } --{self.object.config.damage}
	if bullet_config.audio_name then
		ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name ].audio_name)
	end
	self.create_bullet_id = nil
	hit_data.startCall = function(bullet_data)
		--print("<color=yellow>xxx-------------LayerMonster startCall </color>")
		self.create_bullet_id = bullet_data.bullet_id
	end
	Event.Brocast("monster_attack_hero", hit_data)
	--播放攻击动画
	if self.object.curDir and self.object.anim_pay then
		self.object.anim_pay:Play("attack" .. self.object.curDir,0,0)
	end
	if self.warning_obj then
		Destroy(self.warning_obj)
		self.warning_obj = nil
		self.warning_mask  =nil
	end
end

function M:RefreshWarning()
	if not self.warning_obj then return end
	local my_pos = self.object.transform.position
	local target = GameInfoCenter.GetMonsterAttkByDisMin( my_pos )
	if target then
		self.target_pos = target.transform.position
		self.angle = Vec2DAngle( (self.target_pos - my_pos).normalized )
		self.angle = self.angle % 360
		self.warning_obj.transform.rotation = Quaternion.Euler(0,0,self.angle)
		local dir = target.transform.position - self.object.transform.position
        local hitInfo = nil
        local hitInfos = UnityEngine.Physics2D.RaycastAll(my_pos,dir)
        for i = 0,hitInfos.Length - 1 do
            local m_hitInfo = hitInfos[i]
            local obj_id = tonumber(m_hitInfo.transform.gameObject.name)
			local obj = ObjectCenter.GetObj(obj_id)
			if obj and IsEquals(obj.gameObject) and (obj.gameObject.layer == LayerMask.NameToLayer("hero_head") or obj.gameObject.layer == LayerMask.NameToLayer("MapBuilding")) then
				hitInfo = m_hitInfo
				break
			end
		end
		if hitInfo then
			self.warning_mask.transform.localPosition = Vector3.New(hitInfo.distance,0,0)
		else
			self.warning_mask.transform.localPosition = Vector3.New(100,0,0)
		end

	else
		self.target_pos = nil
		self.warning_mask.transform.localPosition = Vector3.New(100,0,0)
	end
end

function M:FrameUpdate(dt)
	M.super.FrameUpdate(self,dt)
	if self.warning_cd and self.warning_cd > 0 then
		self:RefreshWarning()
		self.warning_cd = self.warning_cd - dt
		if self.warning_cd < 0 then
		end
	end
end

function M:Exit()
	if IsEquals(self.warning_obj) then
		Destroy(self.warning_obj)
	end
	M.super.Exit(self)

	self:ClearResources()
end

---- 清理资源
function M:ClearResources()
	if self.create_bullet_id then
        --print("<color=yellow>xxx-------------SetBulletFinsh</color>")
        SpawnBulletManager.SetBulletFinsh( self.create_bullet_id )
    end

    if self.attackWarningPre then
        self.attackWarningPre:Exit()
        self.attackWarningPre = nil
    end

    if self.warning_obj then
		Destroy(self.warning_obj)
		self.warning_obj = nil
		self.warning_mask  =nil
	end

end
