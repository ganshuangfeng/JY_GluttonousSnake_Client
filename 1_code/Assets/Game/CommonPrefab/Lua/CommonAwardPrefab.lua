-- 创建时间:2021-10-28
-- Panel:AwardPrefab
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

CommonAwardPrefab = basefunc.class()
local M = CommonAwardPrefab
M.name = "CommonAwardPrefab"

M.award_data_array = {}
local Instance
--奖励弹窗数据结构
--[[
	data = {
		[1] = {
			asset_type = "string",
			value = "number",
		}
	}
]]
function M.Create(data)
	--如果界面已存在则将新数据压入队列
	if Instance then
		M.award_data_array[#M.award_data_array + 1] = data
		return Instance
	else
		Instance = M.New(data)
		return Instance
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

--非正常关闭走这个Exit
function M:Exit()
	M.award_data_array = {}
	self:RemoveListener()
	Destroy(self.gameObject)
	Instance = nil
	DOTweenManager.KillLayerKeyTween("award_prefab")
end

--正常关闭走这个
function M:MyExit()
	self:RemoveListener()
	Destroy(self.gameObject)
	Instance = nil
	DOTweenManager.KillLayerKeyTween("award_prefab")
	if M.award_data_array and next(M.award_data_array) then
		local next_award_data = M.award_data_array[1]
		table.remove(M.award_data_array,1)
		M.Create(next_award_data)
	end
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(data)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv40").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.data = data
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
end
local center_height = 654.6
function M:InitUI()
	--计算好生成位置
	local data = self.data
	local row = math.floor(#data / 4) + 1
	-- local center_rect = self.center:GetComponent("RectTransform")
	-- center_rect.sizeDelta = {
	-- 	x = center_rect.sizeDelta.x,
	-- 	y = center_height * row
	-- }
	self.center.transform:GetComponent("RectTransform").sizeDelta = {x = Screen.width,y = center_height}
	self.close_btn.gameObject:SetActive(false)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "award_prefab"})
	for k,v in ipairs(data) do
		local award_item = GameObject.Instantiate(self.award_item,self.content)
		local tbl = LuaHelper.GeneratingVar(award_item.transform)
		local cfg = GameConfigCenter.GetAssetConfigByType(v.asset_type)
		tbl.award_item_img.sprite = GetTexture(cfg.icon)
		tbl.award_item_count_txt.text = v.value
		seq:AppendInterval(0.2)
		seq:AppendCallback(function()
			award_item.gameObject:SetActive(true)
		end)
		tbl.award_item_btn.onClick:AddListener(function()
			ItemShowPanel.Create(v.asset_type)
		end)
	end
	seq:AppendInterval(0.5)
	seq:AppendCallback(function()
		self.close_btn.gameObject:SetActive(true)
	end)
	self:MyRefresh()
end


function M:MyRefresh()
end
