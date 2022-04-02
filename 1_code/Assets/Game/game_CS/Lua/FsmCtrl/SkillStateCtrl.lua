local basefunc = require "Game/Common/basefunc"
--[[
   hewei
   技能状态控制器
   M
--]]
SkillStateCtrl = basefunc.class(BaseCtrl)
local M = SkillStateCtrl
--[[*****data
技能
data.skillObject


*****--]]
function M:Ctor(object, data)
    M.super.Ctor(self, object, data)
    self.ctrlState = StateType.none
    self.skillObject = data.skillObject
end

function M:Delete()
    M.super.Delete(self)
    self.skillObject = nil
    self.object = nil
end

function M:Init()
    if not self.object and self.skillObject then
        print("M:Init: data is error!!")
    else
        --检查是否还能放技能  技能是否处于ready状态
        if self.skillObject.skillState ~= SkillState.ready then
            return
        end

        self.ctrlState = StateType.ready
    end
end

function M:Update(dt)
    M.super.Update(self, dt)
    --[[if self:CheckDead(self) then
        self.ctrlState = StateType.finish
        return
    end--]]

    if self.ctrlState ~= StateType.running then
        return
    end
end

--0准备 1开始 2运行  3暂停 4结束
function M:Begin()
    if self.ctrlState == StateType.ready then
        self.ctrlState = StateType.running

        --发送begin信号
        self.skillObject:AcceptMes(CreateStateMes(self.stateName, StatusMes.begin, {control = self}))
    end
end

function M:Finish()
    --发送结束信号
    self.skillObject:AcceptMes(CreateStateMes(self.stateName, StatusMes.finish, {control = self}))

    self.ctrlState = StateType.finish
end

function M:Stop()
    --发送强制结束信号
    self.skillObject:AcceptMes(CreateStateMes(self.stateName, StatusMes.stop, {control = self}))

    self.ctrlState = StateType.finish
end
