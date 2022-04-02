local basefunc = require "Game/Common/basefunc"

ActiveFloorZiDan = basefunc.class(Object)
local M = ActiveFloorZiDan
M.name = "ActiveFloorZiDan"

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
	self.data_inspector = GetDataInfo(self.gameObject)

	self.dir = nil
	self.prefab_name = nil


	local ab = StringHelper.Split(self.data_inspector.attr,"#")
	if ab[1] == "Ice" then
		self.prefab_name = "Xj_PAO_zidan_bing_1"
		self.fire_tx_name = "Xj_PAO_zidan_bing_paokou"
	elseif ab[1] == "Firing" then
		self.prefab_name = "Xj_PAO_zidan_huo_1"
		self.fire_tx_name = "Xj_PAO_zidan_huo_paokou"
	elseif ab[1] == "Poisoning" then
		self.prefab_name = "Xj_PAO_zidan_du_1"
		self.fire_tx_name = "Xj_PAO_zidan_du_paokou"
	end

	self.fire_tx = NewObject(self.fire_tx_name,self.fire_pos)
	self.fire_tx.gameObject:SetActive(false)

	if self.data_inspector.dir == "down" then
		self.dir = -90
		self.fire_tx.transform.eulerAngles = Vector3.New(0,0,-90)
	elseif self.data_inspector.dir == "left" then
		self.dir = -180
		self.fire_tx.transform.eulerAngles = Vector3.New(0,0,-180)
	elseif self.data_inspector.dir == "right" then
		self.dir = 0
		self.fire_tx.transform.eulerAngles = Vector3.New(0,0,0)
	elseif self.data_inspector.dir == "up" then
		self.dir = 90
		self.fire_tx.transform.eulerAngles = Vector3.New(0,0,90)
	end


	self.timeUse = 0
	self.warning_time = self.data_inspector.hit_space / 5
	self.data_inspector.hit_space = self.data_inspector.hit_space - self.warning_time
end

function M:Init()
	
end

function M:FrameUpdate(time_elapsed)
	self.timeUse = self.timeUse + time_elapsed

	if self.timeUse < self.warning_time and not self.duringInWarn  then
		self.duringInWarn = true
		self.attackWarningPre = MonsterComAttackWarningPrefab.Create(self.gameObject,self.warning_time,function()
		
		end,
		function()
			self.duringInWarn = false
			self.attackWarningPre = nil
		end)
	elseif self.timeUse > self.warning_time and self.timeUse < self.data_inspector.hit_space and not self.isFired then
		self:Hit()
		self.isFired = true
	elseif self.timeUse > self.data_inspector.hit_space then
		self.timeUse = 0
		self.isFired = false
	end

	if self.attackWarningPre then
        self.attackWarningPre:FrameUpdate(time_elapsed)
    end
end

function M:Hit()
	self.fire_tx.gameObject:SetActive(false)
	self.fire_tx.gameObject:SetActive(true)
	local hit_data = {}
	hit_data.hitTarget = {angel = self.dir}
	hit_data.damage = { self.data_inspector.damage }	
	hit_data.bulletPrefabName = { self.prefab_name }
	hit_data.attackFrom = "monster"
	hit_data.moveWay = {"LineMove",}
	hit_data.hitEffect = {"SampleHit",} 
	hit_data.hitStartWay = {"IsHitSomeOne"}
	hit_data.hitType = {"SectorShoot"}
	hit_data.bulletLifeTime = 6
	hit_data.speed = {10}
	hit_data.bulletNumDatas = {1}
	hit_data.attr = {self.data_inspector.attr}
	hit_data.hitOrgin = {pos = self.fire_pos.position}
	Event.Brocast("monster_attack_hero", hit_data)
end