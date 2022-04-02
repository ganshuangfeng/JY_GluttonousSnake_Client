
local fztf_lib = {}

--[[
	game_level = 1,--游戏关卡
	turret = { --炮台数据 
		{
			heroId = 1,
			location = 0,
			type = 1,
			level = 1,
			star = 1,
		}
	},
	asset = { -- 资产
		prop_jin_bi = 100, --金币
	}
	turret_base_level = 1, --炮塔基础等级
]]
function fztf_lib.init(_data,_config)
	fztf_lib.data = _data
	fztf_lib.config = _config
	fztf_lib.ret_tmp = {result = 0}
	fztf_lib.data.skill_jb = 0.5

	fztf_lib.turret_max_id = 1
	fztf_lib.turret_id2data = {}
	for i,v in ipairs(fztf_lib.data.turret) do
		fztf_lib.turret_id2data[v.heroId] = v
		if fztf_lib.turret_max_id < v.heroId then
			fztf_lib.turret_max_id = v.heroId
		end
	end
	return fztf_lib
end

-- _time 为时间戳
function fztf_lib.random(_time,...)

    local rt = _G["random_time"]

    if rt ~= _time then
        _G["random_time"] = _time
        _G["random_index"] = 0
    end

    local ri = _G["random_index"] + 1
    if ri > 1000 then
        ri = 1
    end
    _G["random_index"] = ri


    local next = _time % 10000

    for i=1,ri do

        next = (next * 78416791 + 3624157) % 84397167

    end
    
    local r = next % (132767)

    -- 处理参数逻辑
    local arg = {...}

    if #arg == 0 then

        r = (r+1) / (132767+1)

    elseif #arg == 1 then

        if arg[1] < 0 or math.floor(arg[1]) ~= arg[1] then
            error("random function arguments error")
        end

        if arg[1] < 2 then

            return arg[1]

        else

            r = (r % arg[1]) + 1

        end

    elseif #arg == 2 then

        if arg[1] < 0 
            or arg[2] < arg[1]
            or math.floor(arg[1]) ~= arg[1] 
            or math.floor(arg[2]) ~= arg[2] then
            error("random function arguments error")
        end

        if arg[1] == arg[2] then
            return arg[1]
        end

        r = r % (arg[2] - arg[1] + 1) + arg[1] 

    else
        error("random function not supported")
    end

    return r
end

function fztf_lib.buy_turret(_time,_t)

	local tbl = fztf_lib.data.turret_base_level

	local price = 0-- 100 + (tbl-1)*10

	-- if fztf_lib.data.asset.prop_jin_bi < price then
	-- 	fztf_lib.ret_tmp.result = 1012
	-- 	return fztf_lib.ret_tmp
	-- end

	local id = fztf_lib.turret_max_id + 1
	fztf_lib.turret_max_id = id

	local type_cfg = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
	local tr = fztf_lib.random(_time, #type_cfg)

	local td = {
		heroId = id,
		location = #fztf_lib.data.turret+1,
		type = _t or type_cfg[tr],
		level = tbl,
		-- star = --ClientAndSystemManager.GetStarByType(_t or type_cfg[tr]),
	}
	table.insert(fztf_lib.data.turret,td)
	fztf_lib.data.asset.prop_jin_bi = fztf_lib.data.asset.prop_jin_bi - price

	fztf_lib.turret_id2data[id] = fztf_lib.data.turret[#fztf_lib.data.turret]

	return {data=td,price=price,result=0}
end


function fztf_lib.add_jinbi(_time,jb)

	fztf_lib.data.asset.prop_jin_bi = fztf_lib.data.asset.prop_jin_bi + (jb or 0)

	return {jin_bi=jb,result=0}
end


function fztf_lib.kill_monster(_time,_data)

	if #_data %3 ~= 0 then
		fztf_lib.ret_tmp.result = 1001
		return fztf_lib.ret_tmp
	end
	
	local jb = 0
	local jbd = {}
	for i=1,#_data,3 do
		local id,type,level = _data[i],_data[i+1],_data[i+2]
		if fztf_lib.random(_time) > fztf_lib.data.skill_jb then
			jbd[id] = 0
		else
			jbd[id] = 10 + level*4
			jb = jb + jbd[id]
		end
	end
	
	fztf_lib.data.asset.prop_jin_bi = fztf_lib.data.asset.prop_jin_bi + jb

	return {data=jbd, jin_bi=jb,result=0}
end


function fztf_lib.pass_game_level(_time)

	fztf_lib.data.game_level = fztf_lib.data.game_level + 1

	return {game_level=fztf_lib.data.game_level,result=0}
end

-- 1 -> 2 合并(放在ID2的位置上),消耗id大的炮
function fztf_lib.merge_turret(_time,_id1,_id2)
	
	local t1 = fztf_lib.turret_id2data[_id1]
	local t2 = fztf_lib.turret_id2data[_id2]

	if _id1 == _id2 or not t1 or not t2 or t1.type ~= t2.type or t1.level ~= t2.level then
		fztf_lib.ret_tmp.result = 1001
		return fztf_lib.ret_tmp
	end
	
	local _index1 , _index2 = t1.location , t2.location

	for i=_index1+1,#fztf_lib.data.turret do
		fztf_lib.data.turret[i-1] = fztf_lib.data.turret[i]
		fztf_lib.data.turret[i-1].location = i-1
	end
	fztf_lib.data.turret[#fztf_lib.data.turret] = nil


	fztf_lib.turret_id2data[_id1] = nil
	t2.level = t2.level + 1

	-- id 保留更小的
	if _id1 < _id2 then
		t2.heroId = _id1
		fztf_lib.turret_id2data[_id1] = t2
		fztf_lib.turret_id2data[_id2] = nil

		_id1 , _id2 = _id2 , _id1
	end

	-- 最大的id进行调整
	if _id1 == fztf_lib.turret_max_id then
		fztf_lib.turret_max_id = 0
		for i,v in ipairs(fztf_lib.data.turret) do
			if fztf_lib.turret_max_id < v.heroId then
				fztf_lib.turret_max_id = v.heroId
			end
		end
	end

	return {
		data = fztf_lib.data.turret,
		result = 0,
	}
end

function fztf_lib.place_turret(_time,_id,_location)

	local t = fztf_lib.turret_id2data[_id]
	if not t then
		fztf_lib.ret_tmp.result = 1001
		return fztf_lib.ret_tmp
	end

	if _location > #fztf_lib.data.turret then
		_location = #fztf_lib.data.turret + 1
	end

	if _location ~= t.location then

		local tt = fztf_lib.data.turret[_location]

		if tt then

			t.location , tt.location = tt.location , t.location

			fztf_lib.data.turret[t.location] , fztf_lib.data.turret[tt.location] =
			fztf_lib.data.turret[tt.location] , fztf_lib.data.turret[t.location]

		else

			fztf_lib.data.turret[_location] = t

			for i=t.location+1,#fztf_lib.data.turret do
				fztf_lib.data.turret[i-1] = fztf_lib.data.turret[i]
				fztf_lib.data.turret[i-1].location = i-1
			end

			fztf_lib.data.turret[_location] = nil

		end

	end

	return {data = fztf_lib.data.turret,result=0}
end


function fztf_lib.sale_turret(_time,_id,_jb)

	local t = fztf_lib.turret_id2data[_id]
	if not t then
		fztf_lib.ret_tmp.result = 1001
		return fztf_lib.ret_tmp
	end

	-- if #fztf_lib.data.turret < 2 then
	-- 	fztf_lib.ret_tmp.result = 1001
	-- 	return fztf_lib.ret_tmp
	-- end
	
	local jb = 0--_jb or math.floor((100 + (t.level-1)*10 * 0.6))

	fztf_lib.data.asset.prop_jin_bi = fztf_lib.data.asset.prop_jin_bi + jb

	for i=t.location+1,#fztf_lib.data.turret do
		fztf_lib.data.turret[i-1] = fztf_lib.data.turret[i]
		fztf_lib.data.turret[i-1].location = i-1
	end

	fztf_lib.data.turret[#fztf_lib.data.turret] = nil

	fztf_lib.turret_id2data[_id] = nil

	-- 最大的id进行调整
	if _id == fztf_lib.turret_max_id then
		fztf_lib.turret_max_id = 0
		for i,v in ipairs(fztf_lib.data.turret) do
			if fztf_lib.turret_max_id < v.heroId then
				fztf_lib.turret_max_id = v.heroId
			end
		end
	end

	return {data = fztf_lib.data.turret,jin_bi = jb,result=0}
end

-- 提出来后插入到目标位置
function fztf_lib.insert_turret(_time,_id,_location)

	local t = fztf_lib.turret_id2data[_id]
	if not t then
		fztf_lib.ret_tmp.result = 1001
		return fztf_lib.ret_tmp
	end

	if _location > #fztf_lib.data.turret then
		_location = #fztf_lib.data.turret
	end

	if t.location ~= _location then

		local t1 , t2 = t.location , _location

		if t1 < t2 then

			for i=1,#fztf_lib.data.turret do
				if i > t.location and i <= _location then
					fztf_lib.data.turret[i-1] = fztf_lib.data.turret[i]
					fztf_lib.data.turret[i-1].location = i-1
				end
			end

			fztf_lib.data.turret[_location] = t
			t.location = _location

		else

			for i=#fztf_lib.data.turret,1,-1 do
				if i >= _location and i < t.location then
					fztf_lib.data.turret[i+1] = fztf_lib.data.turret[i]
					fztf_lib.data.turret[i+1].location = i+1
				end
			end

			fztf_lib.data.turret[_location] = t
			t.location = _location

		end

	end

	return {data = fztf_lib.data.turret,result=0}
end

return fztf_lib