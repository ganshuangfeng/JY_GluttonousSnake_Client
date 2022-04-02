---- 用C++版来获取 Astar 路径

local basefunc = require "Game/Common/basefunc"

MoveAlgorithm = basefunc.class()
local C = MoveAlgorithm

local isShowDebug = false

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

---- 外部接口表 , **** 所有接口 将接收的坐标系统的位置参数转换到格子系统中，返回的也全是格子系统的位置，要用坐标系统，自己在外面转或者传参数
C.interfaceMap = {
    "SetMapNotPassGridData" ,     ---- 设置不能过的点,会全部替换(除了强制不能走的点)
    "AddMapNotPassGridData" ,     ---- 添加不能过的点
    "DeleteMapNotPassGridData" ,  ---- 删除不能过的点
    "SetNotPassForScreenRound" ,  ---- 封锁房间周围一圈
    "GetMapNotPassGridData" ,     ---- 获得不能过的点
    "GetMapCanPassGridData",      ---- 获取可以过的点
    "get_grid_pos" ,              ---- 获得  进来的坐标转一下 , 传参是否返回 真实坐标值，

    "SetGridProp",                --- 设置 格子的属性
    "DeleteGridProp",             --- 移除 格子属性
    "GetGridProp",                --- 获得 格子属性

    "GetGridSize",                ---- 获得格子大小
    "GetSceenSize",               ---- 获得地图大小
    "GetGridNum",                 ---- 获得地图 xy轴上的格子个数

    "ConvertToGrid",              ---- 转成格子系统的坐标
    "ConvertToPos",               ---- 转成坐标的系统

    "VecConvertToGrid",           ---- 把vec 转成 格子系统
    "VecConvertToPos",            ---- 把vec 转成 坐标系统

    "GetNotPassDataByPos2",
    "GetNotPassDataByPos",

    ----- pos 表示坐标；coord表示在xy方向上的no ； no表示一维递增的编号左下角为1,
    "GetMapNoByPos",              ---- 获得no 通过坐标
    "GetMapPosByNo",              ---- 获取坐标 通过 no
    "GetMapNoCoordByPos" ,        ---- 获取coord({ x = noX , y = noY }), 通过坐标
    "GetMapNoByCoord" ,           ---- 获取编号 通过 coord
    "GetMapCoordByNo" ,           ---- 获取coord 通过 no
    "GetPosTagKeyStr" ,
    "GetGridPosTagkeyStr" ,

    "DealSnakeTailToGridData",       ---- 将蛇的拖尾位置，格子化(多删少补)

    "GetGridMovePath" ,     --- 找路径
}

--- 初始化外部接口，生成  全局变量 函数 , 需要第一个参数 传入 obj 对象
function C.InitInterface()
    for key , name in pairs(C.interfaceMap) do
        _G[name] = function( _object , ... )
            if not _object or not _object.aStar then
                error( "xxx---------_object not have aStar Object !! interface:" .. name )
            end
            if not _object.aStar[name] then
                error( "xxx--------- aStar Object not have interface !! :" .. name )
            end

            return _object.aStar[name]( _object.aStar , ... )
        end
    end
end

---- 直接初始化
C.InitInterface()

function C:Ctor( _centerOffset , _gridSize , _screenSize )
    --- 是否初始化
    self.isInit = false
    --- 是否测试
    self.isTest = false

    --- a* c#对象 ， C#里面是调的 C++的
    self.astar = nil

    --- 和原点偏移
    self.centerOffset = _centerOffset

    --- 格子大小 , 是一个 number
    self.gridSize = _gridSize
    --- 屏幕宽高 , 是一个 {width = , height = }
    self.screenSize = _screenSize

    --- 格子数量
    self.gridNum = { x =  self.screenSize.width / self.gridSize  , y =  self.screenSize.height / self.gridSize  }

    --- 不能通过的点  key = no , value = bool
    self.canNotPass = {}
    --- 强制不能通过的点，比如方形地图周围的一圈
    self.forceNotPass = {}

    ---- 已经设置 到C#类中的 不能过的点
    self.setedCanNotPass = {}

    --- 格子的属性 ,  [no] = { [propKey] = propKey , ... }
    self.gridPropVec = {}

    self:Init()
end

----外部调用，创建房间之后调用
function C:Init()
	local grid_size = self:GetGridSize()
	local screen_size = self:GetSceenSize()
    local grid_num = self:GetGridNum()

    if not self.isInit then
        self.isInit = true
    	self.astar = GameObject.Find("GameManager").gameObject:AddComponent( typeof(AStar) )
    	self.astar:Create( LuaInterface.PointTem.New(0,0) , LuaInterface.SizeTem.New( grid_size , grid_size) , grid_num.x , grid_num.y )
    end

	self.astar:setGridSize( grid_size , grid_size ) 
    self.astar:setMapSize( grid_num.x, grid_num.y )
    
    self.canNotPass = {}

    if not self.isTest then
        self.isTest = true
        --self:test()
    end

end

---- 退出 , 做清理
function C:Exit()
    -- self.astar:Destroy()

    Destroy(self.astar)
end

-------------------------------------------------------- 辅助函数 ↓ --------------------------------------
---- 矫正位置  到格子系统
function C:ConvertToGrid(_pos)
    local tem = { x = _pos.x , y = _pos.y , z = _pos.z or 0 , isGrid = _pos.isGrid , isPos = _pos.isPos }

    if not tem.isGrid then
        tem.x = tem.x - self.centerOffset.x
        tem.y = tem.y - self.centerOffset.y

        tem.isGrid = true
        tem.isPos = false
    end

    return tem
end

---- 反矫正  到坐标系统
function C:ConvertToPos(_pos)
    local tem = { x = _pos.x , y = _pos.y , z = _pos.z or 0 , isGrid = _pos.isGrid , isPos = _pos.isPos }

    if not tem.isPos then
        tem.x = tem.x + self.centerOffset.x
        tem.y = tem.y + self.centerOffset.y

        tem.isPos = true
        tem.isGrid = false
    end

    return tem
end

----
function C:VecConvertToGrid(_vec)
    local vec = {}
    for key,pos in pairs(_vec) do
        vec[key] = self:ConvertToGrid(pos)
    end
    return vec
end
---
function C:VecConvertToPos(_vec)
    local vec = {}
    for key,pos in pairs(_vec) do
        vec[key] = self:ConvertToPos(pos)
    end

    return vec
end

---- 获得 格子大小
function C:GetGridSize()
    --return GameInfoCenter.map.grid_size 
    return self.gridSize
end

--- 获得屏幕宽高
function C:GetSceenSize()
    --dump( self.screenSize , "xxx------------GetSceenSize:" )
    --return GameInfoCenter.map.sceen_size
    return self.screenSize
end

--- 获得 格子 宽高 数量
function C:GetGridNum()
    --return GameInfoCenter.map.grid_num
    return self.gridNum
end



function C:angle_dis(angle_1 , angle_2)
    local dis = math.abs(angle_1 - angle_2)
    if dis > 180 then
        dis = 360 - dis
    end
    return dis
end

---- 获得某个任意角度在可以移动角度列表中的 最接近的
function C:get_move_dir( _move_model , _dir)
    local min_dir = 9999
    local tar_dir = nil

    local can_move_dir = C.can_move_dir[_move_model]

    for key, dir in pairs(can_move_dir) do
        local dir_offset = self:angle_dis(dir , _dir)
        if dir_offset < min_dir then
            tar_dir = dir
            min_dir = dir_offset
        end
    end
    return tar_dir
end

---- 通过起点终点，获取在模式中的最近方向
function C:GetAngleByStartEndPos( _move_model , _start_pos , _endPos)
    local angle = Vec2DAngle( {x = _endPos.x - _start_pos.x , y = _endPos.y - _start_pos.y } )

    local close_angle = self:get_move_dir( _move_model , angle)
    return close_angle
end

---- 把位置转成 地图no
function C:GetMapNoByPos(_pos)
    -- dump(_pos , "xxx----------GetMapNoByPos:")
    _pos = self:ConvertToGrid(_pos)

    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()
    local grid_num = self:GetGridNum()

    local x_num = math.ceil( (_pos.x + sceen_size.width/2) / grid_size )
    local y_num = math.ceil( (_pos.y + sceen_size.height/2) / grid_size )


    return x_num + (y_num - 1) * grid_num.x
end

---- 获取 坐标，通过编号 , 获取 真实的偏移后的位置
function C:GetMapPosByNo( _no , _isToPos )
    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    local coord = self:GetMapCoordByNo( _no )

    local pos = self:ConvertToGrid({ x = 0.5*grid_size + (coord.x-1) * grid_size - sceen_size.width*0.5 , y = 0.5*grid_size + (coord.y-1) * grid_size - sceen_size.height*0.5 , isGrid = true  } )

    if _isToPos then
        pos = self:ConvertToPos( pos )
    end
    return pos
end

---- 根据 位置获取 x,y左边的编号
function C:GetMapNoCoordByPos(_pos)
    _pos = self:ConvertToGrid(_pos)

    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    local x_num = math.ceil( (_pos.x + sceen_size.width/2) / grid_size )
    local y_num = math.ceil( (_pos.y + sceen_size.height/2) / grid_size )


    return { x = x_num , y = y_num }
end

--- 把 x,y坐标编号 转成 地图no
function C:GetMapNoByCoord( _cx , cy )
    local grid_num = self:GetGridNum()
    return _cx + (cy - 1) * grid_num.x
end

---- 把 no 转成 xy坐标编号
function C:GetMapCoordByNo( _no )
    local grid_num = self:GetGridNum()
    return {x = (_no - 1) % grid_num.x + 1  , y = math.ceil(_no / grid_num.x) , isGrid = true }
end

----- 用坐标 获取位置strTag
function C:GetPosTagKeyStr( _pos )
    _pos = self:ConvertToGrid(_pos)

    local ix , fx = math.modf(_pos.x)
    local iy , fy = math.modf(_pos.y)
    
    return (ix + fx) .. "_" .. (iy + fy)

    --return math.floor(_pos.x*1000) .. "_" .. math.floor(_pos.y*1000)
end

----- 用坐标 获取 转换成格子中心点之后的 strTag
function C:GetGridPosTagkeyStr( _pos )
    return self:GetPosTagKeyStr( self:get_grid_pos( _pos  ) )
end

------
function C:GetNotPassDataByPos2(pos, r)
    local notGrid = self:GetMapNotPassGridData( ) --GameInfoCenter.GetMapNotPassGridData()

    local gPos = self:get_grid_pos( pos )

    local aroundRot = {
        0,45,90,135,180,225,270,315
    }

    r = r or 0.8
    local tt = {}
    for i = 1, #aroundRot do
        local p = { x = pos.x + MathExtend.Cos( aroundRot[i] ) * r , y = pos.y + MathExtend.Sin( aroundRot[i] ) * r }
        local aPos = self:get_grid_pos( p )
        if math.abs(gPos.x - aPos.x) > 0.1 or math.abs(gPos.y - aPos.y) > 0.1 then
            local aNo = self:GetMapNoByPos( aPos )
            if notGrid and notGrid[ aNo ] then
                tt.nott = tt.nott or {}
                tt.nott[#tt.nott + 1] = { pos=aPos , r = 1.6 }
            else
                tt.yestt = tt.yestt or {}
                tt.yestt[#tt.yestt + 1] = { pos=aPos , r = 1.6 }
            end
        end
    end
    return tt
end

-- 获取一个坐标点 周围不能走的不能走的坐标和大小等数据
local aroundXY1 = {
    {x=0, y = 1, rot = 90, dir = 1},
    {x=-1, y = 0, rot = 180, dir = 2},
    {x=1, y = 0, rot = 0, dir = 0},
    {x=0, y = -1, rot = 270, dir = 3},

    -- {x=1, y = 1},
    -- {x=-1, y = 1},
    -- {x=-1, y = -1},
    -- {x=1, y = -1},
}
local aroundXY2 = {
    {x=2, y = -1, rot = 337.5, dir = 0},

    {x=2, y = 0, rot = 0, dir = 0},
    {x=2, y = 1, rot = 22.5, dir = 0},
    {x=1, y = 2, rot = 67.5, dir = 1},
    {x=0, y = 2, rot = 90, dir = 1},
    {x=-1, y = 2, rot = 112.5, dir = 1},
    {x=-2, y = 1, rot = 157.5, dir = 2},
    {x=-2, y = 0, rot = 180, dir = 2},
    {x=-2, y = -1, rot = 202.5, dir = 2},
    {x=-1, y = -2, rot = 247.5, dir = 3},
    {x=0, y = -2, rot = 270, dir = 3},
    {x=1, y = -2, rot = 292.5, dir = 3},

    {x=2, y = 2, rot = 45, dir = 5},
    {x=-2, y = 2, rot = 135, dir = 6},
    {x=-2, y = -2, rot = 225, dir = 7},
    {x=2, y = -2, rot = 315, dir = 8},
}
function C:GetNotPassDataByPos(pos, len)
    local aroundXY = aroundXY1
    len = len or 1
    if len == 2 then
        aroundXY = aroundXY2
    end
    local no = self:GetMapNoByPos( self:get_grid_pos(pos) )
    local notGrid = self:GetMapNotPassGridData()
    local grid_num = self:GetGridNum() --GameInfoCenter.map.grid_num
    local tt = {}
    local girdXY = self:GetMapCoordByNo(no)
    tt.my = {xy=girdXY}
    for k, v in ipairs(aroundXY) do
        local x = girdXY.x + v.x
        local y = girdXY.y + v.y
        if x > 0 and x <= grid_num.x and y > 0 and y <= grid_num.y then
            local aNo = self:GetMapNoByCoord( x, y )
            local aPos = self:GetMapPosByNo( aNo , true )
            if notGrid and notGrid[ aNo ] then
                tt.nott = tt.nott or {}
                tt.nodir = tt.nodir or {}
                tt.nott[#tt.nott + 1] = {xy={x=x,y=y}, dir=v.dir, rot=v.rot, pos=aPos , r = 1.6, no = aNo}
                tt.nodir[v.dir] = v.dir
            else
                tt.yestt = tt.yestt or {}
                tt.yestt[#tt.yestt + 1] = {xy={x=x,y=y}, rot=v.rot, pos=aPos , r = 1.6, no = aNo}
            end
        end
    end
    return tt
end

-------------------------------------------------------- 辅助函数 ↑ --------------------------------------

--------------------------------------------------------- 不能通过的点相关 ↓ -----------------------------------------
---- 全部设置 不能通过的点  , 传入的点 不是坐标 ，而是 xy坐标编号
function C:SetMapNotPassGridData(data)
    self.canNotPass = {}

    --- 直接设置
    for key ,_data in pairs(data) do
        local no = self:GetMapNoByCoord( _data.posX , _data.posY )
        self.canNotPass[no] = true
    end

    -- dump( self.canNotPass , "<color=yellow>xxx-----------SetMapNotPassGridData</color>")
    --- 同步
    --SetMapCantPassGrid()
    self:SynSetMapCantPassGrid( )
end

---- 添加 不能通过的点 , 传入的点 不是坐标 ，而是 xy坐标编号
function C:AddMapNotPassGridData(data)
    local grid_num = self:GetGridNum()

    --local temNotPass = basefunc.deepcopy(self.canNotPass)

    --- 直接设置
    for key ,_data in pairs(data) do
        if _data.posX >= 1 and _data.posX <= grid_num.x and _data.posY >= 1 and _data.posY <= grid_num.y then

            local no = self:GetMapNoByCoord( _data.posX , _data.posY )
            self.canNotPass[no] = true
        end
    end

    --- 同步
    --SetMapCantPassGrid()
    self:SynSetMapCantPassGrid( )
end

---- 删除 不能通过的点
--[[
    posVec = { 
        { posX = coord_x , posY = coord_y , isForce = bool }
    }
--]]
function C:DeleteMapNotPassGridData(posVec)
    if posVec and type(posVec) == "table" then
        for key,data in pairs(posVec) do
            local no = self:GetMapNoByCoord( data.posX , data.posY )

            if data.isForce then
                self.forceNotPass[no] = nil
            end

            self.canNotPass[no] = nil
        end
    end

    --- 同步C#
    self:SynSetMapCantPassGrid( )
end

---- (外部调用，不是通道类型的房间都调一下) 封锁周围一圈， 设置强制不能过的点，
function C:SetNotPassForScreenRound()
    self.forceNotPass = {}
    local grid_num = self:GetGridNum()

    ----- 把周围围起来
    for x = 1 , grid_num.x do
        local no_down = self:GetMapNoByCoord(x , 1)
        local no_up = self:GetMapNoByCoord(x , grid_num.y )

        self:SetGridProp( no_down , "wall" )
        self:SetGridProp( no_up , "wall" )

        self.forceNotPass[ no_down ] = true
        self.forceNotPass[ no_up ] = true

    end

    for y = 1 , grid_num.y do
        local no_left = self:GetMapNoByCoord( 1 , y )
        local no_right = self:GetMapNoByCoord( grid_num.x , y )

        self:SetGridProp( no_left , "wall" )
        self:SetGridProp( no_right , "wall" )
        
        self.forceNotPass[ no_left ] = true
        self.forceNotPass[ no_right ] = true

    end

    --- 同步C#
    self:SynSetMapCantPassGrid( )
end

---- 获得地图不能通过的点
--[[
    _gridPropVec 排除的， 表示 在其中的格子都 不要
--]]
function C:GetMapNotPassGridData( _gridPropVec )
    
    local temData = basefunc.deepcopy( self.canNotPass or {} ) 

    --- 把强制不能过的点 ，合并
    basefunc.merge( self.forceNotPass , temData )

    if _gridPropVec and type(_gridPropVec) == "table" then
        for no , _b in pairs(temData) do
            local propData = self.gridPropVec[no]
            if propData then
                local isFind = false
                for key,prop in pairs(_gridPropVec) do
                    if propData[prop] then
                        isFind = true
                        break
                    end
                end
                --- 没找到删除
                if isFind then
                    temData[no] = nil
                end
            end
        end
    end

    return temData
end

--- 获得地图可以通过的点
function C:GetMapCanPassGridData()
    local cantPassData = self:GetMapNotPassGridData()
    local ret = {}
    local gridNum = self:GetGridNum()

    for x = 1 , gridNum.x do
        for y = 1 , gridNum.y do
            local no = self:GetMapNoByCoord( x , y )
            if not cantPassData[no] then
                ret[no] = true
            end
        end
    end    
    return ret
end

--- 同步 设置哪些点不能通过
---  C:SetMapCantPassGrid()
function C:SynSetMapCantPassGrid( )
    if not self.astar then
        return
    end
    local cantPassGrid = self:GetMapNotPassGridData()

    --- 先删除
    for no , b in pairs(self.setedCanNotPass) do
        if not cantPassGrid[no] then
            self.setedCanNotPass[no] = nil
            self.astar:setNodeInf( no , true ) 
        end
    end

    --- 再添加
    for no , b in pairs( cantPassGrid ) do
        if not self.setedCanNotPass[no] then
            self.setedCanNotPass[no] = true
            self.astar:setNodeInf( no , false ) 
        end
    end
end

--------------------------------------------------------- 不能通过的点相关 ↑ -----------------------------------------

function C:SetGridProp( no , key )
    self.gridPropVec[no] = self.gridPropVec[no] or {}
    local tarData = self.gridPropVec[no]

    tarData[key] = key
end

function C:DeleteGridProp( no , key )
    self.gridPropVec[no] = self.gridPropVec[no] or {}
    local tarData = self.gridPropVec[no]

    tarData[key] = nil
end

function C:GetGridProp(no)
    return self.gridPropVec[no] or {}
end


---- 把位置转成 最近的格子中心点，进来的坐标转一下，出去的不用反转
-- _isNotRev 为 false 则 要反转成真实坐标
function C:get_grid_pos(_pos , _isToPos )
    _pos = self:ConvertToGrid(_pos)
    
    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    if _pos.x < -sceen_size.width/2 then
        _pos.x = -sceen_size.width/2 + 0.5
    end
    if _pos.x > sceen_size.width/2 then
        _pos.x = sceen_size.width/2 - 0.5
    end
    if _pos.y < -sceen_size.height/2 then
        _pos.y = -sceen_size.height/2 + 0.5
    end
    if _pos.y > sceen_size.height/2 then
        _pos.y = sceen_size.height/2 - 0.5
    end


    local x_num = math.ceil( _pos.x / grid_size )
    local y_num = math.ceil( _pos.y / grid_size )

    --if x_num == 0 then x_num = 1 end
    --if y_num == 0 then y_num = 1 end

    local tar_grid_pos = { x = (x_num - 1) * grid_size + grid_size / 2  , y = (y_num - 1) * grid_size + grid_size / 2 , isGrid = true }

    --- 向 %0.2f 转一下
    --tar_grid_pos.x = math.floor(tar_grid_pos.x * 1000 + 0.5) / 1000
    --tar_grid_pos.y = math.floor(tar_grid_pos.y * 1000 + 0.5) / 1000
    if _isToPos then
        return self:ConvertToPos( tar_grid_pos )
    else
        return tar_grid_pos 
    end
end

---- 处理蛇身数据，格子化
function C:DealSnakeTailToGridData(_snake_tail , _start_pos )
    --print("xxx-----------DealSnakeTailToGridData 111")
    _start_pos = self:ConvertToGrid(_start_pos)

    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    _snake_tail = _snake_tail or {}
    _snake_tail.pos_map = {}
    --dump(_snake_tail , "xxx-------------------_snake_tail 111:")
    --print("xxx-----------DealSnakeTailToGridData 222")
    if _snake_tail and type(_snake_tail) == "table" then
       
        if _snake_tail.pos_list and type(_snake_tail.pos_list) == "table" then

            ----
            for key,pos in pairs(_snake_tail.pos_list) do
                _snake_tail.pos_list[key] = self:ConvertToGrid(pos)
            end
            --dump(_snake_tail , "xxx-------------------_snake_tail 222:")
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

                local now_grid_pos = self:get_grid_pos( now_pos )
                local front_grid_pos = self:get_grid_pos( front_pos )
                --dump(now_grid_pos , "xxxx--------------now_grid_pos:")
                --dump(front_grid_pos , "xxxx--------------front_grid_pos:")
                ---- 格子相同，删掉，要减掉index 就用下一个格子运算
                if basefunc.float_equal(now_grid_pos.x , front_grid_pos.x) and basefunc.float_equal(now_grid_pos.y , front_grid_pos.y) then
                    --print("xxx-------------- remove 1234")
                    table.remove( _snake_tail.pos_list , index )
                    index = index - 1
                    --print("xxx---------------------------------------------- equal ,index:", index)
                    break
                end 
                ---- 间距太大，补格子 , 补了格子 index 不用加，下次就以补了的格子为基础来运算
                if math.abs(front_grid_pos.x - now_grid_pos.x) > grid_size + 1E-12 then
                    --print("xxx-------------- insert 111")
                    table.insert( _snake_tail.pos_list , index , { x = now_grid_pos.x + ( front_grid_pos.x>now_grid_pos.x and 1 or -1 ) * grid_size , y = now_grid_pos.y , isGrid = true } )
                    --print("xxx---------------------------------------------- insert 1 ,index:", index)
                    break
                end
                if math.abs(front_grid_pos.y - now_grid_pos.y) > grid_size + 1E-12 then
                    --print("xxx-------------- insert 222")
                    table.insert( _snake_tail.pos_list , index , { x = now_grid_pos.x , y = now_grid_pos.y + ( front_grid_pos.y>now_grid_pos.y and 1 or -1 ) * grid_size , isGrid = true } )
                    --print("xxx---------------------------------------------- insert 2 ,index:", index)
                    break
                end

                
                index = index - 1
                --print("xxx---------------------------------------------- next 3 ,index:" , index)
                until true
            end
            
            ---- 蛇身的位置 的 格子化 和 映射表
            
            for key, pos in pairs(_snake_tail.pos_list) do
                _snake_tail.pos_list[key] = self:get_grid_pos( pos )

                _snake_tail.pos_map[ self:GetPosTagKeyStr(_snake_tail.pos_list[key]) ] = true
            end
        end
    end

    --print("xxx-----------DealSnakeTailToGridData 333")
end





function C:LimitInScreenPos(_pos)
    _pos = self:ConvertToGrid(_pos)

    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    if math.abs(_pos.x) >= sceen_size.width / 2 then
        _pos.x = (_pos.x > 0) and (sceen_size.width / 2 - grid_size/2) or (-sceen_size.width / 2 + grid_size/2)
    end
    if math.abs(_pos.y) >= sceen_size.height / 2 then
        _pos.y = (_pos.y > 0) and (sceen_size.height / 2 - grid_size/2) or (-sceen_size.height / 2 + grid_size/2)
    end

    return _pos
end

---- 处理 点在 不能通过的 点集合里面
function C:DealPosInNotPassVec(_tar_pos , _start_pos, _move_dir , _cannot_move_pos_vec )
    _tar_pos = self:ConvertToGrid(_tar_pos)
    _start_pos = self:ConvertToGrid(_start_pos)

    local grid_size = self:GetGridSize()
    local sceen_size = self:GetSceenSize()

    _cannot_move_pos_vec = self:GetMapNotPassGridData() -- GameInfoCenter.GetMapNotPassGridData() or {}

    local startPosTagStr = self:GetMapNoByPos(_start_pos) --GetGridPosTagkeyStr( _start_pos )

    local old_grid_pos = self:get_grid_pos(_tar_pos )
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

    while _cannot_move_pos_vec[ self:GetMapNoByPos(grid_pos) ] or startPosTagStr == self:GetMapNoByPos(grid_pos) do
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

function C:ShowDebug()
    if not isShowDebug then return end

    local gridNum = self:GetGridNum()
    local cantPassGrid = self:GetMapNotPassGridData()

    self:DeleteDebug()

    local npg = self:GetMapNotPassGridData( { "water" } )

    --print("<color=red>xxxxx------------------------- ShowDebug():</color>" , self )

    

    
    local color = Color.New( math.random(255) / 255 , math.random(255) / 255 , math.random(255) / 255 , 1 )

    for x = 1 , gridNum.x do
        for y = 1 , gridNum.y do
            local no = self:GetMapNoByCoord( x , y )
            local pos = self:GetMapPosByNo( no , true )

            local parent = MapManager.GetMapNode()
            local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
            obj.transform.position = Vector3.New( pos.x , pos.y , 0 )
            obj.gameObject.name = "Astar_debug_" .. pos.x .. "_" .. pos.y .. "|" .. x  .. "," .. y
            
            
            local tarColor = Color.New( color.r , color.g , color.b , 1 )
            if cantPassGrid[no] then
                --- 不能通过
                tarColor = Color.New( 0.1 , 0.1 , 0.1 , 1 )
            end

            local spriteCom = obj.transform:GetComponent("SpriteRenderer")
            spriteCom.color = Color.New( tarColor.r , tarColor.g , tarColor.b , 0.8 )

            self.debugVec = self.debugVec or {}
            self.debugVec[no] = obj
        end
    end

end

function C:DeleteDebug()
    if self.debugVec and type(self.debugVec) == "table" then
        for no,obj in pairs(self.debugVec) do
            Destroy(obj)

        end
    end
    self.debugVec = {}
end

--[[--- 设置一个 节点是否安全
function C:SetMapNoIsSafe( _no , _isSafe )
	self.astar:setNodeInf( _no , _isSafe ) 
end--]]

function C:GetGridMovePath( _move_model , _start_pos , _move_dir , _endPos , _snake_tail , _isToPos )
    -- print("xxx----------------------GetGridMovePath 111")
    local sceen_size = self:GetSceenSize()

    _start_pos = self:ConvertToGrid(_start_pos)
    _endPos = self:ConvertToGrid(_endPos)

    --- 将 起点，终点 限制到屏幕中
    _start_pos = self:LimitInScreenPos(_start_pos )
    _endPos = self:LimitInScreenPos(_endPos )

    local old_start_pos = _start_pos

    --- 格子中心化
    _start_pos = self:get_grid_pos(_start_pos )

    local start_pos_offset = { x = _start_pos.x - old_start_pos.x , y = _start_pos.y - old_start_pos.y }

    ----- 处理目标点在 不能通过的点的情况
    _endPos = self:DealPosInNotPassVec(_endPos , _start_pos , _move_dir , _cannot_move_pos_vec )

	local startPosNo = self:GetMapNoByPos(_start_pos)
    --print("xxx---------------startPosNo:" , _start_pos.x , _start_pos.y , startPosNo )
	local endPosNo = self:GetMapNoByPos(_endPos)
    --print("xxx---------------endPosNo:" , _endPos.x , _endPos.y , endPosNo )

	local path = self.astar:getPathNoByNo( startPosNo , endPosNo )
    --local path = { len = 0 }

	local tarPath = {}
	for i = 0 , path.len-1 do
        tarPath[#tarPath + 1] = { x = path.pathXY[i].x - sceen_size.width/2 , y = path.pathXY[i].y - sceen_size.height/2 , no = path.pathNo[i] }
    end
    -- dump(tarPath , "xxxx---------------------------GetGridMovePath__tarPath")
    
    --- 永远有数据，避免卡死
    if not next(tarPath) then
        if _start_pos.y ~= 0 then
            tarPath[#tarPath + 1] = { x = _start_pos.x , y = 0 }
        end

        local canPassGrid = self:GetMapCanPassGridData()

        if next(canPassGrid) then
            local tem = basefunc.map_to_list( canPassGrid , true )
            tarPath[#tarPath + 1] = self:GetMapPosByNo( tem[ math.random(#tem) ] )
        else
            tarPath[#tarPath + 1] = { x = 0 , y = 0 }
        end
    else
        --- 把起点删掉
        table.remove( tarPath , 1  )
    end

    ----- 处理 不咬蛇身，

    ----- 处理 第一次转向的偏移，避免第一次转向走格子中心
    local finalPath = {}
    local firstAngle = nil
    local is_set = false
    for index = 1 , #tarPath do
        local pos = tarPath[index]
        --local
        if not firstAngle then
            firstAngle = self:GetAngleByStartEndPos( _move_model , _start_pos , pos  )
        end

        local nowAngle = self:GetAngleByStartEndPos( _move_model , tarPath[index-1] or _start_pos , pos )

        --print("<color=blue>xxx-----------GetGridMovePath-</color>:" , index , firstAngle , nowAngle , is_set )

        if nowAngle == firstAngle and not is_set then
            if index ~= #tarPath then
                table.insert( finalPath , { x = pos.x - start_pos_offset.x , y = pos.y - start_pos_offset.y } )
            else
                if nowAngle == 0 or nowAngle == 180 or nowAngle == 360 then
                    table.insert( finalPath , { x = pos.x , y = pos.y - start_pos_offset.y } )
                elseif nowAngle == 90 or nowAngle == 270 then
                    table.insert( finalPath , { x = pos.x - start_pos_offset.x , y = pos.y } )
                end
            end
        else
            table.insert( finalPath , pos )
        end
        if nowAngle ~= firstAngle then
            is_set = true
        end

    end

    ---- 反 矫正
    if _isToPos then
         finalPath = self:VecConvertToPos(finalPath)
    end

    return true , finalPath
end
