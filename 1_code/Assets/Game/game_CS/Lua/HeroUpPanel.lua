-- 创建时间:2021-08-23
-- Panel:HeroUpPanel
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

HeroUpPanel = basefunc.class()
local C = HeroUpPanel
C.name = "HeroUpPanel"

local up_turret_level_need = {
	3,10,100,1000,2000,2000,2000,2000,2000,2000,2000,2000,2000,2000,2000,2000
}

local up_star_need = {
	3,10,100,1000
}


function C.Create(parm)
	return C.New(parm)
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

function C:Ctor(parm)
	

	ExtPanel.ExtMsg(self)
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type = parm.type
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.set_hero_btn.onClick:AddListener(function()
		GameInfoCenter.UpdateBattleTurret(self.cfg.hero_color,self.type)
		self:MyRefresh()
		Event.Brocast("HeroTypeChange",{type = self.type,star = self.star,level = self.level,color = self.cfg.hero_color})
	end)
	self.add_star_btn.onClick:AddListener(function()
		if self.star < 5 and GameInfoCenter.GetAssetNum("prop_turret_fragment_"..self.type) > up_star_need[self.star + 1] then
			GameInfoCenter.AddAssetNum("prop_turret_fragment_"..self.type,-1 *  up_star_need[self.star + 1])
			GameInfoCenter.SetTurretStar(self.type,self.star + 1)
			self:MyRefresh()
		end
		
	end)

	self.add_level_btn.onClick:AddListener(function()
		if self.level < 12 and GameInfoCenter.GetAssetNum("prop_mushroom") > up_turret_level_need[self.level] then
			GameInfoCenter.AddAssetNum("prop_mushroom",-1 * up_turret_level_need[self.level])
			GameInfoCenter.SetTurretLevel(self.type,self.level + 1)
			self:MyRefresh()
		end
	end)

	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.star = GameInfoCenter.GetTurretStar(self.type)
	self.cur_star_txt.text = "当前星级：" .. self.star
	self.level = GameInfoCenter.GetTurretLevel(self.type)
	self.cur_level_txt.text = "当前等级：" .. self.level


	self.cur_level_info_txt.text = "当前蘑菇："..GameInfoCenter.GetAssetNum("prop_mushroom").."  "
	.."当前升级需要："..up_turret_level_need[self.level]
	self.cur_star_info_txt.text = "当前碎片："..GameInfoCenter.GetAssetNum("prop_turret_fragment_"..self.type).."  "
	.."当前升星需要："..up_star_need[self.star + 1]

	self.cfg = GameConfigCenter.GetHeroConfig(self.type,self.star)
	self.hero_name_txt.text = self.cfg.remark or "未知炮台"
end
