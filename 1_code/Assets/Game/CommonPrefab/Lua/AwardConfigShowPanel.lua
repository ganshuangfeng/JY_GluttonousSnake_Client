-- 创建时间:2021-10-27
-- Panel:AwardConfigShowPanel
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

AwardConfigShowPanel = basefunc.class()
local M = AwardConfigShowPanel
M.name = "AwardConfigShowPanel"
local Instance
function M.Create(data)
	if not Instance then
		Instance = M.New(data)
	end
	return Instance
end

function M.Close()
	if Instance then
		Instance:Exit()
	end
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
	Instance = nil
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = data.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	if data.position then
		self.transform.position = data.position
	end
	self.data = data
	if self.data.common_award_id then
		self.common_award_config = GameConfigCenter.GetBaseCommonAwardCfg(self.data.common_award_id)
	end
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	if self.common_award_config then
		for k,v in ipairs(self.common_award_config.award_data) do
			local obj = GameObject.Instantiate(self.award_item.gameObject,self.transform)
			local tbl = LuaHelper.GeneratingVar(obj.transform)
			tbl.award_item_txt.text = StringHelper.ToAbbrNum(v.value)
			if v.asset_type then
				local asset_cfg = GameConfigCenter.GetAssetConfigByType(v.asset_type)
				if asset_cfg.icon then
					tbl.award_item_img.sprite = GetTexture(asset_cfg.icon)
				end
			end
			obj.gameObject:SetActive(true)
		end
	end
	self:MyRefresh()
end

function M:Update()
    if AppDefine.IsEDITOR() then
        if UnityEngine.Input.GetMouseButtonUp(0) then
			M.Close()
        end
    else
        if UnityEngine.Input.touchCount > 0 then
			M.Close()
        end
    end
end

function M:MyRefresh()
end
