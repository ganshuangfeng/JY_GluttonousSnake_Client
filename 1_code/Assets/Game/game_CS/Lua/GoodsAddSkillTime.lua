--[[物品 能量
	支持几种基本回调函数
	
	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
GoodsAddSkillTime = basefunc.class(Object)
local M = GoodsAddSkillTime

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
	self.destroy_time = data.destroy_time or 99999
	self.warn_time = self.destroy_time - 2
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsAddSkillTime"
	end

	self.enabled = true

	self.state = "normal"
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()
	local cur_head = MainModel.UserInfo.GameInfo.head_type
	local cur_head_cfg = GameConfigCenter.GetHeroHeadConfig(cur_head)
	self.head_skill_spr.sprite = GetTexture(cur_head_cfg.skillIcon)

	if self.data.pos then
		self.transform.position = self.data.pos
	end
	self.animator = self.transform:GetComponent("Animator")

	if self.data.initCallback then
		self.data.initCallback(self)
	end
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
		local nl = self.data.nl
		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end
		
		HeadSkillManager.AddSkillUseTimes(1)
		GameInfoCenter.RemoveGoodsById(self.id)
		Event.Brocast("eat_something")
		-- local tx = NewObject("UI_tb_feiji_sg",CSPanel.anim_node)
		-- tx.transform.position = ExtSkillSP4Panel.Instance().st_node.transform.position
		-- GameObject.Destroy(tx,2)
	end
	
	func()
end