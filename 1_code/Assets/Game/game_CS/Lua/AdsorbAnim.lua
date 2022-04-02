--吸附动画
--吸附范围 暂定为6
local basefunc = require "Game/Common/basefunc"

AdsorbAnim = basefunc.class()
local M = AdsorbAnim
M.name = "AdsorbAnim"

function M.Create(obj)
	return M.New(obj)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	if CSPanel then
		CSPanel.RemoveUpdateFunc(self)
	end
	if self.Timer then
		self.Timer:Stop()
	end
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(obj)
	self:MakeLister()
	self:AddMsgListener()
	self.obj = obj
	self.Timer = Timer.New(function()
		if IsEquals(self.obj) then
			self:CheakFunc()
		end
	end,1,-1)
	self.Timer:Start()

	CSPanel.AddUpdateFunc(self,self.Update)
end

function M:Update(time_elapsed)
	local head = GameInfoCenter.GetHeroHead()
	if not IsEquals(self.obj.gameObject) or not IsEquals(head.gameObject) then
		self:Exit()
		return
	end
	if self.canMove then
		self.obj.transform.position = Vector3.MoveTowards(self.obj.transform.position,head.transform.position,0.6)
	end
end


function M:CheakFunc()
	self.Range = 4
	local head = GameInfoCenter.GetHeroHead()
	if not head 
		or not IsEquals(head.transform)
		or not self.obj
		or not IsEquals(self.obj.transform)
		or not self.obj.isLive then
		self:Exit()
		return
	end
	local dis = tls.pGetDistanceSqu(head.transform.position,self.obj.transform.position)
	if dis < self.Range * self.Range then
		self.canMove = true
	end
end

function M:SetRange(Range)
	self.Range = Range
end