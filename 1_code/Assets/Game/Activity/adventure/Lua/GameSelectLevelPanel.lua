-- 创建时间:2021-09-23
-- Panel:GameSelectLevelPanel
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
local bossCfg = ExtRequire("Game.CommonPrefab.Lua.normal_stage_boss_config").main
GameSelectLevelPanel = basefunc.class()
local M = GameSelectLevelPanel
M.name = "GameSelectLevelPanel"

function M.Create(parent)
	return M.New(parent)
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

function M:Ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self:InitSelectLevelPanel()
	if TaskMainManager then
		self.TaskMainEnter =  TaskMainManager.GotoUI({parent = self.main_task_node,goto_scene_parm = "enter"})
	end
	if SysSignInManager then
		self.SignInEnterPrefab = SysSignInManager.GotoUI({parent = self.signin_node,goto_scene_parm = "enter"})
	end
	if TaskManager then
		self.TaskEnter = TaskManager.GotoUI({parent = self.task_node,goto_scene_parm = "enter"})
	end
	self:MyRefresh()
end

function M:MyRefresh()
end
function M:InitSelectLevelPanel()
	self.stage_config = ExtRequire("Game.CommonPrefab.Lua.normal_stage_config")
	local max_level_count = #self.stage_config.main
	if not MainModel.UserInfo.cur_level then
		MainModel.UserInfo.cur_level = MainModel.UserInfo.game_level
		if MainModel.UserInfo.cur_level > max_level_count then
			MainModel.UserInfo.cur_level = max_level_count
		end
	end
	if MainModel.UserInfo.cur_level < 1 then
		MainModel.UserInfo.cur_level = 1
	end
	self.cur_level = MainModel.UserInfo.game_level
	self.cur_select_level = MainModel.UserInfo.cur_level
	self.enter_game_btn.onClick:AddListener(function()
		self:EnterGame()
	end)
	self.cur_level_img_btn.onClick:AddListener(function()
		--self:EnterGame()
	end)
	self.last_level_btn.onClick:AddListener(function()
		self.cur_select_level = self.cur_select_level - 1
		self:RefreshSelectLevelBtn(self.cur_select_level,self.cur_level,max_level_count)
	end)
	self.next_level_btn.onClick:AddListener(function()
		if self.cur_select_level + 1 <= self.cur_level then
			self.cur_select_level = self.cur_select_level + 1
			self:RefreshSelectLevelBtn(self.cur_select_level,self.cur_level,max_level_count)
		else
			LittleTips.Create("尚未解锁")
		end
	end)
	-- if self.task_btn then
	-- 	if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
	-- 		self.task_btn.gameObject:SetActive(false)
	-- 	else
	-- 		self.task_btn.gameObject:SetActive(true)
	-- 		-- test
	-- 		self.task_btn.onClick:AddListener(function()
	-- 			TaskPanel.Create()
	-- 		end)
	-- 	end
	-- end
	self:RefreshSelectLevelBtn(self.cur_select_level,self.cur_level,max_level_count)
end

function M:RefreshSelectLevelBtn(cur_select_level,cur_level_count,cfg_level_count)
	if self.level_btn_objs then
		for k,v in ipairs(self.level_btn_objs) do
			Destroy(v.gameObject)
		end
	end
	if cur_select_level > cfg_level_count then
		cur_select_level = cfg_level_count
	end
	if self.cur_select_level > cfg_level_count then
		self.cur_select_level = cfg_level_count
	end
	local page_count = 5
	local start_level = math.floor((cur_select_level - 1) / 5) * page_count + 1
	self.level_btn_objs = {}
	for i = start_level,start_level + page_count - 1 do
		local obj
		if i > cfg_level_count then
			break
		elseif i == cur_select_level then
			obj = GameObject.Instantiate(self.cur_level_btn,self.level_layout)
		elseif i <= cur_level_count then
			obj = GameObject.Instantiate(self.level_unlock_btn,self.level_layout)
			obj.transform:GetComponent("Button").onClick:AddListener(function()
				self.cur_select_level = i
				self:RefreshSelectLevelBtn(self.cur_select_level,cur_level_count,cfg_level_count)
			end)
		elseif i > cur_level_count then
			obj = GameObject.Instantiate(self.level_lock_btn,self.level_layout)
			obj.transform:GetComponent("Button").onClick:AddListener(function()
				LittleTips.Create("尚未解锁")
			end)
		end
		obj.transform:Find("Text"):GetComponent("Text").text = i
		obj.gameObject:SetActive(true)
		self.level_btn_objs[#self.level_btn_objs + 1] = obj
	end
	if cur_select_level == cfg_level_count then 
		self.next_level_btn.gameObject:SetActive(false)
	end
	if cur_select_level == 1 then
		self.last_level_btn.gameObject:SetActive(false)
	end
	if cur_select_level ~= 1 and cur_select_level ~= cfg_level_count then
		self.next_level_btn.gameObject:SetActive(true)
		self.last_level_btn.gameObject:SetActive(true)
	end
	self.title_txt.text = cur_select_level
	self:RefreshMonsterIcon(cur_select_level)
	self:RefreshTitle(cur_select_level)
	Event.Brocast("SelectStageLevel",cur_select_level)
end

function M:RefreshMonsterIcon(level)
	local l = level % 4
	l = l == 0 and 4 or l

	local mi = bossCfg[level]
	if not mi then
		mi = bossCfg[math.random(1,#bossCfg)]
	end
	if IsEquals(self.monsterObj) then
		Destroy(self.monsterObj)
	end
	self.monsterObj = NewObject(mi.prefab,self.cur_level_img_btn.transform)
	self.monsterObj.transform.localPosition = Vector3.New(mi.pos[1],mi.pos[2],mi.pos[3])
	self.monsterObj.transform.localScale = Vector3.New(mi.size[1],mi.size[2],mi.size[3])
	self.boss_name_txt.text = mi.name
	ChangeLayer(self.monsterObj, 0, true)

	--隐藏血条
	local hpObj = self.monsterObj.transform:Find("hp_max")
	if IsEquals(hpObj) then
		hpObj.gameObject:SetActive(false)
	end
end

function M:RefreshTitle(level)
	if level <= 15 then
		self.title_yjsl_img.gameObject:SetActive(true)
		self.title_smgc_img.gameObject:SetActive(false)
	else
		self.title_yjsl_img.gameObject:SetActive(false)
		self.title_smgc_img.gameObject:SetActive(true)
	end
end
function M:EnterGame()
	dump(self.cur_select_level,"<color=yellow>当前选择关cur_select_level</color>")
	local ret = ActactManager.ConsumeValue()
	if ret == 0 then
		MainLogic.GotoScene("game_CS",{level = self.cur_select_level})
	else
		HintPanel.ErrorMsg(ret)
	end

end