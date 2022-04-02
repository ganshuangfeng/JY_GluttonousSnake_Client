-- 创建时间:2021-10-13
-- Panel:GongjuShowPanel
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

GongjuShowPanel = basefunc.class()
local M = GongjuShowPanel
M.name = "GongjuShowPanel"

function M.Create(gongju_type,parent)
	return M.New(gongju_type,parent)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["FactoryMainUIPanelExit"] = basefunc.handler(self,self.Exit)
	self.lister["model_asset_change_msg"] = basefunc.handler(self,self.MyRefresh)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	self:RemoveRedPointEvent()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(gongju_type,parent)
	self.gongju_type = gongju_type
	self.config = GameConfigCenter.GetGongjuCfgByKey(self.gongju_type)
	
	parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	self.gameObject = NewObject(M.name, parent)
	self.transform = self.gameObject.transform
	GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:AddRedPointEvent()
	self:InitUI()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.name_txt.text = self.config.name
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.skill_name_txt.text = self.config.desc
	self.slider = self.slider:GetComponent("Slider")
	self.close_btn.onClick:AddListener(function ()
        self:Exit()
    end)

	self.up_btn.onClick:AddListener(function ()
		self:Up()
    end)

	self.level_up_gray_btn.onClick:AddListener(function()
		LittleTips.Create("材料不足")
	end)
	if AppDefine.IsEDITOR() then
		self.test_btn.onClick:AddListener(function()
			local test_cfg = {
				team = "prop_team_fragment",
				health = "prop_helth_fragment"
			}
			if test_cfg[self.gongju_type] then
				MainModel.TestAddAsset(
					{
						[1] = {
							asset_type = test_cfg[self.gongju_type],
							asset_value = 10
						},
					}
				)
			end
		end)
	end

	self:MyRefresh()
end

function M:MyRefresh()
	local k = self.gongju_type
	local data
	local lv
	if k == "team" then
		lv = MainModel.QueryTeamLevel()
		data = GameConfigCenter.GetTeamLevelDataConfig()
		self.skill_desc_txt.text = self.config.desc2 ..":<color=green>" .. data[lv].num.."</color>"
	elseif k == "health" then
		lv = MainModel.QueryHealthLevel()
		data = GameConfigCenter.GetHealthLevelDataConfig()
		self.skill_desc_txt.text = self.config.desc2 ..":<color=green>" .. data[lv].hp.."</color>"
	end
	self.curLevel = lv
	self.nextLevel = lv + 1
	self.maxLevel = #data
	self.data = data

	local obj = self
	obj.level_txt.text = "lv." .. lv

	if lv >= #data then
		obj.progress_txt.text = "Max"
		obj.slider.value = 1
	else
		local curNum = 0
		local needNum = 0
		for k1, v1 in pairs(data[lv + 1].upgrade_asset) do
			if v1.asset_type ~= "prop_jin_bi" then
				curNum = curNum + MainModel.GetAssetValueByKey(v1.asset_type)
				needNum = needNum + v1.asset_value
			end
		end

		obj.progress_txt.text = curNum .. "/" .. needNum
		obj.slider.value = curNum / needNum
	end

	self.up_btn.gameObject:SetActive(true)
	self.level_up_gray_btn.gameObject:SetActive(false)
	self.level_max_txt.gameObject:SetActive(false)
	--资产
	DestroyChildren(self.up_content)
	self.upAssetItems = {}
	if self.nextLevel <= self.maxLevel then
		for i, v in ipairs(self.data[self.nextLevel].upgrade_asset) do
			local obj = {}
			obj.gameObject = GameObject.Instantiate(self.up_asset_item,self.up_content).gameObject
			obj.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(obj.gameObject.transform, obj)
			self.upAssetItems[i] = obj
			local asset_cfg = GameConfigCenter.GetAssetConfigByType(v.asset_type)
			obj.up_icon_img.sprite = GetTexture(asset_cfg.icon)
			obj.up_icon_btn = obj.up_icon_img.transform:GetComponent("Button")
			local at = v.asset_type
			obj.up_icon_btn.onClick:AddListener(function ()
				ItemShowPanel.Create(at)
			end)
			local cur_num = MainModel.GetAssetValueByKey(v.asset_type)
			if v.asset_type == "prop_jin_bi" then
				if cur_num < v.asset_value then
					obj.up_asset_num_txt.text ="<color=red>" .. StringHelper.ToAbbrNum(v.asset_value) .. "</color>"
					self.up_btn.gameObject:SetActive(false)
					self.level_up_gray_btn.gameObject:SetActive(true)
					self.level_max_txt.gameObject:SetActive(false)
				else
					obj.up_asset_num_txt.text = StringHelper.ToAbbrNum(v.asset_value)
				end
			else
				if cur_num < v.asset_value then
					obj.up_asset_num_txt.text = "<color=red>" .. cur_num .. "/" .. v.asset_value .. "</color>"
					self.up_btn.gameObject:SetActive(false)
					self.level_up_gray_btn.gameObject:SetActive(true)
					self.level_max_txt.gameObject:SetActive(false)
				else
					obj.up_asset_num_txt.text = cur_num .. "/" .. v.asset_value
				end
			end
		end
	else
		self.up_btn.gameObject:SetActive(false)
		self.level_up_gray_btn.gameObject:SetActive(false)
		self.level_max_txt.gameObject:SetActive(true)
	end
end

function M:Up()
	dump(self.config,"<color=yellow>升级</color>")
	if self.nextLevel > self.maxLevel then
		LittleTips.Create("已经升级到最高等级")
		return
	end
	local asset = self.data[self.nextLevel].upgrade_asset


	local show_tx = function()
		self.up_tx.gameObject:SetActive(false)
		self.up_tx.gameObject:SetActive(true)

		Timer.New(function()
			if IsEquals(self.gameObject) then
				self.up_tx.gameObject:SetActive(false)
			end
		end,1,1):Start()
	end

	if self.gongju_type == "team" then
		MainModel.UpgradeTeamLevel(asset,function (data)
			if data.result == 0 then
				self.curLevel = self.curLevel + 1
				self.nextLevel = self.nextLevel + 1
				LittleTips.Create("升级成功", {x = 0,y =300})
				self.gray_point.gameObject:SetActive(self.curLevel < self.maxLevel)
				show_tx()
				self:MyRefresh()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	elseif self.gongju_type == "health" then
		MainModel.UpgradeHealthLevel(asset,function (data)
			if data.result == 0 then
				self.curLevel = self.curLevel + 1
				self.nextLevel = self.nextLevel + 1
				LittleTips.Create("升级成功", {x = 0,y =300})
				self.gray_point.gameObject:SetActive(self.curLevel < self.maxLevel)
				show_tx()
				self:MyRefresh()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)

	end
	
end

function M:AddRedPointEvent()
	self.onRedPointNumChange = function (redPointNode)
		if redPointNode.num > 0 then
			self.red_point.gameObject:SetActive(true)
			self.gray_point.gameObject:SetActive(false)
		else
			self.red_point.gameObject:SetActive(false)
			self.gray_point.gameObject:SetActive(self.curLevel < self.maxLevel)
		end
	end
	RedPointSystem.Instance:RegisterEvent(RedPointEnum.FactoryGongju .. "." .. self.config.id,self.onRedPointNumChange)
end

function M:CallRedPointEvent()
	RedPointSystem.Instance:CallEvent(RedPointEnum.FactoryGongju .. "." .. self.config.id,self.onRedPointNumChange)
end

function M:RemoveRedPointEvent()
	RedPointSystem.Instance:RemoveEvent(RedPointEnum.FactoryGongju .. "." .. self.config.id,self.onRedPointNumChange)
end