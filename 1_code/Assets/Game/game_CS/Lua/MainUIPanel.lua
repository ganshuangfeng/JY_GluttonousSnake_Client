-- 创建时间:2021-08-20
-- Panel:MainUIPanel
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

MainUIPanel = basefunc.class()
local C = MainUIPanel
C.name = "MainUIPanel"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
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
	self.hero_btn.onClick:AddListener(
		function()
			if self.currPanel then
				self.currPanel:MyExit()
			end
			Event.Brocast("set_mian_timer",{isOn = false})
			self.currPanel = SetHero2Panel.Create()
		end
	)
	self.fright_btn.onClick:AddListener(
		function()
			if self.currPanel then
				self.currPanel:MyExit()
			end
			Event.Brocast("set_mian_timer",{isOn = true})

		end
	)

	self.mijing_btn.onClick:AddListener(function()
		--ClientAndSystemManager.SendRequest("cs_buy_turret",{type = 2})
		local config = {1,2,3,4,7,9,13,14,15,16,17,18,19,20,21}
		local hero_type = config[math.random(1,#config)]
		GameInfoCenter.BuyHero({type=hero_type})
		----- for test
		--[[local allMonster = GameInfoCenter.GetAllMonsters()
		for key, obj in pairs( allMonster ) do
			print("xx---------------- monster add frozen ")
			obj.fsmLogic:addWaitStatusForUser( "frozen" )
		end--]]

	end)
	self.shop_btn.onClick:AddListener(function()
		local all_heros = GameInfoCenter.GetAllHero()
		local id = GameInfoCenter.GetHeroByLocation(1).data.heroId
		--ClientAndSystemManager.SendRequest("cs_sale_turret",{id = id})
		GameInfoCenter.SaleHero()
	end)

	self.town_btn.onClick:AddListener(function()
		MainModel.AddAsset("prop_jin_bi",1000)
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end
