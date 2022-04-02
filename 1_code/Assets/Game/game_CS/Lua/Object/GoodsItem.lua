--[[物品 道具
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsItem = basefunc.class(Object)
local M = GoodsItem

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	self.data.skill = self.data.skill or 1
	local prefab_name = self.data.prefabName[self.data.skill]
	self.data.parent = self.data.parent or MapManager.GetMapNode()
	local obj = GameObject.Instantiate(GetPrefab(prefab_name), self.data.parent).gameObject
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsItem"
	end

	self.destroy_time = data.destroy_time or 99999
	self.warn_time = self.destroy_time - 2
	self.animator = self.transform:Find("kz"):GetComponent("Animator")
	self.mainTimer = Timer.New(function()
		if IsEquals(self.transform) then
			self.update_time = self.update_time or 0
			self.update_time = self.update_time + 1
			if self.update_time >= self.warn_time and not self.isWarning then
				self.isWarning = true
				self.animator:Play("destroy_warn",0,0)
			end

			if self.update_time >= self.destroy_time then
				GameInfoCenter.RemoveGoodsById(self.id)
			end
		end
	end,1,-1)
	self.mainTimer:Start()
	self.enabled = true

	self.state = "normal"

	self.startTime = 0

	self.autoMove = false
	if self.data.disableAutoMove then
		self.autoMove = false
	end

end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	self.transform.position = self.data.pos


	if self.data.initCallback then
		self.data.initCallback(self)
	end
end

function M:MakeLister()
    self.lister = {}
end

function M:AddMsgListener()
    for m,func in pairs(self.lister) do
        Event.AddListener(m, func)
    end
end

function M:RemoveListener()
    for m,func in pairs(self.lister) do
        Event.RemoveListener(m, func)
    end
    self.lister = {}
end

function M:Exit()
	if self.mainTimer then
		self.mainTimer:Stop()
		self.mainTimer = nil
	end
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()

	if self.data.destoryCallback then
		self.data.destoryCallback(self)
	end

	self:Exit()
end

function M:SetEnable(b)
	self.enabled = b
end

local range = 3
function M:FrameUpdate(timeElapsed)
	local hero_queue = GameInfoCenter.GetHeroHead()

	-- if self.autoMove and self.state ~= "die" then
	-- 	self.startTime = self.startTime + timeElapsed
	-- 	local speed = 0.4 * self.startTime
	-- 	local vec = tls.pSub(hero_queue.transform.position,self.transform.position)
	-- 	vec = tls.pNormalize(vec)
	-- 	vec = tls.pMul(vec,speed)
	-- 	vec = Vector3.New(vec.x,vec.y,vec.z)
	-- 	local scale =  -(self.startTime + 1) * (self.startTime - 2)
	-- 	if scale < 1 then scale = 1 end
	-- 	self.transform.localScale = Vector3.New(scale,scale,scale)
	-- 	self.transform:Translate(vec)
	-- end

	if self.state ~= "die" and tls.pGetDistanceSqu(self.transform.position,hero_queue.transform.position) <= range * range then
		self.state = "die"
		self:CreateSkill()
	end
end


function M:CreateSkill()

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_buff.audio_name)

	local yyobj = self.transform:Find("yinying")
	if yyobj then
		yyobj.gameObject:SetActive(false)
	end

	local animator = self.transform:GetComponent("Animator")
	if animator then animator.enabled = false end

	local skill_cfg = {
		[1] = {name ="SkillItemAddAttackDamage",},
		[2] = {name ="SkillItemAddAttackSpeed" , refresh_type = "cover"},
		[3] = {name = "SkillItemAddMoveSpeed",refresh_type = "cover"},
		[4] = {name = "SkillItemHeal"},

	}

	local name = skill_cfg[self.data.skill].name
	--9.17日，满血不能吃血量
	-- if name == "SkillItemHeal" and GameInfoCenter.playerDta.hp >= GameInfoCenter.playerDta.hpMax then
	-- 	return
	-- end

	local refresh_type = skill_cfg[self.data.skill].refresh_type
	local creat_func = function()
		self.skill =  CreateFactory.CreateSkill({
			type = name,
			object = GameInfoCenter.GetHeroHead()
		})
	end
	if refresh_type then
		--覆盖模式,直接使用新的时间
		if refresh_type == "cover" then
			local skill = GameInfoCenter.GetObjSkillByTypeValue(GameInfoCenter.GetHeroHead(),"name",name)
			if skill then
				skill:ReSetTime()
			else
				creat_func()
			end
		end
	else
		creat_func()
	end
	Event.Brocast("eat_something")
	GameInfoCenter.RemoveGoodsById(self.id)
	self:Animate()
	print("<color=red>技能触发了+</color>")
end


function M:OnCollisionEnter2D(collision)

	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end

	if self.autoMove then return end
	

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end
	self.autoMove = true
end

function M:Animate()

	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		-- self:CreateSkill()

		GameInfoCenter.RemoveGoodsById(self.id)

	end)

end
