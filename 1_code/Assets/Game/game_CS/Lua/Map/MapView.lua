local basefunc = require "Game/Common/basefunc"
MapView = basefunc.class()
local M = MapView
M.name = "MapView"

function M.Init(data)
	return M.New(data)
end

function M:Ctor(data)
	dump(data,"<color=white>data</color>")
	ExtPanel.ExtMsg(self)
	self.mapCtrl = data.mapCtrl
	self.mapModel = self.mapCtrl:GetMapModel()
	self.mapModel.mapView = self

	self.gameObject = data.roomGo
	self.gameObject:SetActive(true)

	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddLister()
	self:InitUI()
end

function M:Start()
	self:Binding()
end

function M:Exit()
	self:RemoveLister()
	self:ClearBuilding()
	Destroy(self.gameObject)
end

function M:FrameUpdate(time_elapsed)
end

function M:MakeLister()
    self.lister = {}
end

function M:AddLister()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveLister()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M:Binding()
	self:BindingBuilding()
	self:BindingOther()
end

function M:InitUI()
	self:MyRefresh()
end

function M:MyRefresh()
end

--动态绑定一个GameObject到地图上
function M:BindingGameObjectMapInfo(gameObject,property,obj)
	local building = self.mapModel:BindingGameObjectMapInfo(gameObject,property)
	if obj then
		--建筑已经通过类创建了
		self.buildings = self.buildings or {}
		self.buildings[building.id] = obj
		obj.building = building
	else
		self.buildings = self.buildings or {}
		self.buildings[building.id] = CreateFactory.BindingBuilding(building)
	end
end

--绑定建筑
function M:BindingBuilding()
	UnityEngine.Profiling.Profiler.BeginSample("MapView BindingBuilding 1 ");
	self.mapModel:BindingPrefabMapInfo(self.gameObject)
	UnityEngine.Profiling.Profiler.EndSample();

	UnityEngine.Profiling.Profiler.BeginSample("MapView BindingBuilding 2 ");
    for i, v in ipairs(self.mapModel.mapInfo.building) do
        self.buildings = self.buildings or {}
        self.buildings[v.id] = CreateFactory.BindingBuilding(v)
    end
	UnityEngine.Profiling.Profiler.EndSample();
end

--绑定其它
function M:BindingOther(gameObject)
	UnityEngine.Profiling.Profiler.BeginSample("MapView BindingOther ");
	gameObject = gameObject or self.gameObject

	local function buiningGO(go)
        local property = GetDataInfo(go)
        if property and next(property) and property.keyType and property.keyType ~= "building" then
			property.gameObject = go
			self.other = self.other or {}
			local obj = CreateFactory.BindingBuilding(property)
			self.other[obj.id] = obj
		end
    end

	buiningGO(gameObject)
	local dataInfos = gameObject:GetComponentsInChildren(typeof(DataInfo),true)
    for i = 0, dataInfos.Length - 1 do
        buiningGO(dataInfos[i].gameObject)
    end
	UnityEngine.Profiling.Profiler.EndSample();
end

function M:ClearBuilding()
	if not self.builds or not next(self.builds) then
		return
	end
	for k, v in pairs(self.builds) do
		v:MyExit()
	end
	self.builds = {}
end

function M:TidBuildingGrid(data)
	if not data or not next(data) or not self.buildings or not next(self.buildings) or not self.buildings[data.id] then
		return
	end
	self.mapModel:TidBuildingGrid(data.id)
	self.buildings[data.id] = nil
end

function M:GetMapGameObject()
	return self.gameObject
end

function M:GetWaveNumberAllItems(wn,types)
	if not self.other or not next(self.other) then return end
	local parent
	for k, v in pairs(self.other) do
		if v.data.building.key == "waveNumber" and v.data.building.waveNumber == wn then
			parent = v.data.building.gameObject.transform
			break
		end
	end

	local objs = {}
	for k, v in pairs(self.other) do
		if not types or types[v.data.building.key] then
			if v.data.building.gameObject.transform.parent == parent 
				or v.data.building.gameObject.transform.parent.parent == parent 
			then
				objs[v.id] = v
			end
		end
	end
	dump(objs,"<color=yellow>获取波次下是所有道具</color>")
	return objs
end

function M:GetBuildingObjByKey(key)
	if not self.buildings or not next(self.buildings) then return end
	local objs = {}
	for k, v in pairs(self.buildings) do
		if v.data.building.key == key then
			objs[#objs+1] = v.data.building
		end
	end

	return objs
end

function M:GetBuildingObjByName(name)
	if not self.buildings or not next(self.buildings) then return end

	for k, v in pairs(self.buildings) do
		if v.data.building.name == name then
			return v
		end
	end
end

function M:GetBuildingObjByGameObject(gameObject)
	if not self.buildings or not next(self.buildings) then return end

	for k, v in pairs(self.buildings) do
		if v.data.building.gameObject == gameObject then
			return v
		end
	end
end

-- 不能走的坐标和大小等数据
function M:GetNotPassData()
	if not self.buildings or not next(self.buildings) then return end
	local data = {}
	for k, v in pairs(self.buildings) do
		if not v.data.building.isPass then
			local t = {}
			t.pos = v.data.building.pos
			if v.data.building.collPos then
				t.pos = v.data.building.collPos
			end
			t.size = v.data.building.size
			if v.data.building.collSize then
				t.size = v.data.building.collSize
			end

			data[#data + 1] = t
		end
	end
	return data
end