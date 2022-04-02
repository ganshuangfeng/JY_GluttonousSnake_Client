local basefunc = require "Game/Common/basefunc"

SkillHeroJiaTeLinAttacK = basefunc.class(SkillHeroNorAttack)
local M = SkillHeroJiaTeLinAttacK

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
        hit_data.hitTarget = {angel = Vec2DAngle(Vector3.New(self.targetPos.x-self.object.transform.position.x,self.targetPos.y - self.object.transform.position.y,self.targetPos.z-self.object.transform.position.z))}
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
        else
            break
        end
    end
    if #firePos == 0 then
        --print("xxx--------------hero_id",self.object.data.hero_id)
        return self.fire_target.transform.position
    else
        local r = math.random(1,#firePos)
        self["fire_tx_"..r].gameObject:SetActive(false)
        self["fire_tx_"..r].gameObject:SetActive(true)
        return firePos[r].transform.position
    end
end