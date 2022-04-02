--[[M 对象中心

--]]

ObjectCenter = {}
local M = ObjectCenter

function M.Init()

    -- 回收池：key=classname,value={ [id]=obj }
    M.recyclePool = { }

    -- 对象池：poolName={ [id]=obj }
    M.alivePool = { }

end


function M.Create(data)

    --[[

        local pool = M.recyclePool[data.classname]
        if pool then

            local id,obj = next(pool)

            if id and obj then
                pool[id] = nil
                M.alivePool[data.classname][id] = obj
                obj:Resume(data)
                return obj
            end

        end
    ]]
    local obj = _G[data.classname].New(data)
    M.alivePool[data.poolName] = M.alivePool[data.poolName] or {}
    M.alivePool[data.poolName][obj.id] = obj
    obj:Init(data)

    return obj
end


function M.FrameUpdate(dt)
    for t,d in pairs(M.alivePool) do
        for id,obj in pairs(d) do
            
            if obj.isLive then
                obj:FrameUpdate(dt)
            else
                obj:Exit()
                -- M.recyclePool[t] = M.recyclePool[t] or {}
                -- M.recyclePool[t][id] = obj
                d[id] = nil
            end

        end
    end

end


function M.Exit()

    for t,d in pairs(M.alivePool) do
        for id,obj in pairs(d) do
            obj:Exit()
            d[id] = nil
        end
        M.alivePool[t] = nil
    end

    for t,d in pairs(M.recyclePool) do
        for id,obj in pairs(d) do
            obj:Exit()
            d[id] = nil
        end
        M.recyclePool[t] = nil
    end

end


function M.GetObjsByPoolName(t)
    return M.alivePool[t] or {}
end


function M.GetObj(id)

    for t,d in pairs(M.alivePool) do
        local obj = d[id]
        if obj then
            return obj,t
        end
    end

end
