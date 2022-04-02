local basefunc = require "Game/Common/basefunc"

MonsterBossAttackCtrl = basefunc.class(BaseCtrl)

local M = MonsterBossAttackCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    self.skillObject = data.skillObject
end

function M:Delete()
	M.super.Delete(self)

    self.skillObject=nil

    self.object=nil
end

--- 创建后调用
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
	if self.ctrlState ~= StateType.running then
		return
	end
	
end

--- 状态开始时调用
function M:Begin()
	if self.ctrlState==StateType.ready then

		self.ctrlState=StateType.running

        --- 播放动画
        if IsEquals(self.object.anim_pay) then
            self.object.anim_pay:Play("attack1", 0, 0)
        end

		--发送begin信号
		self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.begin,{control=self}))   

	end
end

--- 结束时调用
function M:Finish()
    if  self.object.isLive then 

    end 
    --发送结束信号
    self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.finish,{control=self}))  

    self.ctrlState=StateType.finish
    self.isLive=false
end

--强制结束
function M:Stop()
    --发送强制结束信号
     self.skillObject:AcceptMes(CreateStateMes(self.stateName,StatusMes.stop,{control=self}))  

    self.ctrlState=StateType.finish
    self.isLive=false  
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause
    return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

end
-- 刷新
function M:Refresh(_data)
	return true
end




