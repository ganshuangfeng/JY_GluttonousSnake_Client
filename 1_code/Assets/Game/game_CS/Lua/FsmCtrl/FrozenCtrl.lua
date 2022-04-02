-- 创建时间:2021-07-29

local basefunc = require "Game/Common/basefunc"

FrozenCtrl = basefunc.class(BaseCtrl)

local M = FrozenCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
	self.data = data
    self.forzen_cd = 2
	if self.data and self.data.keep_time then
		self.forzen_cd = self.data.keep_time
	end
    self.forzen_ct = 0
end

--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready
end

--- 状态开始时调用
function M:Begin()

	if GetTag( self.object , "immune_frozen" ) then
		self.ctrlState = StateType.finish
		return
	end

	self.ctrlState = StateType.running

	self.forzenPrefab = self.object:CreatForzenPrefab()
	self.forzenAnim = self.forzenPrefab.prefab.prefabObj.transform:GetComponent("Animator")
	
	if self.forzenOvering then
		self.forzenAnim:Play("start", 0, 0)
		self.forzenOvering = nil
	end

	self.forzen_ct = self.forzen_cd

	if self.object.anim_pay then
		self.object.anim_pay.speed = 0
	end

	self.object.enableRot = false

	if self.object.vehicle then
		self.object.vehicle:Stop()
	end
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self.object.enableRot = true
	CachePrefabManager.Back(self.forzenPrefab)
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
	self.forzen_ct = self.forzen_cd

	if self.forzenOvering then
		self.forzenAnim:Play("start", 0, 0)
		self.forzenOvering = nil
	end
end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end

	if GetTag( self.object , "break_frozen" ) then
		self.ctrlState = StateType.finish
		return
	end

	self.forzen_ct = self.forzen_ct - dt

	if self.forzen_ct < 0 then
		self.ctrlState = StateType.finish
	else
		if self.forzen_ct < 0.5 and not self.forzenOvering then
	    	self.forzenAnim:Play("over", 0, 0)
	    	self.forzenOvering = true
	    end
	end
end

