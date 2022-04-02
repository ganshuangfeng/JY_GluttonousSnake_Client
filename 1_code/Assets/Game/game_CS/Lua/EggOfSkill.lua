local basefunc = require "Game/Common/basefunc"

EggOfSkill = basefunc.class(Object)
local M = EggOfSkill
M.name = "EggOfSkill"

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
	
	M.super.Ctor( self , data )
	self.data = data or {}

	dump(self.data,"<color=red>技能蛋 数据————————————————————————————————————————————————</color>")
	local parent = CSPanel.map_node
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = NewObject(M.name, parent)
	end
	self.transform = self.gameObject.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.collider = self.transform:Find("New Sprite"):GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "EggOfSkill"
	end
	self.data_inspector = GetDataInfo(self.gameObject)
end

function M:Init()

end

function M:FrameUpdate(time_elapsed)

end

function M:OnTriggerEnter2D(collider)
	local head = GameInfoCenter.GetHeroHead()
	local name = collider.gameObject.name
	if name == head.gameObject.name then
		if self.data_inspector.skill_id == "nil" then
			self.camp_id = tonumber(self.data.building.camp_id)
			self.type_id = tonumber(self.data.building.type_id)
			local skill = GameConfigCenter.GetRandomSkill(self.camp_id,self.type_id)
			if skill then
				if self.camp_id == 1 then
					HeroHeadSkillManager.SetCurrAngelSkill(skill)
					Event.Brocast("GetNewAngelSkill",{skill = skill})
				elseif self.camp_id == 2 then
					HeroHeadSkillManager.SetCurrDemonSkill(skill)
					Event.Brocast("GetNewDemonSkill",{skill = skill})
				end
			end
		else
			
		end
		self:Exit()
	end
end