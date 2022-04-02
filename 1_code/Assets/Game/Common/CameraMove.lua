-- 创建时间:2021-07-08
local basefunc = require "Game/Common/basefunc"

CameraMove = basefunc.class()
local M = CameraMove
local _is_on_off = true
local _can_move = true
local instance
local base_size = 11.7

function M.Start(data)
    data = data or {}

    if not data.get_camera then
        data.get_camera = function ()
            local camera = GameObject.Find("3DCamera")
            if IsEquals(camera) then
                return camera:GetComponent("Camera")
            end
        end
    end

    if not data.get_target then
        data.get_target = function ()
            return GameObject.Find("HeroHead")
        end
    end

    if not data.get_target or not data.get_camera then return end
    if instance then
        instance:Exit()
    end
    instance = M.New(data)
    return instance
end

function M:Ctor(data)
    ExtPanel.ExtMsg(self)
    self:MakeLister()
	self:AddMsgListener()
    self.get_camera = data.get_camera
    self.get_target = data.get_target
    self.camera = self.get_camera()
    self.target = self.get_target()

    if self.start_timer then
        self.start_timer:Stop()
    end
    --local map = MapManager.GetMapSize()
    local map = GetSceenSize( MapManager.GetCurRoomAStar() )

    base_size = map.h / 20

    --这里延时处理，等待游戏界面更新完毕
    self.start_timer = Timer.New(function()
        self:InitCameraPos()

        local function update()
            self:LateUpdate()
        end

        --注册循环
        if not self.late_update_handle then
            self.late_update_handle = LateUpdateBeat:CreateListener(update,self)
        end
        LateUpdateBeat:AddListener(self.late_update_handle)        
    end,0.1,1)
    self.start_timer:Start()
end

function M:Exit()
    if self.start_timer then
        self.start_timer:Stop()
    end
    self.start_timer = nil
    self:RemoveListener()
	if self.late_update_handle then
		LateUpdateBeat:RemoveListener(self.late_update_handle)	
	end
	self.late_update_handle = nil
    instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.OnExitScene)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:OnExitScene()
    self:Exit()
end

function M:InitCameraPos()
    self.camera = self.get_camera()
    self.target = self.get_target()

    self.distance = self.camera.transform.position - self.target.transform.position
    self.distance = Vector3.New(0,-3.4,self.distance.z)
    self.default_distance = self.distance
    self.smooth_time = 0
    self.ve = Vector3.zero

    self:UpdateCameraPos()
end

function M:LateUpdate()
    if not _is_on_off then return end
    if not self:CheckUpdate() then return end
    self:UpdateSpeed()
    self:UpdateCameraPos()
end

function M:CheckUpdate()
    if not IsEquals(self.camera) then
        self.camera = self.get_camera()
    end

    if not IsEquals(self.target) then
        self.target = self.get_target()
        if IsEquals(self.target) then
            self:InitCameraPos()
        end
    end

    if not IsEquals(self.camera) or not IsEquals(self.target) then
        return
    end
    return true
end

function M:UpdateSpeed()
    if self:CheckNear() then
        self.smooth_time = 1000
        self.distance = self.default_distance
        self.cur_distance = nil
        return
    end

    if self:CheckOutRang() then
        self.smooth_time = 0
        if not self.cur_distance then
            self.cur_distance = self.camera.transform.position - self.target.transform.position
            self.distance = self.cur_distance
        end
    else
        self.smooth_time = 1000
        self.distance = self.default_distance
        self.cur_distance = nil
    end
end

function M:GetCenterPos()
    if self.center_pos then return self.center_pos end
    local offset_x = 0
    local offset_y = 340
    self.center_pos = {x = Screen.width / 2 + offset_x, y = Screen.height / 2 + offset_y,z = 0}
    return self.center_pos
end

function M:CheckNear()
    self.center_pos = self:GetCenterPos()
    local target_screen_pos = self.camera:WorldToScreenPoint(self.target.transform.position)
    local a = self.center_pos - target_screen_pos
    local b = self.target.transform.right
    local angle = Vector3.Angle(a,b)
    return angle <= 90
end

function M:CheckOutRang()
    local target_screen_pos = self.camera:WorldToScreenPoint(self.target.transform.position)
    self.center_pos = self:GetCenterPos()
    local max_x = 220
    local min_x = -220
    local max_y = 320
    local min_y = -320

    local offset_x = target_screen_pos.x - self.center_pos.x
    local offset_y = target_screen_pos.y - self.center_pos.y

    if offset_x > max_x or offset_x < min_x or offset_y > max_y or offset_y < min_y then
        return true
    end
end

function M:UpdateCameraPos()
    if _can_move == false then return end
    if self.smooth_time > 100 then return end
    self.camera.transform.position = Vector3.SmoothDamp(self.camera.transform.position, self.target.transform.position + self.distance, self.ve, self.smooth_time);
end

function M.SetCanMove(b)
    _can_move = b    
end

function M:SetOrthographicSize(size)
    if not _is_on_off then return end
    if not IsEquals(self.camera) then
        if not self.get_camera then
            self.get_camera = function ()
                local camera = GameObject.Find("3DCamera")
                if IsEquals(camera) then
                    return camera:GetComponent("Camera")
                end
            end
        end
        self.camera = self.get_camera()
    end
    if not IsEquals(self.camera) then return end

    size = size or base_size
    local start_v = self.camera.orthographicSize
    local end_v = size
    local cur_v = start_v
    local duration = 1

    if start_v == end_v then return end

    if self.DOTSize then
        self.DOTSize:Kill()
        self.DOTSize = nil
    end

    self.DOTSize = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
			function(value)
				cur_v = start_v
				self.camera.orthographicSize = cur_v
                return cur_v
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				cur_v = value
				self.camera.orthographicSize = cur_v
            end
        ),
        end_v,
		duration
	)
	self.DOTSize:SetEase(Enum.Ease.Linear)
end

