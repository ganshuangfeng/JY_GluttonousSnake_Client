--[[
    传送门连接器
]]
local basefunc = require "Game/Common/basefunc"

Connector2 = basefunc.class(Object)
local M = Connector2

function M:Ctor(data)
	M.super.Ctor( self , data )

	self.data = data

    if not self.data.roomNo then
        return
    end
    
    self:AddMsgListener()

    self.state = "off"

    local sd = GameInfoCenter.GetStageData()
    self.stage = sd.curLevel
    self.last_roomNo = sd.roomNo
    self.goto_roomNo = self.data.roomNo

	self:CreateUI()
end

function M:AddMsgListener()
    self.lister = {}
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Init()
	
end

function M:CreateUI()
    --创建传送门
    self.csmPrefab = CachePrefabManager.Take("CSM_chuansongmen", CSPanel.map_node)
    self.csmGameObj = self.csmPrefab.prefab.prefabObj.gameObject
    self.csmGameObj.transform.position = self.data.pos

    -- self.csmGameObj:SetActive(false)
    
    self.state = "on"
end


-- 检测切换
function M:FrameUpdate(dt)
    
    if self.state ~= "on" then
        return
    end

    local head = GameInfoCenter.GetHeroHead()
    local hpos = head.transform.position

    if tls.pGetDistanceSqu(hpos,self.data.pos) < 3 then
        self.state = "over"
        self.csmGameObj:SetActive(false)

        self:LeaveAni()

    end

end


function M:LeaveAni()
    
    CSGamePanel.Instance():SetStopUpdate(true)

    local head = GameInfoCenter.GetHeroHead()
    local hpos = head.transform.position
    local hup = CSModel.Get3DToUIPoint(hpos)

    CSEffectManager.PlayCircleSwitchMaskFX(CSPanel.transform,hup,1,0,1,nil,function ( )
        self:Jump()
        self:EnterAni()
    end)


end

function M:EnterAni()

    local head = GameInfoCenter.GetHeroHead()
    local hpos = head.transform.position
    local hup = CSModel.Get3DToUIPoint(hpos)

    CSEffectManager.PlayCircleSwitchMaskFX(CSPanel.transform,hup,0,0,1.5,6,function ( )
        CSGamePanel.Instance():SetStopUpdate(false)
    end)

end

-- 跳转
function M:Jump()
    
    local head = GameInfoCenter.GetHeroHead()

    --初始化房间
    StageManager.StartNewStage(self.stage,self.goto_roomNo)

    head:SetRoomNo(self.goto_roomNo)

    -- 关卡数据
    local curStageConfig = GameConfigCenter.GetStageConfig(self.stage,self.goto_roomNo)

    -- 蛇头
    local pos = Vector3.New(0, -20, 0)
    if curStageConfig.startPos then
        local n = #curStageConfig.startPos
        local np = math.random(n)
        pos = curStageConfig.startPos[np]
    end
    head.transform.position = pos
    head.transform.rotation = Quaternion.Euler(0, 0, 90)
    head.vehicle:SetPos(pos)
    CameraMoveBase.SetCameraPos( pos )
    head.followCtr:Reset()
    head.followCtr:Refresh()
    head.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
    head:SetSTDir(90)

    GameInfoCenter.SetStageData({
        return_data = {
            roomNo = self.last_roomNo,
            pos = self.data.pos
        },
    })

end


function M:Exit()
	M.super.Exit( self )
    if self.csmPrefab then
        CachePrefabManager.Back(self.csmPrefab)
    end
    self:RemoveListener()
end
