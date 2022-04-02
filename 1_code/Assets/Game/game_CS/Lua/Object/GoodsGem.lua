--[[物品 宝石
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsGem = basefunc.class(Object)
local M = GoodsGem

function M:Ctor(data)
	M.super.Ctor( self , data )

	self.data = data
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
		self.collider.luaTableName = "GoodsGem"
	end

	self.enabled = true
	local data_inspector = GetDataInfo(self.gameObject)
	if data_inspector and self.data.building then
		for k,v in pairs(data_inspector) do
			self.data.building[k] = v
		end
	end
	self.state = "normal"
	if self.data.building then
		-- local stageData = GameInfoCenter.GetStageData()
		-- local _gem_data = {
		-- 	x = self.transform.position.x,
		-- 	y = self.transform.position.y,
		-- 	obj = self,
		-- }
		-- GameConfigCenter.ResetStageGemData(stageData.curLevel,stageData.roomNo,tonumber(self.data.building.stageIndex) ,_gem_data)
		self.gameObject:SetActive(false)
	end
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
			speed = 0.6,
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

			if tls.pGetDistanceSqu(self.transform.position,hero_queue.transform.position) <= 0.5 then
				self:OnCollisionEnter2D()
				self.autoMoveData = nil
			end

		end

	end

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

function M:OnCollisionEnter2D(collision)

	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end
	
	self.state = "die"

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_crystal.audio_name)
	Event.Brocast("eat_something")
	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

end


-- 出现怪物的效果(蓝色冲击波+宝石跳跃)
function M:AnimateAriseMonster()

	self.transform:GetComponent("Animator"):Play("stop")

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_crystal.audio_name)
	
	local ic = 2
	local function aniOver( )
		ic = ic - 1
		if ic < 1 then
			if self.data.aniOverCallback then
				self.data.aniOverCallback(self)
			end
			GameInfoCenter.RemoveGoodsById(self.id)
		end
	end

	CSEffectManager.PlayBSJump(self.transform, function ()
		aniOver( )
	end,self.data.jb)

    ExtendSoundManager.PlaySound(audio_config.cs.battle_monster_debut.audio_name)
    CSEffectManager.PlayShowAndHideAndCall(
                                            MapManager.GetMapNode(),
                                            "Cjb_chongjibo_zise",
                                            0,
                                            self.transform.position,
                                            0.8,
                                            nil,
                                            function (obj)
    											ExtendSoundManager.PlaySound(audio_config.cs.battle_monster_debut.audio_name)
                                            	aniOver( )
                                            end)

end


-- 出现BOSS的效果(宝石剧烈缩放)
function M:AnimateAriseBoss()
	
	CSPanel:SetStopUpdate(true)

	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_coming.audio_name)
	Event.Brocast("stage_state_change","boss_coming")


	self.transform:GetComponent("Animator"):Play("scale")
	self.count = 0
	self.anim_event = self.transform:GetComponent("ComAnimatorEvent")

	self.anim_event.onCall = function (no, event)
		if event == "end" then
			self.count = self.count + 1
			if self.count >= 15 then

				-- Event.Brocast("stage_state_change","boss_coming")
				Event.Brocast("stageShowTargetProgress",false)

				self.transform:GetComponent("Animator"):Play("stop")

				if self.data.aniOverCallback then
					self.data.aniOverCallback(self)
				end
				GameInfoCenter.RemoveGoodsById(self.id)

				Timer.New(function ()
					CSPanel:SetStopUpdate(false)
				end,0.3, 1):Start()

			end
		end
	end

end


-- 关卡结束效果(黄色冲击波+宝石多次闪烁掉金币+震屏+清除怪物和技能)
function M:AnimateStageOver()

	Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_crystal.audio_name)

    CSEffectManager.PlayShowAndHideAndCall(
                                            MapManager.GetMapNode(),
                                            "Cjb_chongjibo",
                                            0,
                                            self.transform.position,
                                            0.8,
                                            nil,
                                            function (obj)

                                            	CSPanel:SetStopUpdate(true)
												
												-- 清除怪物和技能
												if self.data.cjbFinishCallback then
													self.data.cjbFinishCallback(self)
												end
												
												self.transform:GetComponent("Animator"):Play("stop")

												CSEffectManager.PlayBSFlicker(self.transform.position,
																				self.data.jbCount,
																				self.data.jbNum,
												function ()
													
													if self.data.aniOverCallback then
														self.data.aniOverCallback(self)
													end
													GameInfoCenter.RemoveGoodsById(self.id)

													CSPanel:SetStopUpdate(false)
												end)

                                            end)

end

-- 简单的结束
function M:Over()

	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		GameInfoCenter.RemoveGoodsById(self.id)

	end)

end