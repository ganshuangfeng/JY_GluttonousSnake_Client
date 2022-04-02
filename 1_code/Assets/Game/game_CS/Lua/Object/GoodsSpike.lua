--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsSpike = basefunc.class(Object)
local M = GoodsSpike

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObject
	end
	self.transform = self.gameObject.transform
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsSpike"
	end

	self.enabled = true

	self.state = "normal"

end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	if self.data.pos then
		self.transform.position = self.data.pos
	end

	if self.data.initCallback then
		self.data.initCallback(self)
	end
	self:InitSkills()
end

function M:InitSkills()
	self.skill = {}
	if self.data.skill and next(self.data.skill) then
		for i,v in pairs(self.data.skill) do
			local skill = CreateFactory.CreateSkill({object = self,type=v})
			self.skill[skill.id] = skill
		end
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
	for key , skill in pairs(self.skill) do
		skill:Exit()
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

function M:OnTriggerEnter2D(collision)
	if not self.enabled then
		return
	end
	if self.state ~= "normal" then
		return
	end
	local collision_id = tonumber(collision.gameObject.name)
	local hero_head = GameInfoCenter.GetHeroHead()
	if hero_head.id == collision_id then
		Event.Brocast("hit_hero",{damage = 50, id = collision_id,})
	end
end

function M:OnTriggerStay2D(collision)
	if not self.enabled then
		return
	end
	if self.state ~= "normal" then
		return
	end
end

function M:FrameUpdate(dt)
	M.super.FrameUpdate( self , dt )

	for id,skill in pairs(self.skill) do
		if skill.isLive then
			skill:FrameUpdate(dt)
		else
			self.skill[id] = nil
		end
	end
end