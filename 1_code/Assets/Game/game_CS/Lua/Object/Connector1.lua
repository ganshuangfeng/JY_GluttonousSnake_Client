--[[
    走廊连接器
]]
local basefunc = require "Game/Common/basefunc"

Connector1 = basefunc.class(Object)
local M = Connector1

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

    if not self.data.roomNo then
        return
    end

    local offset = self.data.aStarPos
    local gridSize = 1.6
    local roomSize = {width=self.data.aStarSize.w,height=self.data.aStarSize.h}
    -- dump(roomSize , "xxxx------------roomSize:")
    self.aStarData = { aStar = MoveAlgorithm.New( {x = offset.x , y = offset.y}  ,gridSize,roomSize) }
    MapManager.SetAStar(-self.id,self.aStarData)
    self:SetAstarCollision()

    --- debug
    self.aStarData.aStar:ShowDebug()

    self.state = "off"

    self.start_state = nil
    self.end_state = nil

    local sd = GameInfoCenter.GetStageData()
    self.last_roomNo = sd.roomNo
    self.goto_roomNo = self.data.roomNo

    -- 能够从连接器走廊返回上个房间
    self.can_return_room = true

    -- 能够从下个房间返回连接器走廊
    self.can_return_corridor = false

	self:CreateUI()
    -- self:DebugShowGrid()
end

function M:Init()
	
end


local DirCfg = {
    up_down = {
        tag = "top",
        pmy = 0.84,
        epmy = -5.04,
        epsmy = -5.06,
        rot = 0,
        jtp = "ZY_jiantou_JT_u",
    },
    down_up = {
        tag = "down",
        pmy = 0.84,
        epmy = -5.04,
        epsmy = -5.06,
        rot = 0,
        jtp = "ZY_jiantou_JT_d",
    },
    left_right = {
        tag = "left",
        pmy = 0.84,
        epmy = -5.04,
        epsmy = -5.06,
        rot = 90,
        jtp = "ZY_jiantou_JT_l",
    },
    right_left = {
        tag = "right",
        pmy = 0.84,
        epmy = -5.04,
        epsmy = -5.06,
        rot = -90,
        jtp = "ZY_jiantou_JT_r",
    }
}

function M:CreateUI()

    if self.data.dir == "up_down" or self.data.dir == "down_up" then
        local dc = DirCfg[self.data.dir]

        --创建门
        self.posMen = CachePrefabManager.Take("men_hong", CSPanel.map_node)
        self.posMen.prefab.prefabObj.gameObject.transform.position = Vector3.New(self.data.pos.x,self.data.pos.y+dc.pmy,0)
        self.posMen.prefab.prefabObj.gameObject.name = "posMen"
        self.posMen.prefab.prefabObj.gameObject.transform.rotation = Quaternion.Euler(0, 0, dc.rot)


        --创建门
        self.endPosMen = CachePrefabManager.Take("men_bai", CSPanel.map_node)
        self.endPosMen.prefab.prefabObj.gameObject.transform.position = Vector3.New(self.data.endPos.x,self.data.endPos.y+dc.epmy,0)
        self.endPosMen.prefab.prefabObj.gameObject.name = "endPosMen"
        self.endPosMen.prefab.prefabObj.gameObject.transform.rotation = Quaternion.Euler(0, 0, dc.rot)

        --创建门
        self.endPosSuoMen = CachePrefabManager.Take("men_hong", CSPanel.map_node)
        self.endPosSuoMen.prefab.prefabObj.gameObject.transform.position = Vector3.New(self.data.endPos.x,self.data.endPos.y+dc.epsmy,0)
        self.endPosSuoMen.prefab.prefabObj.gameObject:SetActive(false)
        self.endPosSuoMen.prefab.prefabObj.gameObject.name = "endPosSuoMen"
        self.endPosSuoMen.prefab.prefabObj.gameObject.transform.rotation = Quaternion.Euler(0, 0, dc.rot)
    elseif self.data.dir == "left_right" or self.data.dir == "right_left" then
        self.startZhalan = self:CreateZhaLan(self.data.pos + Vector3.New(-1.2,0,0),"men_zhalan")
        self.endZhalan = self:CreateZhaLan(self.data.endPos + Vector3.New(1.2,0,0),"men_zhalan")
    end


end

--[[
	1 -- 关卡通过了
]]
function M:event(type,data)
	if type == 1 then
		self:Open()
	end
end


function M:Open()
    
    if not self.data.roomNo then
        error("error：走廊连接器没有连接的下一个房间！！！ 若没有下一个房间不需要配连接器！！！")
        return
    end

    self.state = "on"
    if self.data.dir == "up_down" or self.data.dir == "down_up" then
        -- 开门散雾
        -- Destroy(self.posMen)
        CachePrefabManager.Back(self.posMen)
        self.posMen = nil
    elseif self.data.dir == "left_right" or self.data.dir == "right_left" then
        self:OpenZhaLan(self.startZhalan)
        self:OpenZhaLan(self.endZhalan)
    end

    local dc = DirCfg[self.data.dir]

    -- 创建门口指引特效
    self.portal_prefab =  CachePrefabManager.Take(dc.jtp, CSPanel.map_node)
    self.portal_prefab.prefab.prefabObj.transform.position = self.data.pos

    -- GameInfoCenter.SetHeroHeadTargetData({pos=self.data.pos,type="csm",})

    self.start_state = "wait_enter" 

    Event.Brocast("room_door_open_msg", {roomNo=-self.id,dir=dc.tag})

end

function M:SetAstarCollision()
    --local gridNoVec = {}
    -- dump(self.data.colls , "xxx---------------------self.data.colls:")
    if self.data and self.data.colls and type(self.data.colls) == "table" then
        for k,data in pairs(self.data.colls) do
            local pos = data.collPos
            local size = data.collSize

            local leftDownPoint = { x = pos.x - size.w / 2 , y = pos.y - size.h / 2 }
            local rightUpPoint = { x = pos.x + size.w / 2 , y = pos.y + size.h / 2 }

            leftDownPoint = GetMapNoCoordByPos( self.aStarData , leftDownPoint )
            rightUpPoint = GetMapNoCoordByPos( self.aStarData , rightUpPoint )

            --local girdSize = GetGridSize( self.aStarData )
            -- dump({ leftDownPoint , rightUpPoint } , "xxx---------------SetAstarCollision:" )

            for x = leftDownPoint.x , rightUpPoint.x do
                for y = leftDownPoint.y , rightUpPoint.y do
                    -- dump({ x , y } , "xxx---------------x,y:" )
                    AddMapNotPassGridData( self.aStarData , { { posX = x , posY = y } } )
                end
            end

        end
    end

end


local Threshold = 3*1.6


local CheckPos = function (hpos,data)
    local aStarStartPosY = data.aStarPos.y - data.aStarSize.h / 2
    local aStarEndPosY = data.aStarPos.y + data.aStarSize.h / 2
    local aStarStartPosX = data.aStarPos.x - data.aStarSize.w / 2
    local aStarEndPosX = data.aStarPos.x + data.aStarSize.w / 2
    local roomPosMinX = data.roomPos.x - data.roomSize.w / 2
    local roomPosMaxX = data.roomPos.x + data.roomSize.w / 2
    local roomPosMinY = data.roomPos.y - data.roomSize.h / 2
    local roomPosMaxY = data.roomPos.y + data.roomSize.h / 2

    local inCurRoom = hpos.x > roomPosMinX and hpos.x < roomPosMaxX and hpos.y > roomPosMinY and hpos.y < roomPosMaxY
    local inRoad = hpos.x > aStarStartPosX and hpos.x < aStarEndPosX and hpos.y > aStarStartPosY and hpos.y < aStarEndPosY

    if inRoad then
        --在通道
        return "inRoad"
    else
        if inCurRoom then
            --在当前房间
            return "inCurRoom"
        else
            --不在当前房间
            return "inNextRoom"
        end
    end
end

local checkFunc = {
    NextRoom = function (hpos,data)
        return CheckPos(hpos,data) == "inNextRoom"
    end,
    lastRoom = function (hpos,data)
        return CheckPos(hpos,data) == "inCurRoom"
    end,
    corridor = function (hpos,data)
        return CheckPos(hpos,data) == "inRoad"
    end,
}

local DirChkFunc = {
    up_down = checkFunc,
    down_up = checkFunc,
    left_right = checkFunc,
    right_left = checkFunc
}


-- 检测切换
function M:FrameUpdate(dt)
    
    if self.state == "off" then
        return
    end

    local head = GameInfoCenter.GetHeroHead()

    -- 必须在我掌控的三个房间内才进行检测
    if head.data.roomNo ~= -self.id 
        and head.data.roomNo ~= self.last_roomNo 
        and head.data.roomNo ~= self.goto_roomNo then
            return 
    end

    local hpos = head.transform.position

    local check = DirChkFunc[self.data.dir]

    -- 在走廊
    if check.corridor(hpos,self.data) then
        --- 如果 不在 不能走的点，能走
        if not head:CheckIsCollisionCantPassGrid( self.aStarData ) then

            head:SetRoomNo(-self.id)

            if not self.stage1 then
                self.stage1 = true

                -- head:SpeedUpInDoor()
                
            end
        end
    
    -- 上一个房间
    elseif not self.last_roomNo_lock and check.lastRoom(hpos,self.data) then

        head:SetRoomNo(self.last_roomNo)

    -- 下一个房间
    elseif check.NextRoom(hpos,self.data) then

        if not self.stage2 then
            self.stage2 = true

            GameInfoCenter.SetHeroHeadTargetData(nil)
            local sd = GameInfoCenter.GetStageData()
            StageManager.StartNewStage(sd.curLevel,self.data.roomNo)

            if self.data.dir == "up_down" or self.data.dir == "down_up" then
                --门消失
                -- Destroy(self.endPosMen)
                CachePrefabManager.Back(self.endPosMen)
                self.endPosMen = nil
            elseif self.data.dir == "left_right" or self.data.dir == "right_left" then
            end

            if not self.can_return_corridor then
                -- 锁门
                if self.data.dir == "up_down" or self.data.dir == "down_up" then
                    self.endPosSuoMen.prefab.prefabObj.gameObject:SetActive(true)
                elseif self.data.dir == "left_right" or self.data.dir == "right_left" then
                    self:ShutZhaLan(self.startZhalan)
                    self:ShutZhaLan(self.endZhalan)
                end

                -- 完全锁了 不用检测了
                self.state = "off"
            end

            -- if not self.can_return_room then
            --     -- 锁门

            --     -- 不可以回上一个房间了
            --     self.last_roomNo_lock = true

            --     local cl = {}
            --     for i=1,10 do
            --         table.insert(cl,{posX=i,posY=1})
            --     end
            --     AddMapNotPassGridData( self.aStarData ,cl )
            -- end

        end

        head:SetRoomNo(self.goto_roomNo)
    end

    -- dump(head.data.roomNo,"rrrrrrrrrrrrrrnnnnnnnnnnnnnnnnnnnnnnn")
end


function M:DebugShowGrid()
    local isShow = true
    if not isShow then
        return
    end
    
    local parent = MapManager.GetMapNode()
    local go = parent.transform:Find("GridNode1")
    if not IsEquals(go) then
        go = GameObject.New("GridNode1")
        go.transform:SetParent(parent)
    end
    parent = go.transform
    DestroyChildren(parent)

    local offset = self.data.pos
    local gridSize = 1.6
    local roomSize = {width=self.data.size.w,height=self.data.size.h}

    -- for i=-roomSize.width*0.5,roomSize.width*0.5,1.6 do
    --     for j=0,roomSize.height,1.6 do
    --         local pos = Vector3.New(offset.x + i,offset.y + j,0)
    --         local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
    --         obj.transform.position = pos
    --         obj.gameObject.name = "GridBack_" .. pos.x .. "_" .. pos.y   
    --     end
    -- end


    local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
    obj.transform.position = self.data.endPos
    obj.gameObject.name = "GridBack_" .. self.data.endPos.x .. "_" .. self.data.endPos.y   
    

    local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
    obj.transform.position = self.data.pos
    obj.gameObject.name = "GridBack_" .. self.data.pos.x .. "_" .. self.data.pos.y   
    
end

function M:Exit()

	M.super.Exit( self )

    if self.portal_prefab then
        CachePrefabManager.Back(self.portal_prefab)
    end

    if self.posMen then
       CachePrefabManager.Back(self.posMen)
    end

    if self.endPosMen then
        CachePrefabManager.Back(self.endPosMen)
    end

    if self.endPosSuoMen then
        CachePrefabManager.Back(self.endPosSuoMen)
    end

end

function M:CreateZhaLan(pos,name)
    name = name or "Men_menlan"
    local go = NewObject(name, CSPanel.map_node).gameObject
    go.transform.position = pos
    self:ShutZhaLan(go)
    return go
end

function M:ShutZhaLan(men_prefab)
    self:MoveZhaLan(men_prefab,Vector3.New(0,0,0),0.2)
end

function M:OpenZhaLan(men_prefab)
    self:MoveZhaLan(men_prefab,Vector3.New(0,-4,0),0.2)
end

function M:MoveZhaLan(men_prefab,pos,t)
    local childs = men_prefab.transform.childCount
    for i = 1, childs do
        local ci = men_prefab.transform:Find("building_zhalan".. i .. "/mask_1/ci")
        local seq = DoTweenSequence.Create()
        seq:Append(ci.transform:DOLocalMove(pos,t))
    end
end