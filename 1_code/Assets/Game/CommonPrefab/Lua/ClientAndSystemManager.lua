-- 创建时间:2021-06-23
local basefunc = require "Game/Common/basefunc"
local fztf_lib = ExtRequire("Game.CommonPrefab.Lua.fztf_lib")

ClientAndSystemManager = {}
local M = ClientAndSystemManager
local msg_map = {}
local msgCacheQueue = basefunc.queue.New()

function M.Init()
	local d = {
	    game_level = MainModel.UserInfo.game_level,
	    turret = basefunc.deepcopy(MainModel.UserInfo.GameInfo.turret_list),
	    asset = basefunc.deepcopy(MainModel.UserInfo.Asset),
	    turret_base_level = MainModel.UserInfo.GameInfo.turret_base_level,
	}
	M.fztf = fztf_lib.init(d)
end

function M.SendRequest(name, args, callback)
	if msg_map[name] then
		msg_map[name](args, callback)
	else
		LittleTips.Create("消息不存在=" .. name)
	end
end

-- 封装一层，网络未连接时直接用本地结果，后续连接成功做结果校验
function M.PackSend(name, args, JHData, callback)
	if callback then
		callback({result = 0})
	else
		if JHData and "function" == type(JHData) then
			JHData({result = 0})
		end
    end
    
	if IsConnectedServer then
		if msgCacheQueue:size() > 0 then
			--有缓存的消息，先发送缓存的消息
			
		else
			--没有缓存直接发送本条消息
			Network.SendRequest(name, args, JHData, callback)
		end
	else
		msgCacheQueue:push_back({name, args, JHData, callback})
	end
end

-- 怪物死亡
function M.MonsterDie(data, callback)
	local msg = {}
	msg.type = 1
	msg.time = os.time()
	msg.data = {}

	for i,v in ipairs(data) do
		table.insert(msg.data,v.id)
		table.insert(msg.data,v.type)
		table.insert(msg.data,v.level)
	end

	local bb = fztf_lib.kill_monster(msg.time,msg.data)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi + bb.jin_bi
		-- Event.Brocast("model_monster_die_msg", bb.data)
		if callback then
			callback(bb)
		end
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				-- --HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end
-- 购买炮台
function M.BuyTurret(data)

	local tn = #MainModel.UserInfo.GameInfo.turret_list
	MainModel.UserInfo.GameInfo.turret_list[tn+1] = {
		heroId = tn+1,
		location = tn+1,
		type = data.type,
		level = 1,
		star = M.GetStarByType(data.type),
	}
	Event.Brocast("model_turret_change_msg")
	do return end



	local msg = {}
	msg.type = 3
	msg.time = os.time()
	msg.data = {data.type}
	local bb = fztf_lib.buy_turret(msg.time,data.type)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi - bb.price
		table.insert(MainModel.UserInfo.GameInfo.turret_list, basefunc.deepcopy(bb.data))

		Event.Brocast("model_turret_change_msg")
		Event.Brocast("model_asset_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		if bb.result == 1012 then
			LittleTips.Create("金币不足,击杀怪物可以获得金币")
		else
			--HintPanel.ErrorMsg(bb.result)
		end
	end
end
--回收炮台
function M.SaleTurret(data)

	local tn = #MainModel.UserInfo.GameInfo.turret_list
	MainModel.UserInfo.GameInfo.turret_list[tn] = nil
	Event.Brocast("model_turret_change_msg")
	do return end








	local msg = {}
	msg.type = 6
	msg.time = os.time()
	msg.data = {data.id}
	local bb = fztf_lib.sale_turret(msg.time,data.id,data.jb)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi + bb.jin_bi
		MainModel.UserInfo.GameInfo.turret_list = basefunc.deepcopy(bb.data)
		Event.Brocast("model_turret_change_msg")
		Event.Brocast("model_asset_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				----HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end
--插入炮台
function M.InsertTurret(data)
	local msg = {}
	msg.type = 7
	msg.time = os.time()
	msg.data = {data.id,data.location}
	local bb = fztf_lib.insert_turret(msg.time,data.id,data.location)
	if bb.result == 0 then
		MainModel.UserInfo.GameInfo.turret_list = basefunc.deepcopy(bb.data)
		Event.Brocast("model_turret_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end


-- 通过关卡
function M.FinishPass(data)
	local msg = {}
	msg.type = 2
	msg.time = os.time()
	msg.data = data
	local bb = fztf_lib.pass_game_level(msg.time)
	if bb.result == 0 then
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end
-- 合成
function M.MergeTurret(data)
	local msg = {}
	msg.type = 4
	msg.time = os.time()
	msg.data = data
	local bb = fztf_lib.merge_turret(msg.time,data[1], data[2])
	if bb.result == 0 then
		MainModel.UserInfo.GameInfo.turret_list = basefunc.deepcopy(bb.data)
		Event.Brocast("model_turret_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end
-- 拖拽
function M.PlaceTurret(data)
	local msg = {}
	msg.type = 5
	msg.time = os.time()
	msg.data = data
	local bb = fztf_lib.place_turret(msg.time,data[1], data[2])
	if bb.result == 0 then
		MainModel.UserInfo.GameInfo.turret_list = basefunc.deepcopy(bb.data)
		Event.Brocast("model_turret_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end

-- 增加金币
function M.AddGold(data)
	local msg = {}
	msg.type = 0
	msg.time = os.time()
	msg.data = {data.jb}
	local bb = fztf_lib.add_jinbi(msg.time,data.jb)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi + bb.jin_bi
		Event.Brocast("model_asset_change_msg")
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	end
end

-- 金币技能
function M.SetGoldSkill(data)
	local msg = {}
	msg.type = 6
	msg.time = os.time()
	msg.data = data
	M.fztf.skill_jb = data.skill_gold
	-- M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
	-- 	if _ret.result ~= 0 then
	-- 		--HintPanel.ErrorMsg(_ret.result)
	-- 	end
	-- end)
end
function M.EatGem(data, callback)
	local msg = {}
	msg.type = 0
	msg.time = os.time()
	msg.data = {data.jb}

	local bb = fztf_lib.add_jinbi(msg.time, data.jb)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi + bb.jin_bi
		Event.Brocast("model_cs_eat_gem_msg", bb)
		if callback then
			callback(bb)
		end
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end

function M.DestroyBox(data, callback)
	local msg = {}
	msg.type = 0
	msg.time = os.time()
	msg.data = {data.jb}

	local bb = fztf_lib.add_jinbi(msg.time, data.jb)
	if bb.result == 0 then
		MainModel.UserInfo.Asset.prop_jin_bi = MainModel.UserInfo.Asset.prop_jin_bi + bb.jin_bi
		Event.Brocast("model_cs_eat_gem_msg", bb)
		if callback then
			callback(bb)
		end
		M.PackSend("sync_player_data", { datas={msg} }, function (_ret)
			if _ret.result ~= 0 then
				--HintPanel.ErrorMsg(_ret.result)
			end
		end)
	else
		--HintPanel.ErrorMsg(bb.result)
	end
end

--#临时代码 添加星级
function M.AddStar(data)
	M.fztf.type_star_map = M.fztf.type_star_map or {}
	M.fztf.type_star_map[data.type] = M.fztf.type_star_map[data.type] or 0
	if M.fztf.type_star_map[data.type] < 3 then
		M.fztf.type_star_map[data.type] = M.fztf.type_star_map[data.type] + 1
	else
		HintPanel.ErrorMsg(5304)
	end
end

function M.GetStarByType(type)
	return GameInfoCenter.GetTurretLevel(type)
end


msg_map["cs_monster_die"] = M.MonsterDie
msg_map["cs_buy_turret"] = M.BuyTurret
msg_map["cs_finish_pass"] = M.FinishPass
msg_map["cs_merge_turret"] = M.MergeTurret
msg_map["cs_place_turret"] = M.PlaceTurret
msg_map["cs_sale_turret"] = M.SaleTurret
msg_map["cs_insert_turret"] = M.InsertTurret
msg_map["cs_set_gold_skill"] = M.SetGoldSkill
msg_map["cs_eat_gem"] = M.EatGem
msg_map["cs_destroy_box"] = M.DestroyBox
msg_map["cs_add_gold"] = M.AddGold
msg_map["cs_add_star"] = M.AddStar