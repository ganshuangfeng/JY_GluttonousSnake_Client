local basefunc = require "Game/Common/basefunc"

--技能运行状态
SkillState = {
    none = 0,
    cd = 1, --技能冷却中，不能触发技能
    active = 2, --技能冷却完毕，处于活跃态，可以触发技能 ，准备切换到ready状态，并发送占状态消息
    ready = 3, --准备触发 ， 等待占位成功，切换成 trigger
    before = 4, --前摇
    trigger = 5, --正在触发
    after = 6, --后摇    
    suspend = 7, --挂起
    finish = 8, --结束
}

Skill = basefunc.class(Base)
local M = Skill

function M:Ctor(data)
    M.super.Ctor(self, data)

    self.skill_id = data.id
    self.type = data.type

    self.object = data.object
    self.skillState = SkillState.none

    --- 发送占位状态数量
    self.sendDataCount = 0
    --- 占位成功状态数量
    self.acceptSucceedCount = 0
    --- 占住的状态集合
    self.stateVec = {}

    self.cd = 0
end

function M:Init(data)
    self:MakeLister()
    self:AddMsgListener()

    ---- 加到对象中去
    if self.object then
        self.object.skill[self.id] = self
    end

    -- 打断机制
    -- dump(self.data.isBreak,"<color=red>isBreak</color>")
    -- dump(self.object.config,"<color=red>self.object.config</color>")
    if self.data and self.data.isBreak and self.object.config.break_data then
        self.isBreak = true
        self.breakCount = self.object.config.break_data[1]
        self.breakDizziness = self.object.config.break_data[2]
        self.breakAwardId = self.object.config.break_data[3]
        self.curBreakCount = 0
    else
        self.isBreak = false
    end
end

function M:Exit(data)
    
    if self.chargePre then
        self.chargePre:Exit()
    end
    self.chargePre = nil
    if self.attackWarningPre then
        self.attackWarningPre:Exit()
    end
    self.attackWarningPre = nil
    self:RemoveListener()
    self.object = nil
    self.skillState = nil
    M.super.Exit(self)
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 0
    self.cd = self:GetRandomCD(self.data.cd)
end


function M:Active()
    self.skillState = SkillState.active
end

function M:Ready()
    self.skillState = SkillState.ready
end

function M:Trigger()
    self.skillState = SkillState.trigger
end

function M:Suspend()
    self.skillState = SkillState.suspend
end

function M:Finish()
    self.skillState = SkillState.finish
    --print("<color=yellow>xxx----------self.skillState:</color>" , self.skillState , self.type )
    --dump( self.stateVec , "xxxx--------self.stateVec on finish" )
    if self.stateVec then
        for key, obj in pairs(self.stateVec) do
            obj:Stop()
        end
    end
    self:ResetData()
    self:CD()

    if self.chargePre then
        self.chargePre:Exit()
    end
    self.chargePre = nil

    if self.ClearResources then
        self:ClearResources()
    end
    --print("<color=yellow>xxx----------self.skillState:</color>" , self.skillState , self.type )
end

function M:Refresh(data)
    self:InitData(data)
end

function M:InitData(data)
    
end
function M:BreakSucceed()
    self.curBreakCount = self.curBreakCount + 1
    if self.curBreakCount >= (self.breakCount) then
        self.curBreakCount = 0
        self.object.fsmLogic:addWaitStatusForUser( "stationary" ,{force = true ,keep_time = self.breakDizziness,form = self.skill_id,tag = "dizziness",prefabName="BOOS_xuanyun"})
    end
    self.chargePre:BreakSucceed()
    -- if self.breakAwardId then
    --     local cfg = GameConfigCenter.OpenBoxById(self.breakAwardId)
    --     if cfg then
    --         DropAsset.Create({pos = self.object.transform.position, destroy_time = 6})
    --     end
    -- end

    self:Finish()

end

function M:OnHit(data)
    if self.isBreak
        and self.skillState == SkillState.before then

            if data.extendData
                and data.extendData.color == self.breakColor
                and data.extendData.tag == "HeroSuperSkill" then

                    self.curBreakCount = self.curBreakCount + 1
                    if self.curBreakCount >= (self.breakCount) then
                        self.curBreakCount = 0
                        self.object.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = self.breakDizziness,form = self.skill_id,tag = "dizziness",prefabName="BOOS_xuanyun"})
                    end
                    self.chargePre:BreakSucceed()
                    if self.breakAwardId then
                        local cfg = GameConfigCenter.OpenBoxById(self.breakAwardId)
                        if cfg then
                            --dump(cfg, "<color=red>breakAward AAAAAAAAAAAAAAAAAAAA </color>")
                            DropAsset.Create({pos = self.object.transform.position, destroy_time = 6})
                        end
                    end

                    self:Finish()
            end
    end
end

function M:Before()
    if self.data and self.data.beforeCd then
        self.cd = self.data.beforeCd
        self.skillState = SkillState.before

        if self.data.isBreak then
            self.object.anim_pay.speed = 0
            local rdn = math.random(0,1)
            --#临时修改 限制只能随机到第二种和第四种
            self.breakColor = rdn == 0 and 2 or 4
        
            self.chargePre = ChargePrefab.Create(function ()
                self.object.anim_pay.speed = 1
                self.chargePre = nil            
            end
            ,function ()
                -- self:Trigger()
            end,
            self,
            self.object.node.transform)
        else
            self.cd = self.data.beforeCd
            self.object.anim_pay.speed = 0
            local parent = self.object
            if self.object.com_attack_warning_node then  parent = self.object.com_attack_warning_node end
            self.attackWarningPre = MonsterComAttackWarningPrefab.Create(parent,self.cd,function()
                --在cd里面触发过了这里就不需要写了
                -- self:Trigger()
            end,
            function()
                self.object.anim_pay.speed = 1
                self.attackWarningPre = nil    
            end,self.data.flashTime)
        end
    else
        self:Trigger()
    end
end

function M:After()
    if self.data and self.data.afterCd then
        self.skillState = SkillState.after
        self.cd = self.data.afterCd
    else
        self:Finish()
    end
end

--------update中持续做的事--------------------
function M:FrameUpdate(dt)    
    if not self.object or not self.object.isLive then
        self:Exit()
        return
    end
    
    self:OnCD(dt)
    self:OnActive(dt)
    self:OnTrigger(dt)
    
    if self.chargePre then
        self.chargePre:FrameUpdate(dt)
    end
    if self.attackWarningPre then
        self.attackWarningPre:FrameUpdate(dt)
    end
end

function M:OnCD(dt)
    if self.skillState ~= SkillState.cd
    and self.skillState ~= SkillState.before
    and self.skillState ~= SkillState.after then
        return
    end
    self.cd = self.cd - dt

    if self.skillState == SkillState.cd then
        if self.cd <= 0 then
            self:Active()
        end
    end
    if self.skillState == SkillState.before then
        if self.cd <= 0 then
            self:Trigger()
        end
    end
    if self.skillState == SkillState.after then
        if self.cd <= 0 then
            self:Finish()
        end
    end
end

function M:OnActive(dt)
end

function M:OnReady(dt)
end

function M:OnTrigger(dt)
end

function M:OnSuspend(dt)
end

function M:OnFinish(dt)
end

--------消息 事件通知方式--------------------
function M:MakeLister()
    self.lister = {}
end

function M:AddMsgListener()
    for msg,func in pairs(self.lister) do
        Event.AddListener(msg, func)
    end
end

function M:RemoveListener()
    for msg,func in pairs(self.lister) do
        Event.RemoveListener(msg, func)
    end
    self.lister = {}
end

--------消息 函数调用方式--------------------
function M:SendStateData()

end

function M:AcceptMes(_data)
    -- print("xxx---------------self.type:" , self.type)
    -- dump( { _data.mesType , _data.data and _data.data.control.stateName , self.skillState ,  self.skill_id } ,
    --     "<color=red>xxx------------- skill AcceptMes </color>" .. (self.object and self.object.data.poolName or "nil") .. "," .. ( self.object and self.object.data.type or "nil" ) )
    

    if self.skillState == SkillState.ready then
        if _data.mesType == StatusMes.begin then
            self.acceptSucceedCount = self.acceptSucceedCount +1 
            if _data.data.control then
                self.stateVec[#self.stateVec + 1] = _data.data.control
            end
            -- 技能可以攻击了
            if self.acceptSucceedCount == self.sendDataCount then
                self:Before()
            end
        end
    end

    if _data.mesType == StatusMes.discard or _data.mesType == StatusMes.stop or _data.mesType == StatusMes.finish then
        -- 正在运行
        if self.skillState == SkillState.trigger or self.skillState == SkillState.before or self.skillState == SkillState.after then
            self:Finish()
        else
            self:ResetData()
            -- 重新回到活跃态  策划要求
            --self:Active()
            ---- 加上这句话，当占位的状态被丢掉或结束时，重新回到CD状态。
            self:CD()
        end
    end

end

function M:ResetData()
    --- 发送占位状态数量
    self.sendDataCount = 0
    --- 占位成功状态数量
    self.acceptSucceedCount = 0

    self.stateVec = {}
end

--随机攻击间隔
function M:GetRandomCD(data_cd)
	if type(data_cd) == "number" then
		return data_cd
	elseif type(data_cd) == "table" then
		return math.random() * (tonumber(data_cd[1]) - tonumber(data_cd[2])) + tonumber(data_cd[1])
    else
        return 0
	end
end