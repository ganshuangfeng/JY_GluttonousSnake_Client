-- 创建时间:2021-10-26
-- Panel:ShopPTItem
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

ShopPTItem = basefunc.class()
local M = ShopPTItem
M.name = "ShopPTItem"

function M.Create(parent, data)
	return M.New(parent, data)
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
	if self.unlock_timer then
		self.unlock_timer:Stop()
		self.unlcok_timer = nil
	end
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent, data)
	self.data = data

	parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.get_btn.onClick:AddListener(function()
		LittleTips.Create("未到领取时间")
	end)
	self:MyRefresh()
end

function M:InitUI()
	self.state = "nor" -- nor:正常 cd:CD中 end:购买完
	self.get_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)

	self:MyRefresh()
end

function M:MyRefresh()
	self:RefreshState()

	self.name_txt.text = self.data.name
	self.icon_img.sprite = GetTexture("wf4_sp_1")

	if self.data.P1 then
		if self.data.buyNum < self.data.P1 then
			self.num_txt.text = "今日剩余次数 " .. (self.data.P1 - self.data.buyNum)
		else
			self.num_txt.text = "今日剩余次数 0"
		end
	else
		self.num_txt.text = ""
	end

	self:RefreshCD()
	if self.state == "cd" then
		self.cd_txt.gameObject:SetActive(true)
		self.hint_txt.gameObject:SetActive(false)
	else
		self.cd_txt.gameObject:SetActive(false)
		self.hint_txt.gameObject:SetActive(true)
	end
end
function M:RefreshState()
	self.state = "nor"

	local curT = os.time()
	if (self.data.cd + self.data.buyTime) > curT then
		self.state = "cd"
	else	
		if self.data.P1 then
			if self.data.buyNum < self.data.P1 then
				self.state = "nor"
			else
				self.state = "end"
			end
		else
			self.state = "nor"
		end
	end
end

function M:RefreshCD()
	self:StopCDTime()
	local curT = os.time()
	if not self.data.P1 or self.data.buyNum < self.data.P1 then
		if (self.data.cd + self.data.buyTime) > curT then
			self.cd_txt.text = StringHelper.formatTimeDHMS5(self.data.cd + self.data.buyTime - curT)
			self.cdTime = Timer.New(function ()
				self:CallCD()
			end, 0.2, -1)
			self.cdTime:Start()
		else
			self.cd_txt.text = ""
		end
	else
		self.cd_txt.text = ""
	end
end
function M:CallCD()
	local curT = os.time()
	if (self.data.cd + self.data.buyTime) > curT then
		self.cd_txt.text = StringHelper.formatTimeDHMS5(self.data.cd + self.data.buyTime - curT)
	else
		self:MyRefresh()
	end	
end
function M:StopCDTime()
	if self.cdTime then
		self.cdTime:Stop()
	end
	self.cdTime = nil
end

function M:OnGetClick()
	if self.state == "nor" then
		ShopManager.BuyShopByID(self.data.id, function (data)
			if data.result == 0 then
				self:MyRefresh()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	elseif self.state == "cd" then
		LittleTips.Create("CD中")
	else
		HintPanel.Create(1, "今日购买次数已用完，请明日再来。")
	end
end

