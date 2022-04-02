--[[ 行动力管理器
    
]]

local basefunc = require "Game.Common.basefunc"


ActactManager = {}
local M = ActactManager


local CapacityMax = 20
local RecoverTime = 60
local ConsumeValue = 5

function M.Init(data)
    
    if not M.instanced then
        if AppDefine.IsEDITOR() then
            data.value = 99999
        end
        M.value =  data.value
        M.lastRecoverTime = data.time

        M.updateTimer = Timer.New(M.Update, 1, -1, nil, true)
        M.updateTimer:Start()
        
        M.Update(0)

        M.instanced = true
    end
end

function M.Update(timeElapsed)
    
    local ct = os.time()

    if M.value >= CapacityMax then
        M.lastRecoverTime = ct
        -- dump({M.value,M.lastRecoverTime},"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm1")
        return
    end

    local dt = ct - M.lastRecoverTime

    if dt >= RecoverTime then

        local v = math.floor(dt/RecoverTime)
        M.AddValue(v)

        if M.value < CapacityMax then
            local lt = dt - v*RecoverTime
            M.lastRecoverTime = ct - lt
        else
            M.lastRecoverTime = ct
        end

    end
    
    -- dump({M.value,M.lastRecoverTime},"mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm2")

end

function M.GetCapacityMax()
    return CapacityMax
end

function M.GetShowValue()
    return string.format("%d/%d",ActactManager.value , CapacityMax)
end

function M.AddValue(v)
    M.value = M.value + v
    if v > 0 then
        M.value = math.min(math.max(M.value,0),CapacityMax)
    else
        M.value = math.max(M.value,0)
    end

    Event.Brocast("ActactValueChange",M.value)

    Network.SendRequest("set_vit_data", { vit=M.value, vit_time=M.lastRecoverTime }, function (_ret)
        if _ret.result ~= 0 then
            HintPanel.ErrorMsg(_ret.result)
        end
    end)
    
end


--[[消费体力
    1|nil 进行游戏
]]
function M.ConsumeValue(type)
    type = type or 1

    if M.value < ConsumeValue then
        return 1024
    else
        M.AddValue(-ConsumeValue)
        return 0
    end

end


--[[获取下一次体力值的剩余时间秒数

]]
function M.GetNextTime()

    if M.value >= CapacityMax then
        return nil
    end

    local ct = os.time()
    local dt = ct - M.lastRecoverTime
    local tt = RecoverTime - dt

    return math.max( tt, 0)
end



function M.Exit()
    M.updateTimer:Stop()
    M.instanced = false
end