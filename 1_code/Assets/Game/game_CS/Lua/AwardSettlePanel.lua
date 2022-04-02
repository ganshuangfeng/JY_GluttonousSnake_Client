-- 创建时间:2021-07-14
-- Panel:AwardSettlePanel
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

AwardSettlePanel = basefunc.class()
local C = AwardSettlePanel
C.name = "AwardSettlePanel"

local AnimEnum = {

}
function C.Create(call)
	return C.New(call)
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
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
	if self.data.callback then
		self.data.callback()
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

function C:Ctor(data)
	dump(data, "<color=red>AwardSettlePanel data</color>")
	self.data = data
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
	
	self.jb_num_txt.text = self.data.settleData.jbNum
	self.box_num_txt.text = self.data.settleData.boxNum
	self.box_jb_txt.text = self.data.settleData.boxJb
	self.monster_num_txt.text = self.data.settleData.monsterNum
	self.monster_jb_txt.text = self.data.settleData.monsterJb
	self.all_jb_num_txt.text = self.data.settleData.allJb
	if self.data.settleData.isPerfect then
		self.perfect.gameObject:SetActive(true)
	end

	-- self.isAddJb = true

	-- self.time = 0
	-- self.update_time = Timer.New(function (_, time_elapsed)
	--         self.time = self.time + time_elapsed
	--         if self.time > 0.5 then
	--         	if self.isAddJb then
	--         		self:addJb()
	--         		self.isAddJb = nil
	--         	end
	--         end
	--         if self.time > 6.5 then
	--         	self:Exit()
	--         end
	--     end, 0.03, -1, nil, true)

	-- self.update_time:Start()

	self.bg_btn.onClick:AddListener(function()
		-- if self.time > 1.5 then
			self:Exit()
		-- end
	end)

end

function C:addJb()
	local jb = math.floor(self.data.settleData.killAward * (self.data.settleData.rate - 1))
	if jb > 0 then

		local r = self.data.settleData.rate
		local jn = 1
		if r < 1.2 then
			jn = 4
		elseif jb < 1.6 then
			jn = 8
		elseif jb < 2.4 then
			jn = 16
		elseif jb < 2.8 then
			jn = 24
		else
			jn = 30
		end

		local function ajb(n)
			if n == jn then
				Event.Brocast("ui_game_get_jin_bi_msg", jb)
			end
		end


		for i=1,jn do

			local seq = DoTweenSequence.Create()
			seq:AppendInterval(math.random(100)*0.01)
			seq:AppendCallback(function()
				local beginPos = self.bl_num.transform.position
				local x = math.random(-200,200)*0.1
				local y = math.random(-200,200)*0.1
				beginPos.x = beginPos.x + x
				beginPos.y = beginPos.x + y
				CSEffectManager.CreateGold(
											CSPanel.anim_node,
											beginPos,
											CSPanel:GetJBNode(),
											nil,
											function()
												ajb(i)
											end)
			end)

		end

	end
end