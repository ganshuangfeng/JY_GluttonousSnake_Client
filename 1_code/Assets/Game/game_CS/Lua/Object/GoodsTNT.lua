--[[物品 炸药桶 进入范围后五秒爆炸
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsTNT = basefunc.class(Object)
local M = GoodsTNT
local default_explode_time = 3
function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObmeObject
	end
	self.transform = self.gameObject.transform
	self.gameObject.name = self.id
	GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsTNT"
	end

	self.enabled = true
	self.explode_time = data.explode_time or default_explode_time
	self.damage = data.damage or 200

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
		self.state = "exploding"
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
	if self.state == "exploding" then
		self:RefreshExploding(dt)
	end

	for id,skill in pairs(self.skill) do
		if skill.isLive then
			skill:FrameUpdate(dt)
		else
			self.skill[id] = nil
		end
	end
end

function M:RefreshExploding(dt)
	if not self.count_down_txt.gameObject.activeSelf then
		self.count_down_txt.gameObject:SetActive(true)
	end
	self.count_down_txt.text = math.ceil(self.explode_time)
	self.transform:GetComponent("SpriteRenderer").sprite = GetTexture("2D_map_zd_02")
	if not self.count_down_fx then
		self.count_down_fx = NewObject("Tong_skill_quan",self.transform)
	end
	self.explode_time = self.explode_time - dt
	if self.explode_time <= 0 then
		self:Explode()
	end
end

function M:Explode()
	self.state = "die"
	if IsEquals(self.count_down_fx) then
		Destroy(self.count_down_fx.gameObject)
	end
	self.explode_fx = NewObject("Tong_skill_baozha",MapManager.GetMapNode())
	self.explode_fx.transform.position = self.transform.position
	local range = 6
	local heroHead = GameInfoCenter.GetHeroHead()
	if tls.pGetDistanceSqu(heroHead.transform.position,self.transform.position) < range * range then
		Event.Brocast("hit_hero",{damage = self.damage, id = heroHead.id,})
	end
	local monsters = GameInfoCenter.GetMonstersRangePos(self.transform.position,range)
	if monsters then
		for k,v in pairs(monsters) do
			Event.Brocast("hit_monster",{damage = self.damage,id = v.id})
		end
	end

	self.transform.gameObject:SetActive(false)
	self.explode_seq = DoTweenSequence.Create()
	self.explode_seq:AppendInterval(2)
	self.explode_seq:AppendCallback(function()
		if IsEquals(self.explode_fx) then
			Destroy(self.explode_fx)
		end
		self:Exit()
	end)
end