-- 创建时间:2021-07-29
local basefunc = require "Game/Common/basefunc"
FollowModel = basefunc.class()
local M = FollowModel

--[[
    self
    {
        density, 密度
        point = {
            dir 方向
            rot 旋转
            pos 位置
            dis 距离起点的距离
            loc obj的location
        },

        locus = {
            [1] = point,
            [2] = point,
        },

        followObjRange = {
            [loc1] = 1
            [loc2] = 2
        }

    }
]]

function M:Ctor(data)
    self.object = data.object
    self.density = 1
    self.locus = {}
end

function M:Exit()
    ClearTable(self)
end

------轨迹存储-------------------
function M:LocusInit(pStart)
    self.locus = {}
    pStart.dis = 0
    self:LocusInsertPoint(pStart)
    local pEnd = {
        pos = pStart.pos - pStart.dir * 40,
        rot = pStart.rot,
        dir = pStart.dir,
        dis = 40,
    }
    self:LocusInsertPoint(pEnd)
end

function M:LocusInsertPointByDensity(p1,p2,index,rot)
    if not p1 or not p2 then return 0 end
    
    local dis = Vector3.Distance(p1.pos,p2.pos)
    local dir = Vector3.Normalize(p1.pos - p2.pos)
    local c = 0
    if dis > self.density then
        for j=1, dis / self.density,1 do
            --距离过大按密度插入
            local p  = {
                pos = p1.pos - dir * j * self.density,
                rot = rot,
                dir = dir,
                dis = p1.dis + j * self.density,
            }
            if p.pos.x ~= p2.pos.x and p.pos.y ~= p2.pos.y and p.pos.z ~= p2.pos.z then
                table.insert(self.locus,index,p)
                index = index + 1  
                c = c + 1
            end                  
        end
    end
    return c
end

function M:LocusRefreshDis(i)
    self.locus[1].dis = 0
    if i == 1 and #self.locus > 1 then
        local addDis = Vector3.Distance(self.locus[1].pos,self.locus[2].pos)
        for j=2,#self.locus,1 do
            self.locus[j].dis = self.locus[j].dis + addDis
        end
    end
end

function M:LocusRefreshDir(i)
    if i ~= #self.locus then
        self.locus[i].dir = Vector3.Normalize(self.locus[i].pos - self.locus[i + 1].pos)
    else
        if self.locus[i - 1] then
            self.locus[i].dir = Vector3.Normalize(self.locus[i - 1].pos - self.locus[i].pos)
        end
    end    
end

function M:LocusInsertPoint(point,i)
    local i = i or #self.locus + 1

    if not point.dis then
        if i == 1 then
            point.dis = 0
        else
            point.dis = Vector3.Distance(point.pos,self.locus[1].pos)
        end
    end

    table.insert(self.locus,i,point) 
    --根据密度补充点
    --补充前面的点
    local c = self:LocusInsertPointByDensity(self.locus[i - 1],point,i,point.rot)

    --补充后面的点
    c = c + self:LocusInsertPointByDensity(point,self.locus[i + 1 + c],i + 1 + c,point.rot)

    self:LocusRefreshDir(i)
    self:LocusRefreshDis(i)

    -- dump(self.locus,"<color=green>路径？？？？？？？？</color>")

    c = c + 1
    return c
end

function M:LocusRemoveBackPoint(i)
    if not self.locus[i] then return end
    local dis = 40
    local disStart = self.locus[i].dis
    local index = #self.locus + 1
    for j = i,#self.locus,1 do
        if self.locus[j].dis - disStart > dis then
            index = j
            break
        end
    end
    for j=#self.locus,index,-1 do
         self.locus[j] = nil
    end
end

function M:FollowAddRange(loc,range)
    self.followObjRange = self.followObjRange or {}
    if self.followObjRange[loc] then
        local t = {}
        for k,v in pairs(self.followObjRange) do
            if k >= loc then
                t[k + 1] = v
            else
                t[k] = v
            end
        end
        t[loc] = range
        self.followObjRange = t
    else
        self.followObjRange[loc] = range
    end
end

function M:FollowRemRange(loc)
    self.followObjRange = self.followObjRange or {}
    self.followObjRange[loc] = nil
    local t = {}
    for k,v in pairs(self.followObjRange) do
        if k > loc then
            t[k - 1] = v
        else
            t[k] = v
        end
    end
    self.followObjRange = t
end

--计算所有跟随obj在轨迹上的点
function M:CalculateAllFollowPointOnLocus()
    local locus = {}
    local function getRange(loc,range)
        if not self.followObjRange[loc] or not self.followObjRange[loc + 1] then return end
        return self.followObjRange[loc] + self.followObjRange[loc + 1] + range
    end

    local loc = 1
    local range = 0
    range = getRange(loc - 1,range)
    local locusIndex
    local insertCount = 0
    for index=1,#self.locus do
        local i = index + insertCount
        if not range then 
            break 
        end
        if math.abs(self.locus[i].dis - range) <= 0.000001 then
            locus[loc] = self.locus[i]
            self.locus[i].loc = loc
            loc = loc + 1
            range = getRange(loc - 1,range)
            if not range then
                locusIndex = i
                break
            end
        elseif self.locus[i].dis > range then
            local p1 = self.locus[i - 1]
            local p2 = self.locus[i]
            local d = p2.dis - range
            local dir = Vector3.Normalize(p1.pos - p2.pos)
            local point = {
                pos = p2.pos + dir * d,
                dir = dir,
                rot = p1.rot,
                dis = p2.dis - d,
                loc = loc
            }

            insertCount = insertCount + self:LocusInsertPoint(point,i)

            locus[loc] = point
            loc = loc + 1
            range = getRange(loc - 1,range)
            if not range then
                locusIndex = i + insertCount
                break
            end
        else
            self.locus[i].loc = loc
            locusIndex = i
        end
    end

    -- dump(locus,"<color=white>计算后的轨迹</color>")
    return locus, locusIndex
end

------插入计算-------------------
function M:FollowInsert(loc,range,pos,rot,dir)
    self:FollowAddRange(loc,range)
    local locus,locusIndex = self:CalculateAllFollowPointOnLocus()
    if locusIndex then
        self:LocusRemoveBackPoint(locusIndex + 1)
    end
    return locus
end

function M:FollowRemove(loc)
    self:FollowRemRange(loc)
    local locus,locusIndex = self:CalculateAllFollowPointOnLocus()
    if locusIndex then
        self:LocusRemoveBackPoint(locusIndex + 1)
    end
    return locus
end

------移动计算-------------------
function M:Move(point)
    -- dump(point,"<color=green>新的位置？？？？？？</color>")
    self:LocusInsertPoint(point,1)
    local locus,locusIndex = self:CalculateAllFollowPointOnLocus()
    if locusIndex then
        self:LocusRemoveBackPoint(locusIndex + 1)
    end
    return locus
end

function M:Refresh()
    local locus,locusIndex = self:CalculateAllFollowPointOnLocus()
    if locusIndex then
        self:LocusRemoveBackPoint(locusIndex + 1)
    end
    return locus
end

------固定距离点计算-------------------
function M:GetPointByRange(range)
    if not range then return end   
    for i=1,#self.locus do
        if math.abs(self.locus[i].dis - range) <= 0.000001 then
            return self.locus[i]
        elseif self.locus[i].dis > range then
            local p1 = self.locus[i - 1]
            local p2 = self.locus[i]
            local d = p2.dis - range

            local point = {
                pos = p2.pos + p2.dir * d,
                dir = p2.dir,
                rot = p2.rot,
                dis = p2.dis - d,
            }
            return point
        end
    end

    --轨迹延长线上的点
    local pEnd = self.locus[#self.locus]
    local point = {
        pos = pEnd.pos - pEnd.dir * (range - pEnd.dis),
        dir = pEnd.dir,
        rot = pEnd.rot,
        dis = range,
    }

    return point
end

function M:GetAllFollowObjectRange()
    local range = 0
    for i=1,#self.followObjRange,1 do
        range = range + self.followObjRange[i] + self.followObjRange[i - 1] 
    end
    range = range + self.followObjRange[#self.followObjRange]
    return range
end


--[[
/// <summary>
/// 计算AB与CD两条线段的交点.
/// </summary>
/// <param name="a">A点</param>
/// <param name="b">B点</param>
/// <param name="c">C点</param>
/// <param name="d">D点</param>
/// <param name="intersectPos">AB与CD的交点</param>
/// <returns>是否相交 true:相交 false:未相交</returns>
]]
function TryGetIntersectPoint(a, b, c, d)
    local intersectPos

    local ab = b - a
    local ca = a - c
    local cd = d - c

    local v1 = Vector3.Cross(ca, cd)

    if (Mathf.Abs(Vector3.Dot(v1, ab)) > 0.000001) then
        -- // 不共面
        return false
    end

    if (Vector3.Cross(ab, cd).sqrMagnitude <= 0.000001) then
        -- // 平行
        return false
    end

    local extend = false --是否计算延长线的交点

    if not extend then
        local ad = d - a
        local cb = b - c
        -- // 快速排斥
        if Mathf.Min(a.x, b.x) > Mathf.Max(c.x, d.x) or Mathf.Max(a.x, b.x) < Mathf.Min(c.x, d.x)
            or Mathf.Min(a.y, b.y) > Mathf.Max(c.y, d.y) or Mathf.Max(a.y, b.y) < Mathf.Min(c.y, d.y)
            or Mathf.Min(a.z, b.z) > Mathf.Max(c.z, d.z) or Mathf.Max(a.z, b.z) < Mathf.Min(c.z, d.z)
        then
            return false
        end

        -- // 跨立试验
        if not (Vector3.Dot(Vector3.Cross(-ca, ab), Vector3.Cross(ab, ad)) > 0
            and Vector3.Dot(Vector3.Cross(ca, cd), Vector3.Cross(cd, cb)) > 0)
        then
            return false
        end
    end

    local v2 = Vector3.Cross(cd, ab)
    local ratio = Vector3.Dot(v1, v2) / v2.sqrMagnitude
    intersectPos = a + ab * ratio
    return true, intersectPos
end