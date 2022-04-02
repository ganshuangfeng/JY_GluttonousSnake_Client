-- 创建时间:2021-10-28
-- Panel:TaskMainItem
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

TaskMainItem = basefunc.class()
local M = TaskMainItem
M.name = "TaskMainItem"

function M.Create(parent,task_obj)
	return M.New(parent,task_obj)
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

function M:Ctor(parent,task_obj)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.task_obj = task_obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.get_award_btn.onClick:AddListener(function()
		self.task_obj.get_award_new()
		local cfg_award = GameConfigCenter.GetBaseCommonAwardCfg(self.task_obj.config.award_data)
		Event.Brocast("common_award_panel",cfg_award.award_data)
	end)
	--计算当前屏幕的宽高比值
	local width = Screen.width
	local height = Screen.height
    local matchWidthOrHeight = GameSceneManager.GetScene_MatchWidthOrHeight(width, height)
    local scale
    if matchWidthOrHeight == 1 then
        scale = (width * GameSceneManager.GameScreenHeight) / (height * GameSceneManager.GameScreenWidth)
    else
        scale = (height * GameSceneManager.GameScreenWidth) / (width * GameSceneManager.GameScreenHeight)
    end
	self.transform:GetComponent("RectTransform").sizeDelta = {
		y = 404.8,
		x = GameSceneManager.GameScreenWidth * scale
	}
end
local bg_cfg = {
	[1] = "xfg_rw_js_1",
	[5] = "xfg_rw_js_1",
	[6] = "xfg_rw_js_1",
	[13] = "xfg_rw_js_1",
}

function M:InitUI()
	--刷新奖励
	if self.task_obj.config.P2 and self.task_obj.config.P3 then
		self.special_award.gameObject:SetActive(true)
		self.special_award_desc_txt.text = self.task_obj.config.P2
		self.special_award_icon_img.sprite = GetTexture(self.task_obj.config.P3)
		if bg_cfg[self.task_obj.config.P1] then
			self.special_award_bg_img.sprite = GetTexture(bg_cfg[self.task_obj.config.P1])
		end
	else
		self.special_award.gameObject:SetActive(false)
	end
	local common_award = GameConfigCenter.GetBaseCommonAwardCfg(self.task_obj.config.award_data).award_data
	table.sort(common_award,function(a,b)
		return a.item_id > b.item_id
	end)
	local width = 220
	local height = 260
	self.normal_award_img.transform:GetComponent("RectTransform").sizeDelta = {
		x = width * (#common_award),
		y = height
	}
	--计算生成坐标
	local calculate_pos_func = function(index,total_award_count,y)
		local total_width = width * total_award_count
		local y = -20
		if total_award_count % 2 == 0 then
			return Vector3.New((index - 0.5 - total_award_count / 2) * total_width/2,y,0)
		else
			return Vector3.New((index - math.floor((total_award_count + 1) / 2)) * total_width/2,y ,0)
		end
	end
	for k,v in ipairs(common_award) do
		local obj = GameObject.Instantiate(self.normal_award_item,self.normal_award_img.transform)
		obj.transform.localPosition = calculate_pos_func(k,#common_award,obj.transform.position.y)
		local tbl = LuaHelper.GeneratingVar(obj.transform)
		tbl.normal_award_count_txt.text = StringHelper.ToAbbrNum(v.value)
		if v.asset_type then
			local asset_cfg = GameConfigCenter.GetAssetConfigByType(v.asset_type)
			if asset_cfg.icon then
				tbl.normal_award_item_img.sprite = GetTexture(asset_cfg.icon)
			end
			tbl.normal_award_item_btn.onClick:AddListener(function()
				ItemShowPanel.Create(v.asset_type)
			end)
		end
		obj.gameObject:SetActive(true)
	end
	--生成间隔图片
	if #common_award > 1 then
		for i = 1,#common_award - 1 do
			local obj = GameObject.Instantiate(self.normal_award_spac,self.normal_award_img.transform)
			obj.transform.localPosition = calculate_pos_func(i,#common_award - 1,obj.transform.position.y)
			obj.gameObject:SetActive(true)
		end
	end
	self:MyRefresh()
end

function M:MyRefresh(task_obj)
	self.task_obj = task_obj or self.task_obj
	local award_status = self.task_obj:get_award_status()
	if award_status == task_mgr.award_status.can_get then
		self.not_complete_node.gameObject:SetActive(false)
		self.complete_node.gameObject:SetActive(false)
		self.can_get_node.gameObject:SetActive(true)
		self.cur_level_can_get_txt.text = "第" .. self.task_obj.config.P1 .. "关"
	elseif award_status == task_mgr.award_status.not_can_get then
		self.not_complete_node.gameObject:SetActive(true)
		self.complete_node.gameObject:SetActive(false)
		self.can_get_node.gameObject:SetActive(false)
		self.cur_level_not_complete_txt.text = "第" .. self.task_obj.config.P1 .. "关"
	elseif award_status == task_mgr.award_status.complete then
		self.not_complete_node.gameObject:SetActive(false)
		self.complete_node.gameObject:SetActive(true)
		self.can_get_node.gameObject:SetActive(false)
		self.cur_level_complete_txt.text = "第" .. self.task_obj.config.P1 .. "关"
	end
end
