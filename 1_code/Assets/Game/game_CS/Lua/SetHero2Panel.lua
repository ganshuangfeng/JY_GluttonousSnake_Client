local basefunc = require "Game/Common/basefunc"

SetHero2Panel = basefunc.class()
local M = SetHero2Panel
M.name = "SetHero2Panel"

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
	self.lister["HeroTypeChange"] = basefunc.handler(self,self.MyRefresh)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:MyExit()
end

function M:MyClose()
	self:MyExit()
end

function M:Ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
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
	self:InitGird()
	self:InitItem()
	self:MyRefresh()
end

function M:MyRefresh()
	self:RefreshSnake()
	self:RefreshItem()
end

--   [1] = "红色", 默认瓶子炮
-- 	 [2] = "绿色", 默认毒液
-- 	 [3] = "黄色", 默认弓箭
-- 	 [4] = "蓝色", 默认星星
local prefab_name = {
	"hongse_img",
	"lvse_img",
	"huangse_img",
	"zise_img",
}

function M:RefreshSnake()
	local data = GameInfoCenter.GetBattleTurret()
	for i = 1,#data do
		local type = data[i]
		local icon = GameConfigCenter.GetHeroIconByType(type)

		self[prefab_name[i]].sprite = GetTexture(icon)
	end
end

function M:InitGird()
	self.girdList = {}
	for i = 1,20 do
		local temp_ui = {}
		local obj = GameObject.Instantiate(self.gird,self.Content)
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		self.girdList[#self.girdList + 1] = temp_ui
		obj.gameObject:SetActive(true)
	end
end

function M:InitItem()
	self.itemList = {}
	local hero_config_list = GameConfigCenter.GetHeroConfigAll()
	--默认最后一个是最大的type，如果不是找策划
	local max_type = hero_config_list[#hero_config_list].type
	for i = 1,max_type do
		local temp_ui = {}
		local obj = GameObject.Instantiate(self.item,self.girdList[i].node)
		local icon = GameConfigCenter.GetHeroIconByType(i)
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		obj.gameObject:SetActive(true)
		self.itemList[#self.itemList + 1] = temp_ui
		temp_ui.main_img.sprite = GetTexture(icon)
		temp_ui.name_txt.text = GameConfigCenter.GetHeroConfig(i,GameInfoCenter.GetTurretStar(i)).remark
		temp_ui.main_btn.onClick:AddListener(
			function()
				HeroUpPanel.Create({parent = self.transform,type = i})
			end
		)

		temp_ui.lv_txt.text = "lv."..GameInfoCenter.GetTurretLevel(i)
	end
end

function M:RefreshItem()
	for i = 1,#self.itemList do
		self.itemList[i].lv_txt.text = "lv."..GameInfoCenter.GetTurretLevel(i)
		local battleTurret = GameInfoCenter.GetBattleTurret()
		self.itemList[i].ysz.gameObject:SetActive(false) 
		for j = 1,#battleTurret do
			self.itemList[battleTurret[j]].ysz.gameObject:SetActive(true)  
		end
	end
end