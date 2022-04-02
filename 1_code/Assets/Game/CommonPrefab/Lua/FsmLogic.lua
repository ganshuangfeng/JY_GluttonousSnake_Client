--[[
	有限状态机逻辑系统
--]]

local basefunc = require "Game.Common.basefunc"

StateType =
{
    none = 0,
    ready = 1,          --准备     
    begin = 2,          --开始      
    running = 3,        --运行      
    pause = 4,            --暂停
    finish = 5,           --结束   
}

FSMstateType =
{
    wait = 1,           --新来的状态继续等待     
    discardNew = 2,     --丢弃新状态 原状态不变      
    replace = 3,        --新状态运行 原状态压栈      
    discardCur = 4,       --新状态运行 丢弃原状态
    refresh = 5,          --刷新
}

--状态的消息类型
StatusMes=
{
    none=0,
    ready = 1,          --准备     
    begin = 2,          --开始      
    running = 3,        --运行      
    pause=4,            --暂停
    finish=5,           --结束
    stop=6,             --强制结束
    discard=7,          --丢弃
}



FsmLogic = basefunc.class()
local C = FsmLogic

function C:Ctor( object , fsmConfig )

    self.object = object

    --- fsm运行的逻辑表
    self.fsmConfig = fsmConfig 

    -- 暂停的状态 堆栈，key 是插槽类型 ， value 是一个堆栈
    self.pausingStack = {}


    --正在运行的状态集合
    self.runningStateSet={}


	--等待队列
	self.waitQueue = basefunc.queue.New()
	 

end

--- 重新设置 状态表
function C:SetFsmConfig(fsmConfig)
    self.fsmConfig = fsmConfig 
end

function C:GetFsmConfig()
    return self.fsmConfig
end

function C:Delete()

    for slotName,obj in pairs(self.runningStateSet) do
        self:endState(slotName)
    end

    --状态插槽栈
    self.pausingStack = {}

    --正在运行的状态集合
    self.runningStateSet={}

    --等待队列
    self.waitQueue:clear()
  

end

--添加一个状态数据包到等待队列,
--参数为{_slotName = ?,stateName = ?,className = ?}的数组
function C:addWaitStatus(newStateData)
    
    self.waitQueue:push_back(newStateData)

end

function C:addWaitStatusForUser( stateName , data , className , callbackObj )
    self:addWaitStatus( self:createStateData( stateName , data , className , callbackObj ) )
end


function C:Update(dt)
    --print("xxxx---------fsmLogic update")
    --dump(self.runningStateSet , "xxxx--------------------self.runningStateSet:")
    --检测是否有状态自然结束
    for slotName,val in pairs(self.runningStateSet) do
        --- 先更新一下
        val:Update(dt)

        if val.ctrlState == StateType.finish then
           self:endState(slotName)

           --恢复
            self:resumeState(slotName)
        end 
    end

    --获得队列长度
    local queueSize = self.waitQueue:size()

    local i=1
	 --遍历等待队列，逐个查询状态表，处理上一帧中的等待队列，处理后等待队列为空
    local lastWaitState = nil
    local flag=true
    while i <= queueSize do

        flag=true

      	local newStateData = self.waitQueue:pop_front()

        ---- 如果当前的状态和上一个处理的状态一致，则不处理
        if newStateData and lastWaitState then 
            if newStateData.className==lastWaitState.className and newStateData.slotName==lastWaitState.slotName and newStateData.stateName == lastWaitState.stateName then 
                --flag=false
            end 
        end 

        if flag then 
            lastWaitState = newStateData
      	    self:dealState(newStateData)
        end

      	i = i + 1
    end

    --激活所有暂停的状态控制器
    for key,val in pairs(self.runningStateSet) do
       	if val.ctrlState == StateType.pause then
            val:Resume()
        elseif val.ctrlState == StateType.ready then
            val:Begin()
       	end 
    end
	
	 
end

--处理新来的状态
function C:dealState(newStateData)
            
           
	-- 查询状态表
    local _type = self:inquireStateTable( self.runningStateSet[newStateData.slotName] , newStateData )
    --print("<color=blue>xxx----------------------dealState:: </color>" , _type )
    --dump( { self.object.data.type , self.runningStateSet[newStateData.slotName] and self.runningStateSet[newStateData.slotName].stateName , newStateData } , "<color=blue>xxxx--------------------------dealState___newStateData </color>")

    --	1：当前状态不变，新状态继续排队等待
    if _type == FSMstateType.wait then

        -- self.waitQueue:pushBack(newStateData)
        self:addWaitStatus(newStateData)

    --	2：当前状态不变，丢弃新状态   
    elseif _type == FSMstateType.discardNew then

        if newStateData.callbackObj and newStateData.callbackObj.AcceptMes then
            newStateData.callbackObj:AcceptMes( CreateStateMes( newStateData.stateName , StatusMes.discard ) )
        end

        return 

    --	3: 新状态运行 老状态压栈
    elseif _type == FSMstateType.replace then

        --- 先暂停一下状态
        self:pauseState(newStateData.slotName)

        self:beginState(newStateData)

    --		4: 丢弃当前状态，弹栈
    elseif _type == FSMstateType.discardCur then

        self:endState(newStateData.slotName)

        --恢复
        self:resumeState(slotName)

        return self:dealState(newStateData) 

    --	5: 当前状态与新状态融合
    elseif _type == FSMstateType.refresh then
        --test  暂定
        self:refreshState(newStateData)

    end

end
 

-- 查询状态表
-- 返回值：
--	1：当前状态不变，新状态继续排队等待
--	2：当前状态不变，丢弃新状态
--	3: 新状态入栈
--	4: 丢弃当前状态，弹栈
--  5: 当前状态与新状态融合
function C:inquireStateTable( curStateObj , newStateData)

    --当前状态为nil  直接运行newState
	if not curStateObj then
		return FSMstateType.replace 
	end 

    local tableRet = self.fsmConfig.fsm:query( newStateData.slotName , {name= newStateData.stateName } , curStateObj.stateName )
    -- dump( { curStateObj.stateName , newStateData.stateName , tableRet } , "<color=green>xxx--------------------inquireStateTable</color>" )
    return FSMstateType[ tableRet ]
end


function C:stopState(slotName)

	self.runningStateSet[slotName]:Stop()
	self.runningStateSet[slotName] = nil

end

--结束
function C:endState(slotName)

    self.runningStateSet[slotName]:Finish()
    self.runningStateSet[slotName] = nil

end

--暂停一个正在运行的状态
function C:pauseState(slotName)
	
	if self.runningStateSet[slotName] then 
		--调用暂停   如果能被暂停 , 则被扔到暂停堆栈中
		if self.runningStateSet[slotName]:Pause()  then 
			--判断有无栈   没有就创建
			self.pausingStack[slotName] = self.pausingStack[slotName] or basefunc.queue.New()

			self.pausingStack[slotName]:push_front(self.runningStateSet[slotName])

		else
            --- 不能暂停 ， 则停止
			self.runningStateSet[slotName]:Stop()
		end 	

		self.runningStateSet[slotName]=nil
    end 
end

--恢复一个暂停的状态
function C:resumeState(slotName)
    
    --先判断栈是否存在 是否为空
    if self.pausingStack[slotName] and not self.pausingStack[slotName]:empty()  then 
		self.runningStateSet[slotName] = self.pausingStack[slotName]:pop_front()
    end    

end

--开始一个状态
function C:beginState(newStateData)
    
	self.runningStateSet[newStateData.slotName] = self:createState(newStateData)
    
    --如果创建失败 则弹栈
    if not self.runningStateSet[newStateData.slotName] then
    	self:resumeState(newStateData.slotName)
    end

end

--刷新一个状态
function C:refreshState(newStateData)

    if self.runningStateSet[newStateData.slotName] then

       self.runningStateSet[newStateData.slotName]:Refresh(newStateData.data)

	end

end

--创建一个状态
function C:createState(newStateData)
    local ret = self:createCtrl( newStateData.className , self.object , newStateData.data)

    --dump(ret , "xxx--------------createState:")

    --赋予状态名
    ret.stateName = newStateData.stateName

    --为none也是创建失败   
    if ret and ret.ctrlState == StateType.none then
        ret = nil
    end

    return ret
end


---- 创建一个控制器
function C:createCtrl( _classname , ...)

    -- 新创建, 直接用全局变量类来创建
    local ret = _G[_classname].New(...)
    ret:Init(...)

    return ret
end

---- 当 构建等待状态数据时调用 ，直接返回其对应的插槽数据，代码类数据
function C:createStateData(stateName , data , className , callbackObj )
    if not self.fsmConfig.base or not self.fsmConfig.base[stateName] then
        print( string.format( "<color=red>xxxx------------error fsmLogic not stateName:%s </color>" , stateName ) )
    end
    local slotName = self.fsmConfig.base[stateName].slotName
    local className = className or self.fsmConfig.base[stateName].className
    local stateName = stateName

    return { stateName = stateName , slotName = slotName , className = className , data = data , callbackObj = callbackObj }
end

---- 某个状态在不在起作用
function C:CheckStateWork( stateName )
    local slotName = self.fsmConfig.base[stateName].slotName

    if self.runningStateSet and self.runningStateSet[slotName] then
        return self.runningStateSet[slotName].stateName == stateName
    end

    return false
end

---- 某个插槽是啥状态
function C:GetSlotState( slotName )
    if self.runningStateSet and self.runningStateSet[slotName] then
        return self.runningStateSet[slotName].stateName
    end
    return nil
end

function CreateStateMes(stateName,mesType,data) 
	return {stateName=stateName,mesType=mesType,data=data}
end
