-- 创建时间:2021-09-09
-- Panel:ExtSkillSP4Panel
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

ExtSkillSP4Panel = basefunc.class()
local M = ExtSkillSP4Panel
M.name = "ExtSkillSP4Panel"


local Instance
local demon_skill_cd = 8
local angel_skill_cd = 8

function M.Create(parent)
	if Instance then
		return Instance 
	else
		Instance = M.New(parent)
		ExtSkillSP2Panel.instance = Instance
		return Instance
	end
end

function M.Instance()
	return Instance
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["GetNewAngelSkill"] = basefunc.handler(self,self.GetNewAngelSkill)
	self.lister["GetNewDemonSkill"] = basefunc.handler(self,self.GetNewDemonSkill)
	self.lister["ChargePrefabXuliEnd"] = basefunc.handler(self,self.OnChargePrefabXuliEnd)
	self.lister["ChargePrefabXuli"] = basefunc.handler(self,self.OnChargePrefabXuli)

    self.lister["global_player_mo_change"] = basefunc.handler(self, self.RefreshOperMode)
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.demon_skill_left = 0
	self.angel_skill_left = 0
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.BossIdList = {} 
end

function M:InitUI()
	CSPanel.st_skill_node = self.st_node
	self.angel_btn.onClick:AddListener(
		function()
			local sd = GameInfoCenter.GetStageData()
			if sd.curLevel ~= 0 and self:IsDuringBossXuLi(4) then
				Event.Brocast("BreakAngelSkill")
				return
			end
			if self.angel_skill_left <= 0 then
				Event.Brocast("PlayAngelSkill")
				self.angel_skill_left = angel_skill_cd
			end
		end
	)
	self.demon_btn.onClick:AddListener(
		function()
			local sd = GameInfoCenter.GetStageData()
			if sd.curLevel ~= 0 and self:IsDuringBossXuLi(2) then
				Event.Brocast("BreakDemonSkill")
				return
			end
			if self.demon_skill_left <= 0 then
				Event.Brocast("PlayDemonSkill")
				self.demon_skill_left = demon_skill_cd
			end
		end
	)
	self:MyRefresh()
end

function M:GetNewAngelSkill(data)
	self.angel_skill_name_txt.text = data.skill.name
end

function M:GetNewDemonSkill(data)
	self.demon_skill_name_txt.text = data.skill.name
end

function M:FrameUpdate(dt) 
	if self.demon_skill_left > 0 then
		self.demon_skill_left = self.demon_skill_left - dt
		self.demon_cut_down_txt.text = math.floor(self.demon_skill_left + 1)
		self.demon_cut_down_txt.gameObject:SetActive(true)
		if self.demon_skill_left < 0 then
			self.demon_tx.gameObject:SetActive(true)
		else
			self.demon_tx.gameObject:SetActive(false)
		end
	else
		self.demon_cut_down_txt.gameObject:SetActive(false)

	end

	if self.angel_skill_left > 0 then
		self.angel_skill_left = self.angel_skill_left - dt
		self.angel_cut_down_txt.text = math.floor(self.angel_skill_left + 1)
		self.angel_cut_down_txt.gameObject:SetActive(true)
		if self.angel_skill_left < 0 then
			self.angel_tx.gameObject:SetActive(true)
		else
			self.angel_tx.gameObject:SetActive(false)
		end
	else
		self.angel_cut_down_txt.gameObject:SetActive(false)
	end

	self.angel_mask_img.fillAmount = self.angel_skill_left / angel_skill_cd
	self.demon_mask_img.fillAmount = self.demon_skill_left /demon_skill_cd
	
end

function M:MyRefresh()
	self:RefreshOperMode()
end

function M:IsDuringBossXuLi(color)
	for k , v in pairs(self.BossIdList) do
		if v and v.color == color then
			return true
		end
	end
	return false
end

function M:OnChargePrefabXuli(data)
	self.BossIdList[data.id] = {color = data.color}
end

function M:OnChargePrefabXuliEnd(data)
	self.BossIdList[data.id] = nil
end

function M:RefreshOperMode()
	local a = GameSetCenter.GetPlayerMO()
	if a == 0 then -- 右手模式
		self.st_node.transform.localPosition = Vector3.New(-411, 516, 0)
		self.angel_btn.transform.localPosition = Vector3.New(388, 742, 0)
		self.demon_btn.transform.localPosition = Vector3.New(388, 368, 0)
	else
		self.st_node.transform.localPosition = Vector3.New(411, 516, 0)
		self.angel_btn.transform.localPosition = Vector3.New(-388, 742, 0)
		self.demon_btn.transform.localPosition = Vector3.New(-388, 368, 0)
	end
end