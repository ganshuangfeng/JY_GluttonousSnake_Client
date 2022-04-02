local basefunc = require "Game/Common/basefunc"

SkillHeroDuyeNorAttack = basefunc.class(Skill)
local M = SkillHeroDuyeNorAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
end

function M:Init(data)
    M.super.Init(self)
    LuaHelper.GeneratingVar(self.object.canno_pre.transform,self)
    
    --self.data = data or self.data

    self:InitData(data)
    --self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")
    self.isAimFinish = false
    self.object.curDir = 0
    self:CD()
    --print("xxx-----------heroNorAttack")
end

---- 初始化数据，refresh 也会调用这个
function M:InitData(data)
    M.super.InitData(self , data)

    self.data = data or self.data
    self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")
end

function M:CD()
    self.skillState = SkillState.cd
    self.data.hit_space = ModifierSystem.GetObjProp(self.object,"hit_space")
    self.cd = self.data.hit_space
end


function M:Ready(data)
    M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end

--CD中
function M:OnCD(dt)
    if self.skillState ~= SkillState.cd then
        return
    end

    --当object的攻击发生变化时，刷新CD
    local object_speed = ModifierSystem.GetObjProp(self.object,"hit_space")
    if object_speed ~= self.data.hit_space then
        self.data.hit_space = object_speed
        self.cd = self.data.hit_space
    end
    self.cd = self.cd - dt

    if self.cd <= 0 then
        self:Active()
    end
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end
    -- 一直找目标，找到后切换到ready状态
    local targetId = self:GetAttackTarget()
    if not targetId then
        return
    end

    self.targetId = targetId
	local target = ObjectCenter.GetObj(targetId)
	if not target or not target.isLive then
		return
	end
	self.targetPos = target.transform.position

    self:Ready()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end
    --print("xxx----heroNorAttack update")
    --瞄准
    self:Aim(dt)

    if self.isAimFinish then
        --print("<color=red>xxx---------------heroNorAttack self.isAimFinish </color> ")
        --攻击
        self:AttackTarget()
        --攻击完成
        self:After()
        self.isAimFinish = false
    end
end

--------消息 函数调用方式--------------------
function M:SendStateData()
    self:ResetData()
    self.object.fsmLogic:addWaitStatusForUser("attack", {skillObject = self}, nil, self)
    self.object.fsmLogic:addWaitStatusForUser("norAttack", {skillObject = self}, nil, self)

    self.sendDataCount = 2
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.hit_space
end

function M:OnAni(dt)
	if true then return end
	if not self.targetPos then return end
	AxisLookAt(self.object.turret,self.targetPos,Vector3.right)
end

--自己的逻辑------
function M:Aim_old(dt)
    self.aimRotSpeed = 16
	-- AxisLookAt(self.object.turret,self.targetPos,Vector3.right)
	-- return true

	local tpos = self.targetPos
	local old_rotation = self.object.turret.transform.rotation
	AxisLookAt(self.object.turret,tpos,Vector3.right)
	local tar_rotation = self.object.turret.transform.rotation
	self.object.turret.transform.rotation = old_rotation
	self.object.turret.transform.rotation = Quaternion.Lerp(old_rotation, tar_rotation, dt * self.aimRotSpeed)
	if Quaternion.Angle(self.object.turret.transform.rotation,tar_rotation) <= 4 then
		return true
	end
end

local dirByImg = {
    "5",
    "4",
    "3",
    "2",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "8",
    "7",
    "6",
}
function M:Aim(dt)
    local maxLen = math.ceil( dt * 30 )
    local tpos = self.targetPos
    local dir = Get3Goto2IndexDir16(Vec2DAngle(tpos - self.object.transform.position))
    if self.object.curDir ~= dir then
        local step = 1
        local len = 1
        if self.object.curDir > dir then
            if (self.object.curDir - dir) > (dir+16-self.object.curDir) then
                step = 1
                len = dir + 16 - self.object.curDir
            else
                step = -1
                len = self.object.curDir - dir
            end
        else
            if (dir - self.object.curDir) > (self.object.curDir+16-dir) then
                step = -1
                len = self.object.curDir + 16 - dir
            else
                step = 1
                len = dir - self.object.curDir
            end
        end
        local call = function (add)
            self.object.curDir = self.object.curDir + add
            self.object.curDir = self.object.curDir % 16
            if self.object.config.type == 1 or self.object.config.type == 7 or self.object.config.type == 14 then
                self.object.curDir = dir
                self.object.turret.transform.eulerAngles = Vector3.New(0,0,0)

                -- 冰冻炮台两帧变化暂时取消
                -- self.object.xx_num = self.object.xx_num or 0
                -- self.object.xx_num = (self.object.xx_num + 1) % 2
                -- if self.object.xx_num == 0 then
                --     self.object.sprite_spr.sprite = GetTexture("2D_YX_BD")
                -- else
                --     self.object.sprite_spr.sprite = GetTexture("2D_YX_bd2")
                -- end
            else 
                self.object.turret.transform.eulerAngles = Vector3.New(0,0,self.object.curDir * 22.5)
                if self.object.config.type == 4 then
                    self.object.sprite_spr.sprite = GetTexture("zt_" .. dirByImg[self.object.curDir+1])
                elseif self.object.config.type == 3 then
                    self.object.sprite_spr.sprite = GetTexture("pzp_" .. dirByImg[self.object.curDir+1])
                elseif self.object.config.type == 2 then
                    self.object.sprite_spr.sprite = GetTexture("gj_" .. dirByImg[self.object.curDir+1])
                elseif self.object.config.type == 13 then
                    self.object.sprite_spr.sprite = GetTexture("dp_" .. dirByImg[self.object.curDir+1])
                elseif self.object.config.type == 15 then
                    self.object.sprite_spr.sprite = GetTexture("shb_" .. dirByImg[self.object.curDir+1])
                end
            end
            if dir == self.object.curDir then
                self.isAimFinish = true
            end
        end

        if len > maxLen then
            call(maxLen * step)
        else
            call(len * step)
        end
    else
        self.isAimFinish = true
    end
end

function M:GetAttackTarget()
    local id = FindTargetFunc.FindOneNearMonsterOrBoxWithID(self.object.attack_range,self.object.gameObject.transform.position)
    return id
end

function M:AttackTarget()
    --local hit_data = self.object.data
    --for k, v in pairs(self.object.config) do
    --    hit_data[k] = v
    --end

    local hit_data = {}
    --- 从子弹配置中
    local bullet_config = GameConfigCenter.GetBulletConfig(self.data.bullet_id)
    for k, v in pairs(bullet_config) do
        hit_data[k] = v
    end

    hit_data.hitOrgin = {id = self.object.id}

    if self.targetPos then
        hit_data.hitTarget = {pos = self.targetPos,id = self.targetId}
    else
        hit_data.hitTarget = {angel = math.random(0, 360)}
    end

    --local damage = {}
    --[[for i = 1, #self.object.config.damage do
        damage[i] =  ModifierSystem.GetObjProp(self.object,"damage",self.object.config.damage[i] + (self.object.data.level - 1) * self.object.config.damage[i] * 0.1)
    end--]]
    

    hit_data.damage = GetBulletDamageList( self , bullet_config ) --{ GetSkillOneDamage( self , "damage_bei" , "damage_fix" ) }
    -- dump( hit_data.damage , "xxx-----------hit_data.damage:"..self.data.type )
    if bullet_config.audio_name then
        ExtendSoundManager.PlaySound(audio_config.cs[ bullet_config.audio_name].audio_name)
    end
    hit_data.fire_pos = self:FindFirePos()
    hit_data.start_pos = self.object.transform.position
    if self.object.config.penfa_pre then
        local fx_pre = NewObject(self.object.config.penfa_pre,self.object.fire_target)
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1)
        seq:AppendCallback(function()
            if IsEquals(fx_pre) then
                Destroy(fx_pre)
            end
        end)
    end

    -- dump(hit_data,"<color=yellow>发起攻击</color>")
    Event.Brocast("hero_attack_monster", hit_data)

    if self.object.cannon_animator then
        self.object.cannon_animator:Play("kaipao", 0, 0)
    end
end

function M:FindFirePos()
    local firePos = {}
    for i = 1,10 do
        if self["fire_target"..i] then
            firePos[#firePos + 1] = self["fire_target"..i]
        end
    end
    if #firePos == 0 then
        --print("xxx--------------hero_id",self.object.data.hero_id)
        return self.fire_target.transform.position
    else
        return firePos[math.random(1,#firePos)].transform.position
    end
end