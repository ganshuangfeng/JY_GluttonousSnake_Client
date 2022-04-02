-- 创建时间:2018-09-28

GameManager = {}

-- 跳转场景
local function GotoGame(gameName, parm, call , enterSceneCall)
	if not gameName or not GameConfigToSceneCfg[gameName] then
		-- error(debug.traceback())
		if call then
			call()
		end
		return
	end
	local sceneName = GameConfigToSceneCfg[gameName].SceneName
	if MainModel.myLocation == sceneName then
		if call then
			call()
		end
		return
	end
	local sTocScene = MainModel.getServerToClient(MainModel.Location)
    if not sTocScene or sTocScene == gameName then
	    if gameName == "game_DdzMillion" then
	        Network.SendRequest(
	            "dbwg_req_game_list",
	            nil,
	            "正在请求数据",
	            function(data)
	                if data.result == 0 then
						if call then
							call()
						end
				        MainLogic.GotoScene(sceneName, parm , enterSceneCall)
	                else
	                    HintPanel.Create(1, "今日没有比赛")
	                end
	            end
	        )
	    else
			if call then
				call()
			end
	        MainLogic.GotoScene(sceneName, parm , enterSceneCall)
	    end
    else
        GameManager.CheckCurrGameScene()
    end
end

---获取配置
local config_new = HotUpdateConfig("Game.CommonPrefab.Lua.switch_scence_config")


-- 检查服务器提示的游戏位置是不是当前所在的游戏，不在就提示在游戏中，点击跳转
function GameManager.CheckCurrGameScene()
	dump(MainModel.Location, "<color=green>MainModel.Location>>>>>>>>>>>>>>>></color>")
    if MainModel.Location then
    	local sTocScene = MainModel.getServerToClient(MainModel.Location)
        local cfg = GameConfigToSceneCfg[sTocScene]
        if cfg == nil then
        	MainModel.Location = nil
            print(string.format( "<color=red>[Error] Need config GameConfigToSceneCfg for: %s</color>",sTocScene))
            return
        end
        local msg = string.format("您正在%s游戏中，是否继续游戏？", cfg.GameName)
        if sTocScene == "game_Fishing" or sTocScene == "game_Fishing3D" then
            HintPanel.Create(2, msg, function()
                GameManager.GotoSceneName(sTocScene)
            end, function ()
            	if sTocScene == "game_Fishing" then
	        	    Network.SendRequest("fsg_quit_game", nil, "请求退出", function ()
	        	    	MainModel.Location = nil
	        	    end)
            	elseif sTocScene == "game_Fishing3D" then
            		local fun = function ()
	            		Network.SendRequest("fsg_3d_quit_game", nil, "请求退出", function ()
		        	    	MainModel.Location = nil
		        	    end)
            		end
            		-- 判断是否在排名赛比赛中,若在,就不处理,若不在,就可以取消
            		Network.SendRequest("bullet_rank_all_info", nil, "", function (data)
            			if data.result ~= 0 then
	        	    		fun()
	        	    	end
	        	    end)
            	end

            end)
	    else
	        HintPanel.Create(2, msg, function()
                GameManager.GotoSceneName(sTocScene)
            end)
        end
    end
end

function GameManager.GotoSceneName(sceneName, parm, call , enterSceneCall,down_style)
	if MainLogic.is_lock_goto_scene then
		LittleTips.Create("下载中，不能切换场景")
		return
	end

	local _down_style
	if parm and type(parm) == "table" and parm.down_style then
		_down_style = parm.down_style
	elseif down_style then
		_down_style = down_style
	end
	GameManager.DownSceneName(sceneName, function ()
		GotoGame(sceneName, parm, call , enterSceneCall)
	end, _down_style)
end
function GameManager.DownSceneName(sceneName, call, down_style)
	local state = gameMgr:CheckUpdate(sceneName)
	dump({state = state,sceneName = sceneName},"<color=green>gamemanager down scene name</color>")
	if state == "Install" or state == "Update" then
        MainLogic.is_lock_goto_scene = true

		HotUpdatePanel.Create(sceneName, function(updateState)
			HotUpdatePanel.Close()
			MainLogic.is_lock_goto_scene = false
			if updateState == string.lower(sceneName) then
		        if call then
		        	call()
		        end
			else
				HintPanel.ErrorMsg(MainLogic.FormatGameStateError(updateState))
			end
		end, down_style)
	elseif state == "Normal" then
        if call then
        	call()
        end
	else
		HintPanel.ErrorMsg(MainLogic.FormatGameStateError(state))
	end
end
--------------------------------------
--------------------------------------
--               跳转UI
--------------------------------------
--------------------------------------
local runCall = function (call)
	if call then
		call()
	end
end
function GameManager.BuyGift(shopid)
	shopid = tonumber(shopid)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)

    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)

    if b1 then
    	if gift_config.buy_limt == 0 then
            if status == 0 then
				HintPanel.Create(1, "您已购买过此礼包了")
                return
            end
        elseif gift_config.buy_limt == 1 then
            if status == 0 then
				local s1 = os.date("%m月%d日%H点", gift_config.start_time)
				local e1 = os.date("%m月%d日%H点", gift_config.end_time)
				HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
                return
            end
        end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end
-- gotoui, goto_scene_parm, call,enter_scene_call
-- 2019-10-11 新增 parent, backcall
local base_goto_ui
base_goto_ui = function (parm)
	local gotoui = parm.gotoui
    if MainModel.Location and GameManager.GetSceneNameByGotoui(gotoui) then
        GameManager.CheckCurrGameScene()
        return
	end

	local goto_scene_parm = parm.goto_scene_parm
	local call = parm.call
	local enter_scene_call = parm.enter_scene_call
	local parent = parm.parent
	local backcall = parm.backcall
	local down_style = parm.down_style
    -- 对应权限的key 
    local _permission_key = parm.condi_key
    if _permission_key then
    	local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint=true})
        if not b then
        	if backcall then
				backcall()
			end
            return false
        end
    end

    if gotoui then
        if gotoui == "copy" then
        	runCall(call)
    		UniClipboard.SetText(goto_scene_parm)
			LittleTips.Create("已复制成功")
		elseif gotoui == "open_url" then
			runCall(call)
			UnityEngine.Application.OpenURL(goto_scene_parm)
		elseif gotoui == "LittleTips" then
			LittleTips.Create(goto_scene_parm)
		else
			if _G[gotoui] and _G[gotoui].Create then
				runCall(call)
				return _G[gotoui].Create(parent, backcall, goto_scene_parm)
			else
				local pre = GameModuleManager.GotoUI(parm)
				if pre then
					runCall(call)
					return pre
				else
					if backcall then
						backcall()
					end
					print("<color=red>找策划确认这个值要跳转到那里 gotoui=" .. gotoui .. "</color>")
					dump(parm)
					print(debug.traceback())
				end
			end
		end
    end
end

GameManager.GotoUIScene = {
	hall = {scene = "game_Hall"},
}

-- 网络请求列表
function GameManager.SendMsgList(tag, msg_list)
	if msg_list and #msg_list > 0 then		
		GameManager.SendRequest(msg_list, 1, tag)
	else
		Event.Brocast("query_send_list_fishing_msg", tag)
	end
end
function GameManager.SendRequest(list, cur_i, tag)
	if list[cur_i] then
		local jh = "发送请求"
		if list[cur_i].is_close_jh then
			jh = nil
		end
		Network.SendRequest(list[cur_i].msg , list[cur_i].data, jh, function (data)
			Event.Brocast(list[cur_i].msg .. "_response", list[cur_i].msg, data)
			cur_i = cur_i + 1
			GameManager.SendRequest(list, cur_i, tag)
		end)
	else
		Event.Brocast("query_send_list_fishing_msg", tag)
	end
end

-- 这个是不是场景跳转 是就返回跳转的场景名
function GameManager.GetSceneNameByGotoui(gotoui)
	if GameManager.GotoUIScene[gotoui] then
		return GameManager.GotoUIScene[gotoui]
	elseif GameConfigToSceneCfg[gotoui] then
		return {scene = GameConfigToSceneCfg[gotoui].SceneName}
	end
end

--MainModel.CurrLogic.quit_game(call, quit_msg_call)
-- 退出消息成功后有可能需要处理一些游戏自己的东西，quit_msg_call是退出消息返回的回调，call是游戏处理完后的回调
-- 大部分情况这两个方法是前后调用，捕鱼就是特例，需要先卸载缓存资源再回调call
local function base_exit_scene(parm, quit_msg_call, call)
	local scene_cfg = GameManager.GetSceneNameByGotoui(parm.gotoui)
	if scene_cfg then
		local sceneName = scene_cfg.scene --or parm.gotoui
		if MainModel.myLocation ~= sceneName and MainModel.CurrLogic and MainModel.CurrLogic.quit_game then
			MainModel.CurrLogic.quit_game(function ()	
				if call then
					call()
				else
					return base_goto_ui(parm)
				end
			end, function (result)
				if result == 0 then
					if quit_msg_call then
						quit_msg_call()
					end
				else
					HintPanel.Create(1,"当前无法进行此操作")
				end
			end)
		else
			if call then
				call()
			else
				if quit_msg_call then
					quit_msg_call()
				end
				return base_goto_ui(parm)
			end
		end
	else
		if quit_msg_call then
			quit_msg_call()
		end
		return base_goto_ui(parm)
	end
end

function GameManager.GotoUI(parm,quit_msg_call)
	return GameManager.CommonGotoScence(parm,quit_msg_call)
end
function GameManager.GuideExitScene(parm, quit_msg_call)
	return GameManager.CommonGotoScence(parm,quit_msg_call)
end

---新的跳转方法 parm = {gotoui = "场景名/模块", goto_scene_parm = {game_id=4}, p_requset = {参数}} 
---请求报名有requset时，参数 p_requset = {}
function GameManager.CommonGotoScence(parm,quit_msg_call)
	local function CheckCodikey(_permission_key)
		local b = SYSQXManager.CheckCondition({_permission_key=_permission_key, is_on_hint=true})
        if b then
            return true
        else
        	return false
        end
	end   

	local function get(sceneName)
		--判断权限
	    -- local _permission_key = config_new.config_scence[sceneName] parm.condi_key
		local channel_type = gameMgr:getMarketPlatform()
		local infor_table = {}
		if #config_new.config_scence[sceneName] ~= 1 then
			--根据平台获取配置（权限，协议，参数，错误返回场景）
			for i=1,#config_new.config_scence[sceneName] do
				if channel_type == config_new.config_scence[sceneName][i].channel then
					infor_table = config_new.config_scence[sceneName][i]
					return infor_table
				end
			end
		else
			return config_new.config_scence[sceneName][1]
		end
	end

	local scene_cfg = GameManager.GetSceneNameByGotoui(parm.gotoui)
	-- dump(scene_cfg,"sceneName")
	local sceneName
	if scene_cfg then
		sceneName = scene_cfg.scene
		parm.gotoui = sceneName
	end
	---当前所在位置能否跳转
	if MainModel.myLocation == sceneName then
		LittleTips.Create("当前无法进行此操作")
		return
	end

	----当前是场景的切换
	if sceneName and config_new.config_scence[sceneName] then
		--判断平台
		local infor_table = get(sceneName)
		---显示权限
		if CheckCodikey(infor_table.condi_key) then
			base_exit_scene(parm, function ()
				if quit_msg_call then
					quit_msg_call()
				end
			end, function ()
				if infor_table.requset then
					Network.SendRequest(infor_table.requset, infor_table.parm or parm.p_requset, "", function (data)
						if data.result == 0 then
							if scene_cfg.goto_scene_parm and not parm.goto_scene_parm then
								parm.goto_scene_parm = scene_cfg.goto_scene_parm
							end
							parm.gotoui = sceneName
							base_goto_ui(parm)
						else
							base_goto_ui({gotoui = infor_table.error_scence})
						end
					end)
				else
					parm.gotoui = sceneName
					base_goto_ui(parm)
				end	

			end)
		end
	------模块/单独的界面	
	else
		return base_exit_scene(parm, quit_msg_call)
	end
end

--打开WebView运营活动
function GameManager.OpenActByWebView(_key)
	Network.SendRequest("create_shoping_token", {geturl= "" and "n" or "y"},function(_data)
		if _data.result == 0 then
			dump(UrlEncode(AppConst.SocketAddress),"<color=white>UrlEncode(AppConst.SocketAddress)	</color>")
			local urlStr = "&url=" .. UrlEncode(MainModel.UserInfo.webview_api)	
			local url = MainModel.UserInfo.webview_url .. "?token=" .. _data.token ..urlStr
			UniWebViewMgr.OpenUrl(_key,url)
			dump(MainModel.UserInfo.webview_api,"<color=green>webview_api</color>")
			dump(MainModel.UserInfo.webview_url,"<color=green>webview_url</color>")
		end
	end)
end