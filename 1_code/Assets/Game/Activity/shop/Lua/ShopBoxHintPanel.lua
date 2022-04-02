-- 创建时间:2021-10-28
-- Panel:ShopBoxHintPanel
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

ShopBoxHintPanel = basefunc.class()
local M = ShopBoxHintPanel
M.name = "ShopBoxHintPanel"

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
	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:Exit()
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	
	self.title_txt.text = self.data.name
	if self.data.id == 10201 then
		self.box_icon_img.sprite = GetTexture("yxbx03")
	else
		self.box_icon_img.sprite = GetTexture("zzbx03")
	end
	
	local list = GameConfigCenter.GetBaseCommonAwardCfg(self.data.award_id)
	dump(list, "<color=red>AAAAAAAAAAAAddddddd</color>")
	self.cell_list = {}
	for k,v in ipairs(list.award_data) do
		local obj = GameObject.Instantiate(self.cell, self.Content)
		obj.gameObject:SetActive(true)
		self.cell_list[#self.cell_list + 1] = obj
		local cfg = AssetItemConfig[v.asset_type]

		local ui = {}
		LuaHelper.GeneratingVar(obj.transform, ui)
		ui.icon_img.sprite = GetTexture( cfg.icon )
		ui.name_txt.text = cfg.name
		if #v.value > 1 and v.value[1] ~= v.value[2] then
			ui.value_txt.text = v.value[1] .. " - " .. v.value[2]
		else
			ui.value_txt.text = v.value[1]
		end
		EventTriggerListener.Get(ui.icon_img.gameObject).onClick = function ()
			ItemShowPanel.Create(v.asset_type)
		end	
	end
end
