--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsGoldCoin = basefunc.class(Object)
local M = GoodsGoldCoin
local warn_time = 4
local destroy_time = 6
function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

	-- dump( self.data.pos ,"<color=red>xxx---------GoodsGoldCoin:</color>"  )

	local obj
	if self.data.building and IsEquals(self.data.building.gameObject) then
		obj = self.data.building.gameObject
	else
		obj = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObject
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsGoldCoin"
	end

	self.enabled = true

	self.state = "normal"

	if self.data.initCallback then
		self.data.initCallback(self)
	end
	self.destroy_time = data.destroy_time or 99999
	self.warn_time = self.destroy_time - 2
	self.mainTimer = Timer.New(function()
		if IsEquals(self.transform) then
			self.update_time = self.update_time or 0
			self.update_time = self.update_time + 1
			if self.update_time >= self.warn_time and not self.isWarning then
				self.isWarning = true
			end

			if self.update_time >= self.destroy_time then
				GameInfoCenter.RemoveGoodsById(self.id)
			end
		end
	end,1,-1)
	self.mainTimer:Start()
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

function M:OnCollisionEnter2D(collision)

	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end
	ExtendSoundManager.PlaySoundLimit(audio_config.cs.cjb_award.audio_name)
	
	self.state = "die"

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

	self:Animate()

end


function M:Animate()
	local func = function()
		local pos = self.transform.position
		local jb = self.data.jb
		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end
		if jb and jb > 0 then
			
			local level = self.data.level
			local jnc = {1,4,9}
			local jn = jnc[level] or 1

			for i = 1, jn do
				
				local p = Vector3.New(pos.x + math.random(-100, 100)*0.01
										, pos.y + math.random(-100, 100)*0.01 
										, 0)

				CSEffectManager.CreateGold(CSPanel.anim_node,
					CSModel.Get3DToUIPoint(p),
					CSPanel:GetJBNode(),
					nil,
					function()
						Event.Brocast("ui_game_get_jin_bi_msg", jb)
					end
				)

			end

		end

		--销毁建筑
		Event.Brocast("eat_something")
		Event.Brocast("ItemDestroy", self)
		DropAsset.ClearGoldPos(self.transform.position)
		GameInfoCenter.RemoveGoodsById(self.id)

	end

	if self.destroy_time > 20 then
		func()
		-- local animator = self.transform:GetComponent("Animator")
		-- animator:Play("fly", 0, 0)
		-- Timer.New(function()
		-- 	func()
		-- end,0.5,1):Start()
	else
		func()
	end
end
