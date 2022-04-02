--启动钻头用电钻攻击敌人每0.5秒造成100伤害，此时碰撞敌人不再受伤。电钻效果持续10秒。
--道具CD：20秒

local basefunc = require "Game/Common/basefunc"

SkillHeadZuanTou = basefunc.class(Skill)
local M = SkillHeadZuanTou
function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
    self.heroHeadSpModifier = nil
	self.addTagName = "ZuanTou"
	self.effectTime = data.keep_time
	self.effectCount = 0
	self.object = self.data.object
end

function M:Init(data)
    M.super.Init(self)
    self.data = data or self.data
    self:CD()
	self.cd = 0
end

function M:Ready(data)
    M.super.Ready(self)
    self:Trigger()
    local head = GameInfoCenter.GetHeroHead()
    --head.head_anim_name = "ph"
    head:RefreshCurHeadDir()
end

function M:Finish(data)
    M.super.Finish(self)
    local head = GameInfoCenter.GetHeroHead()
    head.head_anim_name = "fc"
    head:RefreshCurHeadDir()
    self:ResetData()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end
    --- 创建 修改器
    if not self.heroHeadSpModifier then
        self:AddTX()
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()

        self.heroHeadSpModifier = CreateFactory.CreateModifier( { className = "PropModifier" , 
            object = heroHead , skill = self , 
            modify_key_name = "speed" , 
            modify_type = 2 , 
            modify_value = 200, 
        } )

        --- 暂时这样写 ， 应该写成 自动修改的方式
        local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
        heroHead.vehicle:SetMinSpeed( now_speed  )
        heroHead.vehicle:SetMaxSpeed( now_speed  )
       -- heroHead

        ---- 加一个免疫 冰冻，驱散冰冻的 标签
        AddTag( heroHead , "immune_stationary" )
        for key,obj in pairs(all_hero) do
            AddTag( obj , "immune_stationary" )
        end
        AddTag( heroHead , "break_stationary" )
        for key,obj in pairs(all_hero) do
            AddTag( obj , "break_stationary" )
        end
        ---- 加上特殊标签
        AddTag( heroHead , self.addTagName )
        self.tag_index = self.object:AddTag({form = "zuantou",tag = "immune_close_damage"})
    end

    self.effectCount = self.effectCount + dt
	if self.heroHeadSpModifier then
		self:ZuanTou(dt)
	end
    if self.effectCount > self.effectTime then
        self.effectCount = 0
        self.heroHeadSpModifier:Exit()
        self.heroHeadSpModifier = nil
        local heroHead = GameInfoCenter.GetHeroHead()
        local all_hero = GameInfoCenter.GetAllHero()
        -- 暂时这样写 ， 应该写成 自动修改的方式
        local now_speed = ModifierSystem.GetObjProp( heroHead , "speed" ) 
        heroHead.vehicle:SetMinSpeed( now_speed  )
        heroHead.vehicle:SetMaxSpeed( now_speed  )

        DeleteTag( heroHead , "immune_stationary" )
        for key,obj in pairs(all_hero) do
            DeleteTag( obj , "immune_stationary" )
        end
        DeleteTag( heroHead , "break_stationary" )
        for key,obj in pairs(all_hero) do
            DeleteTag( obj , "break_stationary" )
        end
        self.object.is_immune_close_damage = false
        ---- 加上特殊标签
        DeleteTag( heroHead , self.addTagName )
        self.object:RemoveTagByIndex(self.tag_index)
        self:After() 
        self:DelTX()
    end

end
--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
    self.lister["NewHeadExtraSkillTrigger"] = basefunc.handler(self,self.OnNewHeadExtraSkillTrigger)
end
--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

--通过面板来控制CD和记录可以使用次数
function M:OnNewHeadExtraSkillTrigger(data)
    if data.skill_key == "head_extra_skill" then
        if self.skillState ~= SkillState.active then
            return
        end
        self:Ready()
        Event.Brocast("NewHeadExtraSkillTrigger_Used",data)
    end   
end
--增加和检测特效存不存在
function M:AddTX()
    --头和尾巴
    local heroHead = GameInfoCenter.GetHeroHead()

    if not self.tx_wei then
        local tx = NewObject("YX_jiasu_tuowei",heroHead.tail.transform)
        tx.transform:Rotate(0,0,-90)
        self.tx_wei = tx
        self.tx_tou = self.tx_tou or {}
        local t1 = NewObject("CT_skill_sg",heroHead.transform)
        self.tx_tou[#self.tx_tou + 1] = t1
        local t2 = NewObject("CT_DZ_zise_gx",heroHead.transform)
        t2.transform:Rotate(0,0,-90)
        t2.transform.localScale = Vector3.New(0.7,0.7,0.7)
        self.tx_tou[#self.tx_tou + 1] = t2
    end

    --身体
    self.tx_shenti = self.tx_shenti or {}
    local all_hero = GameInfoCenter.GetAllHero()

    for key , h in pairs(all_hero) do
        --local h = HeroManager.GetHeroByLocation(i)
        if not self.tx_shenti[h.data.location] then
            local tx_name = {"CT_DZ_zise_gx","CT_DZ_zise_gx"}
            local tx = NewObject(tx_name[ h.data.location % 2 + 1],h.body)
            tx.transform.localPosition = Vector3.New(0,0,0)
            tx.transform.localScale = Vector3.New(0.46749,0.46749,0.46749)
            self.tx_shenti[h.data.location] = tx
        end
    end
end

function M:DelTX()
    if self.tx_wei then
        GameObject.Destroy(self.tx_wei)
        self.tx_wei = nil
    end

    for k , v in pairs(self.tx_shenti) do
        if IsEquals(v) then
            GameObject.Destroy(v)
        end
    end

    if self.tx_tou then
        for k , v in pairs(self.tx_tou) do
            if IsEquals(v) then
                GameObject.Destroy(v)
            end
        end
    end
    self.tx_shenti = {}
end

function M:Exit(data)
    if self.skillPre then
        Destroy(self.skillPre)
        self.skillPre = nil
    end
    M.super.Exit(self,data)
end

function M:FrameUpdate(dt)
    if not self.object or not self.object.isLive then
        self:Exit()
        return
    end
    
	if self.tx_shenti then
		for key , tx in pairs(self.tx_shenti) do
			local pos
			if key == 1 then
				pos = GameInfoCenter.GetHeroHead().transform.position
			else
				pos = GameInfoCenter.GetHeroByLocation(key - 1).transform.position
			end
            AxisLookAt(tx.transform,pos,Vector3.up)
		end
	end


    self:OnCD(dt)
    self:OnActive(dt)
    self:OnTrigger(dt)
    --self:CheckMove(dt)
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

function M:CheckMove(dt)
    self.last_head_pos = self.last_head_pos or GameInfoCenter.GetHeroHead().transform.position
    --没有移动就没有风
    if tls.pGetDistanceSqu(self.last_head_pos,GameInfoCenter.GetHeroHead().transform.position) < 0.05 then
        self.can = false
    else
        self.can = true
    end
    self.last_head_pos = GameInfoCenter.GetHeroHead().transform.position
end

function M:ZuanTou(dt)
    self.left_time = self.left_time or 0
    if self.left_time <= 0 then
        local head = GameInfoCenter.GetHeroHead()
        local hit_data = {}
        hit_data.hitOrgin = {id = head.id}
        hit_data.hitTarget = {angel = head.transform.eulerAngles.z}
        hit_data.damage = {20}
        hit_data.attackFrom = "hero"
        hit_data.bulletPrefabName = {"zuantou_zidan"}
        hit_data.moveWay = {"MoveAndRotateWithSelf"}
        hit_data.bulletLifeTime = self.effectTime
        hit_data.hitEffect = {"ExtraPenetrateHit"}
        hit_data.hitStartWay = {"IsHitSome"}
        hit_data.hitType = {"SectorShoot"}
        hit_data.bulletNumDatas = {1}
        hit_data.speed = {1}
        -- dump(hit_data,"<color=yellow>发起攻击</color>")
        Event.Brocast("hero_attack_monster", hit_data)
        self.left_time = hit_data.bulletLifeTime
    else
        self.left_time = self.left_time - dt
    end
end