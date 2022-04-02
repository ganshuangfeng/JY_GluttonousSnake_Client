---  通用任务

local basefunc = require "Game/Common/basefunc"

CommonTask = {}
local task = CommonTask

function task.gen_task_obj(config,data)

	local obj = {
		-- 所有配置
		config = config,
		-- 任务id
		id = config.id,
		-- 任务进度
		process = data.process,
		-- 当前要领的奖励等级
		task_round = data.task_round,

		-- 这个任务的创建时间
		create_time = data.create_time,

		--- 其他数据
		other_data = data.other_data,

		-- 进度等级
		lv = nil,
		-- 当前阶段的进度
		now_lv_process = nil,
		-- 当前阶段还需要多少进度
		now_lv_need_process = nil,

		task_award_get_status = data.task_award_get_status or "0",

		process_index = nil,
		msg = {},

		--- 设置是否启用
		is_open = true,
	}

	---- 处理一下other_data
	if obj.other_data then
		local other_parse_data = task_base_func.parse_activity_data(obj.other_data)
		obj.other_data = other_parse_data
	end

	---- 刷新配置
	obj.refresh_config = function(config)
		obj.config = config
		obj.init(true)
	end

	---- 初始化
	obj.init = function ( is_refresh_cfg )

		task_base_func.deal_msg(obj)

		--- 监听消息
		task_mgr.RegisterMsg( obj , obj.msg )

		if obj.reset_timecancler then
			obj.reset_timecancler()
		end

		obj.max_process , obj.max_task_round = task_base_func.get_max_process(obj.config.process_data)

		obj.lv = 1
		obj.process_index = 1

		obj.get_lv_info()

		--- 处理是否重置进程 , 这个在 get_lv_info 之后，避免处理重置时，要访问任务等级信息
		if obj.config.is_reset == 1 then
			obj.reset_task( )
		end

		---- 管他的都更新一下
		--obj.update_data(true)
	end

	--- 重置任务
	obj.reset_task = function(pre_callback , callback)
		----------------------------
		local now_time = os.time()
		local is_reset , next_refresh_time = task_base_func.get_is_reset_task_data(obj)

		if is_reset then
			if pre_callback then
				pre_callback()
			end

			obj.create_time = now_time
			obj.process = 0
			obj.lv = 1
			obj.process_index = 1
			obj.task_round = 1
			obj.task_award_get_status = "0"

			--- 处理预先的进度,重置的时候也 会加自动进度
			if obj.config.pre_add_process and obj.process < obj.config.pre_add_process then
				obj.process = obj.config.pre_add_process
				---- ps:这里可以不用立刻更新，因为这个判断的操作基本上是这个任务第一次创建的时候执行的，第一次执行，后续会更新数据的
			end
			--- 获得等级数据
		    obj.get_lv_info()

			obj.update_data()

			if callback then
				callback()
			end

		end

		---- 下一天的timeout
		obj.reset_timecancler = basefunc.cancelable_timeout( next_refresh_time * 100 , function ()
			obj.reset_task( pre_callback , callback )
		end)
	end

	---- 设置是否启用
	obj.set_is_open = function(bool)
		--print("-----------------set_is_open:",obj.id , bool and "true" or "false")
		obj.is_open = bool
		if not bool then
			task_mgr.UnRegisterMsg( obj )
			obj.msg = {}
		else
			task_base_func.deal_msg(obj)
			task_mgr.RegisterMsg( obj , obj.msg )
		end
	end

	obj.get_is_open = function()
		return obj.is_open
	end

	-- 设置不接受消息
	obj.not_accept_msg = function()
		--print("-----------------not_accept_msg:",obj.id)
		task_mgr.UnRegisterMsg( obj )
		obj.msg = {}
	end

	---- 销毁
	obj.destroy = function ()

		task_mgr.UnRegisterMsg( obj )

		if obj.reset_timecancler then
			obj.reset_timecancler()
		end

	end

	obj.update_data = function(_is_update_other_data)

		---- 同步服务器数据
		local set_task_data = { deal_type = "set_task" , 
		   						task_id = obj.id , 
								process = obj.process , 
								task_round = obj.task_round , 
								create_time = obj.create_time , 
								task_award_get_status = obj.task_award_get_status ,  
								other_data = obj.other_data and basefunc.safe_serialize(obj.other_data) , 
							}
		task_mgr.AddLocalCacheOrSysServer( set_task_data )

		--[[PUBLIC.update_task( obj.id , obj.process , obj.task_round , obj.create_time , obj.task_award_get_status , obj.time_limit )

		--- 如果要更新other_data
		if _is_update_other_data then
			PUBLIC.update_task_other_data( obj.id , obj.other_data )
		end--]]
	end

	--- 获得当前所处的lv等级,只适用于不能累积任务进度类型的
	obj.get_lv_info = function()
		local now_process = obj.process - task_base_func.get_grade_total_process(obj.config.process_data , obj.lv)
		local process_index = obj.process_index
		local now_lv_need_process = obj.config.process_data[process_index]
		assert( now_lv_need_process ~= -1 , "error now_lv_need_process ~= -1" )
		local lv = obj.lv
		while true do
			local is_add_lv = false
			---- 如果等级已经达到最大了，直接返回
			if lv >= obj.max_task_round then
				break
			end
			---- 如果等级没有达到最大，但进度已经达到这个等级了
			if now_process >= now_lv_need_process then
				is_add_lv = true
			end


			if is_add_lv then
				now_process = now_process - now_lv_need_process
				lv = lv + 1
				process_index = process_index + 1
				now_lv_need_process = obj.config.process_data[process_index]

				if not now_lv_need_process then
					now_lv_need_process = 0
					break
				elseif now_lv_need_process == -1 then
					process_index = process_index - 1
					now_lv_need_process = obj.config.process_data[process_index]
				end
			else
				break
			end
		end


		obj.lv = lv
		obj.now_lv_process = now_process
		obj.now_lv_need_process = now_lv_need_process
		obj.process_index = process_index
	end

	---- 获取一个等级的具体的奖励数据
	obj.get_lv_award_data = function(award_lv)
		local award_data = {}

		local target_award_cfg = obj.config.award_data
		local target_lv_award_cfg = nil

		if target_award_cfg[award_lv] then
			target_lv_award_cfg = basefunc.deepcopy( target_award_cfg[award_lv] )
		else
			if obj.config.process_data[#obj.config.process_data] == -1 then
				target_lv_award_cfg = basefunc.deepcopy( target_award_cfg[#target_award_cfg] )
			end
		end
		dump(target_lv_award_cfg , "xxx--------------target_lv_award_cfg:")
		if target_lv_award_cfg then

			----- 目标奖励,,随机选一个，
			if obj.config.get_award_type == "random" then
				for i = 1 , obj.config.random_award_num do
					local target_rand_award , key = basefunc.get_random_data_by_weight( target_lv_award_cfg , "weight" )
					target_lv_award_cfg[key] = nil
					award_data[#award_data + 1] = target_rand_award 
				end
			elseif obj.config.get_award_type == "nor" then
				award_data = target_lv_award_cfg
			end

			------ 处理 value 的自带随机功能
			for key,data in pairs(award_data) do
				--local awa = basefunc.deepcopy( data )
				local end_value = 0
				if data.value and type(data.value) ~= "table" then
					end_value = data.value
				elseif data.value and type(data.value) == "table" then
					if #data.value == 1 then
						end_value = data.value[1]
					elseif #data.value > 1 then
						local min_value = math.min( data.value[1],data.value[2] )
						local max_value = math.max( data.value[1],data.value[2] )
						end_value = math.random(min_value,max_value)
					end
				end
				data.value = end_value
				--target_award[#target_award + 1] = awa
				--break
			end

			------- 处理限时道具 -------------
			for key,data in pairs(award_data) do
				if data.lifetime then
					data.attribute = {valid_time= os.time() + data.lifetime }
					data.value = nil
					data.lifetime = nil
				end
			end
		end

		return award_data
	end

	----- 获得奖励 [已废弃 ， 用下面那个]
	obj.get_award = function (_award_progress_lv)
		----- 限制任务的有效期，非有效期可以领已经能领的，
		--[[local now_time = os.time()
		if obj.config.start_valid_time and obj.config.end_valid_time then
			if now_time < obj.config.start_valid_time or now_time > obj.config.end_valid_time then
				return 3808
			end
		end--]]
		local award_progress_lv = _award_progress_lv or obj.task_round

		---- 做验证
		if award_progress_lv <= 0 then
			return 1003
		end
		if award_progress_lv > obj.lv then
			return 1003
		end
		if award_progress_lv == obj.lv then
			if obj.now_lv_process < obj.now_lv_need_process then
				return 1003
			end
		end

		local award_status_vec = basefunc.decode_task_award_status( obj.task_award_get_status )
		if award_status_vec[award_progress_lv] then
			return 1003
		end

		local award_data = obj.get_lv_award_data(award_progress_lv)

		obj.task_round = obj.task_round + 1

		---- 任务领奖状态更新
		award_status_vec[award_progress_lv] = true
		obj.task_award_get_status = basefunc.encode_task_award_status( award_status_vec , "string" , true )

		obj.update_data()

		return award_data
	end

	obj.get_award_new = function (_award_progress_lv)
		----- 限制任务的有效期，非有效期可以领已经能领的，
		--[[local now_time = os.time()
		if obj.config.start_valid_time and obj.config.end_valid_time then
			if now_time < obj.config.start_valid_time or now_time > obj.config.end_valid_time then
				return 3808
			end
		end--]]
		local award_progress_lv = _award_progress_lv or obj.task_round

		---- 做验证
		if award_progress_lv <= 0 then
			return 1003
		end
		if award_progress_lv > obj.lv then
			return 1003
		end
		if award_progress_lv == obj.lv then
			if obj.now_lv_process < obj.now_lv_need_process then
				return 1003
			end
		end

		local award_status_vec = basefunc.decode_task_award_status( obj.task_award_get_status )
		if award_status_vec[award_progress_lv] then
			return 1003
		end

		
		local award_cfg = obj.config.award_id
		local tar_award_id = award_cfg[award_progress_lv]

		if tar_award_id then

			if tonumber(tar_award_id) then
				GameConfigCenter.GetCommonAward(tar_award_id , function( award_data ) 
					--- 适配协议 asset_value 
					if award_data and type(award_data) == "table" then
						for key,data in pairs(award_data) do
							data.asset_value = data.value
						end
					end
					---- 资产同步服务器
				    local data = { 
				    	deal_type = "add_asset" , 
				    	asset = award_data 
				    }
				    --处理网络缓存
				    task_mgr.AddLocalCacheOrSysServer(data)
				end)
			end

			obj.task_round = obj.task_round + 1

			---- 任务领奖状态更新
			award_status_vec[award_progress_lv] = true
			obj.task_award_get_status = basefunc.encode_task_award_status( award_status_vec , "string" , true )

			obj.update_data()

			return true
		end

		return false
	end

	----- 增加进度,返回进度是否改变
	obj.add_process = function (exp)
		if obj.process == obj.max_process then
			return false
		end

		----- 限制任务的有效期
		local now_time = os.time()
		if obj.config.start_valid_time and obj.config.end_valid_time then
			if now_time < obj.config.start_valid_time or now_time > obj.config.end_valid_time then
				return false
			end
		end

		obj.process = obj.process + exp
		if obj.process > obj.max_process then
			exp = exp - (obj.process - obj.max_process )
			obj.process = obj.max_process
		end

		if obj.process == obj.max_process then
			--PUBLIC.trigger_msg( {name = "task_process_complete" , send_filter ={ task_own_type = obj.config.own_type } } , obj.id )
		end

		obj.get_lv_info()

		--obj.update_data()

		--- 加上本地缓存或同步数据库
		task_mgr.AddLocalCacheOrSysServer( { 
			deal_type = "add_process" , 
			task_id = obj.id , 
			add_value = exp , 
		}  )

		--- 发出一个消息
		--PUBLIC.trigger_msg( {name = "on_task_progress_change" , send_filter = { task_id = obj.id } } , obj.id , exp , obj.process )

		return true
	end

	--- 任务进度清零(慎用)
	obj.clear_process = function()
		local old_process = obj.process
		obj.process = 0
		local exp = -old_process

		obj.get_lv_info()

		--obj.update_data()

		--- 加上本地缓存或同步数据库
		task_mgr.AddLocalCacheOrSysServer( { 
			deal_type = "add_process" , 
			task_id = task_id , 
			add_value = exp , 
		}  )

		--- 发出一个消息
		--PUBLIC.trigger_msg( {name = "on_task_progress_change" , send_filter = { task_id = obj.id } } , obj.id , exp , obj.process )

		return true
	end

	--- 直接刷新进度
	obj.update_process = function(now_process)
		obj.process = now_process
		obj.get_lv_info()

	end

	--- 获得当前进度，分子
	obj.get_now_process = function()
		local now_lv_process = obj.now_lv_process

		return now_lv_process
	end

	--- 获得当前等级需要的进度，分母
	obj.get_need_process = function()
		local now_lv_need_process = obj.now_lv_need_process

		return now_lv_need_process
	end

	--- 获得奖励领取状态
	obj.get_award_status = function()
		if not obj.is_open then
			return task_mgr.award_status.not_open
		end

		--- 该领取的等级大于最大领取等级，
		if obj.task_round > obj.max_task_round then
			return task_mgr.award_status.complete
		end

		--# 0-不能领取 | 1-可领取 | 2-已完成
		if obj.lv == obj.task_round then
			if obj.now_lv_process == obj.now_lv_need_process then
				return task_mgr.award_status.can_get
			end
			return task_mgr.award_status.not_can_get
		elseif obj.lv > obj.task_round then
			return task_mgr.award_status.can_get
		elseif obj.lv < obj.task_round then
			if obj.process == obj.max_process then
				return task_mgr.award_status.complete
			else
				return task_mgr.award_status.not_can_get
			end
		end
		return task_mgr.award_status.not_can_get
	end
	
	--------------------------------------------------------------- 消息处理 ↓ --------------------------------------
	---- 通关
	obj.pass_stage_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.pass_stage_msg = function(_ , _stage_num )
			dump( { c_data , _stage_num } , "<color=red>xxxx-----------task__pass_stage_msg:</color>"  )
			if (not c_data.stage_num or basefunc.compare_value( _stage_num , c_data.stage_num.condition_value , c_data.stage_num.judge_type )) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---- 击杀怪物
	obj.kill_monster_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.kill_monster_msg = function(_ , _monster_id )
			if (not c_data.monster_id or basefunc.compare_value( _monster_id , c_data.monster_id.condition_value , c_data.monster_id.judge_type )) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---- 选择英雄
	obj.select_hero_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.select_hero_msg = function(_ , _hero_id )
			if (not c_data.hero_id or basefunc.compare_value( _hero_id , c_data.hero_id.condition_value , c_data.hero_id.judge_type )) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---- 解锁英雄
	obj.unlock_hero_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.unlock_hero_msg = function(_ , _hero_id )
			if (not c_data.hero_id or basefunc.compare_value( _hero_id , c_data.hero_id.condition_value , c_data.hero_id.judge_type )) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---- 升级 英雄
	obj.upgrade_hero_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.upgrade_hero_msg = function(_ , _hero_id )
			if (not c_data.hero_id or basefunc.compare_value( _hero_id , c_data.hero_id.condition_value , c_data.hero_id.judge_type )) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---- 升级蛇头
	obj.upgrade_head_deal = function( _c_data , _process_discount )
		local c_data = _c_data or {}
		obj.msg.upgrade_head_msg = function(_ )
			
			local add = math.floor( 1 * _process_discount )
			local is_add_process = obj.add_process(add)
			
		end
	end

	---- 累积登录
	obj.login_count_deal = function( _c_data , _process_discount )

		local c_data = _c_data or {}
		obj.msg.logined = function( _ )
			obj.other_data = obj.other_data or {}
			local now_time = os.time()

			if not obj.other_data.last_login_time or not basefunc.is_same_day(now_time , obj.other_data.last_login_time,0) then
				local add = math.floor( 1 * _process_discount )
				obj.add_process(add)
				obj.other_data.last_login_time = now_time
				
				obj.update_data()
			end
		end
	end

	--- 从商城购买商品
	obj.get_goods_from_shop_deal = function( _c_data , _process_discount )

		local c_data = _c_data or {}
		obj.msg.get_goods_from_shop_msg = function( _ , _goods_id , _goods_type )
			if (not c_data.goods_id or basefunc.compare_value( _goods_id , c_data.goods_id.condition_value , c_data.goods_id.judge_type )) 
				and (not c_data.goods_type or basefunc.compare_value( _goods_type , c_data.goods_type.condition_value , c_data.goods_type.judge_type ) ) then
				local add = math.floor( 1 * _process_discount )
				local is_add_process = obj.add_process(add)
			end
		end
	end

	---解锁科技
	obj.unlock_technology_deal = function( _c_data , _process_discount )

		local c_data = _c_data or {}
		obj.msg.unlock_technology_msg = function( _ )
		
			local add = math.floor( 1 * _process_discount )
			local is_add_process = obj.add_process(add)

		end
	end

	--------------------------------------------------------------- 消息处理 ↑ --------------------------------------

	-------------
	return obj
end

return task