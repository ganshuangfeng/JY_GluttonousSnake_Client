--地图父节点
--中心位置
--旋转角度
--锯片来回速度
--锯片伤害
--如果对象持续留在对象上，该对象会持续收到伤害

local basefunc = require "Game/Common/basefunc"

ActiveFloorSaw = basefunc.class(Object)
local M = ActiveFloorSaw
M.name = "ActiveFloorSaw"

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
	self.collider = self.jupian:GetComponent("ColliderBehaviour")
    self.collider:SetLuaTable(self)
	self.data_inspector = GetDataInfo(self.gameObject)
end

function M:Init()
	self.sizeData = self.data_inspector.size 
	
	self.moveSpeed = tonumber(self.data_inspector.moveSpeed or 10) 
	self.damage = tonumber(self.data_inspector.damage or 5)  -- 每0.1s
	if self.sizeData.w > self.sizeData.h then
		self.isHorizontal = true
		self.grid = self.sizeData.w
		self.width = self.sizeData.w * 1.6-- 策划配的是各自宽度，这里转换一下 
	else	
		self.isHorizontal = false
		self.grid = self.sizeData.h
		self.width = self.sizeData.h * 1.6
	end

	self.p3.transform.localScale = Vector3.New(self.grid * 2.52,1.11,1.11)
	self.p1.transform.localPosition = Vector3.New(self.grid * -0.96,-0.661,0)
	self.p2.transform.localPosition = Vector3.New(self.grid * 0.96,-0.661,0)

	if self.isHorizontal then
	else
		self.node.transform.localRotation = Quaternion:SetEuler(0, 0, -90)
	end
end

function M:FrameUpdate(time_elapsed)
	self:Move(time_elapsed)
	self:Hit(time_elapsed)
end

function M:Move(time_elapsed)
	local dir = self.jupian.transform.up
	local cheak_value = self.jupian.transform.localPosition.x
	if self.isHorizontal then
		dir = self.jupian.transform.right
	end
	self.jupian.transform:Translate(dir * time_elapsed * self.moveSpeed);
	if math.abs(cheak_value) > self.width / 2 then
		local flag = 1
		if cheak_value > 0 then
			flag = -1
		end
		--如果直接乘以 -1 有可能会抖动
		self.moveSpeed = flag * math.abs(self.moveSpeed)
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
					Event.Brocast("hit_monster",{damage = self.damage,id = self.hitObjectList[i]})
				elseif obj.camp == CampEnum.HeroHead then
					Event.Brocast("hit_hero",{damage = self.damage, id = self.hitObjectList[i]})
				end
			end
		end
		self.hitObjectList = {}
	end
end

function M:OnTriggerStay2D(collider)
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