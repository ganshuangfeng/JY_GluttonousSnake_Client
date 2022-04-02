--[[地图 建筑
	支持几种基本回调函数

	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
BuildingGeraRollWoodContinue = basefunc.class(Building)
local M = BuildingGeraRollWoodContinue

function M:Ctor(data)
	M.super.Ctor( self , data )
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	if self.data.pos then
		self.transform.position = self.data.pos
	end

	self:InitCollider()

	if self.data.initCallback then
		self.data.initCallback(self)
	end
	self:InitSkills()
	self:CreateRollWood()
end

function M:InitCollider()
	local co = self.gameObject:GetComponent("BoxCollider2D")
	if IsEquals(co) then
		if self.data.building.isDestroy then
			co.enabled = true
		else
			co.enabled = false
		end
	end

	self.collider = self.gameObject:GetComponent("ColliderBehaviour")

	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "BuildingGeraRollWoodContinue"

		if self.data.building.isDestroy then
			self.collider.enabled = true
		else
			self.collider.enabled = false
		end
	end

	if self.data.building.destroyType then
		SetLayer(self.gameObject,"MapBuilding")
	end
end

function M:OnTriggerEnter2D(coll)
	self:OnColliderEnter2D(coll)
end

function M:OnCollisionEnter2D(coll)
	self:OnColliderEnter2D(coll)
end

function M:OnColliderEnter2D(coll)
	dump(coll,"<color=yellow>滚木碰撞</color>")
	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end

	--碰撞层检查
	if self.data.building.destroyType then
		if not MapManager.CheckCollision(coll,self.data.building) then
			return
		end
	end

	self.state = "coll"

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

	self:ColliderAnimate()
end

function M:ColliderAnimate()
	local obj = self.gameObject
	local cbk = function ()
		if self.timer then
			self.timer:Stop()
		end
	end
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.1):SetLoops(2, Enum.LoopType.Yoyo))
	seq:AppendInterval(0.2)
	seq:AppendCallback(function ()
		if cbk then cbk() end
	end)
	seq:AppendInterval(1)
	seq:OnKill(function()
		self.state = "normal"
	end)
end

function M:CreateRollWood()
	local triggerGera = function (gearName)
		dump(gearName,"<color=yellow>机关的名字？？？？？</color>")
		local bObj = MapManager.GetBuildingObjByName(gearName)
		if IsEquals(bObj) then
			local go = GameObject.Instantiate(bObj.gameObject,bObj.transform.parent)
			local pro = GetDataInfo(go)
			pro.trigger = true
			MapManager.BindingGameObjectMapInfo(go,pro)
		end
	end

	if type(self.data.building.gearName) == "string" then
		triggerGera(self.data.building.gearName)
	elseif type(self.data.building.gearName) == "table" then
		for i, v in ipairs(self.data.building.gearName) do
			triggerGera(v)
		end
	end

	self.timer = Timer.New(function ()
		if type(self.data.building.gearName) == "string" then
			triggerGera(self.data.building.gearName)
		elseif type(self.data.building.gearName) == "table" then
			for i, v in ipairs(self.data.building.gearName) do
				triggerGera(v)
			end
		end
	end,2,-2,false,false)
	self.timer:Start()
end