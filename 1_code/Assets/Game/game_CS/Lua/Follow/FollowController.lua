-- 创建时间:2021-07-29
local basefunc = require "Game/Common/basefunc"

FollowController = basefunc.class()
local M = FollowController

function M:Ctor(data)
    self.object = data.object
    self.model = FollowModel.New({controller = self,data = data})
    self.view = FollowView.New({controller = self,data = data})
end

function M:Init()
    --记录头range
    self.model:FollowAddRange(0,self.object.range)
    local tf = self.object.transform
    --加入第一个轨迹点
    local pStart = {
        pos = tf.position,
        rot = tf.rotation,
        dir = tf.right,
    }
    self.model:LocusInit(pStart)

    self.view:SaveObjectVec()
end

function M:Reset()
    local tf = self.object.transform
    --加入第一个轨迹点
    local pStart = {
        pos = tf.position,
        rot = tf.rotation,
        dir = tf.right,
    }
    self.model:LocusInit(pStart)
end

function M:Exit()
    if self.view then
        self.view:Exit()
    end
    if self.model then
        self.model:Exit()
    end
    ClearTable(self)
end

function M:FrameUpdate(dt)
    if not self.object or not self.object.isLive then
        self:Exit()
        return
    end

    local moveLenght = self.view:GetObjectMoveLenght()
    if not moveLenght then return end

    local point = self.view:GetObjectPoint()
    local locus = self.model:Move(point)
    self.view:RefreshFollowObjectVec(locus)
end

function M:Refresh()
    local locus = self.model:Refresh()
    self.view:RefreshFollowObjectVec(locus)  
end

function M:AddFollowObject(obj)
    self.view:AddFollowObject(obj)

    local loc = obj.data.location
    local range = obj.range
    local pos = obj.transform.position
    local rot = obj.transform.rotation
    local locus = self.model:FollowInsert(loc,range,pos,rot)
    self.view:RefreshFollowObjectVec(locus)
end

function M:DelFollowObject(loc)
    self.view:DelFollowObject(loc)

    local locus = self.model:FollowRemove(loc)
    self.view:RefreshFollowObjectVec(locus)
end

function M:RefreshFollowObject(objs)
   self.view:RefreshFollowObject(objs)
end

function M:GetPointByRange(range)
    return self.model:GetPointByRange(range)
end

function M:GetAllFollowObjectRange()
    return self.model:GetAllFollowObjectRange()
end