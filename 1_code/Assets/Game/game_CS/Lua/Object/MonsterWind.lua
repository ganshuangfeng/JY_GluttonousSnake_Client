---- 小怪蛇序列帧测试

local basefunc = require "Game/Common/basefunc"

MonsterWind = basefunc.class(Monster)
local M = MonsterWind

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
	local oldPos = self.transform.position
	local headPos
	headPos = head.transform.position
	pos = pos or oldPos
	local angle = tls.pToAngleSelf(headPos - oldPos)
	if math.sin(angle) > 0 then
		if self.fsmLogic:GetSlotState("curJob") == "attack" then
			self.spriteRenderer.sprite = GetTexture("2d_gw_xfg02")
		else
			self.spriteRenderer.sprite = GetTexture("2d_gw_xfg01")
		end
	else
		self.spriteRenderer.sprite = GetTexture("2d_gw_xfg03")
	end
end