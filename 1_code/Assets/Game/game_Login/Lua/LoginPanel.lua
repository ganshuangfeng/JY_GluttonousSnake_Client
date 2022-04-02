local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Login.Lua.NoticeConfig"] = nil
require "Game.game_Login.Lua.NoticeConfig"

package.loaded["Game.game_Login.Lua.LoginNotice"] = nil
require "Game.game_Login.Lua.LoginNotice"

package.loaded["Game.game_Login.Lua.LoginPhonePanel"] = nil
require "Game.game_Login.Lua.LoginPhonePanel"

LoginPanel = basefunc.class()

LoginPanel.name = "LoginPanel"

local instance

local pass_words = {
	"0000",
}

local is_need_pass_word = false

function LoginPanel.Create()
	DSM.PushAct({panel = "LoginPanel"})
	instance = LoginPanel.New()
	return CreatePanel(instance, LoginPanel.name)
end
function LoginPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

--启动事件--
function LoginPanel:Awake()
	ExtPanel.ExtMsg(self)

	LuaHelper.GeneratingVar(self.transform, self)
end

function LoginPanel:Start()
	local tran = self.transform
	self.behaviour:AddClick(self.delete_visitor_btn.gameObject, LoginPanel.OnBtnDeleteVisitorClick, self)
	self.behaviour:AddClick(self.login_wx_close_btn.gameObject, LoginPanel.OnLoginWXCloseClick, self)
	self.behaviour:AddClick(self.login_phone_close_btn.gameObject, LoginPanel.OnLoginPhoneCloseClick, self)

	self.behaviour:AddClick(self.login_btn.gameObject, LoginPanel.OnLoginBtnDown, self)
	self.behaviour:AddClick(self.pass_btn.gameObject, LoginPanel.OnPassBtnDown, self)
	self.behaviour:AddClick(self.pass_close_btn.gameObject, LoginPanel.ClosePass, self)
	self.behaviour:AddClick(self.login_wx_btn.gameObject, LoginPanel.OnLoginWXClick, self)
	self.behaviour:AddClick(self.login_phone_btn.gameObject, LoginPanel.OnLoginPhoneClick, self)

	self.behaviour:AddClick(self.repair_btn.gameObject, LoginPanel.OnRepairClick, self)
	self.behaviour:AddClick(self.service_btn.gameObject, LoginPanel.OnServiceClick, self)

	--version
	local vf = resMgr.DataPath .. "udf.txt"
	if File.Exists(vf) then
		local luaTbl = json2lua(File.ReadAllText(vf))
		if luaTbl then
			self.Version_txt.text = "Ver:" .. luaTbl.version .. " " .. gameMgr:getMarketChannel()
		end
	end
	self.Version_txt.text = self.Version_txt.text .. " baseVer:" .. MainVersion.baseVersion

	self:OnStart()
	self:OnOff()

	GameSceneManager.SetGameBGScale(self.bg)

	HandleLoadChannelLua("LoginPanel", self)
end

function LoginPanel:CheatButtonClick(key)
	self.cheatPwd = self.cheatPwd .. key
	if self.cheatPwd == "264153" then
		self.cheatPwd = ""
		LoginLogic.checkServerStatus = false
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()

		self.login_btn.gameObject:SetActive(true)
		-- self.login_btn.transform.localPosition = Vector3.New(366, 0, 0)
	end
end

function LoginPanel:CheatCtrlButtonClick()
	local tran = self.transform

	self.cheatCtrlCount = self.cheatCtrlCount + 1
	if self.cheatCtrlCount >= 6 then
		self.cheatCtrlCount = 0

		for i = 1, 6, 1 do
			self["cbtn_" .. i].gameObject:SetActive(true)
		end
	end

	for i = 1, 6, 1 do
		local img = self["cbtn_" .. i]:GetComponent("Image")
		img.color = Color.New(1, 1, 1, 0.5)
	end
	self.cheatPwd = ""
end

function LoginPanel:OnOff()
	-- 测试需求 打开
	if AppDefine.IsEDITOR() and AppDefine.IsForceOpenYK then
		self.login_btn.gameObject:SetActive(true)
	end

	self.delete_visitor_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_wx_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
	self.login_phone_close_btn.gameObject:SetActive(GameGlobalOnOff.FPS)
end
function LoginPanel:OnStart()
	local tran = self.transform

	if gameMgr:HasUpdated() and gameMgr:NeedRestart() then
		print("Has Update need restart ....")
		HintPanel.Create(1, "更新完毕，请重启游戏", function ()
			gameMgr:QuitAll()
		end)
		return
	end

	self:MakeLister()
	self:AddMsgListener()
	self.privacy = true
	self.service = true
	if self.ClauseHintNode then
		ClauseHintPanel.Create(self.ClauseHintNode)
	end

	--cheatbtn
	self.cheatPwd = ""
	local cheatNode = self.Cheat
	for i = 1, 6, 1 do
		local btn = self["cbtn_" .. i]:GetComponent("Button")
		btn.onClick:AddListener(function ()
			local img = self["cbtn_" .. i]:GetComponent("Image")
			img.color = Color.red

			self:CheatButtonClick(tostring(i))
		end)
	end
	self.cheatCtrlCount = 0
	self.cheat_btn.onClick:AddListener(function ()
		self:CheatCtrlButtonClick()
	end)

	--redir server ip:port
	local ip = LoginLogic.TryGetIP()
	if ip and ip ~= "" then
		AppConst.SocketAddress = ip
		print("[Debug] net redir:" .. ip)
	end

	self:AutoLogin()
end

function LoginPanel:AutoLogin()
	
	if MainModel.GetIsAutoLogin() then
		LoginHelper.AutoLogin()
	end

end

--游客登录
function LoginPanel:OnLoginYKClick(go)
	if AppDefine.IsOffLine then
        MainLogic.GotoScene("game_CS")
		return
	end

	LoginModel.loginData.cur_channel = "youke"
	DSM.PushAct({button = "yk_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_youke"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login("youke", nil, nil)
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--微信登录
function LoginPanel:OnLoginWXClick(go)
	LoginModel.loginData.cur_channel = "wechat"
	DSM.PushAct({button = "wx_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_wechat"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login("wechat")
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

--手机登录
function LoginPanel:OnLoginPhoneClick(go)
	LoginModel.loginData.cur_channel = "phone"
	DSM.PushAct({button = "phone_btn"})
	Event.Brocast("bsds_send_power",{key = "click_login_phone"})
	--local b = self.gxImage.gameObject.activeInHierarchy
	if self.privacy == true and self.service == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LoginHelper.Login("phone")
	else
		LittleTips.Create("勾选同意下方协议才能进入游戏")
	end
end

function LoginPanel:OnBtnDeleteVisitorClick(go)
	LoginHelper.clearYoukeData()
end

function LoginPanel:OnLoginWXCloseClick(go)
	LoginHelper.clearWechatData()
end

function LoginPanel:OnLoginPhoneCloseClick(go)
	LoginHelper.clearPhoneData()
end

function LoginPanel:OnRepairClick()
	if Directory.Exists(resMgr.DataPath) then
		Directory.Delete(resMgr.DataPath, true)
	end
	local web_caches = {"_shop_"}
	-- for _, v in pairs(web_caches) do
	-- 	gameWeb:ClearCookies(v)
	-- end
	UniWebViewMgr.CleanCookies()
	UniWebViewMgr.CleanCacheAll()
	HintPanel.Create(1, "修复完毕，请重新运行游戏", function ()
		--UnityEngine.Application.Quit()
		gameMgr:QuitAll()
	end)
	Event.Brocast("bsds_send_power",{key = "click_repair"})
end

function LoginPanel:OnServiceClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	--self.service_btn.gameObject:SetActive(false)
	Event.Brocast("callup_service_center", "400-8882620")
	Event.Brocast("bsds_send_power",{key = "click_service"})
end

function LoginPanel:Exit()
	if self.spine then
		self.spine:Stop()
	end
	self.spine = nil

	ClauseHintPanel.Close()
	self:RemoveListener()

	Destroy(self.gameObject)
end

function LoginPanel:OnDestroy()
	self:Exit()
end

function LoginPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function LoginPanel:MakeLister()
	self.lister = {}
	self.lister["upd_privacy_setting"] = basefunc.handler(self, self.upd_privacy_setting)
	self.lister["upd_service_setting"] = basefunc.handler(self, self.upd_service_setting)
	self.lister["model_phone_login_ui"] = basefunc.handler(self, self.on_model_phone_login_ui)
end

function LoginPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function LoginPanel:upd_privacy_setting(value)
	self.privacy = value
end
function LoginPanel:upd_service_setting(value)
	self.service = value
end
function LoginPanel:on_model_phone_login_ui()
	if not GameGlobalOnOff.PhoneLogin then return end
	LoginPhonePanel.Create()
end

function LoginPanel:CheckPass(pass_word)
	for i = 1,#pass_words do
		if pass_word == pass_words[i] then
			return true
		end
	end
	return false
end

function LoginPanel:OnPassBtnDown()
	local p_t = self.input_ipf.text
	if self:CheckPass(p_t) then
		self:OnLoginYKClick()
	else
		HintPanel.Create(1,"邀请码错误")
	end
end

function LoginPanel:ClosePass()
	self.PASS.gameObject:SetActive(false)
end

function LoginPanel:OnLoginBtnDown()
	if is_need_pass_word then
		self.PASS.gameObject:SetActive(true)
	else
		self:OnLoginYKClick()
	end
end