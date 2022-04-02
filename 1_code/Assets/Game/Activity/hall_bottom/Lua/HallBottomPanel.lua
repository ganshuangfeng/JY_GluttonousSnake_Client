-- 创建时间:2021-10-13
-- Panel:HallBottomPanel
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

HallBottomPanel = basefunc.class()
local M = HallBottomPanel
M.name = "HallBottomPanel"

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
    self.lister["ExitScene"] = basefunc.handler(self, self.OnDestroy)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:ClearCellList()
	self:RemoveListener()
	HallBottomManager.cur_panel = nil
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent)
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.an_list = HallBottomManager.GetAnList()
	self.cur_index = 1
	for i, v in ipairs(self.an_list) do
		if v.goto_ui and v.goto_ui[1] == "adventure" then -- 默认选中冒险
			self.cur_index = i
			break
		end
	end
	
	self:MyRefresh()

	self:OnGetClick(self.cur_index, true)
end

function M:MyRefresh()
	self:ClearCellList()

	for i, v in ipairs(self.an_list) do
		local pre = HallBottomPrefab.Create(self.bottom_lay_out, v, self.OnGetClick, self, i)
		self.CellList[#self.CellList + 1] = pre
	end
end
function M:ClearCellList()
    if self.CellList then
        for k, v in ipairs(self.CellList) do
            v:OnDestroy()
        end
    end
    self.CellList = {}
end

function M:RefreshSelect()
	for k, v in ipairs(self.CellList) do
		v:RefreshSelect(self.cur_index)
	end
end

function M:OnGetClick(index, b)
	if b or self.cur_index ~= index then
		local cfg = self.an_list[index]
		if not SYSQXManager.CheckCondition(cfg.condi_key) then
			return
		end
		if cfg.is_lock then
			LittleTips.Create("暂未开放")
		else
			if self.cur_pre then
				self.cur_pre:OnDestroy()
				self.cur_pre = nil
			end
			self.cur_index = index
			self.cur_pre = GameManager.GotoUI( GetGotoUIParm(cfg.goto_ui) )
			self:RefreshSelect()
		end
	end
end

function M:on_global_hint_state_change_msg(data)
	if HallBottomManager.IsContain(data.gotoui) then
		for k, v in ipairs(self.CellList) do
			v:RefreshRed()
		end
	end
end


