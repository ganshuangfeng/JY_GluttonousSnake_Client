-- 创建时间:2021-07-30
-- Panel:ExtSkillSP2Prefab
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

ExtSkillSP2Prefab = basefunc.class()
local C = ExtSkillSP2Prefab
C.name = "ExtSkillSP2Prefab"

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_turret_change_msg"] = basefunc.handler(self,self.on_model_turret_change_msg)
    self.lister["HeroTypeChange"] = basefunc.handler(self,self.OnHeroTypeChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:Ctor(parent, data)
	self.data = {}
	self.data.hero_color = data
	ExtPanel.ExtMsg(self)
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
	
	local type = GameInfoCenter.GetBattleTurretByColor(self.data.hero_color)
	local t2i = {
		[1] = "wf4_jn_02",
		[4] = "wf4_jn_01",
	}
	local icon = t2i[type]--GameConfigCenter.GetHeroIconByType(type)
	self.icon_img.sprite = GetTexture(icon)
	self.mask_img.sprite = GetTexture(icon)
	self.lock_img.sprite = GetTexture(icon)
	self.transform:GetComponent("Button").onClick:AddListener(
	function()
		self:TriggerSkill()
	end)
	self.chg_cd = 1
	self.chg_cd2 = 1

	self.cd_value = 10
	self.cd_value2 = 0
	self.cd_value3 = 0
	self.ready = false

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshCD()
	if self.cd_value2 <=0 then
		self.cd_txt.text = ""
	else
		self.cd_txt.text = self.cd_value2
	end

	self:on_model_turret_change_msg(true)
end
function C:on_model_turret_change_msg(noFx)
	local b = false
	if MainModel.UserInfo.GameInfo and MainModel.UserInfo.GameInfo.turret_list then
		for k,v in pairs(MainModel.UserInfo.GameInfo.turret_list) do
			local cfg = GameConfigCenter.GetHeroConfig(v.type,v.star)
			if cfg.hero_color == self.data.hero_color then
				b = true
				break
			end
		end
	end

	if not self.is_lock and b and not noFx then
	    CSEffectManager.PlayShowAndHideAndCall(
                                        CSPanel.anim_node,
                                        "js_jiesuo",
                                        nil,
                                        self.transform.position,
                                        1,
                                        nil,
                                        function ()
                                            
                                        end,
                                        nil,
                                        nil,
                                        function ()
                                            
                                        end)

	end
	self.is_lock = b
	self.lock.gameObject:SetActive(not b)
end

function C:RefreshCD()
	if self.cd_value3 <=0 then
		self.cd_value2 = 0
		self.cd_value3 = 0
	end
	local jd = 1 - self.cd_value3 / self.cd_value
	self.icon_img.fillAmount = jd
end

function C:FrameUpdate(dt)
	if self.ready then
		return
	end
	if self.cd_value3 <= 0 then
		self.cd_value2 = 0
		self.cd_value3 = 0
		self.chg_cd2 = self.chg_cd
		self.ready = true
		self:MyRefresh()
	else
		self.cd_value3 = self.cd_value3 - dt

		self:RefreshCD()

		self.chg_cd2 = self.chg_cd2 - dt
		if self.chg_cd2 < 0 then
			self.chg_cd2 = self.chg_cd2 + self.chg_cd
			self.cd_value2 = self.cd_value2 - 1
			self.cd_txt.text = self.cd_value2
		end
	end
end

--  [1] = "红色",
-- 	[2] = "绿色",
-- 	[3] = "黄色",
-- 	[4] = "蓝色",

local yanse = {
	[1] = "hongse",
	[2] = "lvse",
	[3] = "huangse",
	[4] = "lanse",
}
function C:UseFX()
	CSEffectManager.PlayShowAndHideAndCall(
                                            CSPanel.transform,
                                            "jn_gx_tb_"..yanse[self.data.hero_color],
                                            nil,
                                            self.transform.position,
                                            0.2)


	local all_hero = GameInfoCenter.GetAllHero()
	for k , v in pairs (all_hero) do
		if v.data.hero_color == self.data.hero_color then
			local endPos = CSModel.Get3DToUIPoint(v.transform.position)
			CSEffectManager.PlayMoveAndHideFX(
	                                            CSPanel.transform,
	                                            "TW_"..yanse[self.data.hero_color],
	                                            self.transform.position,
	                                            endPos,
	                                            nil,
	                                            0.5)

			CSEffectManager.PlayShowAndHideAndCall(
                                            v.transform,
                                            "LG_"..yanse[self.data.hero_color],
                                            nil,
                                            v.transform.position,
                                            2,
                                            nil,
                                            nil,
                                            function (tran)
                                                -- tran.localScale = Vector3.New(0.7, 0.7, 0.7)
                                            end)
		end
	end

end

function C:TriggerSkill()
	if self.cd_value2 <= 0 then

		local detailTime = 0
		Event.Brocast("ExtraSkillTrigger",{hero_color = self.data.hero_color})
		--Event.Brocast("ExtraSkillTrigger",{skill_key = "crash_skill" })
		self:UseFX()

		self.cd_value2 = self.cd_value
		self.cd_value3 = self.cd_value
		self.chg_cd2 = self.chg_cd
		self.ready = false
	else
		-- LittleTips.Create("CD中")
		dump(self.data,"<color=red>技能正在CD中:</color>")
	end
end

function C:OnHeroTypeChange(data)
	if data.color == self.data.hero_color then
		local icon = GameConfigCenter.GetHeroIconByType(data.type)
		self.icon_img.sprite = GetTexture(icon)
		self.mask_img.sprite = GetTexture(icon)
		self.lock_img.sprite = GetTexture(icon)
	end
end