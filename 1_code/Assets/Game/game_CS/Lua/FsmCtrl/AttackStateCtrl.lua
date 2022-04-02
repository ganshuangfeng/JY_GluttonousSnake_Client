------ 通用的
local basefunc = require "Game/Common/basefunc"
--[[
   hewei
   攻击状态控制器
   M
--]]
AttackStateCtrl = basefunc.class(BaseCtrl)
local M = AttackStateCtrl

--[[*****data

具体的攻击类型
data.attackType
技能
data.skillObject
*****--]]
function M:Ctor(object , data)
  M.super.Ctor(self,object , data)

    self.ctrlState = StateType.none
    
    self.skillObject = data.skillObject

end

function M:Delete()
	M.super.Delete(self)

    self.skillObject=nil

    self.object=nil
end


function M:Init()

   if not self.object and self.skillObject then
		print("M:Init: data is error!!")
   else
        --检查是否还能放技能  技能是否处于ready状态
        if self.skillObject.skillState ~= SkillState.ready then
			return 
        end

        self.ctrlState=StateType.ready 
   end

end

function M:Update(dt)
   M.super.Update(self,dt)

   if self.ctrlState~=StateType.running then
		return 
   end



end
--0准备 1开始 2运行  3暂停 4结束
function M:Begin()

  if self.ctrlState==StateType.ready then

     self.ctrlState=StateType.running

     --发送begin信号
     self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.begin,{control=self}))   

     self.isLive=true
  end
end
function M:Finish()
    if  self.object.isLive then 

    end 
    --发送结束信号
    self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.finish,{control=self}))  
    --dump( self.object , "<color=red>xxxxx--------------attackStateCtrl finish</color>" )
    self.ctrlState=StateType.finish
    self.isLive=false

end
function M:Stop()
   

    --发送强制结束信号
     self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.stop,{control=self}))  

    self.ctrlState=StateType.finish
    self.isLive=false  

end

function M:Pause()



   self.ctrlState=StateType.pause

end

function M:Resume()
 
   self.ctrlState=StateType.running

end

function M:Refresh(data)

         return true
end







