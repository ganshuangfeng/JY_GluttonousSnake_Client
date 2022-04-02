-- 创建时间:2021-07-19
-- Panel:ExtSkillSP2Panel
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

ExtSkillSP2Panel = basefunc.class()
local C = ExtSkillSP2Panel
C.name = "ExtSkillSP2Panel"
--Event.Brocast("merge_hero",{choose_hero_id = self.choose_hero.data.id,near_hero_id = near_hero.data.id})
local _max = 20
local Instance
function C.Create(parent)
	if Instance then
		return Instance 
	else
		Instance = C.New(parent)
		ExtSkillSP2Panel.instance = Instance
		return Instance
	end
end

function C.Instance()
	return Instance
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
	if self.Mian_Timer then
		self.Mian_Timer:Start()
	end
	self.Mian_Timer = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:Ctor(parent)
	local obj = NewObject("ExtSkillSP3Panel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.energy = 0
	LuaHelper.GeneratingVar(self.transform, self)
	self.Mian_Timer = Timer.New(function(_, time_elapsed)
		self:FrameUpdate(time_elapsed)
	end,0.02,-1, nil, true)
	self.Mian_Timer:Start()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

-- local color_config = {
-- 	[1] = "红色",
-- 	[2] = "绿色",
-- 	[3] = "黄色",
-- 	[4] = "蓝色",
-- }

function C:InitUI()
	
	self.skill_list = {}
	for i = 1,4 do
		local pre = ExtSkillSP2Prefab.Create(self["pos"..i], i)
		self.skill_list[#self.skill_list + 1] = pre
	end

	-- SkillManager.SkillCreate({type = "componse_attack_head_rocket", parent=self.st_node})
	CSPanel.st_skill_node = self.st_node
	self:MyRefresh()
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:UpdateUI()
	if not GameInfoCenter.playerDta or not GameInfoCenter.playerDta.hp then
		self.curr_energy_txt.text = "--/--"
		self.pro_width.sizeDelta = Vector2.New(810 , 24)
		return
	end
	local hp = 0
	if GameInfoCenter.playerDta.hp and GameInfoCenter.playerDta.hp > 0 then
		hp = GameInfoCenter.playerDta.hp
	end

	local hpMax = 1
	if GameInfoCenter.playerDta.hpMax then
		hpMax = GameInfoCenter.playerDta.hpMax
	end
	
	self.curr_energy_txt.text = hp .."/".. hpMax
	self.pro_width.sizeDelta = Vector2.New(810 * hp / hpMax , 24)
end

--主要刷新
function C:FrameUpdate(time_elapsed)
	self:UpdateUI()
	for k,v in ipairs(self.skill_list) do
		v:FrameUpdate(time_elapsed)
	end
end

function C.TriggerExtSkill(type)
	if Instance and Instance.skill_list then
		Instance.skill_list[type]:TriggerSkill()
	end
end

function C.GetSkillCDData()
	if Instance and Instance.skill_list then
		local ret = {}
		for i = 1,4 do
			ret[i] = Instance.skill_list[i].cd_value3
		end
		return ret
	end
end