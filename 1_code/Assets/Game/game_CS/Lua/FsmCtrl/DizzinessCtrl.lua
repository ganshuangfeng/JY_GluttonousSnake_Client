local basefunc = require "Game/Common/basefunc"

DizzinessCtrl = basefunc.class(BaseCtrl)

local M = DizzinessCtrl

function M:Ctor( object , data )

	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none

    self.timeDelay = data and data.timeDelay or 1
    self.timeCount = 0
    self.prefabName = data and data.prefabName or "YX_xuanyun"
end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready
end

--- 状态开始时调用
function M:Begin()
	self.ctrlState = StateType.running

	if GetTag( self.object , "immune_dizziness" ) then
		self.ctrlState = StateType.finish
		return
	end
	local parent = self.object.transform
	if self.object.sprite then parent = self.object.sprite.transform end
	self.tx_obj = GameObject.Instantiate(GetPrefab(self.prefabName), parent)
	self.tx_obj.transform.localPosition = Vector3.New(0, 0, 0)
	
	self.object.enableRot = false

	if self.object.vehicle then
		self.object.vehicle:Stop()
	end
	if self.object.anim_pay then
		self.object.anim_pay.speed = 0
	end
end

--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish
	
	self.object.enableRot = true

	if self.object.vehicle then
		self.object.vehicle:Start()
	end
	if self.object.anim_pay then
		self.object.anim_pay.speed = 1
	end
	Destroy(self.tx_obj)
end

--强制结束
function M:Stop()
	self.ctrlState = StateType.finish
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause
	return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

end
-- 刷新
function M:Refresh(data)
	self.timeDelay = data and data.timeDelay or 3
	self.timeCount = 0
end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	if GetTag( self.object , "break_dizziness" ) then
		self.ctrlState = StateType.finish
		return
	end

	self.timeCount = self.timeCount + dt
	if self.timeCount > self.timeDelay then
		self:Stop()
	end

end