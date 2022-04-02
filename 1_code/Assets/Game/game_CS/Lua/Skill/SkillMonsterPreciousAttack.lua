 local basefunc = require "Game/Common/basefunc"

SkillMonsterPreciousAttack = basefunc.class(Skill)
local M = SkillMonsterPreciousAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
    self.data = data
end

function M:Init(data)
	M.super.Init( self )
    self.data = data or self.data
    self:CD()
    self.minSpeedModifier = nil
    self.maxSpeedModifier = nil
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 3
    self.cd = self.data.cd
end


function M:Ready(data)
	M.super.Ready(self)
    self:Trigger()
end

function M:FrameUpdate(dt)
	if not self.object or not self.object.isLive then 
		self:Exit()
		return 
	end

    M.super.FrameUpdate(self, dt)

    self.last_pos = self.last_pos or Vector3.zero
    if self.tx then
        self.tx.transform.position = self.last_pos
        AxisLookAt(self.tx.transform,self.object.transform.position,Vector3.right)
        self.last_pos = self.object.transform.position
    end
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end

    if not self.minSpeedModifier then
        self.rageTime = 3
        self.minSpeedModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
        object = self.object , skill = self , 
        modify_key_name = "minSpeed" , 
        modify_type = 2 , 
        modify_value = 600 ,       
        } )
        local now_speed = ModifierSystem.GetObjProp( self.object , "minSpeed" ) 
        self.object.vehicle:SetMinSpeed( now_speed  )
        self.tx = NewObject("dbg_jiasu",self.object.transform)

        ---- 加一个免疫 冰冻，驱散冰冻的 标签
        AddTag( self.object , "immune_stationary" )
        AddTag( self.object , "break_stationary" )

    end

    if not self.maxSpeedModifier then
        self.maxSpeedModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
        object = self.object , skill = self , 
        modify_key_name = "maxSpeed" , 
        modify_type = 2 , 
        modify_value = 600 ,       
        } )
        local now_speed = ModifierSystem.GetObjProp( self.object , "maxSpeed" ) 
        self.object.vehicle:SetMaxSpeed( now_speed  )
    end


    if self.minSpeedModifier then
        self.rageTime = self.rageTime - dt
        if self.rageTime < 0 then
            self.minSpeedModifier:Exit()
            self.minSpeedModifier = nil
            local now_speed = ModifierSystem.GetObjProp( self.object , "minSpeed" ) 
            self.object.vehicle:SetMinSpeed( now_speed  )
            DeleteTag( self.object , "immune_stationary" )
            DeleteTag( self.object , "break_stationary" )
        end
        
    end

    if self.maxSpeedModifier then
        if self.rageTime < 0 then
            self.maxSpeedModifier:Exit()
            self.maxSpeedModifier = nil
            local now_speed = ModifierSystem.GetObjProp( self.object , "maxSpeed" ) 
            self.object.vehicle:SetMaxSpeed( now_speed  )
            Destroy(self.tx)
            self.tx = nil
            self:After()
        end
    end

end


--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end
