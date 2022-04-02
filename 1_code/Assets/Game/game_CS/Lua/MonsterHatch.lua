-- 创建时间:2021-09-08
-- Panel:MonsterHatch
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

MonsterHatch = basefunc.class(Object)
local M = MonsterHatch
M.name = "MonsterHatch"

function M.Create(data)
	return M.New(data)
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

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	-- dump(self.data,"<color=red>8888888888888888888888888888888888888888</color>")
	local parent = CSPanel.map_node
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = NewObject(M.name, parent)
	end
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.data_inspector = GetDataInfo(self.gameObject)
	self.gameObject:SetActive(false)
end

function M:Init()
	-- local stageData = GameInfoCenter.GetStageData()
	if self.data_inspector.stageIndex then
		self.stageIndex = tonumber(self.data_inspector.stageIndex)
	else
		self.stageIndex = tonumber(self.data.building.stageIndex)
	end
	local data = self:GetData()
	-- GameConfigCenter.ResetStageMonsterData(stageData.curLevel,stageData.roomNo,self.stageIndex ,data)
end

function M:GetData()
	local data = self.data.building
	local _d  = {}
	_d.pos = self.gameObject.transform.position
	_d.type = data.data_id
	_d.level = data.level or 1
	return _d
end

function M:FrameUpdate(time_elapsed)

end