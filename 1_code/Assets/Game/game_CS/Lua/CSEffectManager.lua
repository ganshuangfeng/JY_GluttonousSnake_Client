-- 创建时间:2021-07-05
-- 游戏特效管理器
CSEffectManager = {}

local M = CSEffectManager

-- 一个固定位置的特效 显示一段时间消失
-- 支持回调方法在中间位置出现
function M.PlayShowAndHideAndCall(parent, fx_name, step, beginPos, keepTime, call_time, finish_call, call, seq_parm, kill_call, delta_t,prefab_scale)
	local call1 = function ()
		local prefab = CachePrefabManager.Take(fx_name, parent, step)
		prefab.prefab:SetParent(parent)
		if prefab_scale then
			prefab.prefab.gameObject.transform.localScale = Vector3.New(prefab_scale,prefab_scale,prefab_scale)
		else
			prefab.prefab.gameObject.transform.localScale = Vector3.one
		end
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
	    if call then -- 修改预制体的内容
	        call(tran)
	    end

	    local seq = DoTweenSequence.Create(seq_parm)
	    if call_time then
	        seq:AppendInterval(call_time)
	        seq:AppendCallback(function ()
	            if finish_call then
	                finish_call()
	            end
	            finish_call = nil
	        end)
	        keepTime = keepTime - call_time
	        if keepTime <= 0 then
	            keepTime = nil
	        end
	    end

	    if keepTime and keepTime > 0.001 then
	        seq:AppendInterval(keepTime)
	    end
	    seq:OnKill(function ()
	        if finish_call then
	            finish_call()
	        end
	        finish_call = nil

	        if kill_call then
	            kill_call()
	        end
	        kill_call = nil
	    end)
	    seq:OnForceKill(function ()
			if IsEquals(prefab.prefab.prefabObj.transform) then
				prefab.prefab.prefabObj.transform.localScale = Vector3.one 				
			end
	        CachePrefabManager.Back(prefab)
	    end)
	    
	    return seq
	end
	if delta_t and delta_t > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(delta_t)
		seq:OnKill(function ()
			call1()
		end)
		return seq
	else
		return call1()
	end
end

-- 通用飞行特效 
function M.PlayMoveAndHideFX(parent, fx_name, beginPos, endPos, keepTime, moveTime, finish_call, endTime, seq_parm)
    local obj = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
    obj.transform.position = beginPos

    local seq = DoTweenSequence.Create(seq_parm)

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end
    seq:Append(obj.transform:DOMove(endPos, moveTime):SetEase(Enum.Ease.InQuint))
    if endTime then
        seq:AppendInterval(endTime)
    end
    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        Destroy(obj)
    end) 
    return seq     
end

function M.CreateGold(parent, beginPos, endPos, delay, call, prefab_name)
	prefab_name = prefab_name or "FlyGlodPrefab"
	local prefab = CachePrefabManager.Take(prefab_name,nil,20)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	-- prefab.prefab.prefabObj.transform.gameObject:SetActive(math.random(0,100) < 20)
	local romdom_pos =  Vector3.New(beginPos.x + math.random(-40,40),beginPos.y + math.random(-40,40),beginPos.z)
	tran.position = romdom_pos
	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	local len = math.sqrt( (romdom_pos.x - endPos.x) * (romdom_pos.x - endPos.x) + (romdom_pos.y - endPos.y) * (romdom_pos.y - endPos.y) )
	local HH = 35
	local t = len / 2000
	local h = math.random(-200, 200)
	--seq:Append(tran:DOMove(Vector3.New(romdom_pos.x, romdom_pos.y + HH, 0), 0.5))
	-- seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	-- seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH*0.7, 0), 0.2))
	-- seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	-- seq:AppendInterval(0.2)
	-- seq:Append(tran:DOMoveBezier(endPos, h, t):SetEase(Enum.Ease.InQuint))
	seq:Append(tran:DOMove(endPos, t):SetEase(Enum.Ease.Linear))
	seq:Insert(0,tran:DOScale(Vector3.New(1.8,1.8,1.8), t * 2/5))
	seq:Insert(t * 2/5,tran:DOScale(Vector3.New(1, 1, 1), t * 3/5))

	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end

function M.PlayMonsterOnHit(monster_tran,monster_pre_name,damage,cbk)
	-- if monster_pre_name == "Monster_1" or monster_pre_name == "Monster_2" then 
	if true then
		local fx_pre
		if CSModel.Is2D then
			fx_pre = CachePrefabManager.Take(monster_pre_name .. "_2D_white", monster_tran, 100)
		else
			fx_pre = CachePrefabManager.Take(monster_pre_name .. "_white", monster_tran, 100)
		end
		fx_pre.prefab.gameObject.transform:SetParent(monster_tran)
		fx_pre.prefab.gameObject.transform.localPosition = Vector3.zero
		fx_pre.prefab.gameObject.transform.localRotation = Vector3.zero
		if CSModel.Is2D then
			fx_pre.prefab.gameObject.transform.localScale = monster_tran.transform:Find("@sprite").localScale
		end
		fx_pre.prefab.gameObject:SetActive(true)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.05)
		seq:AppendCallback(function()
			if IsEquals(monster_tran) then
				CachePrefabManager.Back(fx_pre)
			end
		end)
	end
end

function M.PlayBulletBoom(monster_tran,pre_name,cbk,prefab_scale)
	M.PlayShowAndHideAndCall(
							monster_tran.transform or CSPanel.attack_node,
							pre_name or "Sj_shouji",
							20,
							monster_tran.position + Vector3.New(0,0,-10),
							4,
							nil,
							function ()
								if cbk then cbk() end
							end,
							nil,nil,nil,nil,prefab_scale
							)
end

function M.PlayMonsterOnDead(beginPos, particle_name, cbk)
	M.PlayShowAndHideAndCall(
							CSPanel.attack_node,
							particle_name or "SW_siwangt_yan",
							20,
							beginPos,
							1,
							nil,
							function ()
								if cbk then cbk() end
							end)
end

function M.PlayBossOnDead(beginPos, cbk)
	local scale = 0.2
	CSPanel.time_scale_value = scale
	Time:SetTimeScale(scale)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		CSPanel.time_scale_value = 1
		Time:SetTimeScale(1)
	end)
	M.PlayShowAndHideAndCall(
							CSPanel.map,
							"BOSS_SW_GX_ty",
							nil,
							beginPos,
							5,
							nil,
							function ()
								if cbk then cbk() end
							end)
end

function M.PlayWjBoom(obj, cbk)
	-- local seq = DoTweenSequence.Create()
	-- seq:Append(obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.1):SetLoops(2, Enum.LoopType.Yoyo))
	-- seq:AppendCallback(function()
	-- 	M.PlayShowAndHideAndCall(
	-- 							CSPanel.attack_node,
	-- 							"SW_siwang",
	-- 							20,
	-- 							obj.localPosition,
	-- 							0.5,
	-- 							call_time)
	-- end)
	-- seq:AppendInterval(0.1)
	-- seq:OnKill(function()
	-- 	if cbk then cbk() end
	-- end)
	obj.gameObject:SetActive(false)
	if cbk then cbk() end
	CSEffectManager.PlayMonsterOnDead(obj.transform.position, nil, function ()
	end)
end

--震屏效果
function M.PlayShakeScreen()
	CSModel.camera2d:DOShakePosition(0.5,Vector3.New(5,5,0))
    CSPanel.camera3d:DOShakePosition(0.5, Vector3.New(0.6, 0.6, 0), 20)
end

--加速技能效果
function M.PlaySpeedUpLines()
	M.CloseSpeedUpLines()
	M.speed_up_lines = {}
	local vecs = {
		[1] = Vector3.New(-518,913,0),
		[2] = Vector3.New(493,913,0),
	}
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	CSEffectManager.PlayAllScreenEffect("JS_liangguang")
	for k,v in ipairs(vecs) do
		local fx_pre = NewObject("xian",parent)
		fx_pre.transform.localPosition = v
		M.speed_up_lines[#M.speed_up_lines + 1] = fx_pre
	end
	local ui_fx = NewObject("speed_up_ui_fx",parent)
	ui_fx.transform.localPosition = Vector3.New(850,0,0)
	M.ui_fx = ui_fx
	
	ui_fx.transform:GetComponent("Animator").enabled = false
	local seq = DoTweenSequence.Create()
	seq:Append(ui_fx.transform:DOLocalMove(Vector3.New(275,0,0),0.5))
	seq:OnForceKill(function()
		if IsEquals(ui_fx) then
			ui_fx.transform:GetComponent("Animator").enabled = true
		end
	end)
end

--关闭加速技能效果
function M.CloseSpeedUpLines()
	CSEffectManager.CloseAllScreenEffect("JS_liangguang")
	if M.speed_up_lines then
		for k,v in ipairs(M.speed_up_lines) do
			Destroy(v)
		end
		M.speed_up_lines = nil
	end
	if IsEquals(M.ui_fx) then
		M.ui_fx.transform:GetComponent("Animator").enabled = false
		local seq = DoTweenSequence.Create()
		seq:Append(M.ui_fx.transform:DOLocalMove(Vector3.New(850,0,0),0.5))
		seq:OnForceKill(function()
			if IsEquals(M.ui_fx) then
				Destroy(M.ui_fx.gameObject)
				M.ui_fx = nil
			end
		end)
	end
end

--播放全屏光效，同一时间只能有一个 type:boss JS_liangguang
function M.PlayAllScreenEffect(type)
	if CSPanel and CSPanel.stage_panel then
		if type == "boss" then
			if M.all_screen_effect_state then
				--有其他效果，先不播放boss效果
			else
				M.all_screen_effect_state = "boss"
				CSPanel.stage_panel.bossFightingObj.gameObject:SetActive(true)
			end
		else
			if M.all_screen_effect_state == "boss" then
				CSPanel.stage_panel.bossFightingObj.gameObject:SetActive(false)
			end
			if IsEquals(M.all_screen_effect_obj) then
				Destroy(M.all_screen_effect_obj)
				M.all_screen_effect_obj = nil
			end
			M.all_screen_effect_obj = NewObject(type,GameObject.Find("Canvas/LayerLv50").transform)
			M.all_screen_effect_obj.transform.localPosition = Vector3.zero
			M.all_screen_effect_state = type
		end
	end
end

function M.CloseAllScreenEffect(type)
	if M.all_screen_effect_state == "boss" and type == "boss" then
		CSPanel.stage_panel.bossFightingObj.gameObject:SetActive(false)
		M.all_screen_effect_state = nil
	elseif type == M.all_screen_effect_state then
		if IsEquals(M.all_screen_effect_obj) then
			Destroy(M.all_screen_effect_obj)
			M.all_screen_effect_obj = nil
		end
		if CSPanel and CSPanel.stage_panel then
			if CSPanel.stage_panel.state == "boss" then
				CSPanel.stage_panel.bossFightingObj.gameObject:SetActive(true)
				M.all_screen_effect_state = "boss"
				return
			end
		end
		M.all_screen_effect_state = nil
	end
end

function M.PlayMergeLight(parent,scale,layer)
	if not parent then return end
	local prefab = CachePrefabManager.Take("HC_guangxiao_YX",parent.transform,20)
	local hctx = prefab.prefab.prefabObj
	hctx.transform.parent = parent.transform
	hctx.gameObject:SetActive(true)
	scale = scale or Vector3.one * 0.04
	hctx.transform.localScale = scale
	hctx.transform.localPosition = Vector3.zero

	if layer then
		SetLayer(hctx,"3D")
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(4)
	seq:AppendCallback(function()
		CachePrefabManager.Back(prefab)
	end)
end

-- 宝石跳跃
function M.PlayBSJump(obj, call, jb)
	if not IsEquals(obj) then 
		if call then
			call()
		end
		return
	end
	local play_jb = function ()
		if not IsEquals(obj) then
			return
		end
		if not jb or jb < 1 then
			return
		end

		for i = 1, 5 do
			local beginPos = CSModel.Get3DToUIPoint(obj.transform.position) + Vector3.New(math.random(-50, 50), math.random(-50, 50), 0)
			CSEffectManager.CreateGold(
										CSPanel.anim_node,
										beginPos,
										CSPanel:GetJBNode(),
										nil,
										function()
											Event.Brocast("ui_game_get_jin_bi_msg", jb)
										end)
		end
	end
	local pos = obj.transform.position
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOMove(pos+Vector3.New(0,3,0),0.2))
	seq:Append(obj.transform:DOMove(pos+Vector3.New(0,2,0),0.2))
	seq:Append(obj.transform:DOMove(pos+Vector3.New(0,2.2,0),0.1))
	seq:Append(obj.transform:DOMove(pos+Vector3.New(0,2,0),0.1))
	seq:OnForceKill(function()
		play_jb()
		if call then
			call()
		end
	end)
end


-- 宝石闪光爆金币
function M.PlayBSFlicker(pos, num, value, call)

	local play_jb = function ()

		ExtendSoundManager.PlaySound(audio_config.cs.battle_BOSS_death_2.audio_name)
		
		local beginPos = CSModel.Get3DToUIPoint(pos, 0)
		CSEffectManager.CreateGold(
									CSPanel.anim_node,
									beginPos,
									CSPanel:GetJBNode(),
									nil,
									function()
										Event.Brocast("ui_game_get_jin_bi_msg", value)
									end)
	
	end

	local function fx_func(n)

	    CSEffectManager.PlayShowAndHideAndCall(CSPanel.map_node,"BS_sg",10,pos,
	                                           0.2,nil,function (obj)
	                                           		play_jb()
	                                           		if n > 1 then
	                                           			fx_func(n-1)
	                                           		else
	                                           			if call then
	                                           				call()
	                                           			end
	                                           		end
												end)

	end

	fx_func(num)

end

--boss技能攻击时警告区域填充动画
function M.PlayBossWarning(fx_name,warning_pos,warning_time,warning_wait_time,begin_call,warning_end_call,aniScale)
	aniScale = aniScale or Vector3.one
	return CSEffectManager.PlayShowAndHideAndCall(
		CSPanel.map_node,
		fx_name,
		nil,
		warning_pos,
		warning_time + (warning_wait_time or 0.5),
		nil,
		warning_end_call,
		function(tran)
			--需要在Warning预制体下挂一个@warning_anim_node节点用于播放动画(设置好初始位置和角度)
			if begin_call then begin_call(tran) end
			local tbl = LuaHelper.GeneratingVar(tran)
			if tbl.warning_anim_node then
				local _seq = DoTweenSequence.Create()
				_seq:Append(tbl.warning_anim_node:DOScale(aniScale,warning_time))
			end
		end
	)
end


-- 通用飞行特效 
function M.PlayMoveAndFadeFX(parent, fx_name, beginPos, endPos, keepTime, moveTime, finish_call, endTime, fadeTime, seq_parm)
	local prefab =CachePrefabManager.Take(fx_name, parent)
	local obj = prefab.prefab.prefabObj.gameObject
    obj.transform.position = beginPos

    local seq = DoTweenSequence.Create(seq_parm)

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end
    seq:Append(obj.transform:DOMove(endPos, moveTime):SetEase(Enum.Ease.InQuint))
    if endTime then
        seq:AppendInterval(endTime)
    end

    if fadeTime then
    	obj.transform:GetComponent("CanvasGroup").alpha = 1
    	seq:Append(obj.transform:GetComponent("CanvasGroup"):DOFade(0,fadeTime))
    end

    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
    end) 
    return seq     
end



-- 圆形遮罩切场动画特效 0出场 1进场
function M.PlayCircleSwitchMaskFX(parent, pos, type, delay, time, ms, finish_call, seq_parm)
    local obj = GameObject.Instantiate(GetPrefab("CircleSwitchMask"), parent).gameObject
    obj.transform.position = Vector3.zero

    local cm = obj.transform:Find("CircleMask")
    
    cm.transform.position = pos

    local maxScl = ms or 9
    local tarScl = maxScl

    if type == 0 then
    	cm.transform.localScale = Vector3.zero
    else
    	cm.transform.localScale = Vector3.New(maxScl,maxScl,maxScl)
    	tarScl = 0
    end

    local seq = DoTweenSequence.Create(seq_parm)
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
    seq:Append(cm.transform:DOScale(Vector3.New(tarScl, tarScl, tarScl), time))

    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil
    end)

    seq:OnForceKill(function ()
        Destroy(obj)
    end)

    return seq     
end


-- 通用缩放动画 
function M.PlayScaleFX(parent, fx_name, scale1, scale2, time, keepTime, finish_call, seq_parm)
	local prefab = CachePrefabManager.Take(fx_name, parent)
	local obj = prefab.prefab.prefabObj.gameObject

    obj.transform.localScale = Vector3.New(scale1, scale1, scale1)

    local seq = DoTweenSequence.Create(seq_parm)
	
	seq:Append(obj.transform:DOScale(Vector3.New(scale2, scale2, scale2), time):SetEase(Enum.Ease.InQuint))

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end

    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
    end) 
    return seq     
end
