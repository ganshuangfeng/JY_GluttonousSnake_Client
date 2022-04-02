---- 任务的管理类 
--[[
 	负责任务系统的主体流程
--]]

local basefunc = require "Game/Common/basefunc"
require "Game/CommonPrefab/Lua/task/task_base_func"

task_mgr = {}
local C = task_mgr

---奖励状态
C.award_status = {
	not_can_get = 0,  -- 不能领奖：当前阶段进度 还未完成
	can_get = 1,      -- 可以领奖：当前阶段达成， 且还为领奖
	complete = 2,     -- 任务所有阶段均已完成，且所有奖励也 领完
	not_open = 3,     --- 任务处于关闭状态未开启
}


--- 消息分发器
C.msgDispatcher = basefunc.dispatcher.New()
--- 所有的任务的配置
C.all_task_config = {}

--- 拥有的 原始的任务数据
--[[
	key = task_id , value = { process = 进度 , task_round = 领取波次 , create_time = 创建时间 , task_award_get_status = 奖励标志 , other_data = 其他数据 }
--]]
C.task_data = {}
--- 拥有的任务对象
C.task_list = {}


--------------------------- 消息相关 ↓ --------------------------
--- 注册消息处理表
function C.RegisterMsg( obj , msgtable )
	C.msgDispatcher:register( obj , msgtable )
end

function C.UnRegisterMsg( obj )
	C.msgDispatcher:unregister( obj )
end

function C.TriggerMsg( _msgName , ... )
	C.msgDispatcher:call( _msgName , ... )
end
--------------------------- 消息相关 ↑ --------------------------

--- 获得所有的任务配置
function C.get_all_task_config()
	return C.all_task_config
end

---- 获取所有的任务的配置list
function C.get_all_task_config_list()
	local all_task_config = C.get_all_task_config()
	local task_config_list = {}
	for task_id , data in pairs(all_task_config) do
		task_config_list[#task_config_list + 1] = data
	end
	table.sort( task_config_list , function(a,b) return a.id < b.id end)
	return task_config_list
end

---- 创建一个任务对象
function C.add_one_task(task_id , data , _isSend )
	local task_config = C.get_all_task_config() 
	local config = task_config[task_id]
	--- 没得 相应的任务配置，不能创建任务
	if not config or not data then
		--error("not task config!")
		--print("error_-------------not task config! ",task_id)
		return nil , true
	end

	--- 如果已经有了这个任务id的数据，不可添加
	if C.task_list[task_id] then
		return nil , false
	end

	local task_obj = task_base_func.gen_task_obj(config,data)

	if task_obj then
		--print("add_one_task task_obj:",task_obj)

		--- 加上本地缓存或同步数据库
		if _isSend then
			C.AddLocalCacheOrSysServer( { 
				deal_type = "add_task" , 
				task_id = task_id , 
				process = data.process ,
				task_round = data.task_round ,
				create_time = data.create_time ,
				task_award_get_status = data.task_award_get_status ,
			}  )
		end

		--- 发出一个消息 
		Event.Brocast( "task_item_add" , task_obj )

		C.task_list[task_id] = task_obj
		
		---- 这个放在 赋值之后，避免，init中调用删除，无法删除。
		task_obj.init()
	end

	return task_obj , false
end

function C.delete_one_task( task_id )

	if task_id and C.task_list and C.task_list[task_id] then

		C.task_list[task_id].destroy()
		C.task_list[task_id] = nil

		---

	end

	--- 加上本地缓存或同步数据库
	C.AddLocalCacheOrSysServer( { 
		deal_type = "delete_task" , 
		task_id = task_id , 
	}  )

	Event.Brocast( "task_item_delete" ,  task_id )

end

--- 处理是否拥有任务
function C.deal_is_own_task(task_id , task_data, own_task_table)
	local now_time = os.time()

	if task_data.own_type == "normal" then
		own_task_table[task_id] = true
	end

end

--- 分发任务，根据配置决定哪些任务要挂载，再比较任务存储数据，增删
function C.distribute_task()

	local task_config = C.get_all_task_config_list() 
	
	local own_task_table = {}
	local now_time = os.time()

	for id,task_data in ipairs(task_config) do
		local task_id = task_data.id
		repeat
			--- 不启用(-1表示不载入&不清理数据)
			if task_data.enable == 0 or task_data.enable == -1 then
				break
			end

			----处理是否拥有任务
			C.deal_is_own_task(task_id , task_data, own_task_table)

		until true
	end
	--dump(own_task_table , "-----------------distribute_task----own_task_table")
	C.add_or_delete_task( own_task_table )
end

function C.add_or_delete_task( own_task_table )

	local task_change_vec = {}

	local task_table_temp = basefunc.deepcopy(own_task_table)
	local task_config = C.get_all_task_config() 
	dump( { task_table_temp , C.task_list } , "<color=red>xxx------------------add_or_delete_task</color>" )
	for task_id,data in pairs(C.task_list) do

		local isFind = task_table_temp[task_id]
        task_table_temp[task_id] = nil

		--- 没找到做移除
		if not isFind then

			C.delete_one_task( task_id , true)
			
		end
	end

	-- dump(task_table_temp , "----->>>>>add_or_delete_task , task_table_temp")

	--------- 如果还有 应该要创建的任务，
	if task_table_temp and next(task_table_temp) then

		--- 做新增
		for new_task_id,_ in pairs(task_table_temp) do
			--local ob_data = ob_task_data and ob_task_data[new_task_id]
			local data = task_base_func.get_default_task_data()

			local task_obj = C.add_one_task(new_task_id,data , true)
		end
	end

end

--------------------------------------------- 外部接口 ↓ --------------------------------------
--- 获得任务奖励 , 外部接口
function C.GetTaskAward( _task_id , _award_lv )
	--- 判断，只要有网才能调用
	if not IsConnectedServer then
		--- 弹框提示，

		return true
	end

	--- 先把本地数据同步上去
	--NetworkHelper.SendNetworkCache()

	---- 如果本地没有，就跳出
	local task_obj = C.task_list[_task_id]

	if not task_obj then
		return false
	end

	---- 发送领奖请求 ，请求成功，客户端改客户端的数据，然后设置给服务器
	Network.SendRequest("get_task_simple_award", { task_id = _task_id , award_level = _award_lv } , "领取任务奖励" , function (data)
		if data.result == 0 then
			local task_award = task_obj.get_award_new( _award_lv )
		else
			
		end
	 end)

end

--- 获取所有的 任务
function C.GetAllTask()
	return C.task_list
end


--------------------------------------------- 外部接口 ↑ --------------------------------------

--------------------------------------------------------------------------------------------------------
---[外部接口，获取服务器数据时调用] 获取 服务器 任务数据 ， [ 从服务器拿到的数据可能不完整，因为可能在本地缓存了， ]
function C.LoadTaskDataByServer( _recoverTaskData )
	Network.SendRequest("query_all_task_simple_data", { } , "获取任务数据" , function (data)
		if data.result == 0 then
			dump( data , "<color=yellow>xxx-------------LoadTaskDataByServer:</color>" )

			C.task_data = {}

			for key,data in pairs(data.task_data) do
				data.process = tonumber(data.process)

				C.task_data[data.task_id] = data
			end

			C.mergeLocalCacheTaskData( _recoverTaskData  )

			C.CreateTaskObj()

			--- 发送登录消息
    		task_mgr.TriggerMsg( "logined" )
		end
	end)
end

--- [外部接口，正常登录时调用 ] 合并 本地的缓存数据到任务数据中
--[[
	{ deal_type = "add_process" , task_id = xx , add_value = xxx },
	{ deal_type = "add_task" , task_id = xx , process = 0 , task_round = 1 , create_time = os.time(), task_award_get_status = "0" , },
	{ deal_type = "delete_task" , task_id = xx },
--]]
function C.mergeLocalCacheTaskData( _lacalCache  )
	if _lacalCache then
		dump( _lacalCache , "<color=yellow>xxx-------------mergeLocalCacheTaskData:</color>" )
		for key,data in pairs(_lacalCache) do
			if data.deal_type == "add_process" then
				if C.task_data[data.task_id] then
					C.task_data[data.task_id].process = C.task_data[data.task_id].process + tonumber(data.add_value)
				end
			elseif data.deal_type == "add_task" then
				if not C.task_data[data.task_id] then
					C.task_data[data.task_id] = { 
						task_id = data.task_id , 
						process = data.process , 
						task_round = data.task_round , 
						create_time = data.create_time , 
						task_award_get_status = data.task_award_get_status , 
					}
				end
			elseif data.deal_type == "delete_task" then
				if C.task_data[data.task_id] then
					C.task_data[data.task_id] = nil
				end
			elseif data.deal_type == "set_task" then
				if C.task_data[data.task_id] then
					C.task_data[data.task_id] = { 
						task_id = data.task_id , 
						process = data.process , 
						task_round = data.task_round , 
						create_time = data.create_time , 
						task_award_get_status = data.task_award_get_status , 
					}
				end
			end

		end
	end

end

---- 给外部接口，添加本地缓存 或 有网 同步服务器
function C.AddLocalCacheOrSysServer( data )
	NetworkHelper.HandleNetworkCache({ task = data })


	if data.deal_type == "add_process" or data.deal_type == "set_task" then
		Event.Brocast( "task_item_update" , C.task_list[ data.task_id ] )
	end

end

--- 创建任务对象，通过数据
function C.CreateTaskObjByData(_data)

	if _data and type(_data) == "table" then
		for task_id,d in pairs(_data) do
			if not C.task_list[task_id] then

				local task_obj , is_delete_ob = C.add_one_task(task_id,d)
				--- 如果没有创建 历史 任务对象，删除
			    if is_delete_ob then
			        C.delete_one_task( task_id )
			    end
			end
		end
	end

	dump( C.task_list , "xxx------------CreateTaskObjByData__task_list:" )
end

--- 根据任务数据 创建任务对象 ，[ 这个函数得等到本地缓存数据和 服务器数据合并之后才能调用 ]
function C.CreateTaskObj()
	dump( C.task_data  , "<color=yellow>xxx-------------CreateTaskObj:</color>" )

	--- 先根据数据创建对象，因为要调用 init ，这里面可能有 要删除的对象
	C.CreateTaskObjByData( C.task_data )
	
	C.distribute_task()

	dump( C.task_list  , "<color=yellow>xxx-------------CreateTaskObj 222:</color>" )
end


function C.Init()
	--- 载入配置
	local task_config = ExtRequire("Game.CommonPrefab.Lua.task_server_new")
	C.all_task_config = task_base_func.load_task_server_cfg_new( task_config )
	dump( C.all_task_config , "xxx-----C.all_task_config:" )

end
