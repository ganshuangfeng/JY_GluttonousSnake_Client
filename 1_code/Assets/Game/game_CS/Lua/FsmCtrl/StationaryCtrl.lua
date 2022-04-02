--备注：
--frozen：冰冻
--dizziness：眩晕
--paralysis：麻痹

local basefunc = require "Game/Common/basefunc"

StationaryCtrl = basefunc.class(BaseCtrl)

local M = StationaryCtrl
local tags_enum = {
	"frozen","dizziness","paralysis"
}

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
	self:AddTag(data)
end

--{form = ??,tag = ??,other = ??}
function M:AddTag(data)
	self.sp_tags_index = self.sp_tags_index or 0
	self.sp_tags_index = self.sp_tags_index + 1
	self.sp_tags = self.sp_tags or {}
	self.sp_tags[self.sp_tags_index] = data
	return self.sp_tags_index
end

function M:RemoveTagByIndex(index)
	self.sp_tags = self.sp_tags or {}
	self.sp_tags[index] = nil
end

function M:ReMoveTagByForm(form)
	self.sp_tags = self.sp_tags or {}
	for k, v in pairs(self.sp_tags) do
		if v and v.form == form then
			v = nil
		end
	end
end

function M:ReMoveTagByTag(tag)
	self.sp_tags = self.sp_tags or {}
	for k, v in pairs(self.sp_tags) do
		if v and v.tag == tag then
			v = nil
		end
	end
end

function M:IsTagActive(tag)
	self.sp_tags = self.sp_tags or {}
	for k , v in pairs(self.sp_tags) do
		if v and v.tag == tag  then
			return v.keep_time > 0
		end
	end
	return false
end

function M:GetDataByTag(tag)
	local re = {}
	for k , v in pairs(self.sp_tags) do
		if v and v.tag == tag then
			if v.keep_time > 0 then
				re[#re + 1] = v
			end
		end
	end
	return re
end

--是否处于不可移动状态
function M:IsDuringStationary()
	for i = 1,#tags_enum do
		if self:IsTagActive(tags_enum[i]) then
			return true
		end
	end
	return false
end

--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready
end

--- 状态开始时调用
function M:Begin()
	--不可移动类的通用状态
	if self:IsDuringStationary() then
		self.ctrlState = StateType.running
		if self.object.anim_pay then
			self.object.anim_pay.speed = 0
		end
		self.object.enableRot = false

		if self.object.vehicle then
			self.object.vehicle:Stop()
		end
	else
		self:Finish()
	end
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self.object.enableRot = true
	if self.object.anim_pay then
		self.object.anim_pay.speed = 1
	end
	if self.object.vehicle then
		self.object.vehicle:Start()
	end

end

--强制结束
function M:Stop()
	self:Finish()
end

-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause
	return false
end

-- 刷新
function M:Refresh(_data)
	self:AddTag(_data)
end

function M:Update(dt)
	--不可移动类的通用状态
	--如果出现驱散类标签，去掉所有非强制类的状态(比如BOSS免疫一般眩晕，但是不免疫打断的眩晕)
	if GetTag( self.object , "break_stationary" ) then
		for k , v in pairs(self.sp_tags) do
			if v and v.force then
			
			else
				self.sp_tags[k] = nil
			end
		end
	end

	for k,v in pairs(self.sp_tags) do
		if v and v.keep_time then
			v.keep_time = v.keep_time - dt
			if v.keep_time < 0 then
				self.sp_tags[k] = nil
			end
		end
	end
	self:CheckTags()
end
--检查当前的状态
function M:CheckTags()
	for i = 1,#tags_enum do
		if self:IsTagActive(tags_enum[i]) then
			self.ctrlState = StateType.running
			--不能用if-else，同一帧进来的状态会被错误计算
			--冰冻
			local data = self:GetDataByTag(tags_enum[i])
			if i == 1 then
				self:FrozenStart(data)
			end
			--眩晕
			if i == 2 then
				self:DizzinessStart(data)
			end
			--麻痹
			if i == 3 then
				self:ParalysisStart(data)
			end
		else
			--冰冻
			if i == 1 then
				self:FrozenOver()
			end
			--眩晕
			if i == 2 then
				self:DizzinessOver()
			end
			--麻痹
			if i == 3 then
				self:ParalysisOver()
			end
			if not self:IsDuringStationary() then
				self:Finish()
			end
		end
	end
end

function M:FrozenStart(data)
	if GetTag( self.object , "break_frozen" ) then
		self:FrozenOver()
		return
	end
	if GetTag( self.object , "immune_frozen" ) then
		self:FrozenOver()
		return
	end
	if not self.duringFrozon then
		self.duringFrozon = true
		self.forzenPrefab = self.object:CreatForzenPrefab()
		self.forzenAnim = self.forzenPrefab.prefab.prefabObj.transform:GetComponent("Animator")
		self.forzenAnim:Play("start", 0, 0)
	end
end

function M:FrozenOver()
	if self.duringFrozon then
		self.duringFrozon = false
		self.forzenAnim:Play("over", 0, 0)
		CachePrefabManager.Back(self.forzenPrefab)
	end
end

function M:DizzinessStart(data)
	if GetTag( self.object , "break_dizziness" ) then
		self:DizzinessOver()
		return
	end
	if GetTag( self.object , "immune_dizziness" ) then
		self:DizzinessOver()
		return
	end
	if not self.duringDizziness then
		self.duringDizziness = true
		local parent = self.object.transform
		local prefabName = data[1] and data[1].prefabName or "YX_xuanyun"
		if self.object.sprite then parent = self.object.sprite.transform end
		self.dizzinessPrefab = GameObject.Instantiate(GetPrefab(prefabName), parent)
		self.dizzinessPrefab.transform.localPosition = Vector3.New(0, 0, 0)	
	end
end

function M:DizzinessOver()
	if self.duringDizziness then
		self.duringDizziness = false
		Destroy(self.dizzinessPrefab)
	end
end
--麻痹开始
function M:ParalysisStart(data)
	if GetTag( self.object , "break_paralysis" ) then
		self:ParalysisOver()
		return
	end
	if GetTag( self.object , "immune_paralysis" ) then
		self:ParalysisOver()
		return
	end
	if not self.duringParalysis then
		self.duringParalysis = true
		local parent = self.object.transform
		local prefabName = data[1] and data[1].prefabName or "YX_TSL_zidan_shouji_02"
		if self.object.sprite then parent = self.object.sprite.transform end
		self.paralysisPrefab = GameObject.Instantiate(GetPrefab(prefabName), parent)
		self.paralysisPrefab.transform.localPosition = Vector3.New(0, 0, 0)	
	end
end
--麻痹结束
function M:ParalysisOver()
	if self.duringParalysis then
		self.duringParalysis = false
		Destroy(self.paralysisPrefab)
	end
end