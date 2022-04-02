-- 创建时间:2021-06-30
-- Panel:ComponsePanel_New1
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

ComponsePanel_New1 = basefunc.class()
local C = ComponsePanel_New1
C.name = "ComponsePanel_New1"
ComponsePanel_New1.Pos = {}

local instance = nil
local check_rid = 60
function C.Create(parent)
	instance = C.New(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	return instance
end

function C.Bind()
    local _in = instance
    return _in
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["refresh_componse"] = basefunc.handler(self,self.on_refresh_componse)
	self.lister["hero_hp_change_msg"] = basefunc.handler(self,self.RefreshHeroHp)
	self.lister["model_asset_change_msg"] = basefunc.handler(self,self.RefreshAsset)
	self.lister["ui_game_get_jin_bi_msg"] = basefunc.handler(self,self.ui_game_get_jin_bi_msg)
	self.lister["stage_start"] = basefunc.handler(self,self.on_stage_start)
	self.lister["componse_remove_all_hero"] = basefunc.handler(self,self.on_componse_remove_all_hero)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:Exit()
	if self.UpdateTimer then
		self.UpdateTimer:Stop()
	end
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

end

function C:Awake()
	ExtPanel.ExtMsg(self)
	LuaHelper.GeneratingVar(self.transform, self)
	self.Camera = GameObject.Find("Canvas/Camera").transform:GetComponent("Camera")
	self.Camera3D = GameObject.Find("3DNode/3DCameraRoot/3DCamera").transform:GetComponent("Camera")
	self:MakeLister()
	self:AddMsgListener()
	self.delay_time = 1
	self:InitUI()
	self.add_hero_btn.onClick:AddListener(
		function()
			if not GameInfoCenter.go_in_door_data and ComponseManager.GetMaxLocation() < ComponseManager.Max and self.can_add_hero then
				ExtendSoundManager.PlaySound(audio_config.cs.composite_buy.audio_name)
				--ClientAndSystemManager.SendRequest("cs_buy_turret")
			else
				ExtendSoundManager.PlaySound(audio_config.cs.composite_error.audio_name)
				for i = 1,ComponseManager.Max do
					self:SetTX(i,"HC_hongse",false)
				end
	
				for i = 1,ComponseManager.Max do
					self:SetTX(i,"HC_hongse",true)
				end
			end
		end
	)
	EventTriggerListener.Get(self.main_click.gameObject).onDown = basefunc.handler(
		self,function(self)
			self.can_click = true
		end
	)
	EventTriggerListener.Get(self.main_click.gameObject).onUp = basefunc.handler(
		self,function(self)
			self.can_click = false
		end
	) 

	self.huishoutx = NewObject("HS_huishou",self.transform)
	self.huishoutx.transform.position = self.reclaim.transform.position
	self.huishoutx:SetActive(false)

end

function C:InitUI()
	for i = 1,ComponseManager.Max do
		ComponsePanel_New1.Pos[i] = self["pos"..i]
	end
	self.heroHpProSize = self.heroHpProSize or self.pro_width.transform.sizeDelta

	ExtSkillPanel.Create(self.ext_skill_node)
	
end

function C:MyRefresh()
	for i = 1,ComponseManager.Max do
		self["pos"..i.."_level_txt"].text = ""
		self:SetTX(i,"HC_zhanshi",false)

	end
	for k,v in pairs(ComponseManager.Hero_Wait) do
		if v.data.location <= ComponseManager.Max then
			v.transform.parent = self["pos"..v.data.location]
			if tls.pGetDistance(v.transform.localPosition,Vector3.zero) > 180 then
				v.transform.localPosition = Vector3.zero
			end
		end
	end
	self:RefreshAsset()
end

function C:Update()
	self.delay_time = self.delay_time - 0.016
	if self.delay_time < 0 then
		self:AutoComponse()
	end
	--没有选中任何英雄的时候，按照位置关系移动
	if self.choose_hero == nil then
		for k,v in pairs(ComponseManager.Hero_Wait) do
			v.transform.parent = self["pos"..v.data.location]
			if v.data.location <= ComponseManager.Max then
				v.transform.localPosition = Vector3.MoveTowards(v.transform.localPosition,Vector3.zero,12)
			end
		end
	end

	local data = ComponseManager.GetData()

	if UnityEngine.Input.GetMouseButtonDown(0) and self.choose_hero == nil and self.can_click then
		local pos = UnityEngine.Input.mousePosition
		for k,v in pairs(data) do
			local dis = tls.pGetDistance(pos,self.Camera:WorldToScreenPoint(v.transform.position))
			if dis < 60 then
				ExtendSoundManager.PlaySound(audio_config.cs.composite_pick_up.audio_name)
				self.choose_hero = v
				break
			end
		end
	end
	if self.choose_hero  then
		self.delay_time = 0.4
		for k , v in pairs(data) do
			if self.choose_hero.data.heroId ~= v.data.heroId and GameInfoCenter.CheakIsCanComponse(self.choose_hero,v) then
				v:ShowCanComponse()
			else
				v:HideCanComponse()
			end
		end
		self.choose_hero:SetLayerUp()
		local v = UnityEngine.Input.mousePosition
		self.huishoutx:SetActive(ComponseManager.GetMaxLocation() >= 2 and tls.pGetDistance(v,self.Camera:WorldToScreenPoint(self.reclaim.transform.position)) < 60)
		local choose_hero_pos = self.Camera:ScreenToWorldPoint(v)
		if not IsEquals(self.choose_hero.transform)  then
			self.choose_hero = nil
			return 
		end
		self.choose_hero.transform.position = Vector3.New(choose_hero_pos.x,choose_hero_pos.y,-0.1)
		--处理在面板中的选中
		if true or self.choose_hero.transform.position.y < -182 then
			local new_location = self:InsertCheck(choose_hero_pos)
			self:FakeAnim(self.choose_hero,new_location)
			for i = 1,ComponseManager.Max do
				if new_location == i then
					self:SetTX(new_location,"HC_zhanshi",true)
				else
					self:SetTX(i,"HC_zhanshi",false)
				end
			end
			if UnityEngine.Input.GetMouseButtonUp(0) and GameInfoCenter.GetHeroByHeroId(self.choose_hero.data.heroId) then 
				--回收
				if not GameInfoCenter.go_in_door_data and ComponseManager.GetMaxLocation() >= 2 and tls.pGetDistance(v,self.Camera:WorldToScreenPoint(self.reclaim.transform.position)) < 60 then
					ExtendSoundManager.PlaySound(audio_config.cs.composite_put_down.audio_name)
					--ClientAndSystemManager.SendRequest("cs_sale_turret",{id = self.choose_hero.data.heroId}) 
					self.huishoutx:SetActive(true)
					Timer.New(
						function()
							if IsEquals(self.huishoutx) then
								self.huishoutx.gameObject:SetActive(false)
							end
						end
					,0.6,1):Start()
					self.choose_hero:SetLayerDown()
					self.choose_hero = nil
					return
				end
				--合并成功
				if self:Componse() then
					if new_location then
						self:SetTX(new_location,"HC_zhanshi",false)
					end
					self.choose_hero:SetLayerDown()
					self.choose_hero = nil
					return
				end
				--插入（优先级最后）	
				if not GameInfoCenter.go_in_door_data and new_location and new_location <= ComponseManager.GetMaxLocation()  then
					ExtendSoundManager.PlaySound(audio_config.cs.composite_put_down.audio_name)
					--ClientAndSystemManager.SendRequest("cs_insert_turret",{id = self.choose_hero.data.heroId,location = new_location})
					self.choose_hero:SetLayerDown()
					self.choose_hero = nil
					self:SetTX(new_location,"HC_zhanshi",false)
					return
				elseif not GameInfoCenter.go_in_door_data then
					ExtendSoundManager.PlaySound(audio_config.cs.composite_put_down.audio_name)
					--ClientAndSystemManager.SendRequest("cs_place_turret",{self.choose_hero.data.heroId,ComponseManager.GetMaxLocation() + 1})
					----ClientAndSystemManager.SendRequest("cs_insert_turret",{id = self.choose_hero.data.heroId,location = ComponseManager.GetMaxLocation()})
					if new_location then
						self:SetTX(new_location,"HC_zhanshi",false)
					end
				end
				--旧版的合成规则以交换位置为主
				self.choose_hero:SetLayerDown()
				self.choose_hero = nil
				ComponseManager.RefreshHero()
			else
			end
		end
	else
		for k , v in pairs(data) do
			v:HideCanComponse()
		end
	end
end

function C:InitHero()
	ComponseManager.RemoveAll()
	for i = 1,#MainModel.UserInfo.GameInfo.turret_list do
		local hero_data = GameInfoCenter.GetHeroDataByID(MainModel.UserInfo.GameInfo.turret_list[i].heroId)
		ComponseManager.Create_Wait(hero_data)
	end
	self.can_add_hero =  true
end

function C:on_stage_start(data)
	self:InitHero()
	self:MyRefresh()
	self:RefreshHeroHp(data)
end


function C:RefreshAsset()
    self.use_money_txt.text = 100
    self.curr_use_money_txt.text = MainModel.GetAssetValueByKey("prop_jin_bi")
end

function C:AutoComponse()
	local check_can_componse_more = function()
		local num = 0
		for i = 2,ComponseManager.GetMaxLocation() do
			local hero1 = ComponseManager.GetHeroByLocation(i - 1)
			local hero2 = ComponseManager.GetHeroByLocation(i)
			--第一次合成的结果可能导致第二次合成的情况
			if i < ComponseManager.GetMaxLocation() then
				local hero3 = ComponseManager.GetHeroByLocation(i + 1)
				if  hero1.data.type == hero2.data.type and hero1.data.type == hero3.data.type then
					if hero1.data.level == hero2.data.level and hero3.data.level == hero1.data.level + 1 then
						return true
					end
					if hero1.data.level == hero2.data.level + 1 and hero2.data.level == hero3.data.level then
						return true
					end
				end
			end
			--存在多组合成的情况
			if GameInfoCenter.CheakIsCanComponse(hero1,hero2) then
				i = i + 1
				num = num + 1
			end
			if num >= 2 then
				return true
			end
		end

		return false
	end

	local space = check_can_componse_more() and 0.2 or 0.6

	for i = 2,ComponseManager.GetMaxLocation() do
		local hero1 = ComponseManager.GetHeroByLocation(i - 1)
		local hero2 = ComponseManager.GetHeroByLocation(i)
		if not GameInfoCenter.go_in_door_data and hero1 and hero2 and hero2.life_time > 0.3 and hero1.life_time > 0.3 and GameInfoCenter.CheakIsCanComponse(hero1,hero2) then
			ExtendSoundManager.PlaySound(audio_config.cs.composite_level_up.audio_name)
			--ClientAndSystemManager.SendRequest("cs_merge_turret",{hero2.data.heroId,hero1.data.heroId})
			self.delay_time = space
			return
		end
	end
end

function C:on_refresh_componse()
	
end

--构建特效
function C:SetTX(pos,tx_name,isactive)
	self.tx_map = self.tx_map or {}
	local pos_name = "pos"..pos
	if pos == 0 then 
		pos_name = "head_pos"
	end
	self.tx_map[pos_name] = self.tx_map[pos_name] or {}
	if self.tx_map[pos_name][tx_name] then
		self.tx_map[pos_name][tx_name].gameObject:SetActive(isactive)
	elseif isactive then
		self.tx_map[pos_name][tx_name] = NewObject(tx_name,self[pos_name].transform)
	end
end

function C:FakeAnim(hero,target_location)
	local hero = hero
	self.add_delay_time = self.add_delay_time or 0
	if self.last_target_location == target_location then
		self.add_delay_time = self.add_delay_time + 0.016
	else
		self.add_delay_time = 0
	end
	self.last_target_location = target_location
	local target_hero = ComponseManager.GetHeroByLocation(target_location)
	local location = hero.data.location
	local max_location = ComponseManager.GetMaxLocation()
	self.componse_hero = nil
	--抬起一个英雄
	local on_up_hero = function()
		for i = 1,max_location do
			local h = ComponseManager.GetHeroByLocation(i)
			if i > location then
				local parent_name
				if h.data.location - 1 > 0 then
					parent_name = "pos"..h.data.location - 1
				else
					parent_name = "head_pos"
				end
				h.transform.parent = self[parent_name].transform
				self:MyMove(h)
			elseif i < location then
				h.transform.parent = self["pos"..h.data.location].transform
				self:MyMove(h)
			end
		end
	end
	--获取一个当前画面上最近的英雄（英雄随时可能在滑动），这个检测以具体英雄的位置为准
	local get_near_hero = function()
		local hero_wait = ComponseManager.GetData()
		for k , v in pairs(hero_wait) do
			if tls.pGetDistance(v.transform.position,hero.transform.position) < check_rid and v.data.heroId ~= hero.data.heroId then
				return v
			end
		end
	end
	local near_hero = get_near_hero()
	--检测是否可以直接合成，如果是就不用做动画了
	if not hero then return end
	if near_hero then
		if GameInfoCenter.CheakIsCanComponse(hero,near_hero) then
			self.componse_hero = near_hero
			on_up_hero()
			return
		end
	end
	if target_location and self.add_delay_time > 0.15 then
		--往前插入
		if target_location < location then
			for i = 1,max_location do
				local h = ComponseManager.GetHeroByLocation(i)
				if target_location <= i and i <= location then
					local parent_name = "pos"..h.data.location + 1
					h.transform.parent = self[parent_name].transform
					self:MyMove(h)
				else
					local parent_name = "pos"..h.data.location
					h.transform.parent = self[parent_name].transform
					self:MyMove(h)
				end
			end
		elseif target_location > location then
			--往后插
			for i = 1,max_location do
				local h = ComponseManager.GetHeroByLocation(i)
				if location <= i and i <= target_location then
					if h.data.location - 1 > 0 then
						parent_name = "pos"..h.data.location - 1
					else
						parent_name = "head_pos"
					end
					h.transform.parent = self[parent_name].transform
					self:MyMove(h)
				else
					local parent_name = "pos"..h.data.location
					h.transform.parent = self[parent_name].transform
					self:MyMove(h)
				end
			end
		else
			--原位置
			for i = 1,max_location do
				local h = ComponseManager.GetHeroByLocation(i)
				if i ~= location then
					h.transform.parent = self["pos"..h.data.location].transform
					self:MyMove(h)
				end
			end
		end
	else
		on_up_hero()
	end
end

function C:MyMove(h)
	h.transform.localPosition = Vector3.MoveTowards(h.transform.localPosition,Vector3.zero,12)
end

--合成
function C:Componse()
	local near_hero = self.componse_hero
	if not GameInfoCenter.go_in_door_data and near_hero then
		ExtendSoundManager.PlaySound(audio_config.cs.composite_level_up.audio_name)
		--ClientAndSystemManager.SendRequest("cs_merge_turret",{self.choose_hero.data.heroId,near_hero.data.heroId})
		return true
	end
	-- if near_hero and GameInfoCenter.CheakIsCanComponse(self.choose_hero,near_hero) then
	-- 	--合成
	-- else
	-- 	--交换位置
	-- 	----ClientAndSystemManager.SendRequest("cs_place_turret",{self.choose_hero.data.heroId,near_pos})
	-- end
end

--插入（放在两个之间）
function C:InsertCheck_Old(mouse_v)
	--获取此时相邻的两个pos
	local find_next = function(curr_location)
		for i = curr_location,ComponseManager.GetMaxLocation() do
			local next = i + 1
			if next <= ComponseManager.GetMaxLocation() and self.choose_hero.data.location ~= next then
				return next
			end
		end
	end
	for i = 1,ComponseManager.GetMaxLocation() do
		local pos1
		if i - 1 == 0 then
			pos1 = self["head_pos"].transform.position 
		else
			pos1 = ComponseManager.GetHeroByLocation(i - 1).transform.position
		end
		if self.choose_hero.data.location ~= i - 1 then
			local next = find_next(i - 1)
			if next then
				local bool = false
				pos2 = self["pos"..next].transform.position
				if math.abs(pos2.y - pos1.y) > 5 then
					--垂直方向
					if pos1.x - 40 < mouse_v.x and mouse_v.x < pos1.x + 40 then
						if mouse_v.y < pos1.y and mouse_v.y > pos2.y then
							bool = true
						end
					end
				else
					--水平方向
					if pos1.y - 40 < mouse_v.y and mouse_v.y < pos1.y + 40 then
						local min = pos1.x
						local max = pos2.x
						if max < min then
							max,min = min,max
						end
						if mouse_v.x < max and mouse_v.x > min then
							bool = true
						end
					end
				end

				if bool then
					local new_location = i
					if self.choose_hero.data.location < new_location then
						new_location = new_location -1
					end
					return new_location
				end
			end
		end
	end
end

--第二版插入方式（放在某个方块上面，这个方块以及后面的方块向后面移动）
--这个检测以放置的格子为准
function C:InsertCheck(mouse_v)
	local near_pos = nil
	for i = 1,ComponseManager.Max do
		local dis = tls.pGetDistance(mouse_v,self["pos"..i].transform.position)
		if dis < check_rid then
			near_pos = i
			break
		end
	end
	return near_pos
end

function C:ui_game_get_jin_bi_msg(num)
	if not self.anim_add_jb_prefab_anim then
		self.anim_add_jb_prefab_anim = self.anim_add_jb_prefab:GetComponent("Animator")
	end
	self.anim_add_jb_txt.text = "+" .. num
	self.anim_add_jb_prefab_anim:Play("run", 0, 0)
	self:RefreshAsset()
end

function C:on_componse_remove_all_hero()
	self.can_add_hero = false
end

function C:RefreshHeroHp(data)
	self.pro_txt.text = string.format("%d/%d",data.hp,data.hpMax)
	local x = self.heroHpProSize.x * data.hp/data.hpMax
	local y = self.heroHpProSize.y
	self.pro_width.transform.sizeDelta = {x = x ,y = y}
end
