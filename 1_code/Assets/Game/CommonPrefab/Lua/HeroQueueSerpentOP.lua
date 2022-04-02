local basefunc = require "Game/Common/basefunc"

HeroQueueSerpentOP = basefunc.class()
local C = HeroQueueSerpentOP
C.name = "HeroQueueSerpentOP"

function C.Create(hq)
	if true then return end
	return C.New(hq)
end

function C:FrameUpdate(time_elapsed)
	
end

function C:FixedUpdate()
	if not self:CheckTouch() then return end
	self:SelectHero()
	self:FreedHero()
	self:MoveHero()
	self:ChangeHeroLayer()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["on_trigger_enter_hero"] = basefunc.handler(self,self.OnTriggerEnterHero)
	self.lister["on_trigger_exit_hero"] = basefunc.handler(self,self.OnTriggerExitHero)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	if C.fixed_update_handle then
		FixedUpdateBeat:RemoveListener(C.fixed_update_handle)	
	end
	C.fixed_update_handle = nil
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(hq)
	self.hq = hq
	self:MakeLister()
	self:AddMsgListener()
	self.Camera = GameObject.Find("Canvas/Camera").transform:GetComponent("Camera")
	self.Camera3D = GameObject.Find("3DNode/3DCameraRoot/3DCamera").transform:GetComponent("Camera")

	local function update()
		self:FixedUpdate()
	end

	--注册循环
    if not C.fixed_update_handle then
        C.fixed_update_handle = FixedUpdateBeat:CreateListener(update,C)
    end
	FixedUpdateBeat:AddListener(C.fixed_update_handle)
end

--是否允许点击拖动
function C:CheckTouch()
	return true
end

function C:GetMousePositionHero()
	if not IsEquals(self.Camera3D) then return end
	local ray = self.Camera3D:ScreenPointToRay( UnityEngine.Input.mousePosition )
	local hitInfo = nil
	local isCol, hitInfo = UnityEngine.Physics.Raycast( ray , hitInfo )
	dump({isCol,hitInfo},"<color=yellow>isCol,hitInfo</color>")
	if not isCol then return end

	---- 有选到英雄
	local colliderGameObject = hitInfo.collider.gameObject

	if self.select_hero and self.select_hero.gameObject == colliderGameObject then
		return self.select_hero,hitInfo
	end


	for k,hero in pairs(self.hq.heros) do
		if colliderGameObject == hero.gameObject then
			return hero,hitInfo
		end
	end
end

function C:MoveHero()
	if not UnityEngine.Input.GetMouseButton(0) then return end
	if not self.select_hero then return end
	if not UnityEngine.Input.mousePosition then return end
	local target_screen_point = self.Camera3D:WorldToScreenPoint(self.select_hero.transform.position)
	local curScreenPoint = Vector3.New(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, target_screen_point.z)
	--把当前鼠标的屏幕坐标转换成世界坐标
	local curWorldPoint = self.Camera3D:ScreenToWorldPoint(curScreenPoint)
	curWorldPoint = Vector3.New(curWorldPoint.x,curWorldPoint.y,self.select_hero.transform.position.z)
	self.select_hero.transform.position = curWorldPoint
end

--选择英雄
function C:SelectHero()
	if not UnityEngine.Input.GetMouseButtonDown(0) then return end
	local hitInfo
	local select_hero
	select_hero,hitInfo = self:GetMousePositionHero()
	if not self.select_hero then
		self.select_hero = select_hero
	end
	--选中英雄
	if self.select_hero then
		self.select_hero_location = self.select_hero.data.location
		HeroHeadManager.RemoveHero(self.select_hero)
	end	
end

function C:ChangeHeroLayer()
	if not self.select_hero then return end
	local screen_point = self.Camera3D:WorldToScreenPoint(self.select_hero.transform.position)
	local x_max,x_min = 1200,-200
	local y_max,y_min = 800,300

	if screen_point.x < x_max and screen_point.x > x_min and screen_point.y < y_max and screen_point.y > y_min then
		--在范围内
		if not self.componse_panel_add_hero then
			SetLayer(self.select_hero,"UI")
			self.select_hero.transform.localScale = Vector3.New(100,100,100)
		end
		self.componse_panel_add_hero = true
	else
		if self.componse_panel_add_hero then
			SetLayer(self.select_hero,"3D")
			self.select_hero.transform.localScale = Vector3.New(1,1,1)
		end
		self.componse_panel_add_hero = nil
	end
end

function C:FreedHero()
	if not UnityEngine.Input.GetMouseButtonUp(0) then return end
	if not self.select_hero then return end

	dump({self.select_hero.data.heroId,self.collision_hero_id},"<color=red>GetMouseButtonUp</color>")

	if self.collision_hero_id then
		--更换位置
		local hero = GameInfoCenter.GetHeroByHeroId(self.collision_hero_id)
		HeroHeadManager.AddHero(self.select_hero,hero.data.location)
	elseif self.componse_panel_add_hero then
		--下阵
		local hero_data = basefunc.deepcopy(self.select_hero.data)
		HeroManager.Remove(hero_data.heroId)
		Event.Brocast("componse_panel_add_hero",hero_data)
		self.componse_panel_add_hero = nil
	else
		--还原位置
		HeroHeadManager.AddHero(self.select_hero,self.select_hero_location)
	end
	self.select_hero = nil
	self.select_hero_location = nil
end

function C:OnTriggerEnterHero(data)
	-- dump(data,"<color=yellow>OnTriggerEnterHero</color>")
	if not self.select_hero then return end
	if tostring(data.heroId) == self.select_hero.gameObject.name then
		return
	end
	self.collision_hero_id = data.heroId
end

function C:OnTriggerExitHero(data)
	-- dump(data,"<color=yellow>OnTriggerExitHero</color>")
	if not self.select_hero then return end
	if tostring(data.heroId) == self.select_hero.gameObject.name then
		return
	end
	self.collision_hero_id = nil
end