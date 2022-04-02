-- 创建时间:2021-10-09
-- Panel:NewPlayerGuidePanel
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

NewPlayerGuidePanel = basefunc.class()
local M = NewPlayerGuidePanel
M.name = "NewPlayerGuidePanel"

function M.Create(step)
	return M.New(step)
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

function M:Ctor(step)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	step = step or 1
	if step == 1 then
		self:ShowGameHistroy()
	elseif step == 2 then
		self:GuideToUnlockFirstHero()
	end

	self:GuideToFirstLevel()
	Timer.New(
		function()
			self:Exit()
		end,
	1,1):Start()
end

function M:InitUI()
	self:MyRefresh()
end

function M:MyRefresh()
end

--第一步是通过对话展示背景故事
function M:ShowGameHistroy()
	--self.ShowGameHistroyNode.gameObject:SetActive(true)
	-- Timer.New(function()
	-- 	--self.start_btn.gameObject:SetActive(true)
	-- 	self.start_btn.onClick:AddListener(
	-- 		function()		 
				
	-- 		end
	-- 	)
	-- end,3,1):Start()
end

--进入特定的引导关卡
function M:GotoGuideLevel()

end

--引导解锁第一个英雄
function M:GuideToUnlockFirstHero()
	GuideLogic.CheckRunGuide("hall", function ()
		
	end)
	-- self.factory_btn_transform = GameObject.Find("Canvas/GUIRoot/HallGamePanel/BottomNode/@bottom_lay_out/@factory_btn").transform
	-- local old_index = self.factory_btn_transform:GetSiblingIndex()
	-- self.CommonBK.gameObject:SetActive(true)
	-- self.factory_btn_transform.parent = self.up_node
	-- local temp_obj = GameObject.Instantiate(self.factory_btn_transform.gameObject,self.factory_btn_transform.parent)
	-- temp_obj.transform:SetSiblingIndex(old_index)
end

--引导进入第一个关卡
function M:GuideToFirstLevel()
	--标记此项新手引导已经完成
	MainLogic.GotoScene("game_CS",{level = 0})
	NewPlayerGuideManager.SetThisGuideFinsh()
end

--公用的一些UI操作
function M:CommonUIToDo()

end