--道具GoodsItem上的技能（治疗）
local basefunc = require "Game/Common/basefunc"

SkillMonsterView = basefunc.class(Skill)
local M = SkillMonsterView


function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data

    self.viewRange = self.data.field or 9999999999

    self.vr2 = self.viewRange * self.viewRange

    self.isFindTarget = nil


    ----- 检查间隔
    self.checkDelay = 0.5
    self.checkDelayCount = 0

end

function M:Init(data)
    M.super.Init(self)


    self:Trigger()
end

function M:FindTarget()
    local _obj = GameInfoCenter.GetMonsterAttkByDisMin(self.object.transform.position)
    if _obj then
        local dis = tls.pGetDistanceSqu(self.object.transform.position, _obj.transform.position)
        if dis < self.vr2 then
            return true
        end
    end
end

function M:FrameUpdate(dt)
    M.super.FrameUpdate(self, dt)

    if self.object.fsmLogic:GetSlotState("curJob") ~= "idel" then
        return
    end

    if self.attackWarningPre then
        return
    end

    self.checkDelayCount = self.checkDelayCount + dt
    if self.checkDelayCount >= self.checkDelay then
        self:CheckView()
    end

    

end

----
function M:CheckView()

    Event.Brocast( "monster_view_check_target" , self.object.id )

    if self:FindTarget() then
        self.isFindTarget = true

        local tran = self.object.transform
        if self.object.warnNode then
            tran = self.object.warnNode.transform
        end

        -- CSEffectManager.PlayShowAndHideAndCall(
        --                                         tran,
        --                                         "gw_view_target",
        --                                         0,
        --                                         tran.position,
        --                                         0.3,
        --                                         nil,
        --                                         nil)

        --self.object.fsmLogic:addWaitStatusForUser("chase")

        Event.Brocast( "monster_view_find_target" , self.object.id )

    end
end

