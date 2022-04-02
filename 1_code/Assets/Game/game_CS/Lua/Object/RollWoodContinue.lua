local basefunc = require "Game/Common/basefunc"

RollWoodContinue = basefunc.class(Building)
local M = RollWoodContinue
M.name = "RollWoodContinue"

function M:Ctor(data)
	M.super.Ctor(self, data)
end

function M:Init(data)
	M.super.Init( self )

	self.oPos = self.transform.position
	self.hitObjectList = {}
	self.damage = 10

	if self.data.building.trigger then
		self:TriggerGera()
	end
end

function M:FrameUpdate(time_elapsed)
	self:Hit(time_elapsed)
end

local timeNeed = 0.1
function M:Hit(time_elapsed)
	self.timeUse = self.timeUse or 0
	self.timeUse = self.timeUse + time_elapsed
	if self.timeUse > timeNeed then
		self.timeUse = 0
		for i = 1,#self.hitObjectList do
			local obj = ObjectCenter.GetObj(self.hitObjectList[i])
			if obj then
				if obj.camp == CampEnum.Monster then
					Event.Brocast("hit_monster",{damage = self.damage,id = self.hitObjectList[i]})
				elseif obj.camp == CampEnum.HeroHead then
					Event.Brocast("hit_hero",{damage = self.damage, id = self.hitObjectList[i]})
				end
			end
		end
		self.hitObjectList = {}
	end
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
		self.collider.luaTableName = "RollWoodContinue"

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

function M:OnColliderEnter2D(collider)

	local object_id = collider.gameObject.name
	if object_id then
		object_id = tonumber(object_id)
	end
	--不重复计算ID
	local IsCanAdd = true
	for i = 1,#self.hitObjectList do
		if self.hitObjectList[i] == object_id then
			IsCanAdd = false
			break
		end
	end
	if IsCanAdd then
		self.hitObjectList[#self.hitObjectList + 1] = object_id
	end
end

function M:ColliderAnimate()
	
end

function M:TriggerGera()
	--local mapSize = MapManager.GetMapSize()
	local mapSize = GetSceenSize( self )
	local eulerAngles = self.transform.eulerAngles
	local tPos
	if eulerAngles.z == 0 then
		tPos = {
			x = mapSize.w / 2,
			y = self.oPos.y,
			z = self.oPos.z,
		}
	elseif eulerAngles.z == 90 then
		tPos = {
			x = self.oPos.x,
			y = mapSize.h / 2,
			z = self.oPos.z,
		}
	elseif eulerAngles.z == 180 then
		tPos = {
			x = -mapSize.w / 2,
			y = self.oPos.y,
			z = self.oPos.z,
		}
	elseif eulerAngles.z == 270 then
		tPos = {
			x = self.oPos.x,
			y = -mapSize.h / 2,
			z = self.oPos.z,
		}
	end
	self.transform.position = self.oPos
	--朝Y轴负方向移动
	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOMove(tPos, 8))
	seq:AppendCallback(function ()
		Destroy(self.gameObject)
		GameInfoCenter.RemoveGoodsById(self.id)

		--销毁建筑
		Event.Brocast("MapBuildingDestroy", self.data.building)
	end)
end