-- 创建时间:2019-03-11
-- 子弹

local basefunc = require "Game.Common.basefunc"

BulletPrefab = basefunc.class()

local C = BulletPrefab

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

    self.bulled_speed = 30
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
    self.end_pos = GameInfoCenter.GetMonsterPosById(self.id)
    if self.end_pos then
        self.angle = Vec2DAngle(self.end_pos - self.pos) - 90
        self.transform.rotation = Quaternion.Euler(0, 0, self.angle)
    
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
    else	
        AttackManager.DestoryAttack(self.id)
    end
end

function C:RunCalc(time_elapsed)
    self.transform.position = self.transform.position + self.transform.up * time_elapsed * self.bulled_speed

    if tls.pGetDistanceSqu(self.transform.position, self.end_pos) < 0.15 then
        local pp = CSModel.Get3DToUIPoint(self.end_pos)
        pp.z = 0
        -- CSAnimManager.PlayDebugFX(CSPanel.anim_node, pp, "攻击")
        -- local boom = NewObject("Boom", self.transform)
        -- GameObject.Destroy(boom,1)
        AttackManager.DestoryAttack(self.id)
        Event.Brocast("hit_monster",{hero = self.hero_data, id = self.id})
        return false
    end
    return true
end

function C:Exit()
    self:RemoveListener()
    CachePrefabManager.Back(self.prefab)
end