-- 创建时间:2021-10-13
-- Panel:HallBottomPrefab
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

HallBottomPrefab = basefunc.class()
local M = HallBottomPrefab
M.name = "HallBottomPrefab"

function M.Create(parent_transform, config, call, panelSelf, index)
	return M.New(parent_transform, config, call, panelSelf, index)
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
	self:RemoveRedPointEvent()

	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index

	local obj = NewObject(M.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = "hall_bottom_" .. self.config.id
	GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()

	self:AddRedPointEvent()
	self:CallRedPointEvent()
end

function M:InitUI()
	self.select_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.call(self.panelSelf, self.index)
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	self.icon1_img.sprite = GetTexture(self.config.icon)
	self.icon2_img.sprite = GetTexture(self.config.icon)
	self.icon1_img:SetNativeSize()
	self.icon2_img:SetNativeSize()
	self.name_txt.text = self.config.name

	self:RefreshRed()
end

function M:RefreshRed()
	--走红点系统刷新
	if self.config.goto_ui and (
		self.config.goto_ui[1] == "factory" 
		or self.config.goto_ui[1] == "technology"
		) then
		return
	end
	if self.config.goto_ui then
		local a,b = GameModuleManager.RunFunExt(self.config.goto_ui[1], "GetHintState")
		if a and b ~= ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
			self.red_node.gameObject:SetActive(true)
		else
			self.red_node.gameObject:SetActive(false)
		end
	else
		self.red_node.gameObject:SetActive(false)
	end
end

function M:RefreshSelect(index)
	local b = false
	if self.index == index then
		b = true
	end
	self.select_no.gameObject:SetActive(not b)
	self.select_yes.gameObject:SetActive(b)
end

function M:AddRedPointEvent()
	if self.config.goto_ui and self.config.goto_ui[1] == "factory" then
		self.OnFactoryRedPointNumChange = function (redPointNode)
			if redPointNode.num > 0 then
				self.red_node.gameObject:SetActive(true)
			else
				self.red_node.gameObject:SetActive(false)
			end
		end
		RedPointSystem.Instance:RegisterEvent(RedPointEnum.Factory,self.OnFactoryRedPointNumChange)
	end
	if self.config.goto_ui and self.config.goto_ui[1] == "technology" then
		self.OnTechnologyRedPointNumChange = function (redPointNode)
			if redPointNode.num > 0 then
				self.red_node.gameObject:SetActive(true)
			else
				self.red_node.gameObject:SetActive(false)
			end
		end
		RedPointSystem.Instance:RegisterEvent(RedPointEnum.Technology,self.OnTechnologyRedPointNumChange)
	end
end

function M:CallRedPointEvent()
	if self.config.goto_ui and self.config.goto_ui[1] == "factory" then
		RedPointSystem.Instance:CallEvent(RedPointEnum.Factory,self.OnFactoryRedPointNumChange)
	end
	if self.config.goto_ui and self.config.goto_ui[1] == "technology" then
		RedPointSystem.Instance:CallEvent(RedPointEnum.Technology,self.OnTechnologyRedPointNumChange)
	end
end

function M:RemoveRedPointEvent()
	if self.config.goto_ui and self.config.goto_ui[1] == "factory" then
		RedPointSystem.Instance:RemoveEvent(RedPointEnum.Factory,self.OnFactoryRedPointNumChange)
	end
	if self.config.goto_ui and self.config.goto_ui[1] == "technology" then
		RedPointSystem.Instance:RemoveEvent(RedPointEnum.Technology,self.OnTechnologyRedPointNumChange)
	end
end