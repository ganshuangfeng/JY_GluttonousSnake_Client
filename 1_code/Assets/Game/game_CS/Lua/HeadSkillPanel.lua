local basefunc = require "Game/Common/basefunc"

HeadSkillPanel = basefunc.class()
local M = HeadSkillPanel
M.name = "HeadSkillPanel"

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
	self.lister["NewHeadExtraSkillTrigger_Used"] = basefunc.handler(self,self.on_NewHeadExtraSkillTrigger_Used)
	self.lister["head_skill_usetime_changed"] = basefunc.handler(self,self.on_head_skill_usetime_changed)
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

function M:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Animator = self.skill_btn.gameObject.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.old_times = HeadSkillManager.GetUseTime()

	--从第6关开始 按钮出现
	self.skill_btn.gameObject:SetActive(MainModel.UserInfo.cur_level > 5)
end

function M:InitUI()
	self.skill_btn.onClick:AddListener(
		function()
			if HeadSkillManager.GetUseTime() > 0 and self.cd <= 0 then
				Event.Brocast("NewHeadExtraSkillTrigger",{skill_key = "head_extra_skill"})
			end
		end
	)
	self:MyRefresh()
end

function M:MyRefresh()
	self.pro_txt.text = HeadSkillManager.GetUseTime().."/"..HeadSkillManager.GetMaxTime()
	if self.old_times and self.old_times < HeadSkillManager.GetUseTime() then
		local seq = DoTweenSequence.Create()
		self.Animator.enabled = false
		self.skill_btn.gameObject.transform.localScale = Vector3.New(1,1,1)
		local scale = self.skill_btn.gameObject.transform.localScale
		seq:Append(self.skill_btn.gameObject.transform:DOScale(scale * 1.4,0.1):SetEase(Enum.Ease.InSine))
		seq:Append(self.skill_btn.gameObject.transform:DOScale(scale,0.1):SetEase(Enum.Ease.InSine))
		seq:AppendCallback(
			function()
				self.Animator.enabled = true
			end
		)
		print("<color=red>变大动画+++++++++++++</color>")
	end
	local cur_head = MainModel.UserInfo.GameInfo.head_type
	local cur_head_cfg = GameConfigCenter.GetHeroHeadConfig(cur_head)
	self.skill_icon_img.sprite = GetTexture(cur_head_cfg.skillIcon)
	self.old_times = HeadSkillManager.GetUseTime()
	self:RefreshOperMode()
end

function M:on_head_skill_usetime_changed()
	self:MyRefresh()
end

function M:FrameUpdate(dt)
	if not IsEquals(self.gameObject) then return end
	self.cd = self.cd or 0
	self.cd = self.cd - dt
	local total_cd = HeadSkillManager.GetCD() + HeadSkillManager.GetKeepTime()
	self.mask_img.fillAmount = (self.cd) / total_cd
	if self.cd > 0 then
		self.cd_txt.gameObject:SetActive(true)
		self.cd_txt.text = math.floor(self.cd) + 1
	else
		self.cd_txt.gameObject:SetActive(false)
	end
end

function M:on_NewHeadExtraSkillTrigger_Used(data)
	if data.skill_key == "head_extra_skill" then
		HeadSkillManager.AddSkillUseTimes(-1)
		self.cd = HeadSkillManager.GetCD() + HeadSkillManager.GetKeepTime()
	end
end

function M:RefreshOperMode()
	local a = GameSetCenter.GetPlayerMO()
	if a == 0 then -- 右手模式
		self.skill_btn.transform.localPosition = Vector3.New(372, -563, 0)
	else
		self.skill_btn.transform.localPosition = Vector3.New(-372, -563, 0)
	end
end