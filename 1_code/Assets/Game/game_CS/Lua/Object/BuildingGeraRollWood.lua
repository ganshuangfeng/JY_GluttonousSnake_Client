--[[地图 建筑
	支持几种基本回调函数

	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
BuildingGeraRollWood = basefunc.class(Building)
local M = BuildingGeraRollWood

function M:Ctor(data)
	M.super.Ctor( self , data )
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
		self.collider.luaTableName = "BuildingGeraRollWood"

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
		local triggerGera = function (gearName)
			local bObj = MapManager.GetBuildingObjByName(gearName)
			if bObj then
				bObj:TriggerGera()
			end
		end
		if self.data.building.gearName then
			if type(self.data.building.gearName) == "string" then
				triggerGera(self.data.building.gearName)
			elseif type(self.data.building.gearName) == "table" then
				for i, v in ipairs(self.data.building.gearName) do
					triggerGera(v)
				end
			end
		else
			local childCount = self.transform.childCount
			if childCount > 0 then
				for i = 0,childCount - 1  do
					local gameObject = self.transform:GetChild(i).gameObject
					local property = GetDataInfo(gameObject)
					if property then
						local bObj = MapManager.GetBuildingObjByGameObject(gameObject)
						if bObj then
							bObj:TriggerGera()
						end
					end
				end
			end
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