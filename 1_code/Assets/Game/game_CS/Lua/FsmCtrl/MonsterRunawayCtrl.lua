local basefunc = require "Game/Common/basefunc"

MonsterRunawayCtrl = basefunc.class(BaseCtrl)

local M = MonsterRunawayCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )    
end

--- 状态开始时调用
function M:Begin()
	M.super.Begin(self)
    self.object.vehicle:CloseAllSteerings()
    self.object.vehicle:SetVehiclePattern("normal")
    self.object.vehicle:SetOnOff(Vehicle.SteerType.Flee,true)
    self.object.vehicle:SetOnOff(Vehicle.SteerType.Border,true)

    self.object.enableMove = true
end

function M:Update(dt)
    if self.ctrlState ~= StateType.running then
        return
    end

    local pos_table = {}

    pos_table[#pos_table + 1] = GameInfoCenter.GetHeroHead().transform.position
    local t_p = GameInfoCenter.GetHeroPosList()
    for i = 1,#t_p do
        pos_table[#pos_table + 1] = t_p[i]
    end

    self.object.vehicle:SetTargetPos(Vehicle.SteerType.Flee,pos_table)							

end


-- 暂停时调用
function M:Pause()
    self.object.enableMove = false
    self.ctrlState = StateType.pause

    return true
end

-- 继续时调用
function M:Resume()
    self.object.enableMove = true
    self.ctrlState = StateType.running

end

--- 结束时调用
function M:Finish()
    self.object.enableMove = false
    self.ctrlState = StateType.finish

    ---- 关闭力
    self.object.vehicle:SetOnOff(Vehicle.SteerType.Flee,false)
    self.object.vehicle:SetOnOff(Vehicle.SteerType.Border,false)

end