-- 创建时间:2021-08-09
--[[
    --格子
    grid = {
        id = 1,         --格子id
        size = {w,h},   --大小
        pos = {x,y},    --坐标


        isPass = true,    --能否通过
        passType = {    --能够通过格子的类型
            [1] = hero,
            [2] = monster,
        }

        building = {    --格子上的建筑
            [1] = 草，
            [2] = 树
        }
    }
]]

--以最坐下角为原点坐标,向右为X轴正方向，向上为Y轴正方向

GridBuilder = {}

local M = GridBuilder

-- wc横向格子数, hc纵向格子数, ws格子宽, hs格子高，
function M.BuildGrid(wc,hc,ws,hs)
    local grids = {}

    local id = 1
    for x = 1, wc do
        for y = 1, hc do
            grids[id] = {
                id = id,
                size = {w = ws,h = hs},
                pos = {x = x,y = y},
                isPass = true,  -- 默认格子都可以通过
            }
            id = id + 1
        end
    end

    return grids
end

function M.GetGridByPos(grids,pos)
    for i = 1, #grids do
        if grids[i].pos.x == pos.x and grids[i].pos.y == pos.y then
            return grids[i]
        end
    end
end

function M.GetGridById(grids,id)
    return grids[id]
end

function M.SetPass(grid,isPass)
    if not grid then return end
    grid.isPass = isPass
end

function M.AddBuilding(grid,id)
    grid.building = grid.building or {}
    grid.building[id] = id
end

function M.RemoveBuilding(grid,id)
    if not grid or not grid.building or not next(grid.building) then return end
    grid.building[id] = nil
end