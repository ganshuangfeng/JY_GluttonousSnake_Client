-- 创建时间:2021-07-08
-- Panel:StagePanel
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

StagePanel = basefunc.class()
local C = StagePanel
C.name = "StagePanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_asset_change_msg"] = basefunc.handler(self, self.RefreshAsset)
	self.lister["ui_game_get_jin_bi_msg"] = basefunc.handler(self,self.ui_game_get_jin_bi_msg)

	self.lister["stage_time_count_down"] = basefunc.handler(self,self.on_stage_time_count_down)
	self.lister["stageRefreshBossValue"] = basefunc.handler(self,self.RefreshBossValue)
	self.lister["stageRefreshStageValue"] = basefunc.handler(self,self.RefreshStageValue)
	self.lister["stageRefreshMonsterProgress"] = basefunc.handler(self,self.onStageRefreshMonsterProgress)
	self.lister["stageRefreshGameLv"] = basefunc.handler(self,self.onStageRefreshGameLv)
	self.lister["stage_state_change"] = basefunc.handler(self,self.OnStageStateChange)
	-- self.lister["stage_start"] = basefunc.handler(self,self.RefreshStageLevel)
    self.lister["awardStageLastCountdown"] = basefunc.handler(self,self.onAwardStageLastCountdown)
    -- self.lister["stageSetKillData"] = basefunc.handler(self,self.onStageSetKillData)
	--打断相关
	self.lister["stageRefreshBossNorAttackValue"] = basefunc.handler(self,self.RefreshBossNorAttackValue)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.bossFightingObj = NewObject("Boss_fighting", parent)

	self.state = "normal"

	self:MakeLister()
	self:AddMsgListener()
	CSPanel.jing_bi_anim_node = self.jin_bi_node
	CSPanel.exp_anim_node = self.lv_txt
	self:InitUI()
	self:MyRefresh()
end

function C:InitUI()
	self:BossRedLightShow(false)
	self.curr_use_money_txt.text = StringHelper.ToAbbrNum( MainModel.GetAssetValueByKey("prop_jin_bi") )

	-- 头像
	local headType = 1
	local imgData = {
		[1] = {img="wf4_cdjn_c",scale=1,},
		[2] = {img="ct_10000",scale=1,},
    }
	local d = imgData[headType]
	if d then
		local imgSp = self.head:GetComponent("Image")
		imgSp.sprite = GetTexture(d.img)
		-- imgSp:SetNativeSize()
		imgSp.gameObject.transform.localScale = Vector3.New(d.scale,d.scale,d.scale)
	end

end

function C:GetState()
	return self.state
end

function C:MyRefresh()
	-- self:RefreshStageLevel()
end

function C:RefreshData(k,v)
end

function C:RefreshAsset()
	self.curr_use_money_txt.text = StringHelper.ToAbbrNum( MainModel.GetAssetValueByKey("prop_jin_bi") )
end

function C:RefreshStageLevel()
	do return end
	self.stage_objs = self.stage_objs or {}
	if self.stage_objs and next(self.stage_objs) then
		for k,v in ipairs(self.stage_objs) do
			Destroy(v)
		end
	end
	local max_width = 292
	local max_height = 26
	local sd = GameInfoCenter.GetStageData()
	local cur_id = sd.curLevel
	local id_list = {}
	if cur_id <= 2 then
		id_list = {1,2,3}
		self.stage_progress_img.transform:GetComponent("RectTransform").sizeDelta = {
					x = max_width / 2 * (cur_id - 1),
					y = max_height
		}
	else
		id_list = {cur_id - 1,cur_id,cur_id + 1}
		self.stage_progress_img.transform:GetComponent("RectTransform").sizeDelta = {
			x = max_width / 2,
			y = max_height
		}
	end

	for i = 1,#id_list do
		local obj = nil
		local config = GameConfigCenter.GetStageConfig(id_list[i])
		if config.tag then
			if config.tag == "award" then
				obj = GameObject.Instantiate(self.award_obj.gameObject,self.stage_parent)
			elseif config.tag == "boss" then
				obj = GameObject.Instantiate(self.boss_level_obj.gameObject,self.stage_parent)
			end
		else
			if cur_id > id_list[i] then 
				obj = GameObject.Instantiate(self.cleared_level_obj.gameObject,self.stage_parent)
				obj.transform:Find("level_txt"):GetComponent("Text").text = config.level 
			else
				obj = GameObject.Instantiate(self.normal_level_obj.gameObject,self.stage_parent)
				obj.transform:Find("level_txt"):GetComponent("Text").text = config.level
			end
		end
		obj.gameObject:SetActive(true)
		if cur_id == id_list[i] then
			obj.transform.localScale = Vector3.New(1.6,1.6,1.6)
		end
		obj.transform.localPosition = Vector3.New(max_width / 2 * (i - 1),0,0)
		self.stage_objs[#self.stage_objs + 1] = obj
	end
	return self.stage_objs
end



function C:RefreshBossValue(_cur,_max)
	local stage_hp_width = 600
	local stage_hp_height = 32
	_cur = math.max(_cur,0)
	self.stage_hp_progress_txt.text = math.floor(_cur) .. "/" .. math.floor(_max)
	self.stage_hp_progress_img.transform:GetComponent("RectTransform").sizeDelta = {x = stage_hp_width * (_cur/_max) , y = stage_hp_height}
end

function C:RefreshBossNorAttackValue(_cur,_max)
	self.break_node.gameObject:SetActive(true)
	local total_width = 270
	local defalt_height = 21
	if not self._max or self._max ~= _max then
		self._max = _max
		if self.breaks then
			for k,v in ipairs(self.breaks) do
				Destroy(v.gameObject)
			end
		end
		self.breaks = {}
		for i = 1,_max do
			self.breaks[i] = {}
			local width = total_width / _max
			if _max % 2 == 1 then
				self.breaks[i].x = (i - math.ceil(_max/2)) * width
			else
				self.breaks[i].x = (i - _max / 2) * width - width / 2
			end
			if i == 1 then
				self.breaks[i].gameObject = GameObject.Instantiate(self.left_empty,self.break_parent).gameObject
			elseif i == _max then
				self.breaks[i].gameObject = GameObject.Instantiate(self.right_empty,self.break_parent).gameObject
			else
				self.breaks[i].gameObject = GameObject.Instantiate(self.center_empty,self.break_parent).gameObject
			end
			self.breaks[i].gameObject:SetActive(true)
			self.breaks[i].width = width
			local obj = self.breaks[i].gameObject
			obj.transform.localPosition = Vector3.New(self.breaks[i].x,0,0)
			obj.transform:GetComponent("RectTransform").sizeDelta = {x = width,y = defalt_height}
		end
	end
	if _cur == 0 then
		for i = 1,_max do
			if self.breaks[i].break_obj then
				self.breaks[i].break_obj.gameObject:SetActive(false)
			end
		end
	end
	for i = 1,_cur do
		if self.breaks and self.breaks[i] then
			if not self.breaks[i].break_obj then
				if i == 1 then
					self.breaks[i].break_obj = GameObject.Instantiate(self.left_break,self.breaks[i].gameObject.transform).gameObject
				elseif i == _max then
					self.breaks[i].break_obj = GameObject.Instantiate(self.right_break,self.breaks[i].gameObject.transform).gameObject
				else
					self.breaks[i].break_obj = GameObject.Instantiate(self.center_break,self.breaks[i].gameObject.transform).gameObject
				end
				self.breaks[i].break_obj.transform:GetComponent("RectTransform").sizeDelta = {x = self.breaks[i].width,y = defalt_height}
				self.breaks[i].break_obj.transform.localPosition = Vector3.zero
			end
			self.breaks[i].break_obj.gameObject:SetActive(true)
		end
	end
end

function C:RefreshStageValue(_cur,_max)
	self.stage_hp_progress2_txt.text =  math.floor(_cur)-- .. "/" .. math.floor(_max)
end

function C:OnStageStateChange(_state,_type)

	local imgData = {
		gem = 
			{img="wf4_zs",scale=1,},
		box = 
			{img="2d_img_bx_g_1",scale=1,},
    }
	local d = imgData[_type]
	if d then
		local imgSp = self.tar_img:GetComponent("Image")
		imgSp.sprite = GetTexture(d.img)
		imgSp:SetNativeSize()
		imgSp.gameObject.transform.localScale = Vector3.New(d.scale,d.scale,d.scale)
	end

	self.state = _state
	self.countDownNode.gameObject:SetActive(false)
	if _state == "normal" then

		-- self.gw_node.gameObject:SetActive(true)
		self.boss_node.gameObject:SetActive(false)
		CSEffectManager.CloseAllScreenEffect("boss")


	elseif _state == "boss" then

		-- self.gw_node.gameObject:SetActive(false)
		self.boss_node.gameObject:SetActive(true)
		-- self:BossRedLightShow(true)
		CSEffectManager.PlayAllScreenEffect("boss")

	elseif _state == "boss_coming" then

		CSPanel:SetStopUpdate(true)

		self.StageHpNode.gameObject:SetActive(false)
		CSEffectManager.PlayAllScreenEffect("boss")
		
		Event.Brocast("time_speed_change",{is_speed_down=true,value=0.7,key="boss_coming"})

        CSEffectManager.PlayShowAndHideAndCall(
                                                CSPanel.anim_node,
                                                "UI_BOSS_ziti_01",
                                                nil,
                                                Vector3.zero,
                                                3,
                                                nil,
                                                function ( ... )

                                                	Event.Brocast("time_speed_change",{key="boss_coming"})
                                                    CSPanel:SetStopUpdate(false)

                                                	if type(_type)=="function" then _type() end

                                                    self.StageHpNode.gameObject:SetActive(true)
                                                    self:OnStageStateChange("boss")

                                                end)
	end

end

function C:onStageShowMonsterProgress(b)
	self.gw_node.gameObject:SetActive(b)
end

function C:onStageRefreshMonsterProgress(_cur,_max)
	if _cur and _max then
		p = math.min(math.max(0,_cur/_max),1)
		self.gwNode.gameObject:SetActive(true)
		self.gwProcessImg.transform:GetComponent("RectTransform").sizeDelta = {x = 251.6 *  p , y = 40}
	else
		self.gwNode.gameObject:SetActive(false)
	end
end

function C:onStageRefreshGameLv(lv)
	
	self.lv_txt.text = "Lv." .. lv

end

function C:on_stage_time_count_down(p)
	if p then
		p = math.min(math.max(0,p),1)
		self.countDownNode.gameObject:SetActive(true)
		self.countDownImg.transform:GetComponent("RectTransform").sizeDelta = {x = 600 *  p , y = 30}
	else
		self.countDownNode.gameObject:SetActive(false)
	end
end

function C:BossRedLightShow(_show)
	self.bossFightingObj.gameObject:SetActive(_show)
end

function C:ui_game_get_jin_bi_msg(num)
	if not self.anim_add_jb_prefab_anim then
		self.anim_add_jb_prefab_anim = self.anim_add_jb_prefab:GetComponent("Animator")
	end
	local fx = NewObject("UI_jb_sg_L",self.jb_node)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		if IsEquals(fx.gameObject) then
			Destroy(fx.gameObject)
		end
	end)
	-- ExtendSoundManager.PlaySound(audio_config.cs.battle_get_gold.audio_name)
	self.anim_add_jb_txt.text = "+" .. num
	self.anim_add_jb_prefab_anim:Play("run", 0, 0)
	self:RefreshAsset()
end

function C:onAwardStageLastCountdown(data)

    if data then
        local t = data.time
        
        if not C.stageCountdownData then
            C.stageCountdownData = {

                time = t,

                obj = GameObject.Instantiate(GetPrefab("stageCountdown"), CSPanel.transform).gameObject,
                timer = Timer.New(function (_, timeElapsed)
                    local n = C.stageCountdownData.time
                    C.stageCountdownData.time = C.stageCountdownData.time - timeElapsed
                    if n > 0 and math.floor(n) ~= math.floor(C.stageCountdownData.time) then
                        C.stageCountdownData.obj.transform:Find("node/time")
                                                            :GetComponent("Text").text = math.floor(n)
                        local anim = C.stageCountdownData.obj.transform:GetComponent("Animator")
                        anim:Play("run", 0, 0)
                        ExtendSoundManager.PlaySound(audio_config.cs.stage_countdown.audio_name)

                    end

                    if C.stageCountdownData.time < 0 then
                        Destroy(C.stageCountdownData.obj)
                        C.stageCountdownData.timer:Stop()
                        C.stageCountdownData = nil
                    end
                    
                end, 0.03, -1, nil, true),
            }
            C.stageCountdownData.timer:Start()
        end

    else

        if C.stageCountdownData then
            
            Destroy(C.stageCountdownData.obj)
            C.stageCountdownData.timer:Stop()

            C.stageCountdownData = nil
        end

    end

end

function C:onStageSetKillData(data)
	if data then
		local imgs = {
			[1] = "2D_gw_new1_01",
			[2] = "2D_gw_new2_04",
			[3] = "2d_gw_xj_01",
			[4] = "2D_gw_01_01",
		}

		for i=1,4 do
			local v = data[i]
			local b = self["kn"..i]
			if v then
				b.gameObject:SetActive(true)
				local img = imgs[v.id] or imgs[1]
				b.transform:Find("txt"):GetComponent("Text").text = v.value .. "/" .. v.maxValue
				local imgSp = b.transform:Find("img"):GetComponent("Image")
				imgSp.sprite = GetTexture(img)
			else
				b.gameObject:SetActive(false)
			end
		end
		
	else
		self.kn1.gameObject:SetActive(false)
		self.kn2.gameObject:SetActive(false)
		self.kn3.gameObject:SetActive(false)
		self.kn4.gameObject:SetActive(false)
	end
end