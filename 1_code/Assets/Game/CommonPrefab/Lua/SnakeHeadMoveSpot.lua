-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveSpot
-- 点击屏幕控制

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveSpot = basefunc.class(SnakeHeadMoveBase)
local M = SnakeHeadMoveSpot
M.name = "SnakeHeadMoveSpot"

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
	local mouse = UnityEngine.Input.mousePosition
	local head = GameInfoCenter.GetHeroHead()
	if head then
		local headPos = CSPanel.camera3d:WorldToScreenPoint( head.transform.position )

		local p = mouse - headPos
		local nP = Vec2DNormalize( p )
		local r = Vec2DAngle( nP )

		local d = math.floor( ( r % 360 + 45 ) / 90 ) % 4
		if d == d then
			self.dir_node.position = CSPanel.camera2d:ScreenToWorldPoint( mouse )
			self.anim:Play("run", 0, 0)
			-- Event.Brocast("head_manual_change_target_dir", d)
			Event.Brocast("head_manual_change_target_pos", CSPanel.camera3d:ScreenToWorldPoint( mouse ))
		end
	end
end

