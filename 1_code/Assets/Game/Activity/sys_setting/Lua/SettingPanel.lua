-- 创建时间:2018-06-04

local basefunc = require "Game.Common.basefunc"
SettingPanel = basefunc.class()

SettingPanel.name = "SettingPanel"
SettingPanel.instance = nil
function SettingPanel.Show()
	if SettingPanel.instance then
		SettingPanel.instance:ShowUI()
		return
	end
	SettingPanel.Create()
end
function SettingPanel.Hide()
	if SettingPanel.instance then
		SettingPanel.instance:HideUI()
	end
end
function SettingPanel.Create()
	SettingPanel.instance = SettingPanel.New()
	return SettingPanel.instance
end
function SettingPanel:Ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	SettingPanel.HideParent = GameObject.Find("GameManager").transform

	local obj = NewObject(SettingPanel.name, parent)
	obj = obj.transform
	self.transform = obj
	self.gameObject = obj.gameObject
	GeneratingVar(self.transform, self)

	self.YLOnRate = self.YLOnRate:GetComponent("RectTransform")
	self.YXOnRate = self.YXOnRate:GetComponent("RectTransform")

	self.set_back_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Event.Brocast("global_game_panel_close_msg", {ui="SetPanel"})
		self:OnBackClick()
	end)
	
	self.YLScrollbar_sbar.onValueChanged:AddListener(function (val)
		self:YLRateCall(val)
	end)
	self.YLOnOrOffButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnYLOnOffClick()
	end)

	self.YXScrollbar_sbar.onValueChanged:AddListener(function (val)
		self:YXRateCall(val)
	end)

	self.YXOnOrOffButton_btn.onClick:AddListener(function ()
		self:OnYXOnOffClick()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	end)

	self.AudioOnOffButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAudioOnOffClick()
	end)
	
	self.CZMSOnOrOffButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCZMSClick()
	end)

	self.exitgame_btn.onClick:AddListener(function ()
		local sd = GameInfoCenter.GetStageData()
		if sd.curLevel == 0 then
			LittleTips.Create("当前无法退出")
			return
		end
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoSceneName(GameSceneManager.EnterFirstScene)
	end)
	self.loginout_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnExitClick()
	end)
	self.kfdh_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("callup_service_center", "400-8882620")
	end)
	self.tjjy_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		MainModel.OpenKFFK()
	end)
	self.jxyx_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    	Event.Brocast("global_game_panel_close_msg", {ui="SetPanel"})
    	self:OnBackClick()
	end)

	self:InitRect()
end
function SettingPanel:InitRect()
	self.transform.localScale = Vector3.one
	Event.Brocast("global_game_panel_open_msg", {ui="SetPanel"})

	self:InitNMGPass()
	self.AudioOnOffButton_btn.gameObject:SetActive(false)

	print(gameMgr:GetVersionNumber())
	self.versions_txt.text = "版本：" .. gameMgr:GetVersionNumber()
	self.uid_txt.text = "UID:" .. MainModel.UserInfo.user_id
	if MainModel.myLocation == GameSceneManager.EnterFirstScene then
		self.exitgame_btn.gameObject:SetActive(false)
		self.loginout_btn.gameObject:SetActive(true)
		self.jxyx_btn.gameObject:SetActive(false)
	else
		self.exitgame_btn.gameObject:SetActive(true)
		self.loginout_btn.gameObject:SetActive(false)
		self.jxyx_btn.gameObject:SetActive(true)
	end
	self.ExitGame = function ()
		print("<color=red>收到退出的返回消息</color>")
		if SettingPanel.instance and IsEquals(SettingPanel.instance.transform) then

			-- 先清理掉动画，MainLogic.Init()会释放所有动画资源，导致一些bug
			DOTweenManager.KillAllStopTween()
			DOTweenManager.KillAllExitTween()
			DOTweenManager.CloseAllSequence()

			Event.RemoveListener("ServerConnectDisconnect", self.ExitGame)

			Destroy(SettingPanel.instance.transform.gameObject)
			SettingPanel.instance = nil
            MainLogic.Exit()
            networkMgr:Init()
            Network.Start()
            MainLogic.Init()
		end
	end

	Event.AddListener("ServerConnectDisconnect", self.ExitGame)
	
	self.YLScrollbar_sbar.value = soundMgr:GetMusicVolume(MainModel.sound_pattern)
	self.YXScrollbar_sbar.value = soundMgr:GetSoundVolume(MainModel.sound_pattern)
	self:UpdateAudio()
	self:UpdateCzms()

	DOTweenManager.OpenPopupUIAnim(self.root.transform)
end
function SettingPanel:UpdateMusic()
	if soundMgr:GetMusicVolume(MainModel.sound_pattern) > 0.0001 then
		self.YLOnObj.gameObject:SetActive(true)
		self.YLOffObj.gameObject:SetActive(false)
		self.YLOffMove.gameObject:SetActive(false)
		self.YLOnMove.gameObject:SetActive(true)
		self.YLMove.localPosition = Vector3.New(52, 0, 0)
		soundMgr:SetIsMusicOn(true, MainModel.sound_pattern)
	else
		self.YLOnObj.gameObject:SetActive(false)
		self.YLOffObj.gameObject:SetActive(true)
		self.YLOnMove.gameObject:SetActive(false)
		self.YLOffMove.gameObject:SetActive(true)
		self.YLMove.localPosition = Vector3.New(-52, 0, 0)
		soundMgr:SetIsMusicOn(false, MainModel.sound_pattern)
	end
end
function SettingPanel:UpdateSound()
	if soundMgr:GetSoundVolume(MainModel.sound_pattern) > 0.0001 then
		self.YXOnObj.gameObject:SetActive(true)
		self.YXOffObj.gameObject:SetActive(false)
		self.YXOffMove.gameObject:SetActive(false)
		self.YXOnMove.gameObject:SetActive(true)
		self.YXMove.localPosition = Vector3.New(52, 0, 0)
		soundMgr:SetIsSoundOn(true, MainModel.sound_pattern)
	else
		self.YXOnObj.gameObject:SetActive(false)
		self.YXOffObj.gameObject:SetActive(true)
		self.YXOnMove.gameObject:SetActive(false)
		self.YXOffMove.gameObject:SetActive(true)
		self.YXMove.localPosition = Vector3.New(-52, 0, 0)
		soundMgr:SetIsSoundOn(false, MainModel.sound_pattern)
	end
end

function SettingPanel:UpdateAudio()
	if soundMgr:GetIsCenterOn(MainModel.sound_pattern) then
		self.AudioOnObj.gameObject:SetActive(true)
		self.AudioOffObj.gameObject:SetActive(false)
		self.AudioOnMove.gameObject:SetActive(false)
		self.AudioOffMove.gameObject:SetActive(true)
		self.AudioMove.localPosition = Vector3.New(77, 0, 0)
	else
		self.AudioOnObj.gameObject:SetActive(false)
		self.AudioOffObj.gameObject:SetActive(true)
		self.AudioOnMove.gameObject:SetActive(false)
		self.AudioOffMove.gameObject:SetActive(true)
		self.AudioMove.localPosition = Vector3.New(-77, 0, 0)
	end
end

function SettingPanel:UpdateCzms()
	local a = GameSetCenter.GetPlayerMO()
	if a == 0 then
		self.CZMSOnObj.gameObject:SetActive(true)
		self.CZMSOffObj.gameObject:SetActive(false)
		self.CZMSOffMove.gameObject:SetActive(false)
		self.CZMSOnMove.gameObject:SetActive(true)
		self.CZMSMove.localPosition = Vector3.New(-104, 0, 0)
	else
		self.CZMSOnObj.gameObject:SetActive(false)
		self.CZMSOffObj.gameObject:SetActive(true)
		self.CZMSOnMove.gameObject:SetActive(false)
		self.CZMSOffMove.gameObject:SetActive(true)
		self.CZMSMove.localPosition = Vector3.New(104, 0, 0)
	end
end


-- 音乐音量
function SettingPanel:YLRateCall(val)
	soundMgr:SetMusicVolume(val, MainModel.sound_pattern)
	local volume = soundMgr:GetCenterVolume(MainModel.sound_pattern) * soundMgr:GetMusicVolume(MainModel.sound_pattern)
	self.YLOnRate.sizeDelta = Vector2.New(333 * volume, 51.04)
	self:UpdateMusic()
end

-- 音乐开关
function SettingPanel:OnYLOnOffClick()
	soundMgr:SetIsMusicOn(not soundMgr:GetIsMusicOn(MainModel.sound_pattern), MainModel.sound_pattern)
	if soundMgr:GetIsMusicOn(MainModel.sound_pattern) then
		self.YLScrollbar_sbar.value = 1
	else
		self.YLScrollbar_sbar.value = 0
	end
end

-- 音效音量
function SettingPanel:YXRateCall(val)
	soundMgr:SetSoundVolume(val, MainModel.sound_pattern)
	local volume = soundMgr:GetCenterVolume(MainModel.sound_pattern) * soundMgr:GetSoundVolume(MainModel.sound_pattern)
	self.YXOnRate.sizeDelta = Vector2.New(333 * volume, 51.04)
	self:UpdateSound()
end

-- 音效开关
function SettingPanel:OnYXOnOffClick()
	soundMgr:SetIsSoundOn(not soundMgr:GetIsSoundOn(MainModel.sound_pattern), MainModel.sound_pattern)
	if soundMgr:GetIsSoundOn(MainModel.sound_pattern) then
		self.YXScrollbar_sbar.value = 1
	else
		self.YXScrollbar_sbar.value = 0
	end
end

-- 静音开关(总音量开关)
function SettingPanel:OnAudioOnOffClick()
	soundMgr:SetIsCenterOn(not soundMgr:GetIsCenterOn(MainModel.sound_pattern), MainModel.sound_pattern)
	self:UpdateMusic()
	self:UpdateSound()
	self:UpdateAudio()
end

function SettingPanel:OnCZMSClick()
	local a = GameSetCenter.GetPlayerMO()
	if a == 0 then
		GameSetCenter.SetPlayerMO(1)
	else
		GameSetCenter.SetPlayerMO(0)
	end
	self:UpdateCzms()
end

-- 关闭
function SettingPanel:OnBackClick()
	self:HideUI()
end
-- 退出游戏
function SettingPanel:OnExitClick()
	if MainLogic.isWeakNet then
		Network.SendRequest("player_quit", nil)
		self.ExitGame()
		return
	end
	Network.SendRequest("player_quit", nil, "登出",function (ret)
		if ret and ret.result~=0 then
			HintPanel.ErrorMsg(ret.result)
		else
			self.ExitGame()
		end
	end)
	
	LoginModel.ClearLoginData("dc")

	MainModel.IsLoged = false
end

-- 显示
function SettingPanel:ShowUI()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	if SettingPanel.instance and IsEquals(SettingPanel.instance.transform) then
		SettingPanel.instance.transform:SetParent(parent)
		SettingPanel.instance:InitRect()
	else
		SettingPanel.Create()
	end
end

-- 隐藏
function SettingPanel:HideUI()
	Event.RemoveListener("ServerConnectDisconnect", self.ExitGame)
	self.transform:SetParent(SettingPanel.HideParent)
end

function SettingPanel:InitNMGPass()
	local tran = self.transform
	self.nmgPass = "334455"
	self.inputPass = ""
	self.NMGCloseButton = tran:Find("@root/NMGCloseButton"):GetComponent("Button")
	self.NMGCloseButton.onClick:AddListener(function ()
		self:NMGCloseButtonClick()
	end)
	for i=1 , 6 do
		local btn = tran:Find("@root/NMGButton"..i):GetComponent("Button")
		btn.onClick:AddListener(function ()
			self:NMGButtonClick(btn)
		end)
	end
end
function SettingPanel:NMGButtonClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
	self.inputPass = self.inputPass .. "" .. uipos
	if self.inputPass == self.nmgPass then
		AppDefine.IsDebug = true
		print("<color=red>NMGButtonClick</color>")
		self.inputPass = ""
		local GM = GameObject.Find("GameManager")
		if GM then
			local fps = GM:GetComponent("ShowFPS")
			local rd = GM:GetComponent("RuntimeDebug")
			if fps then
				fps.enabled = true
			end
			if rd then
				rd.enabled = true
			end
		end
	elseif self.inputPass == "666" then
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()
	elseif self.inputPass == "142536" then
		GameComToolPrefab.Create()
		GameManager.GotoUI({gotoui = "sys_game_tool",goto_scene_parm = "panel"})
	end
end
function SettingPanel:NMGCloseButtonClick()
	self.inputPass = ""
end
