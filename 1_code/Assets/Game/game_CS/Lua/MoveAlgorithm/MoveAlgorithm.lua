local basefunc = require "Game/Common/basefunc"

MoveAlgorithmOld = {}
local C = MoveAlgorithmOld

--- 可以移动的角度
C.can_move_dir = {
    ["4_dir"] = {
        0 , 90 , 180 , 270 
    } ,
    ["8_dir"] = {
        0 , 45 , 90 , 135 , 180 , 225 , 270 , 315
    } ,
}
C.max_rotate_angle = {
    ["4_dir"] = 180 ,
    ["8_dir"] = 135 ,
}

C.dir_G_value = {
    [0] = 10, 
    [45] = 14 ,
    [90] = 10 , 
    [135] = 14 ,
    [180] = 10 , 
    [225] = 14 ,
    [270] = 10 ,
    [315] = 14 ,
}

function C.GetGridSize()
    return GameInfoCenter.map.grid_size 
end

function C.GetSceenSize()
    return GameInfoCenter.map.sceen_size
end


--_sceen_size_debug = {w=32, h=48, width=32, height=48}
---- 位置转成 最近的格子中心
get_grid_pos = function(_pos )
    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()

    local x,y = _pos.x,_pos.y

    if _pos.x < -sceen_size.width/2 then
        x = -sceen_size.width/2 + 0.5
    end
    if _pos.x > sceen_size.width/2 then
        x = sceen_size.width/2 - 0.5
    end
    if _pos.y < -sceen_size.height/2 then
        y = -sceen_size.height/2 + 0.5
    end
    if _pos.y > sceen_size.height/2 then
        y = sceen_size.height/2 - 0.5
    end


    local x_num = math.ceil( x / grid_size )
    local y_num = math.ceil( y / grid_size )

    --if x_num == 0 then x_num = 1 end
    --if y_num == 0 then y_num = 1 end

    local tar_grid_pos = { x = (x_num - 1) * grid_size + grid_size / 2  , y = (y_num - 1) * grid_size + grid_size / 2  }

    --- 向 %0.2f 转一下
    --tar_grid_pos.x = math.floor(tar_grid_pos.x * 1000 + 0.5) / 1000
    --tar_grid_pos.y = math.floor(tar_grid_pos.y * 1000 + 0.5) / 1000

    return tar_grid_pos
end

function GetPosTagKeyStr( pos )
    local ix , fx = math.modf(pos.x)
    local iy , fy = math.modf(pos.y)
    
    return (ix + fx) .. "_" .. (iy + fy)

    --return math.floor(pos.x*1000) .. "_" .. math.floor(pos.y*1000)
end

function GetGridPosTagkeyStr(pos )
    return GetPosTagKeyStr( get_grid_pos( pos  ) )
end

function LimitInScreenPos(pos)

    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()

    if math.abs(pos.x) >= sceen_size.width / 2 then
        pos.x = (pos.x > 0) and (sceen_size.width / 2 - grid_size/2) or (-sceen_size.width / 2 + grid_size/2)
    end
    if math.abs(pos.y) >= sceen_size.height / 2 then
        pos.y = (pos.y > 0) and (sceen_size.height / 2 - grid_size/2) or (-sceen_size.height / 2 + grid_size/2)
    end
end

function C.angle_dis(angle_1 , angle_2)
    local dis = math.abs(angle_1 - angle_2)
    if dis > 180 then
        dis = 360 - dis
    end
    return dis
end

---- 获得某个任意角度在可以移动角度列表中的 最接近的
function C.get_move_dir( _move_model , _dir)
    local min_dir = 9999
    local tar_dir = nil

    local can_move_dir = C.can_move_dir[_move_model]

    for key, dir in pairs(can_move_dir) do
        local dir_offset = C.angle_dis(dir , _dir)
        if dir_offset < min_dir then
            tar_dir = dir
            min_dir = dir_offset
        end
    end
    return tar_dir
end

--- 获得 可以移动的角度，
function C.get_might_move_dir(_move_model ,  _now_dir )
    local might_dir = {}
    local can_move_dir = C.can_move_dir[_move_model]
    local max_rotate_angle = C.max_rotate_angle[_move_model]

    for key, dir in pairs(can_move_dir) do
        local dir_offset = C.angle_dis(dir , _now_dir)
        if dir_offset <= max_rotate_angle then
            might_dir[#might_dir + 1] = dir
        end
    end

    return might_dir
end

---- 构造一个 算法的节点数据
--[[
    F = G + H
    G = 从起点到当前的移动消耗
    H = 从当前到目标点 的 估计移动值(启发式的)
--]]
function C.MakeNodeData( _pos , _dir , _parent , _snake_tail , _g , _h )
    return { key = GetGridPosTagkeyStr(_pos) , pos = _pos , dir = _dir , parent = _parent , snake_tail = _snake_tail , G = _g , H = _h , F = _g + _h }
end

---- 处理 点在 不能通过的 点集合里面
function C.DealPosInNotPassVec(_tar_pos , _start_pos, _move_dir , _cannot_move_pos_vec )
    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()

    local startPosTagStr = GetGridPosTagkeyStr( _start_pos )

    local old_grid_pos = get_grid_pos(_tar_pos )
    local grid_pos = basefunc.deepcopy( old_grid_pos )

    local while_limit = 1000
    local now_dir = 1
    local offset_vec = {
        [1] = { x = 1 , y = 0 } ,
        [2] = { x = 0 , y = 1 } ,
        [3] = { x = -1 , y = 0 } ,
        [4] = { x = 0 , y = -1 } ,
    }
    if _move_dir == 90 or _move_dir == 270 then
        offset_vec = {
            [1] = { x = 0 , y = 1 } , 
            [2] = { x = 0 , y = -1 } ,
            [3] = { x = 1 , y = 0 } , 
            [4] = { x = -1 , y = 0 } ,
        }
    elseif _move_dir == 0 or _move_dir == 180 or _move_dir == 360 then
        offset_vec = {
            [1] = { x = 1 , y = 0 } ,
            [2] = { x = -1 , y = 0 } , 
            [3] = { x = 0 , y = 1 } ,
            [4] = { x = 0 , y = -1 } ,
        }
    end



    while _cannot_move_pos_vec[ GetPosTagKeyStr(grid_pos) ] or startPosTagStr == GetPosTagKeyStr(grid_pos) do
        while_limit = while_limit - 1
        if while_limit < 0 then break end

        
        grid_pos = { x = grid_pos.x + offset_vec[now_dir].x * grid_size  , y = grid_pos.y + offset_vec[now_dir].y * grid_size  }
                
        --- 碰墙就换向
        if math.abs(grid_pos.x) > sceen_size.width / 2 or math.abs(grid_pos.y) > sceen_size.height / 2 then
            --grid_pos.x = grid_pos.x - offset_vec[now_dir].x * grid_size
            --grid_pos.y = grid_pos.y - offset_vec[now_dir].y * grid_size

            grid_pos = basefunc.deepcopy( old_grid_pos )

            now_dir = now_dir + 1
        end
        if now_dir > 4 then
            break
        end
        
    end
    return grid_pos
end

---- 处理蛇身数据，格子化
function C.DealSnakeTailToGridData(_snake_tail , _start_pos )
    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()

    _snake_tail = _snake_tail or {}
    _snake_tail.pos_map = {}

    if _snake_tail and type(_snake_tail) == "table" then
       
        if _snake_tail.pos_list and type(_snake_tail.pos_list) == "table" then

            ---- 把蛇尾数据转换到 格子上，因为蛇的一格可能大于格子 也可能 小于格子 ； 如果 蛇身 小于格子很多，注意蛇头和第一节蛇身在一个格子的情况
            local index = #_snake_tail.pos_list
            while index >= 1 do
                repeat

                local now_pos = _snake_tail.pos_list[index]
                local front_pos = nil
                if index == 1 then
                    front_pos = _start_pos
                else
                    front_pos = _snake_tail.pos_list[index - 1]
                end

                local now_grid_pos = get_grid_pos( now_pos )
                local front_grid_pos = get_grid_pos( front_pos )
                --dump(now_grid_pos , "xxxx--------------now_grid_pos:")
                --dump(front_grid_pos , "xxxx--------------front_grid_pos:")
                ---- 格子相同，删掉，要减掉index 就用下一个格子运算
                if basefunc.float_equal(now_grid_pos.x , front_grid_pos.x) and basefunc.float_equal(now_grid_pos.y , front_grid_pos.y) then
                    --print("xxx-------------- remove 1234")
                    table.remove( _snake_tail.pos_list , index )
                    index = index - 1
                    break
                end 
                ---- 间距太大，补格子 , 补了格子 index 不用加，下次就以补了的格子为基础来运算
                if math.abs(front_grid_pos.x - now_grid_pos.x) > grid_size then
                    --print("xxx-------------- insert 111")
                    table.insert( _snake_tail.pos_list , index , { x = now_grid_pos.x + ( front_grid_pos.x>now_grid_pos.x and 1 or -1 ) * grid_size , y = now_grid_pos.y } )
                    break
                end
                if math.abs(front_grid_pos.y - now_grid_pos.y) > grid_size then
                    --print("xxx-------------- insert 222")
                    table.insert( _snake_tail.pos_list , index , { x = now_grid_pos.x , y = now_grid_pos.y + ( front_grid_pos.y>now_grid_pos.y and 1 or -1 ) * grid_size } )
                    break
                end

                index = index - 1

                until true
            end
            
            ---- 蛇身的位置 的 格子化 和 映射表
            
            for key, pos in pairs(_snake_tail.pos_list) do
                _snake_tail.pos_list[key] = get_grid_pos( pos )

                _snake_tail.pos_map[ GetPosTagKeyStr(_snake_tail.pos_list[key]) ] = true
            end
        end
    end
end

---- 获得一个表中的一个数据 ，通过判断一个key的number值的最小
function C.getTableDataByNumberValueMin( _table_data , _key )
    local min_value = 9999999
    local _tar_data_vec = {}
    for key , data in pairs(_table_data) do
        if data[_key] < min_value then
            _tar_data_vec = { data } 
            min_value = data[_key]
        elseif data[_key] == min_value then
            _tar_data_vec[#_tar_data_vec + 1] = data 
        end
    end
    return _tar_data_vec
end

-----  获得一个点 到 一个方向的 下一个格子点
function C.getNextGridByDir(_grid_pos , dir)
    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()

    local tar_move_dis = { x = 0 , y = 0 }

    ---- 左半屏
    if (dir >= 0 and dir < 90) or (dir > 270 and dir <= 360) then
        tar_move_dis.x = grid_size / 2
    elseif (dir > 90 and dir < 270) then
        tar_move_dis.x = -grid_size / 2
    end

    ---- 上半屏
    if (dir > 0 and dir < 180) then
        tar_move_dis.y = grid_size / 2
    elseif (dir > 180 and dir < 360) then
        tar_move_dis.y = -grid_size / 2
    end

    local tar_pos = { x = _grid_pos.x + 2*tar_move_dis.x , y = _grid_pos.y + 2*tar_move_dis.y }
    return tar_pos
end

---- 移动一次蛇身
function C.MoveSnakeTail( _snake_tail , start_pos )
    local snake_tail_tem = basefunc.deepcopy( _snake_tail )

    snake_tail_tem.pos_map = {}
    if snake_tail_tem.pos_list and type(snake_tail_tem.pos_list) == "table" and next(snake_tail_tem.pos_list) then
            
        for i = #snake_tail_tem.pos_list , 1 , -1 do
            if i == 1 then
                snake_tail_tem.pos_list[i] = basefunc.deepcopy(start_pos)
            else
                snake_tail_tem.pos_list[i] = basefunc.deepcopy(snake_tail_tem.pos_list[i-1])
            end
        end
        
        ---- 蛇身的位置 的 格子化 和 映射表
        for key, pos in pairs(snake_tail_tem.pos_list) do
            snake_tail_tem.pos_list[key] = get_grid_pos( pos )

            snake_tail_tem.pos_map[ GetPosTagKeyStr(snake_tail_tem.pos_list[key]) ] = true
        end

    end
    return snake_tail_tem
end

---- 获得 A* 算法的 H 的值
function C.GetAstarHvalue( _pos , _endPos )
    local grid_size = C.GetGridSize()

    local grid_pos = get_grid_pos(_pos)
    local end_grid_pos = get_grid_pos(_endPos)

    local grid_num_x = (grid_pos.x - grid_size/2) / grid_size + 1
    local grid_num_y = (grid_pos.y - grid_size/2) / grid_size + 1

    local end_grid_num_x = (end_grid_pos.x - grid_size/2) / grid_size + 1
    local end_grid_num_y = (end_grid_pos.y - grid_size/2) / grid_size + 1

    return math.abs((end_grid_num_x - grid_num_x)) * 10 + math.abs((end_grid_num_y - grid_num_y)) * 10

end

------- 传入起始点，前进方向，目标点，找出行进的路径，(自己身体占的格子数)
--[[
  大致思路：
    往前进方向上只有周围n个方向可选，这个选取的范围相当于是一个最大的旋转角度，每次选格子时都是从周围格子选取最优的一个，如果某个方向行进失败会往之前的步骤回退
    
    -- _end_move_path 最终路径表，默认传一个接收的空表
    -- _moved_pos     移动过的路径表，默认传一个空表
    _move_model    移动模式，4_dir 四向 还是  8_dir 八向
    _start_pos     开始点
    _move_dir      当前的移动方向
    _tar_pos       目标点

    _snake_tail  蛇的尾部的数据，{ pos_list = { [1] = 第二节位置，[2] = 第三节位置，...[xx] = 最后一节位置 } , pos_map = { [x .."_" .. y] = true } }

    _cannot_move_pos_vec = { [x.."_"..y] = true }

    _grid_size      格子尺寸大小
    _sceen_size     屏幕尺寸

    -- _call_level  调用层级，刚开始是1
--]] 
function GetGridMovePathOld( _move_model , _start_pos , _move_dir , _endPos , _snake_tail , _cannot_move_pos_vec )
    --if true then return true , {} end
    --print("xxxx----------GetGridMovePath 1")
    local grid_size = C.GetGridSize()
    local sceen_size = C.GetSceenSize()
    
    local old_start_pos = _start_pos

    local open_list = {}
    local close_list = {}

    _start_pos = get_grid_pos(_start_pos )
    _endPos = get_grid_pos(_endPos )
    --print("xxxx----------GetGridMovePath 2")
    --dump( {_start_pos , _endPos} , "xxx---------------org s_e_pos" )
    --- 将 起点，终点 限制到屏幕中
    LimitInScreenPos(_start_pos )
    LimitInScreenPos(_endPos )
    --dump( {_start_pos , _endPos} , "xxx---------------LimitInScreenPos s_e_pos" )
    --print("xxxx----------GetGridMovePath 3")
    ----- 处理目标点在 不能通过的点的情况
    _endPos = C.DealPosInNotPassVec(_endPos , _start_pos , _move_dir , _cannot_move_pos_vec )

    --dump( {_start_pos , _endPos} , "xxx---------------DealPosInNotPassVec s_e_pos" )

    --print("xxxx----------GetGridMovePath 4")
    --- 起点终点 格子化
    _start_pos = get_grid_pos(_start_pos )
    _endPos = get_grid_pos(_endPos )

    local start_pos_offset = { x = _start_pos.x - old_start_pos.x , y = _start_pos.y - old_start_pos.y }
    local _endPosTagStr = GetPosTagKeyStr(_endPos)
    --dump(_start_pos , "xxxx--------------start_pos:")
    --dump(_endPos , "xxxx--------------------------------------end_pos:")
    --print("xxxx----------GetGridMovePath 5")

    ---- 处理蛇尾数据
    C.DealSnakeTailToGridData(_snake_tail , _start_pos )
    --print("xxxx----------GetGridMovePath 6")
    --- 把起点加入 开启列表中
    --table.insert( open_list , C.MakeNodeData( _start_pos , nil , _snake_tail , 0 , 0 ) )
    local start_grid_key = GetGridPosTagkeyStr(_start_pos)
    local now_dir = C.get_move_dir(_move_model , _move_dir)
    open_list[ start_grid_key ] = C.MakeNodeData( _start_pos , now_dir , nil , _snake_tail , 0 , 0 )

    --print("xxxx----------GetGridMovePath 7")
    ---- 如果开始点和结束点相同，就返回
    --if start_pos.x == end_pos.x and start_pos.y == end_pos.y then
    --    return true
    --end
    --- 移动过的位置
    --_moved_pos[ GetPosTagKeyStr(start_pos) ] = true
    local while_count = 10000

    --dump(open_list , "xxx------------open_list:")
    local last_check_data = nil

    local find_target = nil
    while next(open_list) do
        while_count = while_count - 1
        if while_count < 0 then
           break
        end
        ---- 从开启列表中找一个最小的F 的 ， 并加入关闭列表
        local ckeck_data_vec = C.getTableDataByNumberValueMin( open_list , "F" )

        ---- 优先找和 上一个 检查的移动方向相同的点
        local ckeck_data = nil

        if last_check_data then
            local last_dir = last_check_data.dir
            for key,data in pairs(ckeck_data_vec) do
                if data.dir == last_dir then
                    ckeck_data = data
                    break
                end
            end
        end
        if not ckeck_data then
            ckeck_data = ckeck_data_vec[ math.random(#ckeck_data_vec) ]
        end


        last_check_data = ckeck_data
        --dump(ckeck_data , "xxx-----------------------------------------------------ckeck_data:")
        open_list[ckeck_data.key] = nil
        close_list[ckeck_data.key] = ckeck_data

        --print( "xxxx--------tar_info" , ckeck_data.pos.x , _endPos.x , ckeck_data.pos.y , _endPos.y)
        if ckeck_data.key == _endPosTagStr then
            find_target = ckeck_data
            --print("<color=red>xxxx-----------find_target success !!!! </color>")
            break
        end

        local moved_snake_tail = C.MoveSnakeTail( ckeck_data.snake_tail , ckeck_data.pos )

        ---- 找到之后 检查是否是目标点，检查 周围的点(可以移动的方向，4向8向不一样) 是否在开启列表，如果在要判断其 G 值是否更新，更新就刷新F；不在要直接加入开启列表
        local might_move_dir = C.get_might_move_dir(_move_model , ckeck_data.dir )
        --dump(might_move_dir , "xxx-------------might_move_dir:")
        --- 对周围每个可能的点进行检查
        for key, might_dir in pairs(might_move_dir) do
            repeat

            local grid_pos = C.getNextGridByDir( ckeck_data.pos , might_dir )
            local grid_pos_key = GetPosTagKeyStr( grid_pos )
            --dump( { ckeck_data.pos , grid_pos , grid_pos_key , might_dir } , "xxx----------might_dir_check" )
            ---- 检查这个可能点是否没有意义
            if ckeck_data.snake_tail.pos_map[ grid_pos_key ] 
                or _cannot_move_pos_vec[ grid_pos_key ] 
                or grid_pos.x < -sceen_size.width / 2 or grid_pos.x > sceen_size.width / 2 or grid_pos.y < -sceen_size.height / 2 or grid_pos.y > sceen_size.height / 2 then
                --print("xxx------------might_dir break:" , might_dir)

                --- 加一个破的机制

                break
            end

            
            ---- 如果没有在开启列表中 , 并且也不在关闭列表中
            if not open_list[grid_pos_key] and not close_list[grid_pos_key] then
                open_list[ grid_pos_key ] = C.MakeNodeData( 
                    grid_pos , might_dir , ckeck_data , moved_snake_tail , 
                    ckeck_data.G + C.dir_G_value[might_dir] , C.GetAstarHvalue( grid_pos , _endPos ) )

                --dump(open_list[ grid_pos_key ] , "xxx----------------------- insert open_list:")

            elseif open_list[grid_pos_key] then
                ---- 如果在开启列表中
                local around_data = open_list[ grid_pos_key ]
                local new_g = ckeck_data.G + C.dir_G_value[might_dir]
                if new_g < around_data.G then
                    --- 设置为新的 父亲
                    around_data.parent = ckeck_data
                    around_data.G = new_g
                    around_data.F = new_g + around_data.H
                    around_data.snake_tail = moved_snake_tail
                end
            end

            until true
        end

    end

    --- 这个会死循环
    --[[if not find_target then
        return GetGridMovePath( _move_model , _start_pos , _move_dir , _endPos , _snake_tail , _cannot_move_pos_vec )
    end--]]

    --print("xxx----------------find_target:" , find_target)
    --------------------------------- 最后的数据组装
    local move_path = {}
    if find_target then
        local move_data_vec = {}
        ---- 从后面往前找，插到移动路径里面去
        local tar_data = find_target
        while tar_data do
            table.insert( move_data_vec , 1 , tar_data )

            tar_data = tar_data.parent
        end

        --- 把起点删掉
        table.remove( move_data_vec , 1  )

        ---- 第一个方向的 有偏移
        local first_dir = nil
        local is_set = false
        for i = 1 , #move_data_vec do
            local data = move_data_vec[i]
            if not first_dir then
                first_dir = data.dir
            end

            if data.dir == first_dir and not is_set then
                table.insert( move_path , { x = data.pos.x - start_pos_offset.x , y = data.pos.y - start_pos_offset.y } )
            else
                table.insert( move_path , data.pos )
            end
            if data.dir ~= first_dir then
                is_set = true
            end

        end

        return true , move_path
    end
    
    
    return false
end