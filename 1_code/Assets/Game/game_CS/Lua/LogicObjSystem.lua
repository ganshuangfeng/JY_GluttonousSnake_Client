------ 逻辑单元的系统

local basefunc = require "Game/Common/basefunc"

LogicObjSystem = {}
local M = LogicObjSystem

function M.Init()
	M.logicId = 0

	--- 正在运行的逻辑 集合 , 一起运行
	M.runningLogicSet = {}

	--- 等待的逻辑列表 ， 每次都从最后往 堆栈里面塞，
	M.waitingLogicList = {}

end

---- 移除无效的，死亡的对象
function M.RemoveNotUseLogic( logic_list )
	local len = #logic_list
	local k = 1
	for i = 1 , len do
		if logic_list[i].obj.isLive then
			logic_list[k] = logic_list[i]
			k = k + 1
		else
			logic_list[i]=nil
		end
	end
end

--- 将等待队列合并到 运行池中
function M.MergeWaitEvent()
	local len = #self.waitingLogicList
	while len > 0 do
		self.runningLogicSet[#self.runningLogicSet+1] = self.waitingLogicList[len]
		self.waitingLogicList[len] = nil
		len = len - 1
	end
end

function M.RefreshEventStack()
	self:RemoveNotUseLogic(self.runningLogicSet)
	self:RemoveNotUseLogic(self.waitingLogicList)
	self:MergeWaitEvent()
end

--- 更新
function M.update(dt)
	---- 先刷新
	M.RefreshEventStack()

	--- 在更新
	if M.runningLogicSet and type(M.runningLogicSet) == "table" and next(M.runningLogicSet) then

		for key , nowLogic in pairs(M.runningLogicSet) do

			if not nowLogic.isAwake and nowLogic.Awake and type(nowLogic.Awake) == "function" then
				nowLogic.Awake()
				nowLogic.isAwake = true
			end

			nowLogic.update(dt)
		end

	end

end

function M.CreateAddEventData(obj )
	M.logicId = M.logicId + 1
	local data = {	
				id = M.logicId,
				obj = obj,
			}

	return data
end

--- 添加 logic obj
function M.AddLogicObj( logicData )
	if type(logicData)~="table" or not logicData.id then
		return  false
	end 

	self.waitingLogicList[#self.waitingLogicList+1] = logicData

	return  true

end
------- 创建 并 添加
function C:createAddLogicData( obj )
	self:AddLogicObj( self:CreateAddEventData( obj  ) )
end