--[[物品 Boss创建的石头
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsBossStone = basefunc.class(Object)
local M = GoodsBossStone

function M:Ctor(data)
	M.super.Ctor( self , data )
	local property = {
		key = "bossStone",
		keyType = "building",
		name = "boss创建的石头",
		isPass = nil,
		isDestroy = 1,
		isItem = 1,
		size = {w = 2,h = 2},
		layer = 4,
		destroyType = {"hero_head","hero_zd",},

	}
	self.data = data
	self.gameObject = NewObject("BossStone",MapManager.GetMapNode()).gameObject

	self.transform = self.gameObject.transform
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	if self.data.pos then
		self.transform.position = self.data.pos
	end
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsBossStone"
	end

	self.enabled = true

	self.state = "normal"
	MapManager.BindingGameObjectMapInfo(self.gameObject,property,self)
	
	--在gameinfocenter里添加物件
	self.type = 3
	GameInfoCenter.AddGoods(self)
	local range = 5
	local hero_head = GameInfoCenter.GetHeroHead()
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.7)
	seq:AppendCallback(function()
		ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_juxiang_luoshi.audio_name)
		if IsEquals(self.transform) then
			if tls.pGetDistanceSqu(hero_head.transform.position,self.transform.position) < range * range then
				Event.Brocast("hit_hero",{damage = self.data.damage, id = hero_head.id,})
			end
		end
	end)
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()
end

function M:MakeLister()
    self.lister = {}
	self.lister["BossStoneFigureSuperAttack3"] = basefunc.handler(self,self.OnBoom)
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
	MapManager.OnMapBuildingDestroy(self.building)
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
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
	-- self.state = "die"
	-- self:Animate()
end


function M:FrameUpdate(dt)
	M.super.FrameUpdate( self , dt )
	if not self.isLive then
		self:Exit()
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

function M:OnBoom(data)
	self.state = "die"
	local fx_pre = NewObject("shitou_baozha",MapManager.GetMapNode())
	fx_pre.transform.position = self.transform.position
	local hero_head = GameInfoCenter.GetHeroHead()
	if data.damage and data.damage ~= 0 then
		Event.Brocast("hit_hero",{damage = data.damage, id = hero_head.id,})
	end
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function()
		GameInfoCenter.RemoveGoodsById(self.id)
	end)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		if IsEquals(fx_pre.gameObject) then
			Destroy(fx_pre)
		end 
	end)
end
