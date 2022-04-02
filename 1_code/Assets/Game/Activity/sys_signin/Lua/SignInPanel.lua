-- 创建时间:2021-10-13
-- Panel:SignInPanel
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

SignInPanel = basefunc.class()
local M = SignInPanel
M.name = "SignInPanel"

function M.Create(backcall)
	return M.New(backcall)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["model_on_query_sign_in_data_response"] = basefunc.handler(self,self.MyRefresh)
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

function M:Ctor(backcall)
	self.backcall = backcall
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.close_btn.onClick:AddListener(function()
		if self.backcall then
			self.backcall()
		end
		self:Exit()
	end)
	self.signin_btn.onClick:AddListener(function()
		if not SysSignInManager.signin_today then
			local cur_sign_in_day = SysSignInManager.m_data.sign_in_day
			SysSignInManager.GetSignInAward("sign_in",cur_sign_in_day)
		end
		if self.backcall then
			self.backcall()
		end
		self:Exit()
	end)

	if not SysSignInManager.signin_today then
		self.signin_btn.gameObject:SetActive(true)
		self.close_btn.gameObject:SetActive(false)
	else
		self.signin_btn.gameObject:SetActive(false)
		self.close_btn.gameObject:SetActive(true)
	end
end

function M:InitUI()
	self.signin_objs = {}
	for i = 1,6 do
		local obj = {}
		obj.gameObject = GameObject.Instantiate(self.signin_obj.gameObject,self.signin_layout)
		obj.transform = obj.gameObject.transform
		obj.day = i
		self.signin_objs[#self.signin_objs + 1] = obj
		obj.gameObject:SetActive(true)
		obj.transform:GetComponent("Button").interactable = false
		obj.tbl = LuaHelper.GeneratingVar(obj.transform)
		obj.tbl.day_txt.text = "第" .. i .. "天"
		obj.cfg = SysSignInManager.UIConfig.sign_in_seven_day[i]
		obj.tbl.award_icon_img.sprite = GetTexture(obj.cfg.icon)
		obj.tbl.award_desc_txt.text = obj.cfg.desc
		obj.tbl.award_get_desc_txt.text = obj.cfg.desc
		local award_cfg = GameConfigCenter.GetBaseCommonAwardCfg(obj.cfg.award_id).award_data
		obj.tbl.item_show_btn.onClick:AddListener(function()
			ItemShowPanel.Create(award_cfg[1].asset_type)
		end)
		if obj.cfg.new_head then
			obj.tbl.new_head_img.gameObject:SetActive(true)
		end
	end
	self:MyRefresh()
end

function M:MyRefresh()
	self:RefreshSignInObjs()
end

function M:RefreshSignInObjs()
	for k,v in ipairs(self.signin_objs) do
		local cur_sign_in_day = SysSignInManager.m_data.sign_in_day
		local cur_sign_in_award = SysSignInManager.m_data.sign_in_award
		if v.day > cur_sign_in_day then
			self:SetSignInObjState(v,1)
		elseif v.day == cur_sign_in_day then
			self:SetSignInObjState(v,2)
		elseif v.day < cur_sign_in_day then
			self:SetSignInObjState(v,3)
		end
	end
end

-- 1 = 不可领取 2 = 可领取 3 = 已领取
function M:SetSignInObjState(obj,state)
	local cur_sign_in_day = SysSignInManager.m_data.sign_in_day
	if state == 1 then
	elseif state == 2 then
		obj.tbl.get_node.gameObject:SetActive(true)
		obj.tbl.award_desc_txt.color = Color.yellow
		obj.transform:GetComponent("Image").sprite = GetTexture("xfg_mrqd_xz")
	elseif state == 3 then
		obj.tbl.got_node.gameObject:SetActive(true)
		obj.tbl.new_head_img.gameObject:SetActive(false)
	end
end