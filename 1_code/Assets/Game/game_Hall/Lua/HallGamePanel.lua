-- 创建时间:2021-05-26
-- Panel:HallGamePanel
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

HallGamePanel = basefunc.class()
local C = HallGamePanel
C.name = "HallGamePanel"
HallGamePanel.Panel_Node = nil
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_asset_change_msg"] = basefunc.handler(self,self.on_model_asset_change_msg)
    self.lister["ActactValueChange"] = basefunc.handler(self,self.RefreshActValue)
    self.lister["SelectStageLevel"] = basefunc.handler(self,self.RefreshSelectLevel)
    self.lister["global_game_panel_close_msg"] = basefunc.handler(self, self.on_global_game_panel_close_msg)
    self.lister["global_game_panel_open_msg"] = basefunc.handler(self, self.on_global_game_panel_open_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	if self.game_btn_pre then
		self.game_btn_pre:Exit()
	end
	if self.select_level_panel then
		self.select_level_panel:Exit()
	end
	if self.factory_panel then
		self.factory_panel:Exit()
	end
	
	self.update_time:Stop()

	self:RemoveListener()
	-- Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor()
	-- ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.update_time = Timer.New(function (_, timeElapsed)
        self:FrameUpdate(timeElapsed)
    end, 0.2, -1, nil, true)
    self.update_time:Start()

	HallGamePanel.Panel_Node = self.Panel_Node
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	TalkingDataManager.BeginMission("进入大厅")
	TalkingDataManager.CompleteMission("进入大厅")
	Event.Brocast("hall_game_in")
	ExtendSoundManager.PlaySceneBGM(audio_config.game.menu_BGM.audio_name)
end

function C:InitUI()
	local btn_map = {}
	btn_map["right_top"] = {self.node1,}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)
	
	GameManager.GotoUI({gotoui = "hall_bottom",goto_scene_parm = "panel", parent = self.transform})
	if self.task_btn then
		if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
			self.task_btn.gameObject:SetActive(false)
		else
			self.task_btn.gameObject:SetActive(true)
			-- test
			self.task_btn.onClick:AddListener(function()
				TaskPanel.Create()
			end)
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self.player_name_txt.text = MainModel.UserInfo.name
	self:on_model_asset_change_msg()

	self.act_value_txt.text = ActactManager.GetShowValue()
	self.act_time_txt.text = 0
	self.act_time_txt.gameObject:SetActive(false)

	-- 新手引导
    GuideLogic.CheckRunGuide("hall", function ()
		GameManager.GotoUI({gotoui = "sys_banner", goto_scene_parm="panel"})
    end)
end

function C:RefreshActValue(value)
	self.act_value_txt.text = ActactManager.GetShowValue()
end

function C:FrameUpdate(timeElapsed)

	local t = ActactManager.GetNextTime()
	if t then
		self.act_time_txt.gameObject:SetActive(true)
		self.act_time_txt.text = string.format("0:%d",t)
	else
		self.act_time_txt.gameObject:SetActive(false)
	end
end

function C:on_model_asset_change_msg()
	self.player_jb_txt.text = StringHelper.ToAbbrNum( MainModel.UserInfo.Asset.prop_jin_bi )
	self.diamond_value_txt.text = StringHelper.ToAbbrNum( MainModel.UserInfo.Asset.prop_diamond )
end  

function C:RefreshSelectLevel(level)
	local style = GameConfigCenter.GetStyleByStage(level)
	if not style or style == "" or style == "maya" then
		self.maya_xq_img.gameObject:SetActive(true)
		self.shamo_xq_img.gameObject:SetActive(false)
	else
		self.maya_xq_img.gameObject:SetActive(false)
		self.shamo_xq_img.gameObject:SetActive(true)
	end
end

function C:on_global_game_panel_close_msg(data)
	if data.ui == "shop" then
        self.act_node.gameObject:SetActive(true)
        self.diamond_node.gameObject:SetActive(false)
    end
end

function C:on_global_game_panel_open_msg(data)
    if data.ui == "shop" then
        self.act_node.gameObject:SetActive(false)
        self.diamond_node.gameObject:SetActive(true)        
    end
end