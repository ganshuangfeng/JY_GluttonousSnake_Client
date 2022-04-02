local basefunc = require "Game.Common.basefunc"
ExtRequire "Game/CommonPrefab/Lua/RedPointEnum"
ExtRequire "Game/CommonPrefab/Lua/RedPointNode"

RedPointSystem = basefunc.class()

local M = RedPointSystem

function M:Ctor()
	---根节点
	self.rootNode = nil
	---配置红点列表
	self.listConfig = {}
	dump(self,"<color=green>红点系统Ctor</color>")
	self:Init()
end

---初始化红点结构
function M:Init()
	self.rootNode = RedPointNode.New()
	self.rootNode:Init()
	self.rootNode.name = ""
	for i = 1, #self.listConfig do
		self:CreateNode(self.listConfig[i])
	end
	dump(self,"<color=green>红点系统Init</color>")
end

function M:ConvertNodeName(nodeName)
	if not nodeName then return end
	local nodeNameArr = string.split(nodeName, ".")
	if #nodeNameArr == 0 then
		return
	end
	return nodeNameArr
	-- nodeName = nodeNameArr[#nodeNameArr]
	-- return nodeName
end

function M:GetRedNode(nodeName)
	local nodeNameArr = self:ConvertNodeName(nodeName)
	if not nodeNameArr then return end
	local node = self:PeekNode(self.rootNode.childNodes[nodeNameArr[1]], nodeNameArr,1);
	if not node then
		logError("[GetRedNode] not found node => " .. nodeName)
		return
	end
	return node
end

function M:PeekNode(node, nodeNameArr,i)
	if not node then
		return
	end
	if i > #nodeNameArr then
		return
	end
	local nodeName = nodeNameArr[i]
	if node.name ~= nodeName then
		return
	end

	if i == #nodeNameArr then
		return node
	end
	for j, v in pairs(node.childNodes or {}) do
		local result = self:PeekNode(v, nodeNameArr,i + 1)
		if result ~= nil then
			return result
		end
	end
end

--创建节点
function M:CreateNode(nodeName)
	local node = self.rootNode
	local arraySplit = string.split(nodeName, ".")
	if #arraySplit > 1 then
		for j = 1, #arraySplit do
			if node.childNodes[arraySplit[j]] == nil then
				node.childNodes[arraySplit[j]] = RedPointNode.New()
				node.childNodes[arraySplit[j]]:Init(arraySplit[j], node)
			else
				node.childNodes[arraySplit[j]].name = arraySplit[j];
				node.childNodes[arraySplit[j]].parent = node;
			end
			node = node.childNodes[arraySplit[j]];
		end
	end
end

---清空节点数据
function M:ClearNode(nodeName)
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[ClearNode] not found node => " .. nodeName)
		return
	end
	node:SetNum(0)
end

---注册回调
function M:RegisterEvent(nodeName, onRedPointNumChange)
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[RegisterEvent] not found node => " .. nodeName)
		return
	end
	node.OnRedPointNumChange = node.OnRedPointNumChange or {}
	node.OnRedPointNumChange[onRedPointNumChange] = onRedPointNumChange
end

--移除回调
function M:RemoveEvent(nodeName,onRedPointNumChange)
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[RemoveEvent] not found node => " .. nodeName)
		return
	end
	node.OnRedPointNumChange = node.OnRedPointNumChange or {}
	node.OnRedPointNumChange[onRedPointNumChange] = nil
end

--执行回调
function M:CallEvent(nodeName,onRedPointNumChange)
	if not onRedPointNumChange then return end
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[CallEvent] not found node => " .. nodeName)
		return
	end
	if not node.OnRedPointNumChange or not node.OnRedPointNumChange[onRedPointNumChange] then
		return
	end
	node.OnRedPointNumChange[onRedPointNumChange](node)
end

---设置红点数据
function M:SetRedPointNum(nodeName, num)
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[SetRedPointNum] not found node => " .. nodeName)
		return
	end
	num = num or 1
	node:SetNum(num)
end

---获取红点数据
function M:GetRedPointNum(nodeName)
	local node = self:GetRedNode(nodeName)
	if not node then
		logError("[GetRedPointNum] not found node => " .. nodeName)
		return 0
	end
	return node:GetNum()
end

---判断节点是否有红点
function M:IsHaveRedPoint(nodeName)
	return self:GetRedPointNum(nodeName) > 0
end

M.Instance = M.New()