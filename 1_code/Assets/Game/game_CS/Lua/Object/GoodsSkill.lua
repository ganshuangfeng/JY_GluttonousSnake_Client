--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsSkill = basefunc.class(Object)
local M = GoodsSkill

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	local obj = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObject
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsSkill"
	end

	self.enabled = true

	self.state = "normal"

	self.startTime = 0

	self.destroy_time = data.destroy_time or 99999
	self.autoMove = true
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


function M:FrameUpdate(timeElapsed)
	if self.autoMove then
		self.startTime = self.startTime + timeElapsed
		local hero_queue = GameInfoCenter.GetHeroHead()
		local speed = 0.4
		local vec = tls.pSub(hero_queue.transform.position,self.transform.position)
		vec = tls.pNormalize(vec)
		vec = tls.pMul(vec,speed)
		vec = Vector3.New(vec.x,vec.y,vec.z)
		local scale =  -(self.startTime + 1) * (self.startTime - 2)
		if scale < 1 then scale = 1 end
		self.transform.localScale = Vector3.New(scale,scale,scale)
		self.transform:Translate(vec)
		local range = 0.5
		if tls.pGetDistanceSqu(self.transform.position,hero_queue.transform.position) <= range * range then
			self.state = "die"
			self:Animate()
		end
	end
end


function M:CreateSkill()

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_buff.audio_name)

	-- local yyobj = self.transform:Find("yinying")
	-- if yyobj then
	-- 	yyobj.gameObject:SetActive(false)
	-- end

	-- local animator = self.transform:GetComponent("Animator")
	-- if animator then animator.enabled = false end


	-- if self.data and self.data.cfg then
	-- 	local data = {
	-- 		type = self.data.cfg.skill_type,
	-- 		cfg = self.data.cfg
	-- 	}
	-- 	local hero_head = GameInfoCenter.GetHeroHead() --HeroHeadManager.GetHeroHead()
	-- 	if hero_head then
	-- 		local skill = _G[data.cfg.skill_type].New({object = hero_head,cfg = data.cfg})
	-- 		hero_head.skill[skill.id] = skill
	-- 		skill:Init()
	-- 	end
	-- end

	GameInfoCenter.RemoveGoodsById(self.id)
end


function M:OnCollisionEnter2D(collision)

	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end
	
	self.state = "die"

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

	self:Animate()

end


function M:Animate()

	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		self:CreateSkill()
		Event.Brocast("eat_something")
		GameInfoCenter.RemoveGoodsById(self.id)

	end)

end
