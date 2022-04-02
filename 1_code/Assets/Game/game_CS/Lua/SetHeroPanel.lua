-- 创建时间:2021-08-20
-- Panel:SetHeroPanel
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

SetHeroPanel = basefunc.class()
local C = SetHeroPanel
C.name = "SetHeroPanel"

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
	self.lister["HeroTypeChange"] = basefunc.handler(self,self.MyRefresh)
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

	--测试数据，每次打开这个面板获取一定数量的资产
	-- GameInfoCenter.AddAssetNum("prop_jin_bi",10000)
	-- GameInfoCenter.AddAssetNum("prop_snake_egg",10000)
	-- GameInfoCenter.AddAssetNum("prop_mushroom",10000)

	-- for i = 1,14 do
	-- 	GameInfoCenter.AddAssetNum("prop_turret_fragment_"..i,10000)
	-- end


	local color_config = {
		[1] = "红色",
		[2] = "绿色",
		[3] = "黄色",
		[4] = "蓝色",
	}

	local config = {
		pingzipao = 3,
		mofaqiu = 11,
		duochongqian = 2,
		huixuanbiao = 7,
		zhentong = 4,
		duhua = 8,
		bingxin = 1,
		dupao = 10,
		huojianpao = 12,
		jiguanqiang = 9,
		mofaqiu = 11,
	}
	-- for k , v in pairs(config) do
	-- 	self[k.."_btn"].onClick:AddListener(
	-- 		function()
	-- 			HeroUpPanel.Create({parent = self.transform,type = v})
	-- 		end
	-- 	)
	-- end
	self.turret_item_list = {}
	for i = 1,#color_config do
		local temp_ui = {}
		local obj = GameObject.Instantiate(self.item,self.Content)
		obj.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		temp_ui.name_txt.text = color_config[i]
		local re = GameConfigCenter.GetHeroConfigByColor(i)
		--re["type"]["star"]
		--从type较小的开始取
		for j = 1,#GameConfigCenter.GetHeroConfigAll() do
			if re[j] then
				local curr_star = GameInfoCenter.GetTurretStar(j)
				local curr_level = GameInfoCenter.GetTurretLevel(j)
				local temp_ui_2 = {}
				local turret_item = GameObject.Instantiate(self.turret_item,temp_ui.s_content)
				turret_item.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(turret_item.transform,temp_ui_2)
				temp_ui_2.turret_name_txt.text = re[j][curr_star].remark
				temp_ui_2.turret_level_txt.text = "等级："..curr_level
				temp_ui_2.turret_star_txt.text = "星级："..curr_star
				temp_ui_2.turret_btn.onClick:AddListener(
					function()
						HeroUpPanel.Create({parent = self.transform,type = j})
					end
				)
				self.turret_item_list[j] = temp_ui_2
			end
		end
	end
	self.hero_length_btn.onClick:AddListener(
		function()
			HeroLengthUpPanel.Create(self.transform)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	for k , v in pairs(self.turret_item_list) do
		local curr_star = GameInfoCenter.GetTurretStar(k)
		local curr_level = GameInfoCenter.GetTurretLevel(k)
		v.turret_level_txt.text = "等级："..curr_level
		v.turret_star_txt.text = "星级："..curr_star
		v.turret_name_txt.text = GameConfigCenter.GetHeroConfig(k,curr_star).remark
		
	end
end
