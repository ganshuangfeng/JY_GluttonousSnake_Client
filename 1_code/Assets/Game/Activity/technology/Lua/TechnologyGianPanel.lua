-- 创建时间:2021-10-27
-- Panel:TechnologyGianPanel
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

TechnologyGianPanel = basefunc.class()
local M = TechnologyGianPanel
M.name = "TechnologyGianPanel"

function M.Create(index)
	return M.New(index)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
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

function M:Ctor(index)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.index = index
	self:InitUI()
end

function M:InitUI() 
	local data = TechnologyManager.GetAllProperty()
	for k ,v in pairs(data) do
		self.notice.gameObject:SetActive(false)
		local icon = TechnologyManager.GetIconMask(k)
		local obj = GameObject.Instantiate(self.item,self.Content)
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.icon_img.sprite = GetTexture(icon)
		temp_ui.key_txt.text = TechnologyManager.GetDesc(k)
		temp_ui.value_txt.text = "+"..v
		obj.gameObject:SetActive(true)
	end
	self:MyRefresh()
	self.close_btn.onClick:AddListener(
		function()
			self:Exit()
		end
	)
end

function M:MyRefresh()
end
