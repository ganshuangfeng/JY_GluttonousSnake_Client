-- 创建时间:2021-08-18

ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveBase")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveClick")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveRocker")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveSlide")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveSpot")
ExtRequire("Game.CommonPrefab.Lua.SnakeHeadMoveRocker360")

SnakeHeadMoveManual = {}
local M = SnakeHeadMoveManual

local instance = nil
function M.Create(data)
	if not instance or IsEquals(instance.gameObject) then
		CSModel.heroHeadPattern = "grid"
		if data and data.type then
			if data.type == 1 then
				instance = SnakeHeadMoveClick.Create()
			elseif data.type == 2 then
				instance = SnakeHeadMoveSlide.Create()
			elseif data.type == 3 then
				instance = SnakeHeadMoveRocker.Create()
			elseif data.type == 4 then
				instance = SnakeHeadMoveSpot.Create()
			elseif data.type == 5 then
				CSModel.heroHeadPattern = "dir"
				instance = SnakeHeadMoveRocker360.Create()
			end
		else
			CSModel.heroHeadPattern = "dir"
			instance = SnakeHeadMoveRocker360.Create()
		end
	end
end

function M.Exit()
	if instance and instance.Exit then
		instance:Exit()
	end
	instance = nil
end
