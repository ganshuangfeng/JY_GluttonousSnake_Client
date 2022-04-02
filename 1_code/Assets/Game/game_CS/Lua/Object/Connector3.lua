--[[
    闪回连接器
    仍然使用 黑屏圆圈的特效切换场景
]]
local basefunc = require "Game/Common/basefunc"

Connector3 = basefunc.class(Object)
local M = Connector3

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

end

function M:Init()
	
end


--[[
	1 -- 关卡通过了
]]
function M:event(type,data)
	if type == 1 then

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

function M:Jump()

    local sd = GameInfoCenter.GetStageData()
    local return_data = sd.return_data

    --self.data.roomNo

    local head = GameInfoCenter.GetHeroHead()
    local pos =return_data.pos
    head.transform.position = pos
    head.transform.rotation = Quaternion.Euler(0, 0, 90)
    head:SetRoomNo(return_data.roomNo)
    head.vehicle:SetPos(pos)
    CameraMoveBase.SetCameraPos( pos )
    head.followCtr:Reset()
    head.followCtr:Refresh()
    head.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
    head:SetSTDir(90)

    GameInfoCenter.SetStageData({
        roomNo = return_data.roomNo,
        return_data = {},
    })
    
end