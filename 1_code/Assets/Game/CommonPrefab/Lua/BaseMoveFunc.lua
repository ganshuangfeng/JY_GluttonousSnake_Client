-- 创建时间:2021-06-25
local basefunc = require "Game/Common/basefunc"

BaseMoveFunc = basefunc.class()
local C = BaseMoveFunc
local temp_v1 = Vector3.New(90,0,0)

function C.Create(data)
    return C.New(data)
end

function C:Ctor(data)
    self.data = data
    self.stage = data.stage
    self.speed = data.speed[self.stage]
    self.check_space = 0
    --生命周期计时器
    self.curr_life_time = 0
    --攻击源头方式
    self.hitOrgin = data.hitOrgin
    --攻击目标方式
    self.hitTarget = data.hitTargets
    --当前攻击阶段
    self.stage = data.stage
    --子弹存在时间
    self.bulletLifeTime = data.bulletLifeTime
    --攻击的来源
    self.attackFrom = data.attackFrom
    --当前的子弹ID
    self.bullet_id = data.bullet_id
    --子弹角度
    self.fireAngle = data.fireAngle
    --开始的位置
    self.start_pos = data.start_pos
    --结束的位置 
    self.end_pos = data.end_pos
    --开始的英雄
    self.start_hero_id = data.start_hero_id
    --结束的怪物
    self.end_monster_id = data.end_monster_id
    
    --开始的怪物
    self.start_monster_id = data.start_monster_id
    --结束的英雄
    self.end_hero_id = data.end_hero_id

    --受击效果
    if  data.shouji_pre then
        if type(data.shouji_pre) == "string" then
            self.shouji_pre = data.shouji_pre
        else
            if data.shouji_pre[self.stage] == "nil" then
                self.shouji_pre = nil
            else
                self.shouji_pre = data.shouji_pre[self.stage]
            end
        end
    end

    if self.end_pos then
        local dis = tls.pGetLength(tls.pSub(self.start_pos,self.end_pos))
        local t = dis / self.speed
        self.v = 0
        -- 抛物线数值
        self.g = -self.start_pos.z*2 / (t*t)
    end
    --当前的检测函数
    local func_name = data.moveWay[self.stage]
    local ab = StringHelper.Split(func_name,"#")
    local type,cfg = ab[1],{ab[2],ab[3],ab[4],ab[5],ab[6],ab[7]}
    self.curr_func = self[type]
    --从配置表来的扩展参数
    self.extend_config_data = cfg
end

function C:Go(Bullet,time_elapsed)
    if self.data.bind_object_id then
        local is_bind_all_live = true 

        for i,v in ipairs(self.data.bind_object_id) do
            local obj = ObjectCenter.GetObj(v)
            if obj and obj.isLive then
            else
                is_bind_all_live = false
                break
            end
        end

        if is_bind_all_live then
            self:curr_func(Bullet,time_elapsed)
        else
            SpawnBulletManager.SetBulletFinsh(self.data.bullet_id)
        end
    else
        self:curr_func(Bullet,time_elapsed)
    end
end

function C:Exit()
    self = nil
end

---------------------------------------------------------------函数库

--直线移动
function C:LineMove(Bullet,time_elapsed)
    local speed = self.speed
    local dir = Vector3.New(0,1,0)
    Bullet.transform:Translate(dir * time_elapsed * speed);
end

--追踪
function C:LockMove(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        if monster then
            self.last_target_pos = monster.transform.localPosition
            Bullet.transform.position = Vector3.MoveTowards(Bullet.transform.position,self.last_target_pos,0.3)
            AxisLookAt(Bullet.transform,self.last_target_pos,Vector3.up)
        else
            local speed = self.speed
            local dir = Vector3.New(0,1,0)
            Bullet.transform:Translate(dir * time_elapsed * 10);
        end
    end
end

--半径逐渐增大的圆周运动
function C:CircleMoveWithRadiusUP(Bullet,time_elapsed)
    local speed = self.speed
    self.radius = self.radius or 3
    self.radius = self.radius + time_elapsed
    self.angularSpeed = self.angularSpeed or 7
    self.angularSpeed = self.angularSpeed - time_elapsed
    if self.angularSpeed < 3 then
        self.angularSpeed = 3
    end
    local hero = ObjectCenter.GetObj(self.start_hero_id)
    if not hero then
        return
    end
    local center = hero.transform.position
    self:CircleMove(Bullet,time_elapsed,self.radius,self.angularSpeed,center)
end
--圆周运动
function C:CircleMove(Bullet,time_elapsed,radius,angularSpeed,center)
    local radius = radius or 1
    local angularSpeed = angularSpeed or 270
    local hero = ObjectCenter.GetObj(self.start_hero_id)
    if hero then
        self.last_center = center
        local _pos_new = {}
        self.angled = self.angled or 0
        self.angled = self.angled + (angularSpeed * time_elapsed) % 360
        _pos_new.x = center.x + Mathf.Cos(math.rad(self.angled)) * radius;
        _pos_new.y = center.y + Mathf.Sin(  
            math.rad(self.angled)) * radius;
        _pos_new.z = Bullet.transform.position.z
        Bullet.transform.position = _pos_new
    end
end

--带转向的圆周运动
function C:CircleMoveRotate(Bullet,time_elapsed,radius,angularSpeed,center)
    local radius = radius or 1
    local angularSpeed = angularSpeed or 3
    local hero = ObjectCenter.GetObj(self.start_hero_id)
    if hero then
        self.last_center = center
        local _pos_new = {}
        self.angled = self.angled or 0
        self.angled = self.angled + (angularSpeed * time_elapsed) % 360
        _pos_new.x = center.x + Mathf.Cos(math.rad(self.angled)) * radius;
        _pos_new.y = center.y + Mathf.Sin(math.rad(self.angled)) * radius;
        _pos_new.z = Bullet.transform.position.z
        if angularSpeed < 0 then
            Bullet.transform.rotation = Quaternion.Euler(0,0,self.angled-180 )
        else
            Bullet.transform.rotation = Quaternion.Euler(0,0,self.angled )
        end
        Bullet.transform.position = _pos_new
    end
end

--向目标进行半圆周运动
function C:HalfCircleMove(Bullet,time_elapsed)
    if not self.radius then
        local dis = tls.pGetDistance(Bullet.transform.position,self.end_pos)
        self.radius = dis / 2
        self.center = (Bullet.transform.position + self.end_pos) / 2 
        self.angled = tls.pToAngleSelf(Bullet.transform.position - self.center) * 180 / math.pi
        -- self.angled = 0
        C.HalfCircleMove_Dir = C.HalfCircleMove_Dir or false
        C.HalfCircleMove_Dir = not C.HalfCircleMove_Dir
        self.angularSpeed = C.HalfCircleMove_Dir and 270 or -270
    end
    self.angularSpeed = self.angularSpeed or 270
    self:CircleMoveRotate(Bullet,time_elapsed,self.radius,self.angularSpeed,self.center)
end

--回旋镖式的曲线
function C:WhirlyMove(Bullet,time_elapsed)
    self.WhirlyMove2_had_move_time = self.WhirlyMove2_had_move_time or 0
    self.WhirlyMove2_had_move_time = self.WhirlyMove2_had_move_time + time_elapsed
    local time_scale = 1
    if self.WhirlyMove2_had_move_time < 0.6 * time_scale then
        local speed = self.speed * 1.5
        local dir = Vector3.New(0,1,0)
        Bullet.transform:Translate(dir * time_elapsed * speed);
    elseif self.WhirlyMove2_had_move_time < 1 * time_scale then
        local speed = self.speed / 6
        local dir = Vector3.New(0,1,0)
        Bullet.transform:Translate(dir * time_elapsed * speed);
    elseif self.WhirlyMove2_had_move_time < 1.6 * time_scale then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            self.last_target_pos = hero.transform.position
        end
        if self.last_target_pos then
            Bullet.transform.position = Vector3.MoveTowards(Bullet.transform.position,self.last_target_pos,0.1)
            if tls.pGetDistance(Bullet.transform.position,self.last_target_pos) < 0.1 then
                SpawnBulletManager.SetBulletFinsh(self.bullet_id)
            end
        end
    else
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            self.last_target_pos = hero.transform.position
        end
        if self.last_target_pos then
            Bullet.transform.position = Vector3.MoveTowards(Bullet.transform.position,self.last_target_pos,0.5)
            if tls.pGetDistance(Bullet.transform.position,self.last_target_pos) < 0.1 then
                SpawnBulletManager.SetBulletFinsh(self.bullet_id)
            end
        end
    end
end

--添加一个Vehicle并进行跟踪移动（自动寻找目标）
function C:VehicleLockTarget(Bullet,time_elapsed)
    local cheak_space = 0.5
    local line_time = 0.2
    self.time_used = self.time_used or 0
    self.cheak_space_num = self.cheak_space_num or 1
    self.cheak_space_num = self.cheak_space_num + time_elapsed
    self.time_used = self.time_used + time_elapsed
    if self.target_id then
        local end_obj = ObjectCenter.GetObj(self.end_monster_id)
        if not end_obj or not end_obj.isLive then
            self.target_id = nil
        end
    end
    if not self.target_id then
        if self.attackFrom == "hero" then
            if self.end_monster_id and ObjectCenter.GetObj(self.end_monster_id) then
                self.target_id = self.end_monster_id
            else
                local monster = GameInfoCenter.GetMonsterDisMin(Bullet.transform.position)
                if monster then
                    self.end_monster_id = monster.id
                    self.target_id = self.end_monster_id
                end
            end
        else
            if self.end_hero_id then
                self.target_id = self.end_hero_id
            else
                local hero = GameInfoCenter.GetHeroHead()
                if hero then
                    self.end_hero_id = hero.id
                    self.target_id = self.end_hero_id
                end
            end
        end
    end
    if self.target_id and self.time_used > line_time then
        local target_obj = ObjectCenter.GetObj(self.target_id)
        if target_obj then
            --向目标方向旋转一定角度
            if self.cheak_space_num >= cheak_space then
                self.target_pos = target_obj.transform.position
                self.cheak_space_num = 0
                local rotate_speed = 185
                local tpos = self.target_pos
                local old_rotation = Bullet.transform.rotation
                local old_angle = Bullet.transform.eulerAngles.z
                AxisLookAt(Bullet.transform,tpos,Vector3.right)
                local tar_rotation = Bullet.transform.rotation
                local tar_angle = Bullet.transform.eulerAngles.z
                Bullet.transform.rotation = old_rotation
                
                self.delta_rotate = rotate_speed * time_elapsed
                if MathExtend.Sin(tar_angle - old_angle) > 0 then
                    self.delta_rotate = - self.delta_rotate
                end
                --当偏转超过时
                if MathExtend.Sin(tar_angle - old_angle) * MathExtend.Sin(tar_angle - old_angle + self.delta_rotate) < 0 then
                    self.delta_rotate = tar_angle - old_angle
                end
            end
            if self.delta_rotate then
                Bullet.transform.rotation = Quaternion.Euler(0,0,Bullet.transform.eulerAngles.z + self.delta_rotate)
            end
        end

        self:LineMove(Bullet,time_elapsed)
    else
        self:LineMove(Bullet,time_elapsed)
        --还没找到目标就直线移动出去
    end
end

--以Z轴做抛物线计算的移动
function C:DropMove(Bullet,time_elapsed)
    local v0 = self.v
    self.v = self.v + self.g * time_elapsed
    local zs = (self.v + v0) * time_elapsed * 0.5

    Bullet.transform.localPosition = Bullet.transform.localPosition
                + Bullet.transform.up * time_elapsed * self.speed 
                + Vector3.New(0,0,zs)
end
--根据怪物位置斜向下运动
function C:DeclivousMove(Bullet,time_elapsed)
    if self.end_pos then
        self.last_target_pos = end_pos
        Bullet.transform:LookAt(self.last_target_pos)
    else
        Bullet.transform:LookAt(self.last_target_pos)
    end
    Bullet.transform:Rotate(temp_v1); 
    self:LineMove(Bullet,time_elapsed)
end
--激光式的移动方式，直接连接发起端和被攻击端（发起端可以是一个英雄或者一个位置）
function C:LaserMove(Bullet,time_elapsed)
    self.end_pos = nil
    if self.attackFrom == "monster" then
        local hero = ObjectCenter.GetObj(self.end_hero_id)
        if hero then
            self.end_pos = hero.transform.position
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
        local monster = ObjectCenter.GetObj(self.start_monster_id)
        if monster then
            self.start_pos = monster.transform.position
        end
    elseif self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if monster  then
            if monster.attack_node then 
                self.end_pos = monster.attack_node.transform.position
            else
                self.end_pos = monster.transform.position
            end
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
        if hero then
            self.start_pos = hero.transform.position
        end
    end
    if self.end_pos then 
        self.last_target_pos = self.end_pos
        local v = (self.start_pos + self.end_pos) / 2
        local dis = tls.pGetDistance(self.start_pos,self.end_pos)
        Bullet.transform:LookAt(Vector3.New(self.last_target_pos.x,self.last_target_pos.y,self.last_target_pos.z))
        Bullet.transform.position = v
        Bullet.transform.localScale = Vector3.New(0.2,dis,0.2)
        Bullet.transform:Rotate(temp_v1);
        Bullet.gameObject:SetActive(true)
    else
        SpawnBulletManager.SetBulletFinsh(self.bullet_id)
    end
end

--利用遮罩机制实现的激光移动
function C:LaserMove2(Bullet,time_elapsed)
    self.end_pos = nil
    if self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if monster then
            if monster.attack_node then 
                self.end_pos = monster.attack_node.transform.position
            else
                self.end_pos = monster.transform.position
            end
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
        if hero then
            self.start_pos = hero.transform.position
        end
    end
    if self.end_pos then
        if not self.mask then
            local temp_ui = {}
            LuaHelper.GeneratingVar(Bullet.transform,temp_ui)
            self.mask = temp_ui.Mask
        end
        self.last_target_pos = self.end_pos
        local dis = tls.pGetDistance(self.start_pos,self.end_pos)
        Bullet.transform:LookAt(Vector3.New(self.last_target_pos.x,self.last_target_pos.y,self.last_target_pos.z))
        Bullet.transform.position = self.start_pos
        self.mask.transform.localPosition = Vector3.New(dis,0,0)
        Bullet.transform:Rotate(temp_v1);
        Bullet.gameObject:SetActive(true)
    else
        SpawnBulletManager.SetBulletFinsh(self.bullet_id)
    end
end

--带旋转扫射的激光
function C:LaserMoveRacastHitWithRotate(Bullet,time_elapsed)
    local max_length = 100
    local rotate_speed = 1
    self.fireAngle = self.fireAngle + rotate_speed
    local direction = Vector2.New( MathExtend.Cos( self.fireAngle) , MathExtend.Sin( self.fireAngle) )
    Bullet.transform.eulerAngles = Vector3.New(0,0,Bullet.transform.eulerAngles.z + rotate_speed)
    local hitInfo = nil
    local hitInfos = UnityEngine.Physics2D.RaycastAll(self.start_pos,direction)
    for i = 0,hitInfos.Length - 1 do
        local m_hitInfo = hitInfos[i]
        local obj_id = tonumber(m_hitInfo.transform.gameObject.name)
        if self.attackFrom == "monster" then
            if obj_id ~= self.start_monster_id then
                local obj = ObjectCenter.GetObj(obj_id)
                if obj and obj.gameObject and (m_hitInfo.transform.gameObject.layer == LayerMask.NameToLayer("hero_head") or m_hitInfo.transform.gameObject.layer == LayerMask.NameToLayer("MapBuilding")) then
                    hitInfo = m_hitInfo
                    dump(hitInfo,"<color=red>GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG</color>")
                    break
                end
            end
        end
    end
end


--激光移动方式(碰到可碰撞物体后停止)
function C:LaserMoveRacastHit(Bullet,time_elapsed)
    local max_length = 100
    if self.start_monster_id and ObjectCenter.GetObj(self.start_monster_id) and ObjectCenter.GetObj(self.start_monster_id).isLive then
        if self.end_pos and self.start_pos then
            self.direction = self.end_pos - self.start_pos
            local hitInfo = nil
            local hitInfos = UnityEngine.Physics2D.RaycastAll(self.start_pos,self.direction)
            for i = 0,hitInfos.Length - 1 do
                local m_hitInfo = hitInfos[i]
                local obj_id = tonumber(m_hitInfo.transform.gameObject.name)
                if self.attackFrom == "monster" then
                    if obj_id ~= self.start_monster_id then
                        local obj = ObjectCenter.GetObj(obj_id)
                        if obj and obj.gameObject and (m_hitInfo.transform.gameObject.layer == LayerMask.NameToLayer("hero_head") or m_hitInfo.transform.gameObject.layer == LayerMask.NameToLayer("MapBuilding")) then
                            hitInfo = m_hitInfo
                            break
                        end
                    end
                end
                if self.attackFrom == "hero" then
                    if obj_id ~= self.start_hero_id then
                        local obj = ObjectCenter.GetObj(obj_id)
                        if obj and obj.data and obj.data.poolName and obj.data.poolName ~= "hero" then
                            hitInfo = m_hitInfo
                            break
                        end
                    end
                end
            end
            Bullet.transform:LookAt(self.end_pos)
            Bullet.transform:Rotate(temp_v1);
            
            if not self.mask then
                local temp_ui = {}
                LuaHelper.GeneratingVar(Bullet.transform,temp_ui)
                self.mask = temp_ui.Mask
            end
            if hitInfo then
                local obj = ObjectCenter.GetObj(tonumber(hitInfo.transform.gameObject.name))
                if obj then
                    local end_pos = obj.transform.position
                    local dis = hitInfo.distance
                    if self.dis and dis < self.dis then
                        --距离短时说明被挡住了
                        self.mask.transform.localPosition = Vector3.New(dis,0,0)
                    end
                    self.mask.transform.localPosition = Vector3.New(dis,0,0)
                    self.dis = dis
                    self.hit_obj = obj
                    self.cur_dis = self.mask.transform.localPosition.x
                end
            else
                self.mask.transform.localPosition = Vector3.New(max_length,0,0)
            end
        end
    else 
        SpawnBulletManager.SetBulletFinsh(self.bullet_id)
    end
end

--激光式的移动方式，直接连接发起端和被攻击端(需要挂在某一个英雄身上)
function C:BigLaserMove(Bullet,time_elapsed)
    self.end_pos = nil
    if self.attackFrom == "hero" then
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if monster then
            if monster.attack_node then 
                self.end_pos = monster.attack_node.transform.position
            else
                self.end_pos = monster.transform.position
            end
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
        if hero then
            self.start_pos = hero.transform.position
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
    if self.start_pos and self.end_pos then
        self.last_target_pos = self.end_pos
        local v = (self.start_pos + self.end_pos) / 2
        local dis = tls.pGetDistance(self.start_pos,self.end_pos)
        Bullet.transform:LookAt(Vector3.New(self.last_target_pos.x,self.last_target_pos.y,self.last_target_pos.z))
        Bullet.transform.position = v
        Bullet.transform.localScale = Vector3.New(0.2,dis,0.2)
        Bullet.transform:Rotate(temp_v1);
        Bullet.gameObject:SetActive(true)
    else
        SpawnBulletManager.SetBulletFinsh(self.bullet_id)
    end
end
--闪电链的移动方式
function C:LighteningMove(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        local monster = ObjectCenter.GetObj(self.end_monster_id)
        if hero and monster then
            Bullet.transform:Find("1").transform.position = hero.transform.position
            Bullet.transform:Find("2").transform.position = monster.transform.position
        end
    end
end
--光圈攻击的移动方式
function C:GQMove(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        self.last_target_pos = self.end_pos
        local v = (self.start_pos + self.end_pos) / 2
        local dis = tls.pGetDistance(self.start_pos,self.end_pos)
        Bullet.transform:LookAt(Vector3.New(self.last_target_pos.x,self.last_target_pos.y,self.last_target_pos.z))
    end
end

function C:BossWaveMove(Bullet,time_elapsed)
    Bullet.transform.localRotation = Vector3.zero
end

function C:SectorFireMove(Bullet,time_elapsed)
    if self.attackFrom == "monster" then

    elseif self.attackFrom == "hero" then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            Bullet.transform.position = hero.transform.position
            Bullet.transform.rotation = hero.turret.transform.rotation
            Bullet.transform:Rotate(0,0,-90)
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
end

function C:DontMove(Bullet,time_elapsed)
    Bullet.transform.eulerAngles = Vector3.New(0,0,0)
end

function C:SkillRocketMove(Bullet,time_elapsed)
    local rdn_range = 6
    if self.attackFrom == "hero" then
        
    end
end
--直接贯穿的长线激光
function C:LineCrossMove(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            Bullet.transform.position = hero.transform.position
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
end
--跟随自己移动的光圈
function C:GQMoveWithSelf(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            Bullet.transform.position = hero.transform.position
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    elseif self.attackFrom == "monster" then
        local obj = ObjectCenter.GetObj(self.start_monster_id)
        if obj then
            Bullet.transform.position = obj.transform.position
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
end
--跟随发射方移动和旋转
function C:MoveAndRotateWithSelf(Bullet,time_elapsed)
    if self.attackFrom == "hero" then
        local hero = ObjectCenter.GetObj(self.start_hero_id)
        if hero then
            Bullet.transform.position = hero.transform.position
            Bullet.transform.eulerAngles = hero.transform.eulerAngles
        else
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
end

--坦克的移动方式 移动出画面后掉头
function C:SkillTankMove(Bullet,time_elapsed)
    local speed = self.speed
    local dir = Vector3.New(0,1,0)
    Bullet.transform:Translate(dir * time_elapsed * speed)
    local pos = CSModel.Get3DToUIPoint(Bullet.transform.position)
    local cur_euler = Bullet.transform.eulerAngles.z
    local pc_value = 100
    local screen_h = Screen.height
    local screen_w = Screen.width
    if pos.x - pc_value > screen_w / 2 then
        Bullet.transform.rotation = Quaternion.Euler(0, 0, 155)
    elseif pos.x + pc_value < - screen_w / 2 then
        Bullet.transform.rotation = Quaternion.Euler(0, 0, -90)
    elseif pos.y - pc_value > screen_h / 2 then
        Bullet.transform.rotation = Quaternion.Euler(0, 0, -205)
    elseif pos.y + pc_value < - screen_h / 2 then
        Bullet.transform.rotation = Quaternion.Euler(0, 0, 0)
    end
end

--抛物线的感觉丢手雷模式
function C:DropGrenades(Bullet,time_elapsed,isUnrotate)
    local anim_func = function (obj)
        local totalTime = 0.6
		local tran = obj.transform
		self.seq = DoTweenSequence.Create()
		local tarPos = self.end_pos
		self.seq:Append(tran:DOMoveX( tarPos.x  , totalTime ):SetEase(Enum.Ease.Linear))

		local upY = 1.6

        if tarPos.y > Bullet.transform.position.y then
            upY =  tarPos.y + upY
        else
            upY = Bullet.transform.position.y + upY
        end

        self.seq:Insert(0 , tran:DOMoveY(upY , totalTime/2 ):SetEase(Enum.Ease.OutCirc));
        --下落
        self.seq:Insert(totalTime / 2 , tran:DOMoveY( tarPos.y , totalTime/2  ):SetEase(Enum.Ease.InCirc));

        self.seq:OnKill(function ()
		end)
	end

    if self.end_pos and not self.seq then
        anim_func(Bullet)
    end

    self.last_target_pos = self.last_target_pos or Vector3.zero
    if not isUnrotate then
        AxisLookAt(Bullet.transform,self.last_target_pos,Vector3.up)
        Bullet.transform:Rotate(0,0,180)
    else
        Bullet.transform.eulerAngles = Vector3.New(0,0,0)
    end
    self.last_target_pos = Bullet.transform.position
end
--抛物线不旋转物体
function C:DropGrenadesNoRotate(Bullet,time_elapsed)
    self:DropGrenades(Bullet,time_elapsed,true)
end


-- 抛物线但是在更大的范围中随机
function C:DropGrenadesWithRandom(Bullet,time_elapsed)
    self.end_pos = Vector3.New(self.end_pos.x + math.random(-3,3),self.end_pos.y + math.random(-3,3))
    self:DropGrenades(Bullet,time_elapsed)
end

--抛物线的感觉丢手雷模式
function C:DropGrenades2(Bullet,time_elapsed)
    local totalTime = 1
    if not self.dis then
        self.dis = tls.pGetDistance(Bullet.transform.position,self.end_pos)
        self.angle = Vec2DAngle(self.end_pos - Bullet.transform.position,Vector3.right)
        self.base_pos = Bullet.transform.position
        C.DropGrenades2_Move = C.DropGrenades2_Move or false
        C.DropGrenades2_Move = not C.DropGrenades2_Move
        self.dir = (C.DropGrenades2_Move == true and 1 or -1) 
    end
    self.time_used = self.time_used or 0
    self.time_used = self.time_used + time_elapsed
    local x = self.time_used
    local y = math.sin(self.time_used * math.pi * 1 / totalTime) * self.dir


    local _pos = Vector3.New(x * self.dis,y * self.dis / 5,0)

    local new_x = _pos.x *  MathExtend.Cos(self.angle) - _pos.y * MathExtend.Sin(self.angle)
    local new_y = _pos.y *  MathExtend.Cos(self.angle) + _pos.x * MathExtend.Sin(self.angle)

    Bullet.transform.position = Vector3.New(new_x,new_y,0) + self.base_pos
    self.last_target_pos = self.last_target_pos or Vector3.zero
    AxisLookAt(Bullet.transform,self.last_target_pos,Vector3.up)
    Bullet.transform:Rotate(0,0,180)

    self.last_target_pos = Bullet.transform.position
end
--接触到不可穿越的物体反弹
function C:ReflectMove(Bullet,time_elapsed)
    self.time_used = self.time_used or 0
    self.time_used = self.time_used + time_elapsed
    self.last_pos = self.last_pos or Bullet.transform.position
    local tatal = self.bulletLifeTime
    local speed = self.speed * (self.bulletLifeTime - self.time_used) /self.bulletLifeTime
    local dir = Vector3.New(0,1,0)

    --local notPassGrid = GetMapNotPassGridData( MapManager.GetCurRoomAStar() )

    local curr_pos = Bullet.transform.position

    local angle_z = Bullet.transform.eulerAngles.z

	if angle_z % 90 == 0 then
		angle_z = angle_z + 10
	end
	if angle_z > 180 then
		angle_z = angle_z - 360
	end

    local npg = GetMapNotPassGridData( MapManager.GetCurRoomAStar() )
	local pos = curr_pos
    
	local k = GetMapNoByPos( MapManager.GetCurRoomAStar()  , pos ) --GetPosTagKeyStr( get_grid_pos( pos ) ) 
    if npg[k] then

        local curr_data = GetMapNoCoordByPos(MapManager.GetCurRoomAStar(),pos)
        local left = {x = curr_data.x - 1,y = curr_data.y}
        local right = {x = curr_data.x + 1,y = curr_data.y}
        local up = {x = curr_data.x,y = curr_data.y + 1}
        local down = {x = curr_data.x,y = curr_data.y - 1}

        local point = GetMapPosByNo(MapManager.GetCurRoomAStar(),k,true)
        --优先判断横
        if npg[GetMapNoByCoord(MapManager.GetCurRoomAStar(),left.x,left.y)] or 
        npg[GetMapNoByCoord(MapManager.GetCurRoomAStar(),right.x,right.y)] then
            if self.last_pos.y > point.y then
                if angle_z <= -90 and angle_z >= - 180 then
                    angle_z = angle_z - 2 * (90 - math.abs(angle_z)) 
                elseif angle_z >= -90 and angle_z <= 0 then
                    angle_z = angle_z + 2 * (90 - math.abs(angle_z))
                end
            else
                if angle_z <= 90  and angle_z >= 0 then 
                    angle_z = angle_z - 2 * (90 - math.abs(angle_z)) 
                elseif angle_z >= 90 and angle_z <= 180 then
                    angle_z = angle_z + 2 * (90 - math.abs(angle_z)) 
                end
            end
        elseif npg[GetMapNoByCoord(MapManager.GetCurRoomAStar(),up.x,up.y)] or
        npg[GetMapNoByCoord(MapManager.GetCurRoomAStar(),down.x,down.y)] then
            if self.last_pos.x > point.x then
                if angle_z <= 0 and angle_z >= - 90 then
                    angle_z =  angle_z - 2 * (90 - math.abs(angle_z)) 
                elseif angle_z >= 0 and angle_z <= 90 then
                    angle_z = angle_z + 2 * (90 - math.abs(angle_z)) 
                end
            else
                if angle_z <= -90 and angle_z >= - 180 then
                    angle_z = angle_z - 2 * (90 - math.abs(angle_z)) 
                elseif angle_z >= 90 and angle_z <= 180 then
                    angle_z = angle_z + 2 * (90 - math.abs(angle_z))
                end
            end
        else
            angle_z = angle_z - 180 + ( math.random(-20,20))
        end
	end
    Bullet.transform.eulerAngles = Vector3.New(0,0,angle_z)
    self.last_pos = Bullet.transform.position
    Bullet.transform:Translate(dir * time_elapsed * speed)
end

---- wss 反弹移动
function C:ReflectMove2(Bullet,time_elapsed,isNotDamp)
    self.time_used = self.time_used or 0
    self.time_used = self.time_used + time_elapsed
    local tatal = self.bulletLifeTime

    local speed = self.speed
    if not isNotDamp then
        speed = self.speed * math.pow(((self.bulletLifeTime - self.time_used)  / self.bulletLifeTime), 2)
    end
    local dir = Vector3.New(0,1,0)

    --local notPassGrid = GetMapNotPassGridData( MapManager.GetCurRoomAStar() )

    local last_pos = Bullet.transform.position

    local angle_z = Bullet.transform.eulerAngles.z
    --- 角度对齐 x轴正向
    angle_z = angle_z - 90

    local old_angle = angle_z

    if angle_z % 90 == 0 then
        angle_z = angle_z + 10
    end
    --[[if angle_z > 180 then
        angle_z = angle_z - 360
    end--]]
    ---- 按角度移动
    --Bullet.transform.eulerAngles = Vector3.New(0,0,angle_z)
    Bullet.transform:Translate(dir * time_elapsed * speed);

    local curr_pos = Bullet.transform.position

    local npg = GetMapNotPassGridData( MapManager.GetCurRoomAStar() , { "water" } )
    
    local k = GetMapNoByPos( MapManager.GetCurRoomAStar()  , curr_pos ) --GetPosTagKeyStr( get_grid_pos( curr_pos ) ) 
    
    local function checkIsInNoPassGrid( k , index )
        if npg[k] then
            
            index = index + 1
            if index > 4 then
                return
            end

            --- 确定 和 
            local girdSize = GetGridSize( MapManager.GetCurRoomAStar() ) 
            local girdPos = GetMapPosByNo( MapManager.GetCurRoomAStar()  , k , true )

            local girdRect = { leftDown = { x = girdPos.x - girdSize*0.5 , y = girdPos.y - girdSize*0.5 } , upRight = { x = girdPos.x + girdSize*0.5 , y = girdPos.y + girdSize*0.5 } }

            local lineK = ( curr_pos.y - last_pos.y ) / (curr_pos.x - last_pos.x)
            local lineB = curr_pos.y - lineK * curr_pos.x
            
            local isInMoveLine = function(jx , jy)
                if jx >= math.min( curr_pos.x , last_pos.x ) and jx <= math.max( curr_pos.x , last_pos.x ) and
                    jy >= math.min( curr_pos.y , last_pos.y ) and jy <= math.max( curr_pos.y , last_pos.y ) then
                        return true
                end
                return false
            end

            --- 和上边相交
            local jy = ( girdPos.y + girdSize*0.5 )
            local jx = ( jy - lineB) / lineK
            local side = 0
            if jx > girdRect.leftDown.x and jx < girdRect.upRight.x and isInMoveLine(jx , jy) then
                angle_z = 180 - (angle_z - 180)
                
                side = 1
                --dump( { old_angle , angle_z ,  side , k} , "<color=blue>xxx-------------peng zhuang 111 </color>")
            end

            --- 和下边相交
            jy = ( girdPos.y - girdSize*0.5 )
            jx = ( jy - lineB) / lineK
            if jx > girdRect.leftDown.x and jx < girdRect.upRight.x and isInMoveLine(jx , jy) then
                angle_z = 180 - (angle_z - 180)
                
                side = 2
                --dump( { old_angle , angle_z ,  side , k} , "<color=blue>xxx-------------peng zhuang 222 </color>")
            end

            ------ 和左边 相交
            jx = ( girdPos.x - girdSize*0.5 )
            jy = lineK * jx + lineB
            if jy > girdRect.leftDown.y and jy < girdRect.upRight.y and isInMoveLine(jx , jy) then
                angle_z = 360 - (angle_z - 180)
                
                side = 3
                --dump( { old_angle , angle_z ,  side , k} , "<color=blue>xxx-------------peng zhuang 333 </color>")
            end

            ------ 和右边 相交
            jx = ( girdPos.x + girdSize*0.5 )
            jy = lineK * jx + lineB
            if jy > girdRect.leftDown.y and jy < girdRect.upRight.y and isInMoveLine(jx , jy) then
                angle_z = 360 - (angle_z - 180)
                
                side = 4
                --dump( { old_angle , angle_z ,  side , k} , "<color=blue>xxx-------------peng zhuang 444 </color>")
            end

            --- 角度对齐 y 轴正向
            angle_z = angle_z + 90

            if angle_z > 360 then
                angle_z = angle_z - 360
            elseif angle_z < 0 then
                angle_z = angle_z + 360
            end

            --dump( { old_angle , angle_z ,  side} , "<color=red>xxx-------------peng zhuang</color>")

            if side ~= 0 then
                --dump( Bullet.transform.position , "xxx-----------Bullet.transform.position 1" )
                --- 碰撞了，还原，并转向
                Bullet.transform.position = last_pos
                --dump( Bullet.transform.position , "xxx-----------Bullet.transform.position 2" )
                Bullet.transform.eulerAngles = Vector3.New(0,0,angle_z)
                Bullet.transform:Translate(dir * time_elapsed * speed);
                
                ---- 
                local k = GetMapNoByPos( MapManager.GetCurRoomAStar()  , Bullet.transform.position )

                checkIsInNoPassGrid(k , index)

            end
        end
    end
    local index = 0
    checkIsInNoPassGrid(k , index)

    if speed < 2 then
        local effect_func = SpawnBulletManager.GetBulletData(self.bullet_id).hit_effect
        effect_func:GoNextStage(self.bullet_id,{pos = Bullet.transform.position},{pos = Bullet.transform.position})
    end
end

function C:ReflectMove3(Bullet,time_elapsed)
    -- body
    self:ReflectMove2(Bullet,time_elapsed, true )
end

--利用旋转正方向进行的最终方式
function C:TraceMove(Bullet,time_elapsed,noRorate,noDisappear)
    self.target_id = self.end_monster_id or self.end_hero_id


    if self.target_id then
        local end_obj = ObjectCenter.GetObj(self.target_id)
        if not end_obj or not end_obj.isLive then
            self.target_id = nil
        end
    end

    if self.target_id == nil then
        self.target_id = FindTargetFunc.FindOneNearMonsterOrBoxWithID(15,Bullet.transform.position)
    end

    if self.target_id then
        local end_pos = ObjectCenter.GetObj(self.target_id).transform.position
        local start_pos = Bullet.transform.position
        local b = Vec2DAngle2(Vector3.New(end_pos.x-start_pos.x,end_pos.y - start_pos.y,end_pos.z - start_pos.z),Bullet.transform.right)
        if b > 90 then
            Bullet.transform:Rotate(0,0,1.6)
        else
            Bullet.transform:Rotate(0,0,-1.6)
        end
    end
    local curr_pos = Bullet.transform.position
    if not noDisappear then
        local npg = GetMapNotPassGridData( MapManager.GetCurRoomAStar() , { "water" } )
        local k = GetMapNoByPos( MapManager.GetCurRoomAStar()  , curr_pos )
        if npg[k] then
            SpawnBulletManager.SetBulletFinsh(self.bullet_id)
        end
    end
    self:LineMove(Bullet,time_elapsed)
    if noRorate then
        if not self.Bullet_Main then
            self.Bullet_Main = Bullet.transform:Find("@main").transform
        end
        self.Bullet_Main.transform.eulerAngles = Vector3.New(0,0,0)
    end
    self.time_used = self.time_used or 0
    self.time_used = self.time_used + time_elapsed
    if self.bulletLifeTime - self.time_used < time_elapsed then
        if self.shouji_pre then
            if type(self.shouji_pre) == "string" then
                CSEffectManager.PlayBulletBoom({position = Bullet.transform.position},self.shouji_pre)
            else
                CSEffectManager.PlayBulletBoom({position = Bullet.transform.position},self.shouji_pre[self.stage])
            end
        end
    end
end

function C:TraceMoveNoRorateNoDisappear(Bullet,time_elapsed)
    self:TraceMove(Bullet,time_elapsed,true,true)
end

function C:TraceMoveNoDisappear(Bullet,time_elapsed)
    self:TraceMove(Bullet,time_elapsed,false,true)
end