-- 创建时间:2021-08-16
-- Panel:SnakeHeadMoveClick
-- 方向键控制

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveClick = basefunc.class(SnakeHeadMoveBase)
local M = SnakeHeadMoveClick
M.name = "SnakeHeadMoveClick"

function M.Create()
	return M.New()
end

function M:Ctor()
	self.prefabName = M.name
	M.super.Ctor(self)
end

function M:InitUI()
	self.pos = {x=0, y=0, z=0}
	self.isRun = false

	-- 四方向按键
	self.keyDir4.gameObject:SetActive(true)

	self.dir4_right_btn.onClick:AddListener(function ()
        self:OnDir4Click(0)
    end)
	self.dir4_left_btn.onClick:AddListener(function ()
        self:OnDir4Click(2)
    end)
	self.dir4_up_btn.onClick:AddListener(function ()
        self:OnDir4Click(1)
    end)
	self.dir4_down_btn.onClick:AddListener(function ()
        self:OnDir4Click(3)
    end)
end

function M:OnDir4Click(d)
	Event.Brocast("head_manual_change_target_dir", d)
end

