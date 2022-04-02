-- 创建时间:2021-07-29
local basefunc = require "Game/Common/basefunc"
FollowView = basefunc.class()
local M = FollowView

function M:Ctor(data)
    self.object = data.data.object
    self.followObj = data.data.followObj or {}
end

function M:Exit()
    ClearTable(self)
end

function M:SaveObjectVec()
    self.curRot = self.object.transform.rotation
    self.curPos = self.object.transform.position
end

function M:GetObjectMoveLenght()
    local moveLenght = Vector3.Distance(self.curPos,self.object.transform.position)
    if moveLenght < 0.01 then
        return
    end
    self:SaveObjectVec()
    return moveLenght
end

function M:GetObjectPoint()
    local tf = self.object.transform
    local p = {
        pos = tf.position,
        rot = tf.rotation,
    }
    return p
end

--更新跟随obj的位置和方向
function M:RefreshFollowObjectVec(locus)
    for loc,point in ipairs(locus) do
        local obj = self.followObj[loc]
        if IsEquals(obj) and IsEquals(obj.transform) then
            obj.transform.position = point.pos
            -- obj.transform.rotation = point.rot
        end
    end
end

function M:AddFollowObject(obj)
    local loc = obj.data.location
    if not self.followObj[loc] then
        self.followObj[loc] = obj
    else
        local t = {}
        for k,v in pairs(self.followObj) do
            if k >= loc then
                t[k + 1] = v
            else
                t [k] = v
            end
        end
        t[loc] = obj

        self.followObj = t
    end
end

function M:DelFollowObject(loc)
    self.followObj[loc] = nil
    local t = {}
    for k,v in pairs(self.followObj) do
        if k >= loc then
            t[k - 1] = v
        else
            t [k] = v
        end
    end
    self.followObj = t
end

function M:RefreshFollowObject(objs)
    self.followObj = {}
    for k,v in pairs(objs) do
        self:AddFollowObject(v)
    end
end