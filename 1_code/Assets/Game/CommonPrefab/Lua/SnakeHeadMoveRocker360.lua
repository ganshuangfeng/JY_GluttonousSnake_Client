-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveRocker360
-- 虚拟摇杆控制

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveRocker360 = basefunc.class(SnakeHeadMoveBase)
local M = SnakeHeadMoveRocker360
M.name = "SnakeHeadMoveRocker360"

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
	self.radius = 142

    self.yPos = Vector3.New(0, -718, 0)
    self.node.localPosition = self.yPos
	self:MyRefresh()
end

function M:MyRefresh()
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
	local len = Vec2DLength(p)
	if len > self.radius then
		-- local cha = len - self.radius
		-- self.mouse = Vector3.New(self.mouse.x + nP.x*cha, self.mouse.y + nP.y*cha, 0)
		-- self.node.position = CSPanel.camera2d:ScreenToWorldPoint( self.mouse )

		len = self.radius
	end
	self.rocker_this.rotation = Quaternion.Euler(0, 0, r)
	self.rocker_node.localPosition = Vector3.New(len*nP.x, len*nP.y, 0)
	--print("xxx--------OnMoveClick 222 self.dir:" , r )
	Event.Brocast("head_manual_change_target_rot", r , math.floor( len / self.radius * 100 ) )
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

