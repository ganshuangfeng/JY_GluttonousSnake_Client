-- 创建时间:2019-03-11
-- 子弹

local basefunc = require "Game.Common.basefunc"

BombPrefab = basefunc.class()

local C = BombPrefab

C.name = "BulletPrefab"

local instance
function C.Create(parent, data)
    return C.New(parent, data)
end

function C:Awake()
end

function C:Start()
end

--[[
    id 子弹ID
    seat_num 用户座位号
    IsRobot 是否是机器人
    lock_fish_id 被锁定鱼的ID，没有则为空
--]]
function C:Ctor(parent, data)
    for k,v in pairs(data) do
        self[k] = v
    end
    self.prefab = CachePrefabManager.Take("BulletPrefab", nil, 10)
    self.prefab.prefab:SetParent(parent)

    self.bulled_speed = 10
    self.move_step_time = 0.15 / self.bulled_speed

    
    local tran = self.prefab.prefab.prefabObj.transform
    self.transform = tran
    self.gameObject = tran.gameObject
    self.gameObject.name = self.id
    
    self.end_pos = GameInfoCenter.GetMonsterPosById(self.id)

    self.angle = Vec2DAngle(self.end_pos - self.pos) - 90
    self.transform.rotation = Quaternion.Euler(0, 0, self.angle)

    self.transform.position = self.pos
    self:MakeLister()
    self:AddMsgListener()

    tran:GetComponent("LuaBehaviour").luaTable = self

    self.gameObject.name = self.id
    self.gameObject:SetActive(true)
    self.parent = parent

    local dis = tls.pGetLength(tls.pSub(self.pos,self.end_pos))
    local t = dis / self.bulled_speed

    self.v = 0

    -- 抛物线数值
    self.g = -self.pos.z*2 / (t*t)

end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:FrameUpdate(time_elapsed)
    if self.stop then
        return
    end

    local ct = time_elapsed
    while (true) do
        if ct >= self.move_step_time then
            if not self:RunCalc(self.move_step_time) then
                return
            end
            ct = ct - self.move_step_time
        else
            if ct > 0.01 then
                if not self:RunCalc(ct) then
                    return
                end
            end
            break
        end
    end
end

function C:RunCalc(time_elapsed)

    local v0 = self.v
    self.v = self.v + self.g * time_elapsed
    local zs = (self.v + v0) * time_elapsed * 0.5

    self.transform.position = self.transform.position
                + self.transform.up * time_elapsed * self.bulled_speed 
                + Vector3.New(0,0,zs)

    if self.transform.position.z > 0.08 then

        local ms = GameInfoCenter.GetMonstersRangePos(self.transform.position,2)
        for i,v in ipairs(ms) do
            Event.Brocast("hit_monster",{hero = self.hero_data, id = v.id})
        end

        local pp = CSModel.Get3DToUIPoint(self.end_pos)
        pp.z = 0
        -- CSAnimManager.PlayDebugFX(CSPanel.anim_node, pp, "攻击")
        AttackManager.DestoryAttack(self.id)
        
        return false
    end
    return true
end

function C:Exit()
    self:RemoveListener()
    CachePrefabManager.Back(self.prefab)
end