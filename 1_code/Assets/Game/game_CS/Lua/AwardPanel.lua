-- 创建时间:2021-07-14
-- Panel:AwardPanel
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

ExtRequire("Game.game_CS.Lua.AwardPrefab")

AwardPanel = basefunc.class()
local C = AwardPanel
C.name = "AwardPanel"

local AnimEnum = {

}

local cfg = {
		[1] = {bg="2D_yx_xing_01", icon="2D_yx_xing_02", name="星星"},
		[2] = {bg="2D_yx_ping_01", icon="2D_yx_jian_02", name="弓箭"},
		[3] = {bg="2D_yx_jian_01", icon="2D_yx_ping_02", name="瓶子炮"},
		[4] = {bg="2D_yx_zhen_01", icon="2D_yx_zhen_02", name="毒液"},

		[5] = {bg="2D_yx_fengce01", icon="2D_yx_fengce02", name="大风车"},
		[6] = {bg="2D_yx_hua_01", icon="2D_yx_hua_02", name="太阳花"},
		[7] = {bg="2D_yx_qiu_01", icon="2D_yx_qiu_02", name="魔法球"},
		[8] = {bg="2D_yx_xingxin_01", icon="2D_yx_xingxin_02", name="紫菱花"},
}
function C.Create(data, call)
	return C.New(data, call)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	self.update_time:Stop()
	if self.call then
		self.call()
	end
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(data, call)
	self.data = {}
	local config = GameConfigCenter.GetAwardUIInfoBy(data)
	for i = 1,#config do
		if config.type_index == 2 then
			GameInfoCenter.AddAssetNum(config.type_name,config.num)
		end
	end
	dump(config,"<color=red>奖励的UI信息的配置+——</color>")
	self.data = config
	self.call = call
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	ExtendSoundManager.PlaySound(audio_config.cs.battle_reward.audio_name)
	
	self.state = "appear"
	self.lottery_index = 0

	self.anim_event = self.transform:GetComponent("ComAnimatorEvent")
	self.anim_event.onCall = function (no, event)
		self:AnimEvent(no, event)
	end
	self.anim_pay = self.transform:GetComponent("Animator")
	self.bg_btn.onClick:AddListener(function()
		if self.state == "lottery" then
			self:BoxLottery()
		elseif self.state == "show" then
			self:Exit()
		end
	end)
	self:MyRefresh()

	self.time = 0
	self.update_time = Timer.New(function (_, time_elapsed)
	        self.time = self.time + time_elapsed
	        if self.time > 8 then
	        	self:Exit()
	        end
	    end, 0.03, -1, nil, true)

	self.update_time:Start()

end

function C:MyRefresh()
	for k,v in ipairs(self.data) do
		local pre = AwardPrefab.Create(self.show_node, v)
	end
	self:BoxAppear()
end

function C:AnimEvent(no, event)
	if event then
		dump(event)
		if event == "appear_finish" then
			self.state = "lottery"
			self.GX_guangyun.gameObject:SetActive(true)
			self.XX_chixu.gameObject:SetActive(true)
		elseif event == "auto_lottery" then
			self.GY_yuanxing.gameObject:SetActive(true)
			self:BoxLottery()
		elseif event == "lottery_finish" then
			self.state = "lottery"
		else
			dump(event, "<color=red>EEEEEEEEE event 没有处理的事件 </color>")
		end
	end
end

-- 宝箱出现
function C:BoxAppear()
    ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_usually_BGM.audio_name)
	self.anim_pay:Play("appear", 0, 0)
end

-- 宝箱开奖
function C:BoxLottery()
	self.state = "lotterying"
	if self.show_award_pre then
		self.show_award_pre:Exit()
	end
	self.lottery_index = self.lottery_index + 1
	if self.lottery_index > #self.data then
		self:ShowAward()
	else
		self.show_award_pre = AwardPrefab.Create(self.lottery_node, self.data[self.lottery_index])
		self.show_award_pre.transform.localScale = Vector3.New(1.8, 1.8, 1)
		ExtendSoundManager.PlaySound(audio_config.cs.battle_get_buff.audio_name)
		self.anim_pay:Play("lottery", 0, 0)
	end
end

-- 奖励展示
function C:ShowAward()
	self.state = "show"
	self.show_node.gameObject:SetActive(true)
	self.title.gameObject:SetActive(true)
end

