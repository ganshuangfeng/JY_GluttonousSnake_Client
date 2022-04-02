-- 创建时间:2021-08-26
-- Panel:SnakeHeadMoveSelectPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SnakeHeadMoveSelectPanel = basefunc.class()
local C = SnakeHeadMoveSelectPanel
C.name = "SnakeHeadMoveSelectPanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
		self:MyExit()
	end)

	self.fxj_btn.onClick:AddListener(function ()
		SnakeHeadMoveManual.Exit()
		SnakeHeadMoveManual.Create({type=1})
		self:MyExit()
	end)
	self.hdpm_btn.onClick:AddListener(function ()
		SnakeHeadMoveManual.Exit()
		SnakeHeadMoveManual.Create({type=2})
		self:MyExit()
	end)
	self.xlyg_btn.onClick:AddListener(function ()
		SnakeHeadMoveManual.Exit()
		SnakeHeadMoveManual.Create({type=3})
		self:MyExit()
	end)
	self.djpm_btn.onClick:AddListener(function ()
		SnakeHeadMoveManual.Exit()
		SnakeHeadMoveManual.Create({type=4})
		self:MyExit()
	end)
	self.yg360_btn.onClick:AddListener(function ()
		SnakeHeadMoveManual.Exit()
		SnakeHeadMoveManual.Create({type=5})
		self:MyExit()
	end)

	self:MyRefresh()
end

function C:MyRefresh()

end
