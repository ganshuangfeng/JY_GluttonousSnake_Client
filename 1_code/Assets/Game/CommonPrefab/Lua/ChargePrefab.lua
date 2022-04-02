-- 创建时间:2021-08-26
-- 打断提示

local basefunc = require "Game/Common/basefunc"

ChargePrefab = basefunc.class()
local C = ChargePrefab
C.name = "ChargePrefab"

function C.Create(backCall, call, object, node)
	return C.New(backCall, call, object, node)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExtraSkillTrigger"] = basefunc.handler(self,self.OnExtraSkillTrigger)
    self.lister["BreakAngelSkill"] = basefunc.handler(self,self.OnPlayAngelSkill)
    self.lister["BreakDemonSkill"] = basefunc.handler(self,self.OnPlayDemonSkill)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	if self.break_ui_fx then
		CachePrefabManager.Back(self.break_ui_fx)
		self.break_ui_fx = nil
	end
	if self.hint_fx then
		CachePrefabManager.Back(self.hint_fx)
		self.hint_fx = nil
	end
	if self.backCall then
		self.backCall()
	end
	Event.Brocast("ChargePrefabXuliEnd",{id = self.object.id})
	CachePrefabManager.Back(self.fxObj)
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(backCall, call, object, node)
	self.backCall = backCall
	self.call = call
	self.object = object
	self.cd = object.data.beforeCd
	self.color = object.breakColor
	self.cdMax = self.cd
	self.fxNode = node

	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.dj_btn.onClick:AddListener(
		function()
			if self.color == 4 then
				Event.Brocast("BreakAngelSkill")
			end
			if self.color == 2 then
				Event.Brocast("BreakDemonSkill")
			end
		end
	)
	--新手引导关卡中 不能打断
	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		self.dj_btn.gameObject:SetActive(false)
		self.icon_img.gameObject:SetActive(false)
		self.transform:Find("ZT_duan").gameObject:SetActive(false)
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_xuli.audio_name)
end

local fx_config = {
	[2] = {
		parent = "demon_btn",
		hint_fx = "kuosan_anniu_ts_01",
		click_fx = "kuosan_anniu_quan_1",
	},
	[4] = {
		parent = "angel_btn",
		hint_fx = "kuosan_anniu_ts_02",
		click_fx = "kuosan_anniu_quan_2"
	}
}
function C:InitUI()
	self.fxObj = CachePrefabManager.Take("BOOS_juqi_daduan_"..self.color, self.fxNode, 20)
	self.fxObj.prefab.prefabObj.transform.localPosition = Vector3.zero
	
	if fx_config[self.color] then
		-- local skill_panel = ExtSkillSP4Panel.Instance()
		-- local fx_cfg = fx_config[self.color]
		-- if skill_panel[fx_cfg.parent] then
		-- 	self.hint_fx = CachePrefabManager.Take(fx_cfg.hint_fx,skill_panel[fx_cfg.parent].transform)
		-- 	self.hint_fx.prefab.prefabObj.transform.localPosition = Vector3.zero
		-- 	local sd = GameInfoCenter.GetStageData()
		-- 	if sd.curLevel == 0 then
		-- 		self.hint_fx.prefab.prefabObj.gameObject:SetActive(false)
		-- 	end
		-- end
	end
	if CSPanel and CSPanel.stage_panel and CSPanel.stage_panel.break_node then
		self.break_ui_fx =  CachePrefabManager.Take("daduan_biankuang_UI_" .. self.color,CSPanel.stage_panel.break_node)
		self.break_ui_fx.prefab.prefabObj.transform.localPosition = Vector3.zero
		self.break_ui_fx.prefab.prefabObj.transform.localScale = Vector3.New(1,1,1)
	end
	Event.Brocast("ChargePrefabXuli",{color = self.color,id = self.object.id})
	
	self:MyRefresh()
end

local colorImg = {
	[1] = "2d_img_jn_6",
	[2] = "wf4_jn_01",
	[3] = "2d_img_jn_4",
	[4] = "wf4_jn_02",
}
function C:MyRefresh()
	self.icon_img.sprite = GetTexture(colorImg[self.color])
	self:RefreshCD()
end

function C:RefreshCD()
	if self.cd <= 0 then
		self.cd_img.fillAmount = 0
		self:Exit()
		if self.call then
			self.call()
		end
	else
		self.cd_img.fillAmount = self.cd /	self.cdMax
	end
end

function C:FrameUpdate(dt)
	if self.object and self.object.object and IsEquals(self.object.object.transform) then
		self.transform.position = CSModel.Get3DToUIPoint(self.object.object.transform.position)
	end
	self.cd = self.cd - dt
	self:RefreshCD()
end

function C:BreakSucceed()
	ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_xulidaduan.audio_name)
	if IsEquals(self.hint_fx) then
		CachePrefabManager.Back(self.hint_fx)
		self.hint_fx = nil
	end
	if fx_config[self.color] then
		-- local skill_panel = ExtSkillSP4Panel.Instance()
		-- local fx_cfg = fx_config[self.color]
		-- if skill_panel[fx_cfg.parent] then
		-- 	local click_fx = NewObject(fx_cfg.click_fx,skill_panel[fx_cfg.parent].transform)
		-- 	local seq = DoTweenSequence.Create()
		-- 	seq:AppendInterval(2)
		-- 	seq:AppendCallback(function()
		-- 		if IsEquals(click_fx) then
		-- 			Destroy(click_fx)
		-- 		end
		-- 	end)
		-- end
	end
    CSEffectManager.PlayShowAndHideAndCall(MapManager.GetMapNode(),
    										"ZT_ziti_daduan",
    										nil,
    										self.object.object.transform.position + Vector3.New(0, 1, -10),
                                       		999)
    CSEffectManager.PlayShowAndHideAndCall(CSPanel.stage_panel.break_node,
    										"ChargeHint_stage",
    										nil,
											Vector3.zero,
                                       		4,
											nil,
											nil,
											function(tran)
												tran.transform.localPosition = Vector3.zero
											end)
end

function C:OnExtraSkillTrigger(data)
	if self.object.breakColor == data.hero_color then
		self.object:BreakSucceed()
	end
end

function C:OnPlayAngelSkill()
	if self.object.breakColor == 4 then
		self.object:BreakSucceed()
	end
end

function C:OnPlayDemonSkill()
	if self.object.breakColor == 2 then
		self.object:BreakSucceed()
	end
end
