-- 创建时间:2021-09-16
-- Panel:DebugHeroHead
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

DebugHeroHead = basefunc.class()
local M = DebugHeroHead
M.name = "DebugHeroHead"

function M.Create()
	return M.New()
end
function M:Exit()
	self:CloseCell()
	Destroy(self.gameObject)
end

function M:Ctor()
	self.cellpre = GetPrefab("DebugGrid")
	self.cellpre2 = GetPrefab("DebugGrid2")
	self.stcellpre = GetPrefab("DebugGridST")
	self.cellpre3 = GetPrefab("DebugGrid3")
end

function M:CloseCell()
	if self.cellList then
		for k,v in pairs(self.cellList) do
			Destroy(v)
		end
	end
	self.cellList = {}
end

function M:CreateCell(nott, yest)
	self:CloseCell()

	if nott and #nott > 0 then
		for k,v in pairs(nott) do
			local obj = GameObject.Instantiate(self.cellpre, CSPanel.map_node)
			obj.transform.localPosition = Vector3.New(v.pos.x, v.pos.y, 0)
			self.cellList[#self.cellList + 1] = obj
		end
	end

	if yest and #yest > 0 then
		for k,v in pairs(yest) do
			local obj = GameObject.Instantiate(self.cellpre2, CSPanel.map_node)
			obj.transform.localPosition = Vector3.New(v.pos.x, v.pos.y, 0)
			self.cellList[#self.cellList + 1] = obj
		end
	end
	
end

function M:CreateXCell(v)
	local obj = GameObject.Instantiate(self.cellpre3, CSPanel.map_node)
	obj.transform.localPosition = Vector3.New(v.pos.x, v.pos.y, 0)
	self.cellList[#self.cellList + 1] = obj	
end

function M:CreateSTCell(st)
	if st then
		local obj = GameObject.Instantiate(self.stcellpre, CSPanel.map_node)
		obj.transform.localPosition = Vector3.New(st.gPos.x, st.gPos.y, 0)
		self.cellList[#self.cellList + 1] = obj
		obj.transform:Find("STZSPos1").transform.localPosition = Vector3.New(
																			(st.gPos.x-st.pos1.x) / -3.076923, 
																			(st.gPos.y-st.pos1.y) / -3.076923, 0)
		obj.transform:Find("STZSPos2").transform.localPosition = Vector3.New(
																			(st.gPos.x-st.zPos.x) / -3.076923, 
																			(st.gPos.y-st.zPos.y) / -3.076923, 0)
	end
end

