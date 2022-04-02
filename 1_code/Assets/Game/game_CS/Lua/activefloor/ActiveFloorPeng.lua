 local basefunc = require "Game/Common/basefunc"

ActiveFloorPeng = basefunc.class(Object)
local M = ActiveFloorPeng
M.name = "ActiveFloorPeng"

function M.Create(data)
	return M.New(data)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["StageFinish"] = basefunc.handler(self,self.Exit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data or {}
	local parent = CSPanel.map_node
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = NewObject(M.name, parent)
	end
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self.hitObjectList = {}
	self:MakeLister()
	self:AddMsgListener()
	self.anim = self.transform:GetComponent("Animator")
	self.collider = self.fire_pos:Find("1"):GetComponent("ColliderBehaviour")
    self.collider:SetLuaTable(self)
	self.data_inspector = GetDataInfo(self.gameObject)
	self.isFire = false

	self.warning_time = self.data_inspector.space_time / 5

	self.data_inspector.space_time = self.data_inspector.space_time - self.warning_time

	self.zhouqi_time = self.data_inspector.space_time + self.data_inspector.keep_time
	self.zhouqi_used_time = 0
end

function M:Init()
	
end

function M:FrameUpdate(time_elapsed)
	self:Hit(time_elapsed)
	self.zhouqi_used_time = self.zhouqi_used_time + time_elapsed

	if self.zhouqi_used_time < self.warning_time and not self.duringInWarn then
		self.duringInWarn = true
		self.attackWarningPre = MonsterComAttackWarningPrefab.Create(self.gameObject,self.warning_time,function()
		
		end,
		function()
			self.duringInWarn = false
			self.attackWarningPre = nil
		end)
	elseif self.zhouqi_used_time > self.warning_time and self.zhouqi_used_time < self.data_inspector.keep_time and not self.isFire then
		self.isFire = true
		self:StartFire()
	elseif self.zhouqi_used_time > self.data_inspector.keep_time and self.isFire then
		self.isFire = false
		self:OverFire()
	elseif self.zhouqi_used_time > self.zhouqi_time then
		self.zhouqi_used_time = 0
	end

	if self.attackWarningPre then
        self.attackWarningPre:FrameUpdate(time_elapsed)
    end
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
					--Event.Brocast("hit_monster",{attr = self.data_inspector.attr,damage = self.data_inspector.damage,id = self.hitObjectList[i]})
				elseif obj.camp == CampEnum.HeroHead then
					Event.Brocast("hit_hero",{from_id = self.id,attr = self.data_inspector.attr,damage = self.data_inspector.damage, id = self.hitObjectList[i]})
				end
			end
		end
		self.hitObjectList = {}
	end
end

function M:OnTriggerStay2D(collider)
	if self.isLock then
		return
	end
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

function M:StartFire()
	self.isLock = true
	self.fire_pos.gameObject:SetActive(true)
	self.fire_pos:Find("1").gameObject:SetActive(true)
	self.anim:Play("building_peng_fire",0,0)
	Timer.New(function()
		if IsEquals(self.gameObject) then
			self.isLock = false
		end
	end,0.2,1):Start()
end

function M:OverFire()
	self.anim:Play("building_peng_disappear",0,0)
	Timer.New(function()
		if IsEquals(self.gameObject) then
			self.fire_pos.gameObject:SetActive(false)
		end
	end,0.3,1):Start()
end