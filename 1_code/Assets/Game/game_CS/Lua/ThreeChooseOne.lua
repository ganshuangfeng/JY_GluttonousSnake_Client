-- 创建时间:2021-09-22
-- Panel:ThreeChooseOne
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

ThreeChooseOne = basefunc.class(Object)
local M = ThreeChooseOne
M.name = "ThreeChooseOne"

function M.Create(data)
	return M.New(data)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["StageFinish"] = basefunc.handler(self,self.Exit)
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

function M:Ctor(data)
	ExtPanel.ExtMsg(self)
	M.super.Ctor( self , data )

	self.data = data
	local parent = CSPanel.map_node
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = NewObject(M.name, parent)
	end
	self.transform = self.gameObject.transform
	
	LuaHelper.GeneratingVar(self.transform, self)
	self.guangxiao.gameObject:SetActive(true)
	self:MakeLister()
	self:AddMsgListener()
	self.data_inspector = GetDataInfo(self.gameObject)
	self.collider = self.gameObject.transform:GetComponent("ColliderBehaviour")
    self.collider:SetLuaTable(self)

end

function M:InitUI()
	self:MyRefresh()
end

function M:MyRefresh()
end


function M:OnTriggerEnter2D(collider)
	if self.state == "die" then return end
	local object_id = collider.gameObject.name
	if object_id then
		object_id = tonumber(object_id)
	end
	local HeroHead = GameInfoCenter.GetHeroHead()
	if object_id == HeroHead.id then
		local config = {
			--hero_15 = 1,
			heal = 999999999,--固定存在
			Invincible = 1,
			hpMaxUp = 1,
			attackSpeedUp = 1,
			attackDamageUp = 1,
			addSkillUseTime = 1, 
		}
		local config = basefunc.deepcopy(config)
		if ItemThreeChooseOneManager.isNotHeroOn then
			for k, v in pairs(config) do
				if string.sub(k, 1,5) == "hero_" then
					config[k] = nil
				end
			end
		end
		ItemThreeChooseOneManager.Create(config,"diaoxiang")
		self.guangxiao.gameObject:SetActive(false)
		self.gameObject:SetActive(false)
		self.state = "die"
	end
end