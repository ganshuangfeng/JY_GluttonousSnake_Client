local basefunc = require "Game/Common/basefunc"

LevelStatementsPanel = basefunc.class()
local M = LevelStatementsPanel
M.name = "LevelStatementsPanel"
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
	if self.backcall then
		self.backcall()
	end
	if self.MainUpdateTimer then
		self.MainUpdateTimer:Stop()
	end
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
	ExtPanel.ExtMsg(self)
	ExtendSoundManager.PlaySound(audio_config.cs.battle_reward.audio_name)
	self.data = data
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	if self.data then
		self.backcall = self.data.backcall
	end
	self.close_btn.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	
	DOTweenManager.OpenPopupUIAnim(self.transform)
	self.award_data = LevelStatements.GetThisAwardData()
	dump(self.award_data,"<color=red>奖励数据</color>")
	--碎片种类的数量
	self.fragment_type_num = 0
	if self.award_data then
		for i = 1,#self.award_data.hero_fragment_data do
			local hero_type = self.award_data.hero_fragment_data[i].type
			local v = self.award_data.hero_fragment_data[i].num
			if v > 0 then
				HeroDataManager.ChangeHeroFragmentNumByType(hero_type,v)
				self.fragment_type_num = self.fragment_type_num + 1
			end
		end
	end

	-- 立刻存储数据
    StageManager.StageSaveData(1)

	Timer.New(function()
		self:InitUI()
		self.MainUpdateTimer = Timer.New(
			function()
				self:MyUpdate()
			end
		,0.02,-1):Start()
	end,0.2,1):Start()

end

function M:InitUI()
	local title = {
		"t1","t2","t3"
	}

	self.title = nil
	local percent = math.floor(self.award_data.percent_score)
	dump(percent,"<color=red>当前的评分!</color>")
	local use_t = 2
	local choose_level = self.award_data.score_level
	if choose_level == 3 then
		use_t = 4
	elseif choose_level == 2 then
		use_t = 3
	end

	--self.operate_score_txt.text = percent.."%"
	self.destroy_box_txt.text = "摧毁箱子 "
	--self.destroy_box_award_txt.text = "+"..LevelStatements.GetBoxDestroyNum() * LevelStatements.OneBoxAward()

	self.collect_hero_txt.text = "收集英雄 "
	--self.collect_hero_award_txt.text = "+"..LevelStatements.GetHeroLengthAward()

	local func = function()
		local seq = DoTweenSequence.Create()
		for i = 1,#self.award_data.hero_fragment_data do
			seq:AppendInterval((i-1) * 0.3 + 0.2)
			seq:AppendCallback(
				function()
					if self.award_data.hero_fragment_data[i].num > 0 then
						local temp_ui = {}
						local b =  GameObject.Instantiate(self.item,self.node)
						b.gameObject:SetActive(true)
						LuaHelper.GeneratingVar(b.transform,temp_ui)
		
						local seq2 = DoTweenSequence.Create()
						seq2:Append(b.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
						seq2:Append(b.transform:DOScale(Vector3.New(1,1,1), 0.1))
						
						local hero_type = self.award_data.hero_fragment_data[i].type
						temp_ui.icon_img.sprite = GetTexture(GameConfigCenter.GetHeroFragmentIcon(hero_type))
						temp_ui.num_txt.text = self.award_data.hero_fragment_data[i].num
						if i == self.fragment_type_num then
							Timer.New(
								function()
									self.close_btn.gameObject:SetActive(true)
									self[title[choose_level]].gameObject:SetActive(true)
								end,0.5,1
							):Start()
						end
						LevelStatements.ClearBoxDestroyNum()
					end
				end
			)
		end
	end

	
	self:MyRefresh()
	self.close_btn.onClick:AddListener(
		function()
			self:Exit()
		end
	)


	local step3 = function()
		self.step_tx2.gameObject:SetActive(true)
		local seq2 = DoTweenSequence.Create()
		seq2:Append(self.destroy_box_txt.gameObject.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
		seq2:Append(self.destroy_box_txt.gameObject.transform:DOScale(Vector3.New(1,1,1), 0.1))

		local seq3 = DoTweenSequence.Create()
		seq3:AppendInterval(0.2)
		seq3:AppendCallback(function()
			self.step_tx3.gameObject:SetActive(true)
			self.destroy_box_award_txt.text = "+"..LevelStatements.GetBoxDestroyNum() * LevelStatements.OneBoxAward()
			seq3:Append(self.destroy_box_award_txt.gameObject.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
			seq3:Append(self.destroy_box_award_txt.gameObject.transform:DOScale(Vector3.New(1,1,1), 0.1))
		end)
		
		self.collect_hero_func = self:NumberJump(GameInfoCenter.GetHeroNum(),2,function()
			self.step_tx4.gameObject:SetActive(true)
			local seq2 = DoTweenSequence.Create()
			seq2:Append(self.collect_hero_txt.gameObject.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
			seq2:Append(self.collect_hero_txt.gameObject.transform:DOScale(Vector3.New(1,1,1), 0.1))

			local seq3 = DoTweenSequence.Create()
			seq3:AppendInterval(0.2)
			seq3:AppendCallback(
				function()
					self.step_tx5.gameObject:SetActive(true)
					self.collect_hero_award_txt.text = "+"..LevelStatements.GetHeroLengthAward()
					seq3:Append(self.collect_hero_award_txt.gameObject.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
					seq3:Append(self.collect_hero_award_txt.gameObject.transform:DOScale(Vector3.New(1,1,1), 0.1))
					func()
				end
			)
		end)	
	end
	local step2 = function()
		self.step_tx1.gameObject:SetActive(true)
		local seq2 = DoTweenSequence.Create()
		seq2:Append(self.operate_score_txt.gameObject.transform:DOScale(Vector3.New(1.2,1.2,1.2), 0.2))
		seq2:Append(self.operate_score_txt.gameObject.transform:DOScale(Vector3.New(1,1,1), 0.1))
		self.destroy_box_func = self:NumberJump(LevelStatements.GetBoxDestroyNum(),2,step3)
	end

	self.operate_score_func = self:NumberJump(percent,use_t,step2)
end

function M:MyUpdate()
	if  IsEquals(self.gameObject) then
		self.operate_score_txt.text = math.floor(self.operate_score_func()) .."%"
		if self.destroy_box_func then
			self.destroy_box_txt.text = "摧毁箱子 x"..math.floor(self.destroy_box_func()).."个"
		end

		if self.collect_hero_func then
			self.collect_hero_txt.text = "收集英雄 x"..math.floor(self.collect_hero_func()).."个"
		end
	end
end

--数字跳动
function M:NumberJump(num,use_time,backcall)
	local percent = num / use_time / 30
	local total = 0
	local isOver = false
	local this_do = function()
		if total <= num then
			total = total + percent
			if total == num and not isOver then
				isOver = true
				if backcall then
					backcall()
				end
			end
			return total
		else
			if not isOver then
				isOver = true
				if backcall then
					backcall()
				end
			end
			return num
		end
	end
	return this_do
end

function M:MyRefresh()
end
