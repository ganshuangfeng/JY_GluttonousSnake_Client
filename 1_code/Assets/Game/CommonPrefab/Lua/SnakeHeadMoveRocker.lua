-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveRocker
-- 虚拟摇杆控制

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveRocker = basefunc.class(SnakeHeadMoveBase)
local M = SnakeHeadMoveRocker
M.name = "SnakeHeadMoveRocker"

function M.Create()
	return M.New()
end

function M:Ctor()
	self.prefabName = M.name
	M.super.Ctor(self)
end

function M:InitUI()
	M.super.InitUI(self)
	self.pos = {x=0, y=0, z=0}
	self.isRun = false
	self.runMaxTime = 0.5
	self.runCurTime = self.runMaxTime

    self.yPos = Vector3.New(0, -750, 0)
    self.node.localPosition = self.yPos
	self:MyRefresh()
end

function M:MyRefresh()
	for i = 0, 3 do
		if self.dir and self.dir == i then
			self["dir4_yes_"..i].gameObject:SetActive(true)
			self["dir4_no_"..i].gameObject:SetActive(false)
		else
			self["dir4_yes_"..i].gameObject:SetActive(false)
			self["dir4_no_"..i].gameObject:SetActive(true)
		end
	end
end

function M:OnDownClick()
	self.mouse = UnityEngine.Input.mousePosition
	self.isRun = true
	self.node.position = CSPanel.camera2d:ScreenToWorldPoint(self.mouse)
end

function M:OnMoveClick(pos)
	local p = pos - self.mouse
	local nP = Vec2DNormalize( p )
	if Vec2DDistanceSq(nP) < 0.1 then
		return
	end
	local r = Vec2DAngle( nP )
	self.rocker_this.rotation = Quaternion.Euler(0, 0, r)
	self.rocker_node.localPosition = Vector3.New(12*nP.x, 12*nP.y, 0)

	local d = math.floor( ( r % 360 + 45 ) / 90 ) % 4
	if d == d then
		if not self.dir or self.dir ~= d then
			self.runCurTime = self.runMaxTime
			self.dir = d
			Event.Brocast("head_manual_change_target_dir", self.dir)
			self:MyRefresh()
		else
			self.runCurTime = self.runCurTime - Time.deltaTime
			if self.runCurTime < 0 then
				self.runCurTime = self.runMaxTime
				Event.Brocast("head_manual_change_target_dir", self.dir)
			end
		end
	end
end

function M:OnUpClick()
	self.isRun = false
	self.dir = nil
	self.runCurTime = self.runMaxTime
	self.node.localPosition = self.yPos
	self.rocker_this.rotation = Quaternion.Euler(0, 0, 0)
	self.rocker_node.localPosition = Vector3.zero
	self:MyRefresh()
	Event.Brocast("head_manual_change_move_onoff", false)
end

