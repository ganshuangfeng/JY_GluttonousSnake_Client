-- 创建时间:2021-07-14
-- Panel:CSGamePanel
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

CSGamePanel = basefunc.class()
local C = CSGamePanel
C.name = "CSGamePanel"

local instance

function C.Instance()
    return instance
 end

function C.Create()
	instance = C.New()
	instance = CreatePanel(instance, C.name)
	return instance
end
function C.Bind()
    local _in = instance
    instance = nil
    return _in
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["stage_manager_level_change_msg"] = basefunc.handler(self,self.RefreshGK)
    self.lister["model_asset_change_msg"] = basefunc.handler(self, self.RefreshAsset)
    
    self.lister["ClearStageFx"] = basefunc.handler(self, self.onClearStageFx)
    self.lister["GameLoseFx"] = basefunc.handler(self, self.OnGameLoseFx)
    self.lister["GameWinFx"] = basefunc.handler(self, self.OnGameWinFx)
    self.lister["GameLvUpFx"] = basefunc.handler(self, self.OnGameLvUpFx)
    self.lister["level_start"] = basefunc.handler(self, self.on_stage_init_finish)
    self.lister["time_speed_change"] = basefunc.handler(self,self.on_time_speed_change)
    self.lister["set_mian_timer"] = basefunc.handler(self,self.on_set_mian_timer)
    self.lister["ui_shake_screen_msg"] = basefunc.handler(self, self.on_ui_shake_screen_msg)

    self.lister["head_manual_change_target_dir"] = basefunc.handler(self, self.on_head_manual_change_target_dir)
    self.lister["global_game_panel_close_msg"] = basefunc.handler(self, self.on_global_game_panel_close_msg)
    self.lister["global_game_panel_open_msg"] = basefunc.handler(self, self.on_global_game_panel_open_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
    if self.update_time then
        self.update_time:Stop()
    end
    self.update_time = nil
    if self.componse_pre then
        self.componse_pre:Exit()
    end

    if self.game_btn_pre then
        self.game_btn_pre:Exit()
    end
    self.stage_panel:Exit()
    self.skill_panel:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
    HeroHeadSkillManager.Exit()
    ObserverCenter.Exit()
    AttackManager.Exit()
    ComponseManager.Exit()
    CameraMoveBase.Exit()
    StageManager.Exit()
    GameInfoCenter.Exit()
    -- GameConfigCenter.Clear()
    MapManager.Exit()
    ObjectCenter.Exit()
    CSPanel = nil
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end


function C:Awake()
	ExtPanel.ExtMsg(self)
	LuaHelper.GeneratingVar(self.transform, self)
    
    self.time_scale_value = 1
	self:MakeLister()
	self:AddMsgListener()

    if CSModel.Is2D then
        local obj = NewObject("CSGame2DNode")
        obj.gameObject.name = "3DNode"
    else
        local obj = NewObject("CSGame3DNode")
        obj.gameObject.name = "3DNode"
    end

	self:InitUI()
	
    local btn_map = {}
    btn_map["right_top"] = {self.annode,}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)

    local cache = ExtRequire("Game.game_CS.Lua.cs_cache_config")
    -- 缓存资源
    GameCacheLoadingPanel.Create(function (state)
        if state == "finish" then
            Event.Brocast("model_recover_finish")
        else
            self:MyRefresh()
        end
    end, {cache_list = cache})
end


function C:InitUI()
    CSPanel = self
    self.update_time = Timer.New(function (_, time_elapsed)
        if time_elapsed > 0.5 then -- 后台回来正常执行
            time_elapsed = 0.03
        end
        time_elapsed = time_elapsed * self.time_scale_value
        self:FrameUpdate(time_elapsed)
    end, 0.03, -1, nil, true)

    --self.buy_btn.onClick:AddListener(function ()
    --    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --    --print("è´­ä¹°")
    --    --ClientAndSystemManager.SendRequest("cs_buy_turret")
    --end)

    local isAutoCtrlEnable = AutoControlModelManager.GetIsEnable()
    if isAutoCtrlEnable then
        self.auto_txt.text = "开"
    else
        self.auto_txt.text = "关"
    end

    self.auto_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        
        local isAutoCtrlEnable = AutoControlModelManager.GetIsEnable()
        
        self:setAutoControlModel( not isAutoCtrlEnable )
    end)

    self.select_btn.onClick:AddListener(function ()
        SnakeHeadMoveSelectPanel.Create()
    end)

    self.debug_txt.text = ""
    self.camera2d = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    self.camera3d = GameObject.Find("3DNode/3DCameraRoot/3DCamera"):GetComponent("Camera")
    CSModel.SetCamera(self.camera3d, self.camera2d)

    self.map = GameObject.Find("3DNode/map").transform
    self.attack_node = GameObject.Find("3DNode/map/bullet_node").transform
    self.map_node = GameObject.Find("3DNode/map/map_node").transform
    self.monster_node = GameObject.Find("3DNode/map/monster_node").transform
    self.hero_node = GameObject.Find("3DNode/map/hero_node").transform
    
    ObjectCenter.Init()
    AutoControlModelManager.Init()
    -- GameConfigCenter.Init()
    GameInfoCenter.Init()
    ObserverCenter.Init()
    
    ComponseManager.Init()

    MapManager.Init(self.map_node, self.camera3d)

    StageManager.Init()
    AttackManager.Init(self.attack_node)
    LotteryManager.Init()
    SnakeHeadMoveAI.Init()
    SkillManager.Init()
    --老板英雄技能面板
    HeroHeadSkillManager.Init()
    --新版英雄界面
    HeadSkillManager.Init()
    LevelStatements.Init()
    HeroLinkCheck.Init()
    DropAsset.Init()
    --LotteryPanel.Create(self.transform)
    self:InitSkill()
    -- self.componse_pre = ComponsePanel_New1.Create(self.transform)
    self.stage_panel = StagePanel.Create(self.transform)
    --ExtSkillSP2Panel.Create(self.transform)
    self.skill_panel =  HeadSkillPanel.Create(self.transform)
    if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Android" then
        self.task_btn.gameObject:SetActive(false)
    else
        self.task_btn.gameObject:SetActive(true)
        -- test
        self.task_btn.onClick:AddListener(function()
            TaskPanel.Create()
        end)
        MainUIPanel.Create()
    end
    self.clickMove = SnakeHeadMoveManual.Create()

    --LevelStatementsPanel.Create()
end

function C:InitSkill()
    local skill_cfg = {
        -- [1] = {
        --     type = "rocket",
        --     parent = self.rocket_skill_node
        -- },
        [1] = {
            type = "componse_attack",
        }
    }
    for k,v in ipairs(skill_cfg) do 
        SkillManager.SkillCreate(v)
    end
end

local isPointDownOnUI = false
function C:Update()
	-- 是否在UI上
    local worldpos_up
    local worldpos_down
    if AppDefine.IsEDITOR() then
    	if UnityEngine.Input.GetMouseButtonDown(0) then
    		if EventSystem.current:IsPointerOverGameObject() then
    			isPointDownOnUI = true
            	return
    		else
    			worldpos_down = UnityEngine.Input.mousePosition
    		end
			isPointDownOnUI = false
    	end

        if UnityEngine.Input.GetMouseButtonUp(0) then
            worldpos_up = UnityEngine.Input.mousePosition
            isPointDownOnUI = false
        end
    else
        if UnityEngine.Input.touchCount > 0 then
        	local touch = UnityEngine.Input.GetTouch(0)
        	if UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
	        	if EventSystem.current:IsPointerOverGameObject(touch.fingerId) then
		            isPointDownOnUI = true
		            return
	        	else
	        		worldpos_down = Vector3.New(touch.position.x, touch.position.y, 0)
	        	end
	            isPointDownOnUI = false
        	end

	        if UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
	            worldpos_up = Vector3.New(touch.position.x, touch.position.y, 0)
	            isPointDownOnUI = false
	        end
        end
    end

    if isPointDownOnUI then
    	return
    end

    local worldpos
    if UnityEngine.Input.GetMouseButton(0) then
        worldpos = UnityEngine.Input.mousePosition
    end

    if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Moved then
        worldpos = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
    end

    if worldpos_down then
    	local ray = self.camera2d:ScreenPointToRay(worldpos_down)
    	local hit11,hit12 = UnityEngine.Physics.Raycast(ray, nil)
    	local hit = UnityEngine.Physics.RaycastAll(ray)
    	if hit then
    		self.obj_list = {}
        	self.bb_pos = UnityEngine.Input.mousePosition
    		for i = 0, hit.Length - 1 do
    			print(hit[i].collider.gameObject.name)
    			self.obj_list[#self.obj_list + 1] = {obj=hit[i].collider.gameObject, pos=hit[i].collider.transform.localPosition}
    		end
        	self.is_touch = true
        	self.is_down = true
    	end
		if hit11 and hit12 and IsEquals(hit12.collider) then
        	print(hit12.collider.gameObject.name)
        	-- hit12.collider.transform.position = self.camera2d:ScreenToWorldPoint(worldpos_down)
        	self.bb_pos = UnityEngine.Input.mousePosition
        	self.is_touch = true
        	self.is_down = true
        end
    end
    if worldpos_up then
    	self.is_touch = true
    	self.is_down = false
    end
end

function C:OnBeginDrag()
	print("OnBeginDrag")
end
function C:OnEndDrag()
	print("OnEndDrag")
end
function C:OnDrag()
end
function C:MyRefresh()
    self:RefreshAsset()

    -- MapManager.Start()
    StageManager.Start()

    --CreateFactory.CreateMonster( { use_id = 4 , pos = {x = 5,y = 0} , roomNo = 1 } )
    --CreateFactory.CreateMonster( { use_id = 17 , pos = {x = 5,y = 0} , roomNo = 1 , damage = 5 } )
end


function C:RefreshAsset()

end
function C:RefreshGK()
    ExtendSoundManager.PlaySound(audio_config.cs.battle_star.audio_name)
end

function C:SetTimeStage(s)
    if not self.time_stage_count and s == -1 then
        return
    end
    self.time_stage_count = self.time_stage_count or 0
    self.time_stage_count = self.time_stage_count + s
    if self.time_stage_count == 0 then
        self.update_time:Stop()
    elseif self.time_stage_count == 1 then
        self.update_time:Start()
    elseif self.time_stage_count < 0 then
        print(debug.traceback())
    end
    dump(self.time_stage_count, "<color=red>SetTimeStage time_stage_count ========== </color>")
end

function C:RefreshStage(data)
    -- self.update_time:Start()
    self:SetTimeStage(1)

    CameraMoveBase.Awake()

    self.stage_panel:MyRefresh()
end

function C:GetJBNode()
    return self.jing_bi_anim_node.position
end

function C:GetExpNode()
    return self.exp_anim_node.transform.position
end

function C:FrameUpdate(time_elapsed)
	if self.is_touch and self.obj_pos then
		if self.is_down then
		else
	    	self.obj_pos = nil
		end
	end

    CameraMoveBase.FrameUpdate(time_elapsed)

    if self.is_stop then
        return
    end

    --  self.hero_test:FrameUpdate(time_elapsed)
	
    --self.hero_head_test:FrameUpdate(time_elapsed)
	
    --self.boss_test:FrameUpdate(time_elapsed)

    -- if self.skill_test then
    --     self.skill_test:FrameUpdate(time_elapsed)
    -- end
    AutoControlModelManager.FrameUpdate(time_elapsed)
    StageManager.FrameUpdate(time_elapsed)
    ObjectCenter.FrameUpdate(time_elapsed)
    SnakeHeadMoveAI.FrameUpdate(time_elapsed)
	MapManager.FrameUpdate(time_elapsed)
    AttackManager.FrameUpdate(time_elapsed)
    SkillManager.FrameUpdate(time_elapsed)
    CSPanel.UpdateNewFunc(time_elapsed)
    self.skill_panel:FrameUpdate(time_elapsed)
    self:Debug("bullet", SpawnBulletManager.GetCurNum())


end

function C:Debug(key, txt)
    self.debug_map = self.debug_map or {}
    self.debug_map[key] = txt
    local ss = ""
    for k,v in pairs(self.debug_map) do
        ss = ss .. "\n" .. k .. "=" .. v
    end
    -- self.debug_txt.text = ss
    self.stage_panel:RefreshData(key,txt)
end


function C:on_stage_init_finish(data)
    -- self.update_time:Stop()    
    self:SetTimeStage(-1)
    CSEffectManager.PlayShowAndHideAndCall(
                                            self.transform,
                                            "game_begin_fx",
                                            nil,
                                            Vector3.New(0,500,0),
                                            3,
                                            1,
                                            function ()
                                            end,
                                            function (tran)

                                                if data.type then
                                                    tran:Find("Image/Text").gameObject:SetActive(false)
                                                    local imgTran = tran:Find("Image/img")
                                                    imgTran.gameObject:SetActive(true)
                                                    local imgData = {
                                                        jlg = 
                                                            {img="2d_gk_wz_03",scale=1,},
                                                        boss = 
                                                            {img="2d_gk_wz_04",scale=1,},
                                                    }
                                                    local d = imgData[data.type]
                                                    local imgSp = imgTran:GetComponent("Image")
                                                    imgSp.sprite = GetTexture(d.img)
                                                    imgSp:SetNativeSize()
                                                    imgSp.gameObject.transform.localScale = Vector3.New(d.scale,d.scale,d.scale)
                                                else
                                                    tran:Find("Image/img").gameObject:SetActive(false)
                                                    tran:Find("Image/Text").gameObject:SetActive(true)
                                                    tran:Find("Image/Text"):GetComponent("Text").text = "第" .. (data.level or 0) .. "关"
                                                    if data.level == 0 then
                                                        tran:Find("Image").gameObject:SetActive(false)
                                                    else
                                                        tran:Find("Image").gameObject:SetActive(true)
                                                    end
                                                end
                                            end,
                                            nil,
                                            function ()
                                            end)
                                            
    self:RefreshStage(data)
    
end

function C:onClearStageFx(data)

    CSEffectManager.PlayScaleFX(
                                CSPanel.transform,
                                "game_qyqk_fx",
                                0,
                                1,
                                0.6,
                                1.4)

end

-- 升级特效
function C:OnGameLvUpFx(data)
    local head = GameInfoCenter.GetHeroHead()
    local hpos = head.transform.position

    local time = 1

    local prefab = CachePrefabManager.Take("ST_shenji_tb", CSPanel.map_node, time)
    local tran = prefab.prefab.prefabObj.transform
    tran.position = hpos

    local dt = 0.03
    local tn = math.ceil(time/dt)
    local ct = 0
    local timer = nil
    timer = Timer.New(function()
        ct = ct + 1
        local head = GameInfoCenter.GetHeroHead()
        if not head then
            CachePrefabManager.Back(prefab)
            timer:Stop()
            return
        end
        local hpos = head.transform.position
        tran.position = hpos
        if ct >= tn then
            CachePrefabManager.Back(prefab)
        end
    end,dt,tn)
    timer:Start()

end

function C:OnGameWinFx(data)

    local show_panel = function()
        LevelStatementsPanel.Create({backcall = function()
            self.is_stop = true
            if data.callback then
                data.callback()
            end
            self.is_stop = false
        end})
    end







    if data.type == "boss" then
        CSEffectManager.PlayShowAndHideAndCall(
                                            self.transform,
                                            "game_win_fx",
                                            nil,
                                            Vector3.New(0,0,0),
                                            2.5,
                                            nil,
                                            function ()
                                                show_panel()
                                            end,
                                            function (tran)
                                            end)
    elseif data.type == "box" then
        self.is_stop = true

        local callback = data.callback
        local function cbk()
            if callback then
                callback()
            end
            self.is_stop = false
        end
        
        data.callback = cbk


        AwardSettlePanel.Create(data)

    else
        CSEffectManager.PlayShowAndHideAndCall(
                                            self.transform,
                                            "game_win_fx",
                                            nil,
                                            Vector3.New(0,0,0),
                                            1.5,
                                            nil,
                                            function ()
                                                show_panel()
                                            end,
                                            function (tran)
                                            end)
    end
end

function C:OnGameLoseFx(data)
    
    if self.gameLoseFxObj then
        return
    end

    self.is_stop = true
    
    self.gameLoseFxObj = GameObject.Instantiate(GetPrefab("game_lose_fx"), GameObject.Find("Canvas/LayerLv5").transform).gameObject
    self.gameLoseFxObj.transform.position = Vector3.New(0,0,0)

    --新手引导
	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		self.gameLoseFxObj.transform:Find("@notice").gameObject:SetActive(true)
        self.gameLoseFxObj.transform:Find("@notice2").gameObject:SetActive(true)
	end

    self.gameLoseFxObj.transform:Find("btn"):GetComponent("Button").onClick:AddListener(function()
        self.is_stop = false
        if data.callback then
            data.callback()
        end
        Destroy(self.gameLoseFxObj)
        self.gameLoseFxObj = nil
    end)

end

function C:on_time_speed_change(data)
    --data = {key= key ,is_speed_down = true}
    self.timeSpeedMap = self.timeSpeedMap or {}
    if data.is_speed_down then
        self.timeSpeedMap[data.key] = 1
        self.time_scale_value = data.value or 0.1
    else
        self.timeSpeedMap[data.key] = nil
        if next(self.timeSpeedMap) == nil  then
            self.time_scale_value = 1
        end
    end
end

function C:SetStopUpdate(b)

    self.is_stop = b

end

function C:on_set_mian_timer(data)
    if self.update_time then
        if data then
            if data.isOn then
                self:SetTimeStage(1)
                -- self.update_time:Start()
            else
                self:SetTimeStage(-1)
                -- self.update_time:Stop()
            end
        end
    end
end

function C:on_ui_shake_screen_msg(data)
    data = data or {}
    local t = data.t or 0.1
    local range = data.range or 0.6
    local delta_t = data.delta_t or 0.1

    if self.shake_seq then
        self.shake_seq:Kill()
    end
    self.shake_seq = DoTweenSequence.Create()
    if data.stop_frame_update then
        self.shake_seq:AppendCallback(function()
            self.is_stop = true
        end)
    end
    if delta_t and delta_t > 0.001 then
        self.shake_seq:AppendInterval(0.1)
    end
    self.shake_seq:Append(self.map_node.transform:DOShakePosition(t, Vector3.New(range, range, 0), 20))
    self.shake_seq:OnForceKill(function ()
        if data.stop_frame_update then
            self.is_stop = false
        end
        -- if IsEquals(self.camera3d) then
        --     self.camera3d.transform.localPosition = Vector3.zero
        -- end
        self.shake_seq = nil
    end)
end


function C:on_head_manual_change_target_dir(dir)
    --print("xxx------------on_head_manual_change_target_dir 1")
    local isAutoCtrlEnable = AutoControlModelManager.GetIsEnable()
    --print("xxx------------on_head_manual_change_target_dir 33" , isAutoCtrlEnable)
    if not isAutoCtrlEnable then
        return
    end
    print("xxx------------on_head_manual_change_target_dir 2")
    
    self:setAutoControlModel(not isAutoCtrlEnable , dir)

end

function C:on_global_game_panel_open_msg(data)
    if data.ui == "SetPanel" then
        self:SetTimeStage(-1)
    end
end

function C:on_global_game_panel_close_msg(data)
    if data.ui == "SetPanel" then
        self:SetTimeStage(1)
    end
end

function C:setAutoControlModel(enable , dir)
    AutoControlModelManager.SetIsEnable( enable )

    if not enable then
        local heroHead = GameInfoCenter.GetHeroHead()
        print("xxx-------------- add manualOper")
        heroHead.fsmLogic:addWaitStatusForUser( "manualOper" , { initDir = dir }  )
    end

    --isAutoCtrlEnable = AutoControlModelManager.GetIsEnable()
    -- if enable then
    --     self.auto_txt.text = "开"
    -- else
    --     self.auto_txt.text = "关"
    -- end
end

function C.AddUpdateFunc(key,func)
    CSPanel.UpdateFuncList = CSPanel.UpdateFuncList or {}
    if CSPanel.UpdateFuncList[key] then
        print("<color=red>已经存在相同的key</color>")
    else
        CSPanel.UpdateFuncList[key] = func
    end
end

function C.RemoveUpdateFunc(key)
    if CSPanel.UpdateFuncList[key] then
        CSPanel.UpdateFuncList[key] = func
    else
        print("<color=red>不存在的key</color>")
    end
end

function C.UpdateNewFunc(time_elapsed)
    CSPanel.UpdateFuncList = CSPanel.UpdateFuncList or {}
    for k,v in pairs(CSPanel.UpdateFuncList) do
        v(k,time_elapsed)
    end
end


