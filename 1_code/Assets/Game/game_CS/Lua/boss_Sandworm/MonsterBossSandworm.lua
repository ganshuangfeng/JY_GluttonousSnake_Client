-- 创建时间:2021-10-19
---- 沙虫boss （三个boss共享血量）

local basefunc = require "Game/Common/basefunc"
local monsterBossFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterBossFsmTable"

MonsterBossSandworm = basefunc.class(MonsterBossSandwormMain)
local M = MonsterBossSandworm

function M:OnHit(data)
	if not self.mainBoss then
		self:GetOther()
	end
	if self.mainBoss and self.mainBoss.isLive then
		self.mainBoss:OnHit(data)
		self.hp = self.mainBoss.hp
	end
end

--找到场景中的主体
function M:GetOther()
	local monsters = GameInfoCenter.GetAllMonsters()
	for k,v in pairs(monsters) do
		if v.config.classname == "MonsterBossSandwormMain" then
			self.mainBoss = v
		elseif v.config.classname == "MonsterSandworm" and v.id ~= self.id then
			self.otherBoss = v
		end
	end
end