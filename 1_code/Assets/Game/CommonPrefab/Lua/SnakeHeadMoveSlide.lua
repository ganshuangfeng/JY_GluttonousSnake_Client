-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveSlide
-- 滑动屏幕控制

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveSlide = basefunc.class(SnakeHeadMoveBase)
local M = SnakeHeadMoveSlide
M.name = "SnakeHeadMoveSlide"

function M.Create()
	return M.New()
end

function M:Ctor()
	self.prefabName = M.name
	M.super.Ctor(self)
end

function M:InitUI()
	M.super.InitUI(self)
	self.anim = self.transform:GetComponent("Animator")
	self.pos = {x=0, y=0, z=0}
	self.isRun = false
	self.runMaxTime = 0.5
	self.runCurTime = self.runMaxTime
	self:MyRefresh()
end

function M:OnDownClick()
	self.mouse = UnityEngine.Input.mousePosition
end

function M:OnUpClick()
	local p = UnityEngine.Input.mousePosition - self.mouse
	local nP = Vec2DNormalize( p )
	local r = Vec2DAngle( nP )

	local d = math.floor( ( r % 360 + 45 ) / 90 ) % 4
	if d == d then
		self.dir_node.position = CSPanel.camera2d:ScreenToWorldPoint(self.mouse)
		self.dir_node.rotation = Quaternion.Euler(0, 0, d*90)
		self.anim:Play("run", 0, 0)
		Event.Brocast("head_manual_change_target_dir", d)
	end
end

