-- 创建时间:2021-08-25
-- Panel:HeroLengthUpPanel
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

HeroLengthUpPanel = basefunc.class()
local C = HeroLengthUpPanel
C.name = "HeroLengthUpPanel"

function C.Create(parent)
	return C.New(parent)
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

function C:Ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self.add_length_btn.onClick:AddListener(
		function()
			if GameInfoCenter.GetHeroCapacity() < 22 and GameInfoCenter.GetAssetNum("prop_snake_egg") >= 2 then
				GameInfoCenter.AddAssetNum("prop_snake_egg",-2)
				GameInfoCenter.SetHeroCapacity(GameInfoCenter.GetHeroCapacity() + 1)
				self:MyRefresh()
			end
		end
	)
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self.curr_info_txt.text = "当前金蛇胆："..GameInfoCenter.GetAssetNum("prop_snake_egg").."\n"
	.."当前升级需要金蛇胆：2".."\n"
	.."当前蛇长度："..GameInfoCenter.GetHeroCapacity()
end
