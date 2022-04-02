-- 创建时间:2021-09-24
-- Panel:FactoryPanel
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

FactoryPanel = basefunc.class()
local M = FactoryPanel
M.name = "FactoryPanel"

function M.Create(parent)
	return M.New(parent)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["hero_level_changed"] = basefunc.handler(self,self.on_hero_level_changed)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv1").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.head_btn.onClick:AddListener(function()
		if not self.HeadShowPanel then
			self.HeadShowPanel = HeadShowPanel.Create(self)
		end
		self.turret_node.gameObject:SetActive(false)
		self.turret_btn.gameObject:SetActive(true)
		self.head_node.gameObject:SetActive(true)
		self.head_btn.gameObject:SetActive(false)
		self.turret_show_node.gameObject:SetActive(false)
		self.head_show_node.gameObject:SetActive(true)
	end)
	self.turret_btn.onClick:AddListener(function()
		self.turret_node.gameObject:SetActive(true)
		self.turret_btn.gameObject:SetActive(false)
		self.head_node.gameObject:SetActive(false)
		self.head_btn.gameObject:SetActive(true)
		self.turret_show_node.gameObject:SetActive(true)
		self.head_show_node.gameObject:SetActive(false)
	end)
end

function M:InitUI()
	self.TurretShowPanel = TurretShowPanel.Create(self)
	self:MyRefresh()

	GuideLogic.CheckRunGuide("hall")
end

function M:MyRefresh()
end

function M:on_hero_level_changed(data)
	if data.hero_type == self.TurretShowPanel.cur_hero_type then
		self.TurretShowPanel.turret_items[data.hero_type].level = data.level
		self:Refresh()
	end
end

function M:Refresh()
	self.TurretShowPanel:RefreshTurretInfo(self.TurretShowPanel.cur_hero_type)
	self.TurretShowPanel:RefreshTurretItem(self.TurretShowPanel.cur_hero_type)
end