--[[地图 建筑
	支持几种基本回调函数

	创建完成	initCallback
	碰撞开始	collisionCallback
	动画结束	aniOverCallback
	对象销毁	destoryCallback

]]
local basefunc = require "Game/Common/basefunc"
Building = basefunc.class(Object)
local M = Building
M.name = "Building"

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	self.gameObject = self.data.building.gameObject
	self.transform = self.gameObject.transform
	--print("xxxx------------building init:" , self.gameObject ,self.transform )
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.enabled = true
	self.state = "normal"
	self.tag = "Building"
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	if self.data.pos then
		self.transform.position = self.data.pos
	end

	self:InitCollider()

	if self.data.initCallback then
		self.data.initCallback(self)
	end
	self:InitSkills()

	Timer.New(function ()
		--print("xxx---------------initTimer11:" , self.data.roomNo )
		if self.data.roomNo then
			--print("xxx---------------initTimer 22:" , self.data.roomNo )
			self:SetRoomNo(self.data.roomNo)

			self:BindBuildKeyToGrid()
		end
	end, math.random(190) / 100 + 0.1 , 1 ):Start()
	
end

function M:MakeLister()
    self.lister = {}
end

function M:AddMsgListener()
    for m,func in pairs(self.lister) do
        Event.AddListener(m, func)
    end
end

function M:RemoveListener()
    for m,func in pairs(self.lister) do
        Event.RemoveListener(m, func)
    end
    self.lister = {}
end

function M:Exit()
	self:ExitSkill()
	self:RemoveListener()
	self:ClearBuildKeyToGrid()

	Destroy(self.gameObject)
end

function M:OnDestroy()

	if self.data.destoryCallback then
		self.data.destoryCallback(self)
	end

	self:Exit()
end

function M:FrameUpdate(dt)
	M.super.FrameUpdate( self , dt )
	self:FrameUpdateSkill(dt)
end


function M:SetEnable(b)
	self.enabled = b
end

function M:InitCollider()
	local co = self.gameObject:GetComponent("BoxCollider2D")
	if IsEquals(co) then
		if self.data.building.isDestroy then
			co.enabled = true
		else
			co.enabled = false
		end
	end

	self.collider = self.gameObject:GetComponent("ColliderBehaviour")

	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = M.name

		if self.data.building.isDestroy then
			self.collider.enabled = true
		else
			self.collider.enabled = false
		end
	end

	if self.data.building.destroyType then
		SetLayer(self.gameObject,"MapBuilding")
	end
end

function M:OnTriggerEnter2D(coll)
	self:OnColliderEnter2D(coll)
end

function M:OnCollisionEnter2D(coll)
	self:OnColliderEnter2D(coll)
end

function M:OnColliderEnter2D(coll)
	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end

	if self.data.building.fixNotDestroy then
		return
	end

	--碰撞层检查
	if self.data.building.destroyType then
		if not MapManager.CheckCollision(coll,self.data.building) then
			return
		end
	end

	self.state = "die"

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

	self:ColliderAnimate()
end

function M:OnHit()
	if not self.enabled then
		return
	end

	if self.state ~= "normal" then
		return
	end

	if self.data.building.fixNotDestroy then
		return
	end
	self.state = "die"

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

	self:ColliderAnimate()
end

function M:ColliderAnimate()
	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		self:FlopGold()
		self:FlopItem()

		GameInfoCenter.RemoveGoodsById(self.id)
		--销毁建筑
		Event.Brocast("MapBuildingDestroy", self.data.building)
	end)
end

--掉落金币
function M:FlopGold()
	local jb = self.data.jb
	if not jb or jb <=0 then return end
	local pos = self.transform.position
	CSEffectManager.CreateGold(CSPanel.anim_node,
		CSModel.Get3DToUIPoint(pos),
		CSPanel:GetJBNode(),
		nil,
		function()
			Event.Brocast("ui_game_get_jin_bi_msg", jb)
		end
	)
end

--掉落道具
function M:FlopItem()
	if not self.data.building.isItem then
		return
	end

	local config = StageManager.OutputGoods("building")
	local pos = self.transform.position
	DropAsset.Create({pos = pos,config = config})
end

function M:InitSkills()
	if not self.data.building.isSkill then return end
	self.data.skill = MapManager.GetSkillByKey(self.data.building.key)
	if not self.data.skill or not next(self.data.skill) then return end

	self.skill = {}
	if self.data.skill then
		for i,v in ipairs(self.data.skill) do
			local skill = CreateFactory.CreateSkill({object = self,type=v})
			self.skill[skill.id] = skill
		end
	end
end

function M:FrameUpdateSkill(dt)
	if not self.data.building.isSkill then return end
	if not self.data.skill or not next(self.data.skill) then return end
	for id,skill in pairs(self.skill) do
		if skill.isLive then
			skill:FrameUpdate(dt)
		else
			self.skill[id] = nil
		end
	end
end

function M:ExitSkill()
	if not self.data.building.isSkill then return end
	if not self.data.skill or not next(self.data.skill) then return end
	for key , skill in pairs(self.skill) do
		skill:Exit()
	end
end

-----
function M:BindBuildKeyToGrid()
	--print("xxxx--------------BindBuildKeyToGrid 11", self.gameObject , self.gameObject.transform )
	if not IsEquals(self.gameObject) then 
		return
	end
	--print("xxxx--------------BindBuildKeyToGrid 22")
	local coll = self.gameObject.transform:GetComponent("Collider2D")
	if not IsEquals(coll) then
		return
	end
	local oldEnable = coll.enabled
	coll.enabled = true
    --dump(coll.bounds,"<color=yellow>碰撞器大小</color>")
    local building = {}

    self:ClearBuildKeyToGrid()

    if IsEquals(coll) then
    	--print("xxxx--------------BindBuildKeyToGrid 33")
        building.collPos = {x = coll.bounds.center.x, y = coll.bounds.center.y}
        if self.gameObject.transform.localRotation.z == 90 or self.gameObject.transform.localRotation.z == -90 then
            building.collSize = { w = coll.bounds.extents.y * 2, h = coll.bounds.extents.x * 2}
        else
            building.collSize = { w = coll.bounds.extents.x * 2, h = coll.bounds.extents.y * 2}
        end
    	
        local pos = building.collPos
        local size = building.collSize

        local leftDownPoint = { x = pos.x - size.w / 2 , y = pos.y - size.h / 2 }
        local rightUpPoint = { x = pos.x + size.w / 2 , y = pos.y + size.h / 2 }

        --dump( {leftDownPoint , rightUpPoint} , "xxxxx-------------------BindBuildKeyToGrid 11" )

        leftDownPoint = GetMapNoCoordByPos( self , leftDownPoint )
        rightUpPoint = GetMapNoCoordByPos( self , rightUpPoint )

        local girdSize = GetGridSize( self )
        --dump( {leftDownPoint , rightUpPoint} , "xxxxx-------------------BindBuildKeyToGrid" )

        for x = leftDownPoint.x , rightUpPoint.x do
            for y = leftDownPoint.y , rightUpPoint.y do
            	local no = GetMapNoByCoord(self , x , y )
            	--print( "xxx----------no:" , no )
            	if no > 0 then
            		--print("<color=yellow>xxxx-----------SetGridProp:</color>" , no , self.data.building.key )
                	SetGridProp( self , no , self.data.building.key )
                	self.gridBuildGridKey[no] = self.data.building.key
                end
            end
        end

        coll.enabled = oldEnable
    end
end

function M:ClearBuildKeyToGrid()
	if self.gridBuildGridKey and type(self.gridBuildGridKey) == "table" then
		for no , value in pairs( self.gridBuildGridKey ) do
			DeleteGridProp( self , no , value )
		end
	end

	self.gridBuildGridKey = {}
end
