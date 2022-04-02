--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsHero = basefunc.class(Object)
local M = GoodsHero

function M:Ctor(data)
	M.super.Ctor( self , data )

	local config = {
		[1] = "dj_sd_tb_dj_YX_1",
		[2] = "dj_sd_tb_dj_YX_2",
		[3] = "dj_sd_tb_dj_YX_3",
		[4] = "dj_sd_tb_dj_YX_4",
		[7] = "dj_sd_tb_dj_YX_7",
		[13] = "dj_sd_tb_dj_YX_13",
		[14] = "dj_sd_tb_dj_YX_14",
		[15] = "dj_sd_tb_dj_YX_15",
	}
	self.data = data
	local obj
	if self.data.building and IsEquals(self.data.building.gameObject) then
		obj = self.data.building.gameObject
	else
		self.data.prefabName = self.data.prefabName or config[self.data.heroType]
		self.prefab = CachePrefabManager.Take(self.data.prefabName, self.data.parent)
		obj = self.prefab.prefab.prefabObj.gameObject
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsHero"
	end
	
	self.destroy_time = data.destroy_time or 99999
	self.warn_time = self.destroy_time - 2
	if self.transform and self.transform:Find("kz") then
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
	end
	self.enabled = true

	self.state = "normal"
	-- self.AdsorbAnim = AdsorbAnim.Create(self)
	-- self.AdsorbAnim:SetRange(0.2)
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	if self.data.pos then
		self.transform.position = self.data.pos
	end
	
	self.autoMoveData = nil
	if self.data.autoMove then

		self.autoMoveData = {
			stage = 1, -- 1-动画 2-移动
			speed = 0.4,
		}
		self.enabled = false
		CSEffectManager.PlayBSJump(self.transform, function ()
			self.autoMoveData.stage = 2
			self.enabled = true
		end)

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

function M:FrameUpdate(timeElapsed)

	if self.autoMoveData then

		if self.autoMoveData.stage == 2 then

			local hero_queue = GameInfoCenter.GetHeroHead()
			local vec = tls.pSub(hero_queue.transform.position,self.transform.position)
			vec = tls.pNormalize(vec)
			vec = tls.pMul(vec,self.autoMoveData.speed)

			self.transform:Translate(vec)

		end

	end

end

function M:Exit()
	if self.mainTimer then
		self.mainTimer:Stop()
		self.mainTimer = nil
	end
	self:RemoveListener()
	CachePrefabManager.Back(self.prefab)
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

	ExtendSoundManager.PlaySound(audio_config.cs.composite_buy.audio_name)

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end
	
	self:Animate()

end


function M:Animate()

	local pos = self.transform.position
	local jb = self.data.jb
	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end
		
		self:CreatHero()

		GameInfoCenter.RemoveGoodsById(self.id)

	end)

end



function M:CreatHero()

    if GameInfoCenter.GetHeroNum() < GameInfoCenter.playerDta.heroCapacity then
		if not self.data.hero_3in1 then
		-- 创建英雄
			GameInfoCenter.BuyHero({type=self.data.heroType})
			ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
		else
		--创建英雄三选一界面
			local config = self.data.heroConfig or {
				hero_1 = 1000,
				hero_2 = 1000,
				hero_3 = 1000,
				hero_4 = 1000,
				hero_7 = 1000,
				hero_13 = 1000,
				hero_14 = 1000,
				hero_15 = 1000,
			}
			Event.Brocast("eat_something")
			ItemThreeChooseOneManager.Create(config)
		end
    else
    	Event.Brocast("ExtraSkillTrigger",{type = self.data.heroType})
    end

end

