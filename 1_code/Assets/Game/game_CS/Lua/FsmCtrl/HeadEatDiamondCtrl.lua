local basefunc = require "Game/Common/basefunc"

HeadEatDiamondCtrl = basefunc.class(BaseCtrl)

local M = HeadEatDiamondCtrl

function M:Ctor( object , data )
	M.super.Ctor( self , object , data )
    self.ctrlState = StateType.none
    
    self.data = data
    --- 是否找到砖石
    self.isFindDiamond = false
    --- 移动的目标位置
    self.tar_pos = nil

    self.debug_obj = nil

    self.lister = {}

    self.test_time = 12

    ---- 测试数据
    --[[self.test_pos_vec = { 
    	Vector3.New( -5 , 0 , 0  ) ,
    	Vector3.New( 0 , 2 , 0  ) ,
    	Vector3.New( 5 , 2 , 0  ) ,
    	Vector3.New( 5 , 5 , 0  ) ,
    	Vector3.New( 0 , 5 , 0  ) ,
    	Vector3.New( 0 , 3 , 0  ) ,
    	Vector3.New( 3 , 3 , 0  ) ,
    	Vector3.New( -10 , 10 , 0  ) ,
    }--]]

end
--- 创建后调用
function M:Init()
	self.ctrlState = StateType.ready

	self:MakeLister()
end

--- 状态开始时调用
function M:Begin()
	self.ctrlState = StateType.running

	---- begin 开始的时候，得把 固定移动模式打开
	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )

	self:AddListener()






end

---------------------------------- 消息监听相关 ↓ -------------------------
function M:MakeLister()
	self.lister = {}
	self.lister["vehicle_finish_step"] = basefunc.handler(self, self.on_vehicle_finish_step)

end

function M:AddListener()
	for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M:on_vehicle_finish_step( id )
	--print("xx-----------eat on_vehicle_finish_step 1")
	if id == self.object.vehicle.ID then
		self.tar_pos = nil
		self.isFindDiamond = false
		--print("xx-----------eat on_vehicle_finish_step 2" , self.isFindDiamond , self.object.vehicle.m_vPos.x , self.object.vehicle.m_vPos.y )
		--self:Finish()
		if self.data and self.data.overBack then
			self.ctrlState = StateType.finish
		end
	end
end


---------------------------------- 消息监听相关 ↑ -------------------------


function M:AddDebugObj()
	if true then
		return
	end

	if self.debug_obj then
		Destroy(self.debug_obj)
	end

	local parent = GameObject.Find("3DNode/map/hero_node").transform
	self.debug_obj = NewObject( _obj_perfab or "HeroBase" , parent) 
	self.debug_obj.name = "target_pos"
	self.debug_obj.transform.position = self.tar_pos
end

function M:getDiamondPos()

	--print("findgemmmmmmmmmmmmmmmmmmmm___@11111111" , self.isFindDiamond)
	---- 没找到的话，每次都要去获取一下宝石的位置
	if not self.isFindDiamond then
		---- 获取宝石位置
		local diamond_pos = nil
		local td = GameInfoCenter.GetHeroHeadTargetData()
		if td then
			--local objGridPos = get_grid_pos( self.object.transform.position )
			--local tarGridPos = get_grid_pos( td.pos )
			local objGridPos = get_grid_pos( self.object , self.object.transform.position , true )
			local tarGridPos = get_grid_pos( self.object , td.pos , true )

			if objGridPos.x ~= tarGridPos.x or objGridPos.y ~= tarGridPos.y then
				diamond_pos = td.pos
			end
		end
		--dump(diamond_pos , "xxx--------------diamond_pos:")
		if diamond_pos then
			self.isFindDiamond = true
			self.tar_pos = diamond_pos
			--dump( self.tar_pos , "findgemmmmmmmmmmmmmmmmmmmm___@3333333333333")
			self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.tar_pos )

			self:AddDebugObj()
		end
		--print("findgemmmmmmmmmmmmmmmmmmmm___@4444444444444444")
		---- 如果没找到钻石，并且没有目标位置
		if not self.tar_pos then
			--print("findgemmmmmmmmmmmmmmmmmmmm___@5555555555555555")
			if not self.isFindDiamond then
				self.tar_pos = Vector3.New( math.random( -10 , 10 ) , math.random(-10 , 10) , 1 )
				--self.tar_pos = Vector3.New( 1 , 1 , 0 )
			end

			--dump(self.tar_pos , "findgemmmmmmmmmmmmmmmmmmmm___@6666666666666" )

			self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.tar_pos )

			--print("findgemmmmmmmmmmmmmmmmmmmm___@7777777777777")
			self:AddDebugObj()
		end

		if self.test_pos_vec and next( self.test_pos_vec ) then
			self.tar_pos = table.remove( self.test_pos_vec , 1 )
			--print("findgemmmmmmmmmmmmmmmmmmmm___@8888888888888")
			self.object.vehicle:SetTargetPos( Vehicle.SteerType.FixedPointPath, self.tar_pos )
			--print("findgemmmmmmmmmmmmmmmmmmmm___@99999999999999")
			self:AddDebugObj()
		end
	end

	--print("findgemmmmmmmmmmmmmmmmmmmm___@00000000000000000")
	
end


--- 结束时调用
function M:Finish()
	self.ctrlState = StateType.finish

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )

	self:RemoveListener()
end

--强制结束
function M:Stop()
	self:Finish()
end
-- 暂停时调用
function M:Pause()
	self.ctrlState = StateType.pause

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, false )
	self.tar_pos = nil
	self.isFindDiamond = false
	self:RemoveListener()

	return true
end
-- 继续时调用
function M:Resume()
	self.ctrlState = StateType.running

	self.object.vehicle:SetOnOff( Vehicle.SteerType.FixedPointPath, true )
	self:AddListener()

	self.test_time = 5

end
-- 刷新
function M:Refresh(_data)

end

function M:Update(dt)
	if self.ctrlState ~= StateType.running then
		return
	end
	--print("xxx------------HeadEatDiamondCtrl update")
	self:getDiamondPos()

	--[[if self.moveToPosVec and next( self.moveToPosVec ) do

		self.transform:
	end--]]

	--[[if self.tar_pos then
		local old_pos = self.object.transform.position
		local old_rotation = self.object.transform.eulerAngles

		local angle = Vec2DAngle( Vec2DSub( self.tar_pos , old_pos ) )

		local sp = ModifierSystem.GetObjProp( self.object , "speed" )

		self.object.transform.eulerAngles = Vector3.New( old_rotation.x , old_rotation.y , angle )
		--AxisLookAt( self.object.transform , self.tar_pos , Vector3.right )

		local move_dis = Vec2DMultNum( self.object.transform.right , sp*dt )

		self.object.transform.position = Vector3.New( old_pos.x + move_dis.x , old_pos.y + move_dis.y , old_pos.z )

		local dis = Vector2.Distance( self.object.transform.position , self.tar_pos )
		if dis < 0.3 then
			--self.ctrlState = StateType.finish

			self.tar_pos = nil
			self.isFindDiamond = false

			Destroy( self.debug_obj )
		end

	end--]]

end



