--
-- Author: wss
-- Date: 2019/4/29
-- Time: 15:11
-- 说明：任务  可能需要的一些通用函数

local basefunc = require "Game/Common/basefunc"

local loadstring = rawget(_G, "loadstring") or load

require "Game.CommonPrefab.Lua.task.CommonTask"

task_base_func = {}
local C = task_base_func

--- 处理任务配置 [旧版配置 已废弃]
function C.load_task_server_cfg(raw_config)

	local main_config = {}

	local aws = {}
	for i,ad in ipairs(raw_config.award_data) do

		aws[ad.award_id] = aws[ad.award_id] or {}
		local len = #aws[ad.award_id]+1

		local target_asset_type = ad.asset_type
		---- 处理限时道具
		local str_split_vec = basefunc.string.split(ad.asset_type, "_")

		local obj_lifetime = nil
		if str_split_vec and type(str_split_vec) == "table" and next(str_split_vec) then
			if str_split_vec[1] == "obj" then
				obj_lifetime = 86400
				if tonumber(str_split_vec[#str_split_vec]) then
					target_asset_type = ""
					for i=1,#str_split_vec - 1 do
						target_asset_type = target_asset_type .. str_split_vec[i]
						if i ~= #str_split_vec - 1 then
							target_asset_type = target_asset_type .. "_"
						end
					end

					obj_lifetime = tonumber( str_split_vec[#str_split_vec] )
				end
			end
		end

		aws[ad.award_id][len] = {
			award_name = ad.award_name,
			asset_type = target_asset_type,
			value = ad.asset_count,
			weight = ad.get_weight or 1,
			broadcast_content = ad.broadcast_content,
			special_broadcast = ad.special_broadcast,
			is_send_email = ad.is_send_email,
		}

		if obj_lifetime then
			aws[ad.award_id][len].value = nil
			aws[ad.award_id][len].lifetime = obj_lifetime
		end

	end

	----- 条件表
	local condition = {}
	for id,data in pairs(raw_config.condition) do
		condition[ data.condition_id ] = condition[ data.condition_id ] or {}
		local cond = condition[ data.condition_id ]
		cond[data.condition_name] = { condition_value = data.condition_value , judge_type = data.judge_type }
	end


	--- 进度来源表
	local source = {}
	if raw_config.source then
		for key,data in pairs(raw_config.source) do
			--- 如果有来源类型
			if data.source_type then
				--
				source[ data.source_id ] = source[ data.source_id ] or {}
				local tar_data = source[ data.source_id ]

				---- 防配置出错
				if data.process_discount then
					if data.process_discount > 1 then
						data.process_discount = 1
					end
					if data.process_discount < 0 then
						data.process_discount = 0
					end
				end

				tar_data[#tar_data + 1] = {
					source_type = data.source_type ,
					condition_data = basefunc.deepcopy( condition[ data.condition_id ] or {} ) ,
					process_discount = data.process_discount or 1,
				}
			end
		end
	end

	for id,td in pairs(raw_config.task) do

		main_config[id]=td

		for i,cd in ipairs(raw_config.process_data) do
			if td.process_id == cd.process_id then
				if not cd.process then
					cd.process = 0
				end

				if type(cd.process) == "number" then
					cd.process = { cd.process }
				end

				--main_config[id].condition_type = cd.condition_type
				main_config[id].source_data = cd.source_id and basefunc.deepcopy( source[ cd.source_id ] or {} ) or {}
				--main_config[id].condition_data = basefunc.deepcopy( condition[ cd.condition_id ] or {} )
				main_config[id].get_award_type = cd.get_award_type or "nor"
				main_config[id].process_data=cd.process
				main_config[id].pre_add_process = cd.pre_add_process
				main_config[id].award_data={}

				main_config[id].is_auto_get_award = cd.is_auto_get_award

				---- 如果是一个数字就转成数组
				if not cd.awards then
					cd.awards = {}
				elseif type(cd.awards) == "number" then
					cd.awards = { cd.awards }
				end
				for i,ai in ipairs(cd.awards) do
					main_config[id].award_data[i] = basefunc.deepcopy( aws[ai] )
				end

                -- 奖励条件表(by lyx 2021-7-29)
                if type(cd.awards_condition_id) == "number" then
                    if cd.awards_condition_id > 0 then
                        main_config[id].awards_condition = basefunc.deepcopy( condition[cd.awards_condition_id] or {} )
                        main_config[id].awards_condition.use_same=true -- 都用相同的条件
                    end
                elseif type(cd.awards_condition_id) == "table" then
                    if #cd.awards_condition_id > 0 then
                        main_config[id].awards_condition = {}
                        for i,ai in ipairs(cd.awards_condition_id) do
                            main_config[id].awards_condition[i] = basefunc.deepcopy( condition[ai] or {} )
                        end
                    end
                end
			end
		end

		main_config[id].process_id=nil

	end

	return main_config
end

--- 替换配置 值
function C.replace_config_value( t , k , value , orgData )
	if type(value) == "string" then
		if string.find( value , "^#(.*)" ) then
			local s,e , key = string.find( value , "^#(.*)" )

			if orgData and type(orgData) == "table" and orgData[key] then
				if t and type(t) == "table" and k then
					t[k] = orgData[key]
				end
			elseif orgData and type(orgData) == "table" and not orgData[key] then
				t[k] = nil
			end
			
		end
	elseif type(value) == "table" then
		for key,data in pairs(value) do
			C.replace_config_value( value , key , data , orgData )

			--- 如果条件的 字段缺少一个，则整个上表字段不要了
			if type(data) == "table" and ( (data.condition_value and not data.judge_type) or (not data.condition_value and data.judge_type) ) then
				value[key] = nil
			end 

		end
		return value
	end 

end

---- 处理 新版的 任务配置 [ 新版配置 ]
function C.load_task_server_cfg_new(raw_config)
	local main_config = {}

	---- condition id 对应 来源的 map
	local condition_id_2_source_map = {
		[101] = { --- 通过某关
			source_type = "pass_stage" , 
			process_discount = 1 ,
			condition_data = { 
				stage_num = {
					condition_value = "#P1" , 
					judge_type = 2 ,
				} 
			} , 
		},
		[102] = { --- 击杀任意怪
			source_type = "kill_monster" , 
			process_discount = 1 ,
			condition_data = { 
				
			} , 
		},
		[103] = { --- 击杀任意boss
			source_type = "kill_monster" , 
			process_discount = 1 ,
			condition_data = { 
				monster_id = {
					condition_value = { 101 , 102 , 103 , 104 , 105 , 106 , 107 , 108 } , 
					judge_type = 2 ,
				} 
			} , 
		},
		[105] = { --- 解锁任意英雄
			source_type = "unlock_hero" , 
			process_discount = 1 ,
			condition_data = { 
			} , 
		},
		[106] = { --- 升级某个英雄
			source_type = "upgrade_hero" , 
			process_discount = 1 ,
			condition_data = { 
				hero_id = {
					condition_value = "#P1" , 
					judge_type = 2 ,
				} 
			} , 
		},
		[107] = { --- 升级 任意头部
			source_type = "upgrade_head" , 
			process_discount = 1 ,
			condition_data = { 
			} , 
		},
		[108] = { --- 累积登录
			source_type = "login_count" , 
			process_discount = 1 ,
			condition_data = { 
			} , 
		},
		[110] = { --- 在商店中领取钻石1次
			source_type = "get_goods_from_shop" , 
			process_discount = 1 ,
			condition_data = { 
				goods_id = {
					condition_value = 10102 , 
					judge_type = 2 ,
				} 
			} , 
		},
		[111] = { --- 在商店中领取英雄宝箱1次
			source_type = "get_goods_from_shop" , 
			process_discount = 1 ,
			condition_data = { 
				goods_id = {
					condition_value = 10201 , 
					judge_type = 2 ,
				} 
			} , 
		},
		[113] = { --- 在商店中购买每日精选商品1次
			source_type = "get_goods_from_shop" , 
			process_discount = 1 ,
			condition_data = { 
				goods_type = {
					condition_value = 3 , 
					judge_type = 2 ,
				} 
			} , 
		},
		[114] = { --- 解锁科技1次
			source_type = "unlock_technology" , 
			process_discount = 1 ,
			condition_data = { 
			} , 
		},
	}

	--- 先处理 奖励item
	--[[local awards = {}
	if raw_config.award_item then
		for key,data in pairs(raw_config.award_item) do
			awards[data.award_id] = awards[data.award_id] or {}

			--dump( { data.asset_id , AssetItemConfig } , "xxx---------deal__award_item" )

			local tar_data = {
				award_name = data.award_name,
				asset_type = AssetItemConfig[data.asset_id].asset_type ,
				value = data.asset_count,
				weight = data.P1 or 1,
				-- broadcast_content = data.broadcast_content,
				-- special_broadcast = data.special_broadcast,
				-- is_send_email = data.is_send_email,
			}

			table.insert( awards[data.award_id] , tar_data )
		end
	end--]]

	--- 处理主表
	for id,data in pairs(raw_config.task) do
		--------- 转成自己的表的处理
		local tar_data = {
			id = data.id ,
			enable = data.enable ,
			name = data.desc ,
			desc = data.desc ,
			own_type = "normal" , 
			task_enum = "common" ,
			is_reset = 0 ,
			reset_delay = 1 ,
			start_valid_time = 1609430400 ,   --- 2021年1月1日 0点 , 周五
			end_valid_time = 4102416000 ,     --- 2100年1月1日 0点

			
			relation = data.relation ,

			award_data = data.award,
			P1 = data.P1,
			P2 = data.P2,
			P3 = data.P3,
			gotoui = data.gotoui
		}

		--- 处理 进度
		if type(data.process) == "table" then
			local tar_process_vec = {}
			for i = 1 , #data.process do
				if i == 1 then
					tar_process_vec[i] = data.process[i]
				else
					tar_process_vec[i] = data.process[i] - data.process[i-1] 
				end
			end

			tar_data.process_data = tar_process_vec
		else
			tar_data.process_data = { data.process } 
		end
		
		--- 处理奖励
		if type(data.award) ~= "table" then
			data.award = { data.award }
		end
		tar_data.award_id = data.award 

		--- 处理重置
		if type(data.reset) == "number" then
			if data.reset == 1 then  
				--- 每日0点重置
				tar_data.is_reset = 1 
				tar_data.reset_delay = 1 
			elseif data.reset == 2 then
				--- 每周1 , 0点重置
				tar_data.is_reset = 1 
				tar_data.reset_delay = 7 
				tar_data.start_valid_time = 1609689600    --- 2021年1月4日 0点 , 周1
			end
		elseif type(data.reset) == "table" then
			if #data.reset >= 2 and data.reset[1] == 3 then
				local reset_day = data.reset[2]
				tar_data.is_reset = 1 
				tar_data.reset_delay = reset_day 
				tar_data.start_valid_time = 1609689600     --- 2021年1月4日 0点 , 周1
			end
		end

		----P3作为重置的时分秒
		if data.P3 and type(data.P3) == "number" then
			tar_data.start_valid_time = tar_data.start_valid_time + data.P3
		end

		---------- 处理 新表的数据
		tar_data.task_type = data.task_type

		--- 来源数据
		tar_data.source_data = {
			[1] = C.replace_config_value( nil , nil , basefunc.deepcopy( condition_id_2_source_map[data.condition] ) , data ) 
		}
		--- 得奖方式
		--tar_data.get_award_type = ( raw_config.award[ data.award ].award_type == 2 ) and "random" or "nor"
		--- 随机方式获得几个
		--tar_data.random_award_num = raw_config.award[ data.award ].P1 or 1

		--- 奖励 , 只有一个阶段
		--if data.award and awards[ data.award ] then
		--	tar_data.award_data = {}
		--	tar_data.award_data = { [1] = awards[ data.award ] }
		--end
		--- 奖励预览 , { [asset_type] = { value = xx } , [asset_type2] = { value = xx2 } }
		local award_overview = {}
		if data.award_overview and type(data.award_overview) == "string" then
			for asset_id , value in string.gmatch( data.award_overview , "(%d+)%*(%d+)" ) do
				local asset_id = tonumber(asset_id)
				local value = tonumber(value)

				award_overview[ AssetItemConfig[asset_id].asset_type ] = { value = value }
			end
		end

		main_config[id] = tar_data
	end

	dump( main_config , "xxx-----------------main_config" )
	return main_config
end

function C.gen_task_obj(config,data)
	if  config.task_enum == "common" then
		return CommonTask.gen_task_obj( config , data )
	else
		----- 走默认的,用task_enum作为文件名，来加载
		--[[local module_name = "task." .. config.task_enum
		local ok,task_protect = pcall( require , module_name)
		if ok and task_protect and task_protect.gen_task_obj then
			return task_protect.gen_task_obj(config,data)
		end--]]
		
		local className = config.task_enum

		local module_name = "Game.CommonPrefab.Lua.task." .. config.task_enum
		local ok = pcall( require , module_name)
		if not ok then
			error("xxxx------------ task module_name no file !")
		end

		local tarTaskClass = _G[className]
		if tarTaskClass and tarTaskClass.gen_task_obj then
			return tarTaskClass.gen_task_obj( config , data )
		end
	end

	return nil
end

----- 获取一个任务的数据
function C.get_one_task_data(task_obj , target_value)
	target_value.id = task_obj.id
	target_value.now_total_process = tostring( task_obj.process )
	target_value.now_lv = task_obj.lv
	target_value.now_process = tostring( task_obj.get_now_process() )
	target_value.need_process = tostring( task_obj.get_need_process() )
	target_value.task_round = task_obj.task_round 
	target_value.award_status = task_obj.get_award_status()
	target_value.award_get_status = task_obj.task_award_get_status or "0"
	target_value.task_type = task_obj.config and task_obj.config.own_type or nil

	--target_value.task_condition_type = task_obj.config and task_obj.config.condition_type or nil

	target_value.create_time = tostring(task_obj.create_time)
	target_value.over_time = tostring( task_obj.time_limit )

	target_value.start_valid_time = tostring( task_obj.config and task_obj.config.start_valid_time or nil )
	target_value.end_valid_time = tostring( task_obj.config and task_obj.config.end_valid_time or nil )

	if task_obj.other_data and task_obj.other_data.fix_award_data and type(task_obj.other_data.fix_award_data) == "table" and next(task_obj.other_data.fix_award_data) then
		for key,data in pairs(task_obj.other_data.fix_award_data) do
			target_value.fix_award_data = target_value.fix_award_data or {}
			target_value.fix_award_data[key] = target_value.fix_award_data[key] or {}
			local target_vec = target_value.fix_award_data[key]
			target_vec.award_data = target_vec.award_data or {}

			for _,award_data in pairs(data) do
				target_vec.award_data[ #target_vec.award_data + 1 ] = { asset_type = award_data.asset_type , asset_value = award_data.value }
			end
			
		end
	end

	if task_obj.get_other_data_str then
		target_value.other_data_str = task_obj.get_other_data_str()
	end

	

	return target_value
end

---- 获得一个默认的任务的初始数据
function C.get_default_task_data()
	return {
				process = 0,
				task_round = 1,
				create_time = os.time(),
				task_award_get_status = "0",
			}
end

---- 获得任务的 重置信息
function C.get_is_reset_task_data(task_obj)

	local is_need_reset = false
	local next_refresh_time = nil
	----------------------------
	local now_time = os.time()
	--- 任务开始的时间
	local start_valid_time = task_obj.config and task_obj.config.start_valid_time or 0
	--- 每隔多少天重置
	local reset_delay = task_obj.config and task_obj.config.reset_delay or 1

	--- 当前时间距离开始时间的时间
	local dif_time = now_time - start_valid_time
	--- 距离开始时间已经过了多少天
	local dif_day = math.floor( dif_time / 86400 )
	--- 到下一个刷新点还需要的时间
	next_refresh_time = (reset_delay - (dif_day % reset_delay))*86400 - dif_time % 86400

	-------------
	local create_dif_time = task_obj.create_time - start_valid_time
	local create_dif_day = math.floor( create_dif_time / 86400 )

	
	if math.floor(dif_day / reset_delay) ~= math.floor(create_dif_day / reset_delay) then
		is_need_reset = true
	end

	return is_need_reset , next_refresh_time

end

--- 获得最大的进程值
function C.get_max_process(process_data)
	local max_process = 0
	local max_task_round = 0   --- 最大的领取等级
	if process_data and type(process_data) == "table" then
		for key,process_value in pairs(process_data) do
			if process_value ~= -1 then
				max_process = max_process + process_value
				max_task_round = max_task_round + 1
			else
				max_process = 99999999999
				max_task_round = 99999999
				break
			end
		end
	end
	return max_process , max_task_round
end

--- 获得达到一个等级所需的总共进度
function C.get_grade_total_process(process_data,grade)
	local total_process = 0
	
	if not process_data or not grade or type(process_data) ~= "table" or type(grade) ~= "number" then
		return total_process
	end

	
	local index = 0
	local process_index = 1
	while true do
		index = index + 1
		if index >= grade then
			break
		end

		local lv_process = process_data[process_index]
		if not lv_process then
			break
		elseif lv_process == -1 then
			process_index = process_index - 1
			lv_process = process_data[process_index]
		end

		process_index = process_index + 1

		total_process = total_process + lv_process

	end

	return total_process
end

function C.parse_activity_data(_data)
	if not _data then
		return nil
	end

	local code = "return " .. _data
	local ok, ret = xpcall(function ()
		local data = loadstring(code)()
		if type(data) ~= 'table' then
			data = {}
			print("parse_activity_data error : {}")
		end
		return data
	end
	,function (err)
		print("parse_activity_data error : ".._data)
		print(err)
	end)

	if not ok then
		ret = {}
	end

	return ret or {},ok
end

function C.deal_reset_process( obj , pre_callback , callback )
	obj.reset_task(pre_callback , callback)
end

---- 处理 任务的来源对应的消息
function C.deal_msg(obj)

	if obj.config and obj.config.source_data and type(obj.config.source_data) == "table" then
		for key,data in pairs(obj.config.source_data) do
			--- 默认的处理、
			local deal_func_name = data.source_type .. "_deal"
			if obj[ deal_func_name ] and type(obj[ deal_func_name ]) == "function" then
				obj[ deal_func_name ]( data.condition_data , data.process_discount )
			end
		end
	end

end


return C