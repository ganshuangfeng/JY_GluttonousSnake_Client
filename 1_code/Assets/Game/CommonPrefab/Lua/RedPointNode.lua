local basefunc = require "Game/Common/basefunc"
RedPointNode = basefunc.class()
local M = RedPointNode

function M:Ctor()
	
end

function M:Init(name, parent)
	self.name = name
	self.parent = parent
	self.OnRedPointNumChange = nil
	---子节点列表
	self.childNodes = {}
	self:SetNum(0)
	-- self.num = 0
end

function M:Exit()
	ClearTable(self)
end

---是否有子节点
function M:IsLeaf()
	if self.childNodes ~= nil and #self.childNodes == 0 then
		return true
	end
	return false
end

function M:GetNum()
	return self.num
end

function M:SetNum(value)
    if self.num == value then return end
	self.num = value
	self:NotifyRedPointChange()
	if self.parent ~= nil then
		self.parent:ChangeParentRedPoint()
	end
end

function M:NotifyRedPointChange()
	if not self.OnRedPointNumChange or not next(self.OnRedPointNumChange) then return end
	for k, v in pairs(self.OnRedPointNumChange) do
		v(self)
	end
end

function M:ChangeParentRedPoint()
	local totalNum = 0
	for i, v in pairs(self.childNodes) do
		totalNum = totalNum + v.num
	end
	self:SetNum(totalNum)
	-- if self.num ~= totalNum then
	-- 	self.num = totalNum
	-- end
end