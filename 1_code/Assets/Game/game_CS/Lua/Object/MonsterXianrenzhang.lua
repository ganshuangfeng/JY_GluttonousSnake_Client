---- 小怪蛇序列帧测试

local basefunc = require "Game/Common/basefunc"

MonsterXianrenzhang = basefunc.class(Monster)
local M = MonsterXianrenzhang

function M:Ctor(data)
	M.super.Ctor( self , data )
end

function M:CreateUI(data)
	M.super.CreateUI(self,data)
	if self.sprite.transform.localScale.x < 0 then
		-- dump("<color=red>？？？？？？？？？？？？？？？？</color>")
	elseif self.node.transform.localScale.x < 0 then
		-- dump("<color=red>？？？？？？？？？？？？？？？？</color>")
	end
	self.sprite.transform.localScale = Vector3.New(1,1,1)
	self.node.transform.localScale = Vector3.New(1,1,1)
end

function M:UpdateRot(pos,r)
	local head = GameInfoCenter.GetHeroHead()
	if not head then
		return
	end
	local curState = self.fsmLogic:GetSlotState("curJob")
	local moving = curState == "chase"
	local attacking = curState == "attack"
	local oldPos = self.transform.position
	local dir
	if r and (moving or attacking) then
		dir = Get3Goto2IndexDir8(r)
	else
		local oldPos = self.transform.position
		local headPos
		headPos = head.transform.position
		pos = pos or oldPos
		local angle = tls.pToAngleSelf(headPos - oldPos)/math.pi * 180
		dir = Get3Goto2IndexDir8(angle)
	end
	if dir ~= self.curDir then
		self.curDir = dir
		if moving then
			self.anim_pay:Play("move" .. self.curDir,0,0)
		elseif attacking then
			self.anim_pay:Play("attack" .. self.curDir,0,0)
		else
			self.anim_pay:Play("idle" .. self.curDir,0,0)
		end
	end
end