--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsBuildings = basefunc.class(Object)
local M = GoodsBuildings

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	self.gameObject = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObject
	self.transform = self.gameObject.transform
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsBuildings"
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
	self:SetSortingOrder()
	self:InitSkills()
end

function M:InitSkills()
	self.skill = {}
	if self.data.skill then
		for i,v in pairs(self.data.skill) do
			local skill = CreateFactory.CreateSkill({object = self,type=v})
			self.skill[skill.id] = skill
		end
	end
end
function M:SetSortingOrder()
	if self.data.type == 3 and self.data.index then
		
		self.count = 1
		while (self["wj"..self.count.."_spr"]) do
			self.count = self.count + 1
		end
		self.count = self.count - 1

		local cha = (self.data.index - 1) * self.count
		for i = 1, self.count do
			local obj = self["wj"..i.."_spr"]
			obj.sortingOrder = obj.sortingOrder + cha + 2
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

function M:OnTriggerStay2D(collision)
	if not self.enabled then
		return
	end
	if self.state ~= "normal" then
		return
	end
	for k,v in pairs(self.skill) do
		v:OnTriggerStay2D(collision)
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

function M:Animate()

	local pos = self.transform.position
	local jb = self.data.jb
	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		if jb and jb > 0 then
			
			CSEffectManager.CreateGold(CSPanel.anim_node,
				CSModel.Get3DToUIPoint(pos),
				CSPanel:GetJBNode(),
				nil,
				function()
					Event.Brocast("ui_game_get_jin_bi_msg", jb)
				end
			)
		end

		GameInfoCenter.RemoveGoodsById(self.id)
	end)

end
