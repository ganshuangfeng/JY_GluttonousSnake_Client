local basefunc = require "Game/Common/basefunc"

HeroShowMasterPanel = basefunc.class()
local M = HeroShowMasterPanel
M.name = "HeroShowMasterPanel"

function M.Create(attack_type,config)
	return M.New(attack_type,config)
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
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(attack_type,config)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.attack_type = attack_type
	self.config = config
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.BG = self.transform:Find("GameObject")
	self.BG.transform.anchorMin = {x = 0.5,y = 0.5}
	self.BG.transform.anchorMax = {x = 0.5,y = 0.5}
	self.BG.transform.anchoredPosition = {x = -0.5999756,y = 92.29999}
	self.BG.transform.sizeDelta = {x = 884.3,y = 850}
end

function M:InitUI() 
	local config = GameConfigCenter.GetHeroMasterConfig()
	self.items = {}
	self.title_txt.text = self.config.type_name.."大师"
	for i = 1,#config do
		local temp_ui = {}
		local obj =  GameObject.Instantiate(self.item,self.Content)
		GeneratingVar(obj.transform,temp_ui)
		obj.gameObject:SetActive(true)
		local str = ""
		if config[i].damage_up then
			str = "攻击伤害+"..config[i].damage_up.."%" 
		end
		if config[i].hitSpeed_up then
			str = "攻击速度+"..config[i].hitSpeed_up.."%" 
		end
		
		temp_ui.desc1_txt.text = config[i].hero_type_num_need.."个炮台达到"..config[i].hero_level_num_need.."级"
		temp_ui.desc2_txt.text = str
		temp_ui.desc1_mask_txt.text = temp_ui.desc1_txt.text
		temp_ui.desc2_mask_txt.text = str
		local cheak = function()
			local hero_list = GameConfigCenter.GetHeroListByAttackType(self.attack_type)
			local num = 0
			local level = config[i].hero_level_num_need
			for ii = 1,#hero_list do
				local l = HeroDataManager.GetHeroLevelByType(hero_list[ii])
				if l >= level then
					num = num + 1 
				end
			end
			return num >= config[i].hero_type_num_need
		end
	
		
		temp_ui.notice.gameObject:SetActive(cheak())
		temp_ui.desc1_mask_txt.gameObject:SetActive(not cheak())
		temp_ui.desc2_mask_txt.gameObject:SetActive(not cheak())

	end

	self.close_btn.onClick:AddListener(
		function()
			self:Exit()
		end
	)
	self:MyRefresh()
end

function M:MyRefresh()
end
