local basefunc = require "Game/Common/basefunc"

SkillMonsterBossBaWangFlowerSuperAttack = basefunc.class(Skill)
local M = SkillMonsterBossBaWangFlowerSuperAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
end

function M:MakeLister()
    self.lister = {}
	self.lister["BawangFlowerSuperAttack"] = basefunc.handler(self,self.Ready)
end

function M:Init(data)
	M.super.Init( self )

	self.data = data or self.data
	self:CD()
end

function M:Before()
	M.super.Before(self)
	local radius_spac = 3
	local start_radius = 10
	local num_spac = 6
	self.start_num = 8
	self.target_positions = {}
	for num = 1,self.start_num do 
		local angle = num / self.start_num * 2 * math.pi
		local radius = start_radius
		local vec = Vector3.New(math.cos(angle),math.sin(angle),0) * radius
		local pos = vec + self.object.transform.position
		self.target_positions[#self.target_positions + 1] = pos
	end
	if self.data.beforeCd then
		for k,pos in ipairs(self.target_positions) do
			CSEffectManager.PlayBossWarning("BossWarning6",pos,self.data.beforeCd + 0.5,0)
		end
	end
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 0
    self.cd = self.data.cd
end


function M:Ready(data)
	M.super.Ready(self)
	if data then
		self.attack_num = data.attack_num
		self.super_skill_attack_num = data.super_skill_attack_num
	end
    -- 发送攻击状态数据包
    self:SendStateData()
end

--触发
function M:Trigger()
	M.super.Trigger(self)
	if self.attack_num and self.super_skill_attack_num then
		Event.Brocast("stageRefreshBossNorAttackValue",self.attack_num,self.super_skill_attack_num)
	end   
	--直接创建地刺进行攻击
	self.object.anim_pay:Play("attack",0,0)
	local seq = DoTweenSequence.Create()
	--四层地刺
	-- for i = 1,4 do
		seq:AppendCallback(function()
			for k,pos in ipairs(self.target_positions) do
				--创建子弹
				local hit_data = self.object.data
				for k,v in pairs(self.object.config) do
					hit_data[k] = v
				end
				local damage = {}
				hit_data.hitOrgin = { pos = self.object.transform.position }
				hit_data.hitTarget = {pos = pos}
				hit_data.damage = { self.object.data.damage }
				ExtendSoundManager.PlaySound(audio_config.cs.boss_attack1.audio_name)
				hit_data.bulletPrefabName = {"GW_srh_zidan"}
				hit_data.attackFrom = "monster"
				hit_data.moveWay = {"DropGrenades",}
				hit_data.hitEffect = {"BombHit#3",} 
				hit_data.hitStartWay = {"IsReachTarget"}
				hit_data.hitType = {"SectorShoot"}
				hit_data.bulletLifeTime = 4
				hit_data.speed = {10}
				hit_data.bulletNumDatas = {1}
				hit_data.shouji_pre = "GW_srh_baoza"
				hit_data.attr = {"Slow#50#0.2"}
			
				Event.Brocast("monster_attack_hero", hit_data)
				Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})
			end
		end)
		seq:AppendInterval(0.0)
	-- end
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		self:After()
	end)
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
end