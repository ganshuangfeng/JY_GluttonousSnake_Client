local basefunc = require "Game/Common/basefunc"
ExtRequire("Game.CommonPrefab.Lua.BoidsMoveDriver")
ExtRequire("Game.CommonPrefab.Lua.snake_move_driver")

SnakeHeadMoveAI = {}
local C = SnakeHeadMoveAI

C.priority_pos_data = {}   --- 特殊优先级的数据
C.running_priority_pos_data = nil
C.priority_pos_change_time = 10    --- 优先级点长时间未到，自动切换
C.priority_pos_change_count = 0

C.time_delay_range = { min = 3 , max = 5 }
C.time_delay = 0
C.time_delay_count = 0

C.boss_time_delay_range = { min = 1 , max = 3 }

C.logic_model_type = {
	fix_pos = 1,
	priority = 2,
	auto  = 3 ,
}

---移动模式
C.logic_model = C.logic_model_type.auto   --- fix_pos 固定点 , priority  优先点 ，auto 自动选 

---- 固定点模式
C.fix_move_pos_change_time = 10
C.fix_move_data = nil
C.fix_move_index = 0
C.fix_move_index_dir = 1


---- 位置测试点的 对象
C.debug_pos_obj = {}

function C.FrameUpdate(time_elapsed)
	
	--print("<color=red>xxxx-------FrameUpdate 11</color>" , C.time_delay_count , C.time_delay , time_elapsed)
	if C.logic_model == C.logic_model_type.fix_pos then

		C.time_delay_count = C.time_delay_count + time_elapsed
		if C.time_delay_count >= C.time_delay then
			C.deal_fix_move_logic()
			C.time_delay_count = 0
		end
	elseif C.logic_model == C.logic_model_type.priority then
		--- 先处理优先级的点
		C.deal_priority_pos(time_elapsed)

	elseif C.logic_model == C.logic_model_type.auto then
		--print("<color=red>xxxx-------FrameUpdate 22</color>" , C.time_delay_count , C.time_delay , time_elapsed , C.is_arriving_priority_pos)
		
		C.time_delay_count = C.time_delay_count + time_elapsed
		if C.time_delay_count >= C.time_delay then
			C.reset_auto_module_time_delay()
			C.time_delay_count = 0

			C.deal_find_path_logic()
		end
		
	end


end

local lister
local function AddLister()
    lister={}
    lister["hero_vehicle_finish_step"] = C.on_hero_vehicle_finish_step

    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function C.Init()
	AddLister()
end

function C.Exit()
	RemoveLister()
end



---- 找到最密的点 , 把全部敌人点，想成一个群体里面，找这个群体里面的最稠密点
function C.find_best_dense_pos()
	print("<color=green>xxxx-------find_best_dense_pos</color>")
	local all_monster = GameInfoCenter.GetAllMonsters()


	local dis_cache = {}
	local total_dis_vec = {}

	for key,data in pairs(all_monster) do
		local total_dis_data = { id = key , total_dis = 0 }

		for _k,_v in pairs(all_monster) do
			if key ~= _k then
				local tar_cache_key = math.min(key,_k) .."_".. math.max(key,_k) --2^key + 2^_k 
				if not dis_cache[ tar_cache_key ] then
					local dis = tls.pGetDistanceSqu( data.transform.position , _v.transform.position )
					dis_cache[ tar_cache_key ] = dis
				end

				total_dis_data.total_dis = total_dis_data.total_dis + dis_cache[ tar_cache_key ]
			end
		end

		total_dis_vec[#total_dis_vec + 1] = total_dis_data
	end

	table.sort( total_dis_vec , function(a , b) 
		return a.total_dis < b.total_dis
	end)

	if #total_dis_vec >= 1 then
		return all_monster[ total_dis_vec[1].id ].transform.position

	end
	return nil
end

---- 第二种找密集点，把相互距离小于n的化为同一个群体，会有多个群体，找数量最多的群体的密集点
function C.find_best_dense_pos_by_group()
	--- key 是组id , value = {}
	local group_vec = {}
	---

	local all_monster = GameInfoCenter.GetAllMonsters()

	----距离的缓存
	local dis_cache = {}
	--- 距离超过这个，就在不同组中
	local group_dis = 10

	--- 遍历所有的敌人
	for key,data in pairs(all_monster) do
		local find_group_key = nil
		--- 再遍历，找到自己应该在的组(某个组里面有距离自己近的敌人)
		for group_key , group_data in pairs(group_vec) do
			for index , monster_key in pairs(group_data) do
				--local tar_cache_key = 2^key + 2^monster_key 
				local tar_cache_key = math.min(key,monster_key) .."_".. math.max(key,monster_key) --2^key + 2^_k 
				if not dis_cache[ tar_cache_key ] then
					local dis = tls.pGetDistanceSqu( data.transform.position , all_monster[monster_key].transform.position )
					dis_cache[ tar_cache_key ] = dis
				end
				if dis_cache[ tar_cache_key ] <= group_dis then
					find_group_key = group_key
					break
				end
			end
			if find_group_key then
				break
			end
		end

		if not find_group_key then
			find_group_key = #group_vec + 1
		end

		group_vec[find_group_key] = group_vec[find_group_key] or {}
		local tar_group = group_vec[find_group_key]
		tar_group[#tar_group + 1] = key
	end

	table.sort( group_vec , function( a,b ) 
		return #a > #b
	end)
	-- dump(group_vec , "xxx--------------------group_vec:")
	if next(group_vec) then

		local total_dis_vec = {}

		local max_num_group = group_vec[1]
		for key , m_key in pairs(max_num_group) do
			local total_dis_data = { id = m_key , total_dis = 0 }

			for _k,_m_key in pairs(max_num_group) do
				if m_key ~= _m_key then
					--local tar_cache_key = 2^m_key + 2^_m_key 
					local tar_cache_key = math.min(m_key,_m_key) .."_".. math.max(m_key,_m_key) --2^key + 2^_k 
					if not dis_cache[ tar_cache_key ] then
						--error("xxx------------dis_cache error ," .. tar_cache_key )
						local dis = tls.pGetDistanceSqu( all_monster[m_key].transform.position , all_monster[_m_key].transform.position )
						dis_cache[ tar_cache_key ] = dis
					end

					total_dis_data.total_dis = total_dis_data.total_dis + dis_cache[ tar_cache_key ]
				end
			end

			total_dis_vec[#total_dis_vec + 1] = total_dis_data
		end

		table.sort( total_dis_vec , function(a,b)
			return a.total_dis < b.total_dis
		end )

		if #total_dis_vec >= 1 then
			return all_monster[ total_dis_vec[1].id ].transform.position
		end

	end
	
	return nil

end

---- 找最近的敌人
function C.find_min_dis_enemy_pos()
	local all_monster = GameInfoCenter.GetAllMonsters()

	--- 蛇头的位置
	local snake_head_pos = {x = 0 , y = 0}

	local min_dis = nil
	local min_enemy_pos = nil

	for key,data in pairs(all_monster) do
		local dis = tls.pGetDistanceSqu( data.transform.position , snake_head_pos )
	
		if not min_dis or dis < min_dis then
			min_dis = dis
			min_enemy_pos = data.transform.position
		end
	end

	
	return min_enemy_pos
end

function C.on_hero_vehicle_finish_step()
	
	if C.logic_model == C.logic_model_type.fix_pos then
		C.deal_fix_move_logic() 
		C.time_delay_count = 0
	elseif C.logic_model == C.logic_model_type.priority then
		if C.running_priority_pos_data and C.running_priority_pos_data.move_type == "move_to" then
			C.running_priority_pos_data = nil

		end
	end

end

--- 处理固定点移动逻辑
function C.deal_fix_move_logic()
	local tar_pos = nil
	if C.fix_move_data and next(C.fix_move_data) then
		--- 只有一个的时候有点问题，影响不大
		if not C.fix_move_data[C.fix_move_index+C.fix_move_index_dir] then
			C.fix_move_index_dir = -C.fix_move_index_dir
		end

		C.fix_move_index = C.fix_move_index + C.fix_move_index_dir

		tar_pos = C.fix_move_data[C.fix_move_index]
	end

	if tar_pos then

		Event.Brocast( "snake_move_target_pos", tar_pos )
	end

end

function C.deal_find_path_logic()
	--local tar_pos = nil
	--if C.move_data and next(C.move_data) then
	--	tar_pos = C.move_data[1]
	--	table.remove( C.move_data  ,1 )
	--end

	---- 找优先的位置 
	-- local tar_pos = C.find_priority_pos()


	--local tar_pos = C.find_best_dense_pos()

	local tar_pos = nil
	---- 是否有boss
	local boss_monster = GameInfoCenter.GetMonsterBossObj()
	if boss_monster then
		local boss_pos = {x = boss_monster.transform.position.x , y = boss_monster.transform.position.y }
		tar_pos = boss_pos

		--[[local rand_x = math.random(2,5)
		local rand_y = math.random(2,5)

		local tar_x = boss_pos.x + (math.random() < 0.5 and rand_x or -rand_x)
		local tar_y = boss_pos.y + (math.random() < 0.5 and rand_y or -rand_y)

		tar_pos = { x = tar_x , y = tar_y , z = 0 }--]]

		Event.Brocast( "snake_circle_move_target_pos", tar_pos , 5 )
		C.reset_auto_module_boss_time_delay()

		C.add_debug_obj( tar_pos )
		return
	end

	----- 找密集点
	if not tar_pos then
		tar_pos = C.find_best_dense_pos_by_group()
	end

	if tar_pos then
		-- print( string.format("<color=blue>xxxxxxx-----------------snake_move_target_pos:%s , %s</color>" , tar_pos.x , tar_pos.y ) )

		C.add_debug_obj( tar_pos )

		Event.Brocast( "snake_move_target_pos", tar_pos )

	end
end

--- 处理优先级点的逻辑
function C.deal_priority_pos(_dt)
	if not C.running_priority_pos_data then
		if next(C.priority_pos_data) then
			--- 换了一个新点，得把时间清一下
			C.priority_pos_change_count = 0

			local tar_data = table.remove( C.priority_pos_data , 1 )

			-- dump( tar_data , "xxxx--------------------deal_priority_pos" )
			C.running_priority_pos_data = tar_data

			if tar_data.move_type == "move_to" then
				Event.Brocast( "snake_move_target_pos", tar_data.pos )

			elseif tar_data.move_type == "circle" then
				Event.Brocast( "snake_circle_move_target_pos", tar_data.pos , tar_data.radius )
			end
			C.add_debug_obj( tar_data.pos , "HeroBase2D" )
		else
			--- 没有正在运行的优先点，也没有后面加的优先点
			C.logic_model = C.logic_model_type.auto
		end
	else
		C.priority_pos_change_count = C.priority_pos_change_count + _dt
		if C.priority_pos_change_count > C.priority_pos_change_time then
			C.stop_priority_pos_move()
			C.priority_pos_change_count = 0
		end
	end
end

--- 设置优先级点
function C.set_priority_pos(_pos , _move_type , _other_data )
	C.priority_pos_data[#C.priority_pos_data + 1] = { pos = _pos , move_type = ((type(_move_type) == "string") and _move_type or "move_to") , other_data = _other_data }

	C.logic_model = C.logic_model_type.priority
end

--- 停止当前的优先级运动 ， 圆形围绕可能是外部取消
function C.stop_priority_pos_move()
	if C.running_priority_pos_data then
		C.running_priority_pos_data = nil

	end
end

function C.start_fix_move_data()
	C.fix_move_data = MapManager.GetMapPathData()

	C.time_delay = C.fix_move_pos_change_time
	C.time_delay_count = C.time_delay
end

function C.add_debug_obj( _tar_pos , _obj_perfab )
	if true then
		return true
	end

	local parent = GameObject.Find("3DNode/map/hero_node").transform
	local obj = NewObject( _obj_perfab or "HeroBase" , parent) 
	obj.name = "target_pos"
	obj.transform.position = _tar_pos

	if next(C.debug_pos_obj) then
		Destroy(C.debug_pos_obj[1])
		table.remove(C.debug_pos_obj , 1)
	end

	C.debug_pos_obj[#C.debug_pos_obj + 1] = obj
end

function C.delete_all_debug_obj()
	if C.debug_pos_obj and type(C.debug_pos_obj) == "table" then
		for key,obj in pairs(C.debug_pos_obj) do
			Destroy(obj)
		end
	end
end

----重置 自动模式 时间延迟
function C.reset_auto_module_time_delay()
	C.time_delay = math.random( C.time_delay_range.min , C.time_delay_range.max )
end

function C.reset_auto_module_boss_time_delay()
	C.time_delay = math.random( C.boss_time_delay_range.min , C.boss_time_delay_range.max )
end

function C.Start()

	C.priority_pos_data = {}
	C.running_priority_pos_data = nil
	C.delete_all_debug_obj()


	if C.logic_model == C.logic_model_type.fix_pos then
		C.start_fix_move_data()
	elseif C.logic_model == C.logic_model_type.auto then
		C.reset_auto_module_time_delay()
		C.time_delay_count = C.time_delay-2
	end

end



