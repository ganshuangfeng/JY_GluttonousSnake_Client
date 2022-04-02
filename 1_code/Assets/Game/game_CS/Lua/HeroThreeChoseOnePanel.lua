-- 创建时间:2021-09-13
-- Panel:英雄三选一界面
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

HeroThreeChoseOnePanel = basefunc.class()
local M = HeroThreeChoseOnePanel
M.name = "HeroThreeChoseOnePanel"

function M.Create()
	return M.New()
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
	CSPanel:SetStopUpdate(false)
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	CSPanel:SetStopUpdate(true)
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
	local not_include_hero = math.random(1,4)
	for i = 1,4 do
		if not_include_hero ~= i then
			local obj = GameObject.Instantiate(self.hero_btn.gameObject,self.parent)
			local tbl = LuaHelper.GeneratingVar(obj.transform)
			local link_times = HeroLinkCheck.CheckLinkTimes(i)
			local turret_data = {level = GameInfoCenter.GetTurretLevel(i),star = GameInfoCenter.GetTurretStar(i)}
			local cfg = GameConfigCenter.GetHeroConfig(i,link_times + 1,turret_data.level)
			tbl.hero_name_txt.text = cfg.remark
			obj.transform:GetComponent("Button").onClick:AddListener(function()
				--ClientAndSystemManager.SendRequest("cs_buy_turret",{type=cfg.type})
				GameInfoCenter.BuyHero({type=cfg.type})
				ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
				self:Exit()
			end)
			tbl.hero_name_txt.text = cfg.remark
			tbl.hero_desc_txt.text = cfg.desc
			local next_link_count = 9999
			local next_link_desc
			for k,v in ipairs(cfg.base_change) do
				--从base_change种读取下一次连接的配置
				if v.link_desc and v.id == i and v.star > link_times and v.star < next_link_count then
					next_link_desc = v.link_desc
					next_link_count = v.star
				end
			end
			if cfg.icon_img then
				tbl.hero_img.sprite = GetTexture(cfg.icon_img)
			end
			if next_link_count - link_times <= 1 then
				tbl.hero_can_link_node.gameObject:SetActive(true)
				tbl.hero_not_link_node.gameObject:SetActive(false)
				tbl.hero_can_link_txt.text = next_link_count
				tbl.hero_can_link_desc_txt.text = next_link_desc
			else
				tbl.hero_can_link_node.gameObject:SetActive(false)
				tbl.hero_not_link_node.gameObject:SetActive(true)
				tbl.hero_not_link_txt.text = next_link_count
				tbl.hero_not_link_desc_txt.text = next_link_desc
			end
			if not next_link_desc then
				next_link_count = 0
				--没有下一等级的提示时 显示最大等级提示
				tbl.hero_can_link_node.gameObject:SetActive(false)
				tbl.hero_not_link_node.gameObject:SetActive(false)
				tbl.hero_link_max_node.gameObject:SetActive(true)
				
				for k,v in ipairs(cfg.base_change) do
					
					if v.link_desc and v.id == i and v.star >= next_link_count then
						next_link_desc = v.link_desc
						next_link_count = v.star
					end
				end
				tbl.hero_link_max_txt.text = next_link_count
				tbl.hero_link_max_desc_txt.text = next_link_desc
			end
			obj.gameObject:SetActive(true)
		end
	end
	self:MyRefresh()
end

function M:MyRefresh()
end
