--每8s无敌2s
local basefunc = require "Game/Common/basefunc"

SkillInvincible = basefunc.class(Skill)
local M = SkillInvincible
local space_time = 8
local keep_time = 2
function M:Ctor(data)
    M.super.Ctor(self, data)
    self.name = "SkillInvincible"
    self.data = data
	self.object = self.data.object
end

function M:Init(data)
    M.super.Init(self)
end



function M:Trigger()
	self.curr_used_time = 0
end

function M:OnCD()

end
--
function M:FrameUpdate(dt)
    M.super.FrameUpdate(self, dt)
	self.curr_used_time = self.curr_used_time or 0
	self.curr_used_time = self.curr_used_time + dt

	if self.curr_used_time < keep_time then
		if not self.tx_tou then 
			local data = {}
			local tx = NewObject("YX_tou_hudun",MapManager.GetMapNode())
			self.tx_tou = tx
		end
		self.invincible_index =	self.object:AddTag({form = "SkillInvincible",tag = "invincible"})
	elseif self.curr_used_time > keep_time and self.curr_used_time < space_time + keep_time then
		self.object:RemoveTagByIndex(self.invincible_index)
		if self.tx_tou then
			GameObject.Destroy(self.tx_tou)
			self.tx_tou = nil
		end
	else
		self.curr_used_time = 0
	end

	if self.tx_tou then
        self.tx_tou.transform.position = GameInfoCenter.GetHeroHead().transform.position
    end
end

function M:Finish()
    self:Exit()
end

function M:Exit()
    if self.object and self.object.skill and self.object.skill[self.id] then
        self.object.skill[self.id] = nil
    end
    M.super.Exit(self)
end