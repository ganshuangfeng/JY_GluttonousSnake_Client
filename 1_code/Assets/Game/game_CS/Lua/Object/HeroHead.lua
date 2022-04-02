---- 蛇头

local basefunc = require "Game/Common/basefunc"
local heroHeadFsmTable = require "Game.game_CS.Lua.FsmConfig.heroHeadFsmTable"

local isDebug = false
require "Game.game_CS.Lua.DebugHeroHead"


HeroHead = basefunc.class(Object)
local M = HeroHead
M.name = "HeroHead"
local total_scale = 2.32
function M:Ctor(data)
	M.super.Ctor( self , data )
	dump(data,"<color=yellow>蛇头数据？？？？？？？？？？</color>")
	self.data = data
	self.skill = {}	

	self.modifier = {}

	-------------------------- 基础数据 ↓
	self.hp = GameInfoCenter.playerDta.hp
	self.maxHp = self.config.maxHp
	self.speed = self.config.speed
	self.damage = self.config.damage or 100
	self.hit_space = self.config.hit_space or 6
	self.attack_range = self.config.attack_range or 10
	-------------------------- 基础数据 ↑
	-------------------------- 技能数据 ⬇
	self.fsmLogic = FsmLogic.New( self , heroHeadFsmTable )

	self:CreateSkill()

	-------------------------- 技能数据 ↑	 
	---- 力模式
	self.vehicle = nil
	--跟随
	self.followCtr = FollowController.New({object = self})

	self.state = "normal"

	---- 蛇头的 range 碰撞范围
	self.collisionRange = 2

	if isDebug then
		self.DebugHeroHead = DebugHeroHead.Create()
	end
	--动画配置
	self.head_anim_name = "fc"
end

function M:CreateSkill()
	--#测试代码 如果没有数据 默认创建 goldRush技能
	if not self.headData then
		CreateFactory.CreateSkillById(80,{object = self})
	end
	-- CreateFactory.CreateSkillById( self.config.skillId , {object = self} )
	if not self.data.headData or not next(self.data.headData) then return end
	local createSkill = function (skill)
		if not skill then
			return
		end
		if type(skill) =="number" and skill ~= 0 then
			CreateFactory.CreateSkillById( skill , {object = self} )
		elseif type(skill) =="type" then
			for k, v in pairs(skill) do
				if type(v) =="number" and v ~= 0 then
					CreateFactory.CreateSkillById( v , {object = self} )
				end
			end
		end
	end
	-- createSkill(self.data.headData.zd_skill)

	--创建车头额外技能
 	local s = HeadSkillManager.CreateSkill(self.data,self)
end

function M:SetRoomNo(roomNo)
	local oldRoomNo
	if self.data then
		oldRoomNo = self.data.roomNo
	end
	M.super.SetRoomNo( self , roomNo )
	if self.data and oldRoomNo and self.data.roomNo and oldRoomNo ~= self.data.roomNo then
		Event.Brocast("hero_head_room_no_change_msg", {roomNo = self.data.roomNo})
	end
end

function M:CreateUI()
	
	local obj_name = self.config.head
	local obj = NewObject(obj_name, CSPanel.map )
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	self.transform.localScale = Vector3.one * total_scale
	

	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "HeroHead"
	end

	GeneratingVar(self.transform, self)
	--刷新血量
	self.hp_txt.text = self.hp or GameInfoCenter.playerDta.hp
	
	local width = self.hp_spr.size.x
	local h = GameInfoCenter.playerDta.hp / GameInfoCenter.playerDta.hpMax

	local px = (h - 1) * width * 0.5
	local sx = h

	local lp = self.hp_spr.transform.localPosition
	self.hp_spr.transform.localPosition = Vector3.New(px,lp.y,lp.z)
	local ls = self.hp_spr.transform.localScale
	self.hp_spr.transform.localScale = Vector3.New(sx,ls.y,ls.z)
	local lp = self.hp_white_spr.transform.localPosition
	self.hp_white_spr.transform.localPosition = Vector3.New(px,lp.y,lp.z)
	local ls = self.hp_white_spr.transform.localScale
	self.hp_white_spr.transform.localScale = Vector3.New(sx,ls.y,ls.z)
end

--{form = ??,tag = ??,other = ??}
function M:AddTag(data)
	self.sp_tags_index = self.sp_tags_index or 0
	self.sp_tags_index = self.sp_tags_index + 1
	self.sp_tags = self.sp_tags or {}
	self.sp_tags[self.sp_tags_index] = data
	return self.sp_tags_index
end

function M:RemoveTagByIndex(index)
	self.sp_tags = self.sp_tags or {}
	self.sp_tags[index] = nil
end

function M:ReMoveTagByForm(form)
	self.sp_tags = self.sp_tags or {}
	for k, v in pairs(self.sp_tags) do
		if v and v.form == form then
			v = nil
		end
	end
end

function M:ReMoveTagByTag(tag)
	self.sp_tags = self.sp_tags or {}
	for k, v in pairs(self.sp_tags) do
		if v and v.tag == tag then
			v = nil
		end
	end
end

function M:IsTagActive(tag)
	self.sp_tags = self.sp_tags or {}
	for k , v in pairs(self.sp_tags) do
		if v.tag == tag then
			return true
		end
	end
	return false
end

function M:Init(data)
	M.super.Init( self )

	self:CreateUI()

	self.range = 1 / 1.5 * total_scale 

	if data.pos then
		self.transform.position = data.pos
	end

	self.vehicle = VehicleManager.CreateHero( { 
												m_vPos = 
												{ 
													x = self.transform.position.x, 
													y = self.transform.position.y,
												},
												m_dMinSpeed = self.speed ,
      						 					m_dMaxSpeed = self.speed , 
      						 					m_dUpperLimitSpeed = self.speed * 1.8 , 
      											},
      											self )
	-- self.vehicle:Start()

	self.fsmLogic:addWaitStatusForUser( "manualOper" )-- ( "eatDiamond" ) ( "manualOper" ) 

	--初始化蛇身方向调整
	self.transform.rotation = Quaternion.Euler(0, 0, 90)
	self.followCtr:Init()
	-- local heros = GameInfoCenter.GetAllHero()
	-- for k,v in pairs(heros) do
	-- 	v.range = 1.6
	-- 	v.location = v.data.location
	-- 	self.followCtr:AddFollowObject(v)
	-- end
	self.time_scale_value = 1

	self:MakeLister()
	self:AddMsgListener()

	self:InitTail()

	local cmt = {"nearest","random"}
	local cr = math.random(2)
	--在符合取怪的范围内随机获取一个
	self.checkMonsterType = cmt[2]


	self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)

	self:SetSTDir(90)
end

function M:Refresh()
	M.super.Refresh( self )
	self:SetCameraOrthographicSize()
end

function M:Exit()
	M.super.Exit( self )

	if self.DebugHeroHead then
		self.DebugHeroHead:Exit()
	end

	self:RemoveListener()
	self.followCtr:Exit()
	self.fsmLogic:Delete()
	self:ExitTail()

	for k,v in pairs(self.skill) do
		v:Exit()
	end

	for k,v in pairs(self.modifier) do
		for _,obj in pairs(v) do
			obj:Exit()
		end
	end

	for k,v in pairs(self.seqs or {}) do
		v:Kill()
	end
	self.seqs = nil

	Destroy(self.gameObject)
	ClearTable(self)
end

function M:OnCollisionEnter2D(collision)

	if self.state ~= "normal" then
		return
	end

	local id = tonumber(collision.gameObject.name)

	if id then
		local o = ObjectCenter.GetObj(id)

		local obj = GameInfoCenter.GetMonsterById(id)
		if obj and obj.isLive and obj.state ~= "die" then
			if not self:IsTagActive("immune_close_damage") then
				Event.Brocast("hit_hero", {id=self.id,damage=obj.damage})
			end
		end
	end
	
end

function M:FrameUpdate(dt)
	if self.state == "die" then return end

	dt = dt * self.time_scale_value

	-- if not CSPanel.is_head then
	    self.vehicle:FrameUpdate(dt)
	-- end
	M.super.FrameUpdate( self , dt )

	self.fsmLogic:Update(dt)

	if self.skill and next(self.skill) then
		for id,skill in pairs(self.skill) do
			if skill.isLive then
				skill:FrameUpdate(dt)
			else
				skill:Exit()
				table.remove(self.skill,id)
			end
		end
	end

	self.followCtr:FrameUpdate(dt)
	
	self:RefreshTail()

	self:RecordHeadPos()

	self:RefreshPreCastPos(dt)
end

function M:RecordHeadPos()
	self.head_pos_list = self.head_pos_list or {}
	if #self.head_pos_list > 100 then
		table.remove(self.head_pos_list,1)
	end
	self.head_pos_list[#self.head_pos_list + 1] = self.gameObject.transform.position
end
--刷新预判位置（1，当我直走的时候，直接预判未来的位置，当我徘徊的时候，就是当前时刻位置）
function M:RefreshPreCastPos(dt)
	local preCastLenght = self.speed / 1.05
	local range = 2
	if tls.pGetDistanceSqu(self.head_pos_list[1],self.gameObject.transform.position) < range then
		self.precast_pos.transform.localPosition = Vector3.zero
		return
	end

	self.precast_pos.transform.localPosition = Vector3.New(preCastLenght,0,0)
	local is_right_pos = function(pos)
		--local size = GameInfoCenter.GetMapSize()
		local size = GetSceenSize(self)
		local new_pos = {z = 0}
		if math.abs(pos.x) > size.width / 2 then
			return false
		end
		if math.abs(pos.y) > size.height /2 then
			return false
		end
		return true
	end

	--local npg = GameInfoCenter.GetMapNotPassGridData()
	local npg = GetMapNotPassGridData( self )
	local pos = self.precast_pos.transform.position
	local k = GetMapNoByPos( self , pos ) --GetPosTagKeyStr( get_grid_pos( pos ) )
	if npg[k] or not is_right_pos(pos) then
		self.precast_pos.transform.localPosition = Vector3.zero
	end
end

function M:MakeLister()
	M.super.MakeLister( self )
	self.lister = {}
	self.lister["level_start"] = basefunc.handler(self, self.on_level_start)
	
    self.lister["boss_arise"] = basefunc.handler(self, self.On_boss_arise)
    self.lister["gem_arise"] = basefunc.handler(self, self.On_gem_arise)

	self.lister["HeroSetState"] = basefunc.handler(self, self.OnHeroSetState)

    self.lister["hero_hp_change_msg"] = basefunc.handler(self, self.OnUpdateHeroHead)

    self.lister["HeroDestroy"] = basefunc.handler(self, self.OnHeroDestroy)
    self.lister["HeroChange"] = basefunc.handler(self, self.OnHeroChange)
    self.lister["HeroCreate"] = basefunc.handler(self, self.OnHeroCreate)
    self.lister["HeroRefresh"] = basefunc.handler(self, self.OnHeroRefresh)
	self.lister["HeroSaleAll"] = basefunc.handler(self, self.SaleAllHero)
	self.lister["eat_something"] = basefunc.handler(self, self.on_eat_something)
end

function M:AddMsgListener()
	M.super.AddMsgListener( self )
	for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
	M.super.RemoveListener( self )
	for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
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

function M:SetSTDir(r)
 --    local dir = Get3Goto2IndexDir16( r )
	-- if not self.curDir or dir ~= self.curDir then
	-- 	self.curDir = dir
	--     self.head_spr.sprite = GetTexture("ct_" .. dirByImg[self.curDir+1])
 --    	local ss = self.head_spr.transform.localScale
	--     if self.curDir > 3 and self.curDir < 13  then
	-- 	    self.head_spr.transform.localScale = Vector3.New(-1*math.abs(ss.x), ss.y, ss.z)
	--     else
	-- 	    self.head_spr.transform.localScale = Vector3.New(math.abs(ss.x), ss.y, ss.z)
	--     end
	-- end

	local dir = Get3Goto2IndexDir16( r )
	if not self.curDir or dir ~= self.curDir then
		if not self.head_anim then
			self.head_anim = self.head_spr.transform:GetComponent("Animator")
		end
		self:RefreshCurHeadDir(dir)
	end
    self.head_node.localRotation = Quaternion.Euler(0, 0, -r)
end

function M:RefreshCurHeadDir(dir)
	self.curDir = dir or self.curDir
	self.head_anim:Play(self.head_anim_name..dirByImg[self.curDir+1], 0, 0)
	local ss = self.head_spr.transform.localScale
	if self.curDir > 3 and self.curDir < 13  then
		self.head_spr.transform.localScale = Vector3.New(-1*math.abs(ss.x), ss.y, ss.z)
	else
		self.head_spr.transform.localScale = Vector3.New(math.abs(ss.x), ss.y, ss.z)
	end
end

function M:UpdateTransform(pos, r)
	if self.state == "die" then return end
	self:SetSTDir(r)

	if self.state == "intoHole" then
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		return
	end

	self:CalcAmendTransform(pos, r)
end
function M:CalcAmendTransform(pos, r)
	self:CalcAmendTransform5(pos, r)
end

function M:CalcAmendTransform1(pos, r)
	local len = 2
	local range = 1.6 * len
	local t = MapManager.GetNotPassDataByPos(pos, len)

	local yPos = get_grid_pos(pos , true )
	
	local pos1
	if self.DebugHeroHead then
		pos1 = {x=pos.x, y=pos.y}
	end

	if self.DebugHeroHead then
		self.DebugHeroHead:CreateCell(t.nott, t.yestt)
	end
	if t.nott then
		local nor = {x = MathExtend.Cos(r), y = MathExtend.Sin(r), z = 0}

		if t.nodir[0] or t.nodir[2] then
			pos.x = yPos.x
		end
		if t.nodir[1] or t.nodir[3] then
			pos.y = yPos.y
		end

		if self.DebugHeroHead then
			self.DebugHeroHead:CreateSTCell({pos1=pos1, zPos=pos, gPos=yPos})
		end

		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		if self.vehicle then
			self.vehicle:SetPos(pos)
		end
	else
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
	end
end
function M:CalcAmendTransform2(pos, r)
	local len = 2
	local range = 1.6 * len
	local t = MapManager.GetNotPassDataByPos(pos, len)

	local yPos = get_grid_pos(pos , true )
	if self.DebugHeroHead then
		self.DebugHeroHead:CreateCell(t.nott, t.yestt)
	end

	if t.nott then
		local nn = 0
		local pyPos = {x=0, y=0}
		for k,v in pairs(t.nott) do
			local a = tls.pGetDistance(pos, v.pos)
			if a < range then
				local pp = Vec2DAdd( Vec2DTruncate( Vec2DSub(pos, v.pos) , range ) , v.pos )
				pyPos.x = pyPos.x + pp.x
				pyPos.y = pyPos.y + pp.y
				nn = nn + 1
			end
		end
		if nn > 0 then
			dump({nn, pyPos}, "<color=red>AAAAAAA 11231313</color>")
			pos.x = pyPos.x/nn
			pos.y = pyPos.y/nn
		end
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		if self.vehicle then
			self.vehicle:SetPos(pos)
		end
	else
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
	end
end
function M:CalcAmendTransform3(pos, r)
	local len = 1
	local range = 1.6 * len
	local t = GetNotPassDataByPos( self , pos, len)

	local pos1
	if self.DebugHeroHead then
		pos1 = {x=pos.x, y=pos.y}
	end

	local yPos = get_grid_pos(self , pos , true )
	if self.DebugHeroHead then
		self.DebugHeroHead:CreateCell(t.nott, t.yestt)
	end

	--dump(t , "xxxx-------------CalcAmendTransform3  roomNo:" .. self.data.roomNo )

	if t.nott then
		for k,v in pairs(t.nott) do
			local a = tls.pGetDistance(pos, v.pos)
			if a < range then
				if self.DebugHeroHead then
					self.DebugHeroHead:CreateXCell(v)
				end
				
				if math.abs(v.pos.x - yPos.x) < 0.001 then
					pos.y = yPos.y
				end
				if math.abs(v.pos.y - yPos.y) < 0.001 then
					pos.x = yPos.x
				end
			end
		end

		if self.DebugHeroHead then
			self.DebugHeroHead:CreateSTCell({pos1=pos1, zPos=pos, gPos=yPos})
		end

		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		if self.vehicle then
			self.vehicle:SetPos(pos)
		end
	else
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
	end
end
function M:CalcAmendTransform4(pos, r)
	local len = 2
	local range = 1.6 * len
	local t = GetNotPassDataByPos2( self , pos, range * 0.5)

	local yPos = get_grid_pos( self , pos , true )
	if self.DebugHeroHead then
		self.DebugHeroHead:CreateCell(t.nott, t.yestt)
	end

	--dump( t , "xxx----------CalcAmendTransform4" )

	if t.nott then
		for k,v in pairs(t.nott) do
			local pp = Vec2DAdd( Vec2DTruncate( Vec2DSub(pos, v.pos) , range ) , v.pos )
		end
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		if self.vehicle then
			self.vehicle:SetPos(pos)
		end
	else
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
	end
end

---- 判断蛇头 是否在某个 astar 系统中 与不能碰撞的点 碰撞了
function M:CheckIsCollisionCantPassGrid( atarObj )
	local range = self.collisionRange

	local gridSize = GetGridSize(atarObj)
	local t = GetMapNotPassGridData(atarObj)
	local pos = self.transform.localPosition

	for no,bb in pairs(t) do
		local cPos = GetMapPosByNo( atarObj , no , true )
		
		local radius = range*0.5 + gridSize*0.5
		---- 
		if math.abs( cPos.x - pos.x ) < radius - 0.0001 and math.abs( cPos.y - pos.y ) < radius - 0.0001 then
			return true
		end
	end
	return false
end

function M:CalcAmendTransform5(pos, r)
	--- 蛇头的宽度
	local range = self.collisionRange
	local t = GetMapNotPassGridData(self) --GetNotPassDataByPos2( self , pos, range * 0.5)
	local gridSize = GetGridSize(self)
	--local yPos = get_grid_pos( self , pos , true )
	if self.DebugHeroHead then
		self.DebugHeroHead:CreateCell(t.nott, t.yestt)
	end
	--print("<color=yellow>xxxx------------heroHead roomNo:</color>" , self.data.roomNo )
	--dump( t , "xxx----------CalcAmendTransform4" )
	local oldPos = self.transform.localPosition
	
		for no,bb in pairs(t) do
			local cPos = GetMapPosByNo( self , no , true )
			--dump( { pos , cPos } , "xxx------------cPos:")

			local radius = range*0.5 + gridSize*0.5
			---- 
			if math.abs( cPos.x - pos.x ) < radius - 0.0001 and math.abs( cPos.y - pos.y ) < radius - 0.0001 then
				--dump( { cPos , oldPos , pos } , "<color=yellow>xxx--------------check 11</color>" )
				local isSet = false
				if math.abs( cPos.x - oldPos.x ) < radius - 0.0001 then
					pos.y = (cPos.y + ((oldPos.y - cPos.y)>0 and 1 or -1) * radius  )
					isSet = true
					--dump( { cPos , oldPos , pos } , "<color=yellow>xxx--------------check 22</color>" )
				end
				if math.abs( cPos.y - oldPos.y ) < radius - 0.0001 then
					pos.x = (cPos.x + ((oldPos.x - cPos.x)>0 and 1 or -1) * radius  )
					isSet = true
					--dump( { cPos , oldPos , pos } , "<color=yellow>xxx--------------check 33</color>" )
				end

				--- 如果是切着进来的，上次的位置 xy 坐标没有和碰撞体相交
				if not isSet then
					local dir = {
						x = (oldPos.x - cPos.x) > 0 and 1 or -1 ,
						y = (oldPos.y - cPos.y) > 0 and 1 or -1 ,
					}

					local forNum = math.ceil(range / gridSize)
					
					local isFind = false
					for key = 1 , 2 do
						if isFind then
							break
						end
						local findKey = key == 1 and "x" or "y"
						local otherKey = findKey == "x" and "y" or "x"

						local CanPass = true
						for i = 1 , forNum do
							local nextPos = { [findKey] = cPos[findKey] + i * dir[findKey]*gridSize , [otherKey] = cPos[otherKey] }
							local nextNo = GetMapNoByPos( self , nextPos )
							if t[nextNo] then
								CanPass = false
								break
							end
						end
						if CanPass then
							isFind = true
							pos[findKey] = (cPos[findKey] + ((oldPos[findKey] - cPos[findKey])>0 and 1 or -1) * radius  )

							--dump( { cPos , oldPos , pos } , "<color=yellow>xxx--------------check 44</color>" .. findKey )
						end
					end

					
				end

			end

		end
		self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
		if self.vehicle then
			self.vehicle:SetPos(pos)
		end
	


end


function M:CalcAmendTransform___(pos, r)
	self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	self.transform.rotation = Quaternion.Euler(0, 0, r)
	self.hp_node.transform.eulerAngles = Vector3.New(0,0,0)
end

function M:AddHero(hero,isStart,isLast)
	hero.range = 1.02
    self.followCtr:AddFollowObject(hero)
	self.heros = self.heros or {}
	self.heros[hero.data.heroId] = hero
	self:SetCameraOrthographicSize()
	self:RefreshTail()
	
	self:PlayAddHeroAni(hero,isStart,isLast)

	self:ChangeSortLayer()
end

function M:RemHero(data)
	if not self.heros then return end
	local hero = self.heros[data.heroId]
	self.heros[data.heroId] = nil

    self.followCtr:DelFollowObject(data.location)
	self:RefreshTail()
	self:PlayRemHeroAni(hero)

	self:SetCameraOrthographicSize()
end

function M:ChangeHero(data)
	data.hero:Refresh(data)
end

function M:RefreshHero()
	if not self.heros then return end
	self.followCtr:RefreshFollowObject(self.heros)
	self.followCtr:Refresh()

	self:PlayRefreshHeroAni()

	self:ChangeSortLayer()
end

-- 修改蛇身的层级
function M:ChangeSortLayer()
	-- do return end -- 屏蔽
	-- ChangeLayer(self.head_spr, 10000, true)
	-- ChangeLayer(self.tail, 1000, true)

	-- if not self.heros then return end	
	-- for k,v in pairs(self.heros) do
	-- 	ChangeLayer(v, 10000 - v.data.location * 100 , true)
	-- end
end
function M:GetHeroByLoc(loc)
	if not self.heros then return end	
	for k,v in pairs(self.heros) do
		if v.data.location == loc then
			return v
		end
	end
end

function M:GetHeroMaxLoc()
	if not self.heros then return 0 end	
	local maxLoc = 0
	for k,v in pairs(self.heros) do
		if v.data.location > maxLoc then
			maxLoc = v.data.location
		end
	end
	return maxLoc
end

--尾巴------------------------------
function M:InitTail()
	local tail_obj = {}
	tail_obj.gameObject = NewObject(self.data.config.tail,CSPanel.map)
	tail_obj.transform = tail_obj.gameObject.transform
	tail_obj.gameObject:SetActive(false)
	tail_obj.head = tail_obj.transform:Find("@head")
	tail_obj.tail = tail_obj.transform:Find("@tail")
	tail_obj.body = tail_obj.transform:Find("@body")
	tail_obj.icon = tail_obj.transform:Find("@body/@icon_img"):GetComponent("SpriteRenderer")
	tail_obj.icon_anim = tail_obj.icon.transform:GetComponent("Animator")
	--搁表里
	self.tail = tail_obj
end

function M:ExitTail()
	Destroy(self.tail.gameObject)
end

function M:RefreshTail()
	local point = self.followCtr:GetPointByRange(self.followCtr:GetAllFollowObjectRange())
	if not point then return end
	self.tail.transform.position = point.pos
	self.tail.transform.rotation = point.rot
	if not self.heros or #self.heros == 0 then
		self.tail.gameObject:SetActive(true)
	end

	-- 16向
	local r = Vec2DAngle(point.dir)
    local dir = Get3Goto2IndexDir16( r )
	if not self.curTailDir or dir ~= self.curTailDir then
		self.curTailDir = dir
		self.tail.icon_anim:Play("cw_" .. dirByImg[self.curTailDir+1],0,0) 
    	local ss = self.tail.icon.transform.localScale
	    if self.curTailDir > 3 and self.curTailDir < 13  then
		    self.tail.icon.transform.localScale = Vector3.New(-1*math.abs(ss.x), ss.y, ss.z)
	    else
		    self.tail.icon.transform.localScale = Vector3.New(math.abs(ss.x), ss.y, ss.z)
	    end
	end

end
--尾巴------------------------------
function M:on_level_start(data)
	local heros = GameInfoCenter.GetHeroList()
	for k,v in ipairs(heros) do
		self:AddHero(v, true, k == #heros)
	end
end
function M:PlayAddHeroAni(hero,isStart,isLast)
	if isStart then
		hero.gameObject:SetActive(false)
		self.tail.gameObject:SetActive(false)
		local t = hero.data.location * 0.1 + 0.5
		CSEffectManager.PlayShowAndHideAndCall(
                                            CSPanel.map_node,
                                            "C_bao_chuxian",--"CC_lg",
                                            nil,
                                            hero.transform.position,
                                            0.5,
                                            0.2,
											function ()
												if IsEquals(hero) and IsEquals(hero.gameObject) then
													hero.gameObject:SetActive(true)
													if isLast then
														self.tail.gameObject:SetActive(true)
													end
												end
											end,
                                            function (tran)
												ExtendSoundManager.PlaySound(audio_config.cs.battle_hero_debut.audio_name)
                                            	tran.localScale = Vector3.New(0.7, 0.7, 0.7)
                                            end,
                                            nil,
                                            nil,
                                            t)
	else
		CSEffectManager.PlayMergeLight(hero,nil,"3D")
		self:HeroScaleFromChangeAni(hero,Vector3.New(2,2,2))
	end
end

function M:PlayRemHeroAni(hero,bodyTf,tailTf)
	if not hero then return end
	self:HeroGameObjectScaleChangeAni(hero)
end

function M:PlayRefreshHeroAni()
	local maxLoc = 0
	for k,v in pairs(self.heros) do
		if v.data.location > maxLoc then
			maxLoc = v.data.location
		end
	end

	for k,v in pairs(self.heros) do
		if v.data.locationOld and v.data.locationOld ~= v.data.location then
			--位置不一样
			if v.data.locationOld < v.data.location then
				self:HeroScaleFromChangeAni(v,Vector3.one * 0.5)
			else
				self:HeroScaleFromChangeAni(v,Vector3.one * 1.5)
			end

			if v.data.location == maxLoc then
				self:HeroScaleFromChangeAni(self.tail,Vector3.one * 0.5)
			end
		end
	end
end

function M:SetCameraOrthographicSize()
	if not self.heros then return end
	local c = 0
	for k,v in pairs(self.heros) do
		c = c + 1
	end
	local offset = (CameraMoveBase.max_size - CameraMoveBase.min_size) / (15 - 5)

	if c <= 5 then
		CameraMoveBase.SetOrthographicSize()
	else
		CameraMoveBase.SetOrthographicSize(CameraMoveBase.min_size + offset * (c - 5 ))
	end
end

function M:GetHeroBodyTf(hero)
	if not hero then return end
	local bodyTf = {}
	for i=hero.data.location + 1,self:GetHeroMaxLoc() do
		--元素前移
		bodyTf[i] = {
			pos = self:GetHeroByLoc(i).body.transform.position,
			rot = self:GetHeroByLoc(i).body.transform.rotation,
		}
	end
	return bodyTf
end

function M:GetTailBodyTf(tail)
	if not tail then return end
	local bodyTf = {
		pos = tail.body.transform.position,
		rot = tail.body.transform.rotation,
	}
	return bodyTf
end

function M:ObjTransformChangeAni(obj,tf)
	if obj.transformChange then
		obj.transformChange:Kill()
	end
	local seq = DoTweenSequence.Create()
	seq:Append(obj.body.transform:DOMove(tf.pos,0.4):From():SetEase(Enum.Ease.InSine))
	seq:OnKill(function ()
		if IsEquals(obj.transform) then
			obj.body.transform.localPosition = Vector3.zero
		end
		self.seqs[seq] = nil
	end)
	obj.transformChange = seq
	self.seqs = self.seqs or {}
	self.seqs[seq] = seq
end

function M:HeroGameObjectScaleChangeAni(hero)
	local heroGameObject = GameObject.Instantiate(hero.gameObject,hero.transform.parent)
	heroGameObject.transform.position = hero.transform.position
	heroGameObject.transform.rotation = hero.transform.rotation
	local body = heroGameObject.transform:Find("@body")
	local seq = DoTweenSequence.Create()
	seq:Append(body.transform:DOScale(Vector3.zero,0.4):SetEase(Enum.Ease.InSine))
	seq:OnKill(function ()
		Destroy(heroGameObject)
		self.seqs[seq] = nil
	end)
	seq:OnForceKill(function ()
		Destroy(heroGameObject)
		self.seqs[seq] = nil
	end)
	self.seqs = self.seqs or {}
	self.seqs[seq] = seq
end

function M:HeroScaleFromChangeAni(hero,vec)
	if hero.scaleFromChange then
		hero.scaleFromChange:Kill()
	end

	local seq = DoTweenSequence.Create()
	seq:Append(hero.body.transform:DOScale(vec,0.4):From():SetEase(Enum.Ease.InSine))
	seq:OnKill(function ()
		if hero and IsEquals(hero.transform) then
			hero.body.transform.localScale = Vector3.one
		end

		self.seqs[seq] = nil
	end)
	hero.scaleFromChange = seq
	self.seqs = self.seqs or {}
	self.seqs[seq] = seq
end

function M:HeroScaleChangeAni(hero,vec,t,callback)
	if hero.scaleChange then
		hero.scaleChange:Kill()
	end

	local seq = DoTweenSequence.Create()
	seq:Append(hero.body.transform:DOScale(vec,t):SetEase(Enum.Ease.InSine))
	seq:OnKill(function ()
		if hero and IsEquals(hero.transform) then
			hero.body.transform.localScale = vec
		end

		if callback then
			callback()
		end

		self.seqs[seq] = nil
	end)
	hero.scaleChange = seq
	self.seqs = self.seqs or {}
	self.seqs[seq] = seq
end

function M:SpeedUpInDoor()
	self.time_scale_value = 2.5
end


function M:On_boss_arise(bossObj)
    -- self.fsmLogic:addWaitStatusForUser( "circleMove" , { circleTargetObj = bossObj , radius = 6 } )
end


function M:On_gem_arise()
	-- self.fsmLogic:addWaitStatusForUser( "eatDiamond" ,{overBack=true})
end

function M:OnHeroDestroy(data)
	dump(data.location)
    if not data or not data.location then return end
    self:RemHero(data)
end

function M:OnHeroChange(data)
    if not data or not data.hero then return end
    self:ChangeHero(data)
end

function M:OnHeroCreate(data)
    if not data or not data.hero then return end
    self:AddHero(data.hero)
end

function M:SaleAllHero()

    GameInfoCenter.turret_list = {}
    
	-- local heros = GameInfoCenter.GetHeroList()

	-- local del = {}
	-- for i,v in ipairs(heros) do
	-- 	if v.data.location ~= 1 then
	-- 		del[v.data.heroId] = v.data.heroId
	-- 	end
	-- end

	-- for k,v in pairs(del) do
	-- 	--ClientAndSystemManager.SendRequest("cs_sale_turret",{id = v})
	-- end

end

function M:OnHeroRefresh()
    self:RefreshHero()
end

function M:OnHeroSetState(state)
	self.state = state
end

function M:OnHit(data)
	--如果当前处于无敌状态，并且不处于无视无敌的状态
	if self:IsTagActive("invincible") and data.attr ~= "IgnoreInvicble" then
		return
	end
	
	if self.state == "gameFinish" then
		return
	end

	if self.state == "die" then
		return
	end


	-- dump(data,"英雄受伤")
	if GameInfoCenter.playerDta.hp - data.damage < 1 then
		self.state = "die"
		self:DamageTxt(data.damage)
		GameInfoCenter.AddPlayerHp(-data.damage)
		self:OnDie()
	return
	else
		GameInfoCenter.AddPlayerHp(-data.damage)
		self:DamageTxt(data.damage)
	end


	Event.Brocast("ui_shake_screen_msg", {t=0.2, range=0.6,})
	-- 受伤即无敌 持续约1s (因为会导致dot伤害无敌，改为0.45s)
	self.invincible_index = self:AddTag({form = "herohead",tag = "invincible"})
	local at = 0.07
	local keep_invincible_time = 0.45
	local lp = math.floor(keep_invincible_time / (at*2))
	if IsEquals(self.hp_max) then
		local seq = DoTweenSequence.Create()
		local _fx = NewObject("YX_xuetiao_shouji",self.hp_max)
		local baidi = _fx.transform:Find("baidi")
		seq:AppendInterval(keep_invincible_time)
		seq:AppendCallback(function()
			if IsEquals(self.hp_max) and IsEquals(_fx.gameObject) then
				Destroy(_fx)
			end
		end)
	end
	--受击效果
	if IsEquals(self.head_spr) then

		--- 红色白色闪烁
		local seq = DoTweenSequence.Create()
		seq:AppendCallback(function()
			if not IsEquals(self.head_spr) then return end
			 self.head_spr.color = Color.red 
		end  )
		seq:AppendInterval(at)
		seq:AppendCallback(function()
			if not IsEquals(self.head_spr) then return end
			 self.head_spr.color = Color.white 
			end)
		seq:AppendInterval(at)
		seq:SetLoops(lp, Enum.LoopType.Restart)
		seq:OnKill(function ()
			if IsEquals(self.head_spr) then
				self.head_spr.color = Color.white				
				self:RemoveTagByIndex(self.invincible_index)
			end
		end)

	end

end

function M:OnHpUp()

end

function M:OnDie()
	Event.Brocast("set_mian_timer",{isOn = false})
	local seq = DoTweenSequence.Create()
	local allHeros = GameInfoCenter:GetAllHero()
	local sort_heros = {}
	for k,v in pairs(allHeros) do
		if v.data.location then
			sort_heros[v.data.location] = v
		end
	end
	local fxs = {}
	seq:AppendCallback(function()
		fxs[#fxs + 1] = NewObject("YX_sw_baozha_xiao",MapManager.GetMapNode())
		ExtendSoundManager.PlaySound(audio_config.cs.battle_hero_death1.audio_name)
		fxs[#fxs].gameObject.transform.position = self.tail.transform.position
		self.tail.gameObject:SetActive(false)
	end)
	local total_time = 1
	for i = #sort_heros,1,-1 do
		local v = sort_heros[i]
		if v then
			seq:AppendInterval(0.2)
			seq:AppendCallback(function()
				fxs[#fxs + 1] = NewObject("YX_sw_baozha_xiao",MapManager.GetMapNode())
				ExtendSoundManager.PlaySound(audio_config.cs.battle_hero_death1.audio_name)
				fxs[#fxs].gameObject.transform.position = v.transform.position
				v.transform.gameObject:SetActive(false)
			end)
		end
	end
	seq:AppendInterval(0.5)
	seq:AppendCallback(function()
		Event.Brocast("ui_shake_screen_msg", {t=0.5, range=0.6,})
		fxs[#fxs + 1] = NewObject("YX_sw_baozha_da",MapManager.GetMapNode())
		ExtendSoundManager.PlaySound(audio_config.cs.battle_hero_death2.audio_name)
		fxs[#fxs].gameObject.transform.position = self.transform.position
		self.gameObject:SetActive(false)
	end)
	seq:AppendInterval(2)
	seq:AppendCallback(function()
		for k,v in ipairs(fxs) do
			if IsEquals(v.gameObject) then
				Destroy(v.gameObject)
			end
		end
		GameInfoCenter.playerDta.state = "die"
		Event.Brocast("HeroAllDie")
	end)
end

function M:OnUpdateHeroHead(data)

	if not self.hp_spr then
		return
	end
	local width = self.hp_spr.size.x

	local oldHp = data.oldHp
	local oldMaxHp = data.oldMaxHp
	data.hp = math.max(data.hp,0)

	local h = data.hp / data.hpMax

	local px = (h - 1) * width * 0.5
	local sx = h

	local lp = self.hp_spr.transform.localPosition
	self.hp_spr.transform.localPosition = Vector3.New(px,lp.y,lp.z)
	local ls = self.hp_spr.transform.localScale
	self.hp_spr.transform.localScale = Vector3.New(sx,ls.y,ls.z)
	self.hp_txt.text = data.hp

	---- 白色血条慢慢减
	if data.hp < oldHp then
		local seq = DoTweenSequence.Create()
		seq:Append( self.hp_white_spr.transform:DOLocalMoveX( px , 0.5 ):SetEase(Enum.Ease.Linear)  )
		seq:Insert( 0 , self.hp_white_spr.transform:DOScaleX( sx  , 0.5 ):SetEase(Enum.Ease.Linear)  )
		seq:OnKill(function ()
			
		end)
	
		--- 加一个边框粒子效果
		self.hpBorderTx = NewObject( "XT_biankuang" , self.hp_max )
		local seq2 = DoTweenSequence.Create()
		seq2:AppendInterval(1)
		seq2:OnKill(function() 
			if self.hpBorderTx then
				Destroy(self.hpBorderTx)
				self.hpBorderTx = nil
			end
		end)

		--- 血条的抖动效果
		local hpLocalPos = self.hp_max.transform.localPosition

		local seq3 = DoTweenSequence.Create()
		seq3:Append( self.hp_max.transform:DOLocalMoveY( hpLocalPos.y + 0.1 , 0.05 ):SetEase(Enum.Ease.Linear) )
		seq3:Append( self.hp_max.transform:DOLocalMoveY( hpLocalPos.y -0.1 , 0.1 ):SetEase(Enum.Ease.Linear) )
		seq3:Insert( 0 , self.hp_max.transform:DOLocalMoveX( hpLocalPos.x + 0.1 , 0.05 ):SetEase(Enum.Ease.Linear) )
		seq3:Insert( 0 , self.hp_max.transform:DOLocalMoveX( hpLocalPos.x -0.1 , 0.1 ):SetEase(Enum.Ease.Linear) )
		seq3:SetLoops(3, Enum.LoopType.Restart)
		seq3:OnKill(function()
			self.hp_max.transform.localPosition = hpLocalPos
		end)

	else
		if data.hp - oldHp > 0 then
			self:DamageTxt(data.hp - oldHp,"Damage_Heal",nil,true)
		end
		if oldMaxHp and GameInfoCenter.playerDta.hpMax - oldMaxHp > 0 then
			self:DamageTxt(GameInfoCenter.playerDta.hpMax - oldMaxHp,"Damage_HpMaxUp",nil,true)
		end
	end

end

function M:DamageTxt(d,prefab,desc,hp_up)
	desc = desc or ""
	local tag = "-"
	if hp_up then
		tag = "+"
	end
	local pos = CSModel.Get3DToUIPoint(self.transform.position)

    CSEffectManager.PlayShowAndHideAndCall(
											MapManager.GetMapNode(),
											prefab or "Damage_Hero",
                                            20,
                                            Vector3.New(0, 2, 0),
                                            1,
                                            nil,
                                            nil,
                                            function (obj)
                                            	local r = math.random(-100,100) / 100
                                            	local r2 = math.random(0,50) / 100
                                            	obj.position = self.hp_node.transform.position + Vector3.New(0+r, 3.2+r2, 0)
                                            	local anim = obj.transform:GetComponent("Animator")
                                            	anim:Play("damage_anim", 0, 0)
                                            	obj.transform:Find("txt"):GetComponent("TMP_Text").text = 
												desc..tag..StringHelper.ToAbbrNum( d )
												obj.transform.parent = CSPanel.attack_node
                                        	end)
end

function M:CreatForzenPrefab()

	local forzenPrefab = CachePrefabManager.Take("forzen", self.forzenNode, 10)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero

	return forzenPrefab

end

function M:on_eat_something()
	local seq = DoTweenSequence.Create()
	self.transform.localScale = Vector3.New(total_scale,total_scale,total_scale)
	local scale = self.transform.localScale
	seq:Append(self.transform:DOScale(scale * 1.2,0.1):SetEase(Enum.Ease.InSine))
	seq:Append(self.transform:DOScale(scale,0.1):SetEase(Enum.Ease.InSine))
end