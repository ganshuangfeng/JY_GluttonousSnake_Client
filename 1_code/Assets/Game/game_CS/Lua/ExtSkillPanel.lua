-- 创建时间:2021-07-19
-- Panel:ExtSkillPanel
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

ExtSkillPanel = basefunc.class()
local C = ExtSkillPanel
C.name = "ExtSkillPanel"
--Event.Brocast("merge_hero",{choose_hero_id = self.choose_hero.data.heroId,near_hero_id = near_hero.data.heroId})
local _max = 20

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
	self.lister["hero_prefab_level_up"] = basefunc.handler(self,self.on_hero_prefab_level_up)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:Exit()
	if self.Mian_Timer then
		self.Mian_Timer:Start()
	end
	self.Mian_Timer = nil
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(parent)
	ExtPanel.ExtMsg(self)
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.energy = 20
	LuaHelper.GeneratingVar(self.transform, self)
	self.Mian_Timer = Timer.New(function()
		self:MainUpDate()
	end,0.02,-1)
	self.Mian_Timer:Start()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.config = {
		[1] = {
			type = 1,
			cd = 5,
			name = "冰星",
			icon = "2d_img_jn_3",
			event = "Big1",
			pay = 0,
			left_cd = 0,
		},
		[2] = {
			type = 2,
			cd = 5,
			name = "弓箭",
			icon = "2d_img_jn_4",
			event = "Big2",
			pay = 0,
			left_cd = 0,
		},
		[3] = {
			type = 3,
			cd = 5,
			name = "激光",
			icon = "2d_img_jn_6",
			event = "Big3",
			pay = 0,
			left_cd = 0,
		},
		[4] = {
			type = 4,
			cd = 5,
			name = "毒液",
			icon = "2d_img_jn_5",
			event = "Big4",
			pay = 0,
			left_cd = 0,
		},
	}
	for i = 1,#self.config do
		local obj = GameObject.Instantiate(self.item,self["pos"..i])
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.cd_txt.text = self.config[i].cd
		temp_ui.mask_img.sprite = GetTexture(self.config[i].icon)
		temp_ui.icon_img.sprite = GetTexture(self.config[i].icon)
		temp_ui.pay_txt.text = self.config[i].pay
		obj.transform:GetComponent("Button").onClick:AddListener(
			function()
				self[self.config[i].event](self)
			end
		)
		obj.gameObject:SetActive(true)
		self.config[i].ui = temp_ui
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:on_hero_prefab_level_up(data)
	if self.energy < _max then
		self.energy = self.energy + 1
	end
	local type = data.hero.type
	local hero_wait = ComponseManager.GetHeroByHeroId(data.hero.id)
	GameComAnimTool.PlayMoveAndHideFX(self.transform,"TW_lizi",hero_wait.transform.position,self["pos"..type].transform.position,0.3,1.5,nil,1)
	--self:UpDateDataByType(type)
end

-- function C:UpDateDataByType(type)
-- 	for i = 1,#self.config do
-- 		if self.config[i].type == type then
-- 			self.config[i].cd = self.config[i].cd - 1
-- 			self:UpdateUI()
-- 		end
-- 	end
-- end

function C:ReSetCD(type)
	for i = 1,#self.config do
		if self.config[i].type == type then
			self.config[i].left_cd = self.config[i].cd
			self:UpdateUI()
		end
	end
end

function C:GetDataByType(type)
	for i = 1,#self.config do
		if self.config[i].type == type then
			return self.config[i]
		end
	end
end


function C:UpdateUI()
	for i = 1,#self.config do
		if self.config[i].left_cd <= 0 then
			if self.energy >= self.config[i].pay then
				self.config[i].ui.cd_txt.text = ""
				self.config[i].ui.icon_img.fillAmount = 1
			else
				self.config[i].ui.cd_txt.text = "能量不足"
				self.config[i].ui.icon_img.fillAmount = 0
			end	
		else
			self.config[i].ui.cd_txt.text = string.format("%.1f", self.config[i].left_cd) 
			self.config[i].ui.icon_img.fillAmount = (self.config[i].cd - self.config[i].left_cd)/ self.config[i].cd
		end
	end
	self.curr_energy_txt.text = self.energy.."/".._max
	self.pro_width.sizeDelta = Vector2.New(630 * self.energy / _max ,24.78)
end
--全体释放 冰星
function C:Big1()
	if self:GetDataByType(1).left_cd <= 0 and self:IsEnergyEnough(1) then
		local all_hero = GameInfoCenter.GetAllHero()
		for k , v in pairs (all_hero) do
			if v.config.hero_color == 1 then
				self:ReSetCD(1)
			end
		end
		self.energy = self.energy - self.config[1].pay
		Event.Brocast("ExtraSkillTrigger",{hero_color = 4})
	end
end

--全体释放 弓箭
function C:Big2()
	if self:GetDataByType(2).left_cd <= 0 and self:IsEnergyEnough(2) then
		local all_hero = GameInfoCenter.GetAllHero()
		for k , v in pairs (all_hero) do
			if v.config.hero_color == 2 then
				self:ReSetCD(2)
			end
		end
		self.energy = self.energy - self.config[2].pay
		Event.Brocast("ExtraSkillTrigger",{hero_color = 3})
	end
end
--全体释放 激光
function C:Big3()
	if  self:GetDataByType(3).left_cd <= 0 and self:IsEnergyEnough(3) then
		local all_hero = GameInfoCenter.GetAllHero()
		for k , v in pairs (all_hero) do
			if v.config.hero_color == 3 then
				self:ReSetCD(3)
			end
		end
		self.energy = self.energy - self.config[3].pay
		Event.Brocast("ExtraSkillTrigger",{hero_color = 1})
	end
end
--全体释放 毒液
function C:Big4()
	if self:GetDataByType(4).left_cd <= 0 and self:IsEnergyEnough(4) then
		local all_hero = GameInfoCenter.GetAllHero()
		for k , v in pairs (all_hero) do
			if v.config.hero_color == 4 then
				self:ReSetCD(4)
			end
		end
		self.energy = self.energy - self.config[4].pay
		Event.Brocast("ExtraSkillTrigger",{hero_color = 2})
	end
end
--主要刷新
function C:MainUpDate()
	for i = 1,#self.config do
		if self.config[i].left_cd <= 0 then
			self.config[i].left_cd = 0
		else
			self.config[i].left_cd = self.config[i].left_cd - 0.02
		end
	end
	self:UpdateUI()
end
--测试
function C:TestExtSkill()

end

function C:IsEnergyEnough(type)
	if self.energy >= self.config[type].pay then
		return true
	end
	return false
end