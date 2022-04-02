------ 蛇身绕成 闭环后，被绕的区域，给其中的怪物加上debuff

local basefunc = require "Game/Common/basefunc"

SkillSnakeCircleGroundAttack = basefunc.class(Skill)
local M = SkillSnakeCircleGroundAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data

    ---- 检查间隔
    self.checkDelay = 0.02
    self.checkCount = 0
    
    ---- debuff 延迟
    self.debuffDelay = 0.3
    self.debuffCount = 0

    ---- 已经围上的格子点的集合 , map , key = tagStr , value = gridPos
    self.circledGridVec = {}

    ---- 正在做表现的点集合
    self.effectGridVec = {}

    --- 正在做死亡的格子 , key = tagStr , value = effectObj
    self.deadingGridEffectVec = {}
    self.deadingAlphaSp = 100

    --- 颜色
    self.color = { r = 0 , g = 1, b = 1 }

    ---- 当前的不透明度
    self.txAlpha = 255 
    self.txAlphaSp = 500
    self.txAlphaDir = 1
    self.minAlpha = 100

end

function M:Init(data)
    M.super.Init(self)

    self.data = data or self.data

    self:CD()
end


function M:Ready(data)
    M.super.Ready(self)

    self:Trigger()
end

function M:Exit(data)
    M.super.Exit(self)

    if self.effectGridVec and type(self.effectGridVec) == "table" then
    	for key,data in pairs(self.effectGridVec) do
    		if data.effect then
    			Destroy(data.effect)
    		end
    	end

    end
    self.effectGridVec = {}
    if self.deadingGridEffectVec and type(self.deadingGridEffectVec) and next(self.deadingGridEffectVec) then
		for tagStr , effectObj in pairs( self.deadingGridEffectVec ) do
			Destroy(effectObj)
		end
	end
	self.deadingGridEffectVec = {}


end

function M:Finish(data)
    M.super.Finish(self)

    if self.stateVec then
        for key, obj in pairs(self.stateVec) do
            obj:Stop()
        end
    end

    self:ResetData()

    ---- 状态重新回到 cd状态
    self:CD()
end

--------update中持续做的事--------------------
function M:OnActive(dt)
	if self.skillState ~= SkillState.active then
        return
    end
	
	self:Ready()
end

--触发中
function M:OnTrigger(dt)
    if self.skillState ~= SkillState.trigger then
        return
    end
    
    self.checkCount = self.checkCount + dt
    if  self.checkCount > self.checkDelay then
    	self.checkCount = 0
	    self:CheckAndCreateCircleGround()
	end

	self:dealDeadingGridEffect(dt)
	----做表现
	self:dealEffectSprite(dt)

	---- 处理 debuff
	self.debuffCount = self.debuffCount + dt
	if self.debuffCount > self.debuffDelay then
		self.debuffCount = 0
		self:dealCircleGroundDebuff()
	end

end

--- 处理正在死亡的格子，渐隐消失
function M:dealDeadingGridEffect(dt)
	-- dump( { self.deadingGridEffectVec , self.effectGridVec , self.circledGridVec }, "xxxx---------------self.deadingGridEffectVec:")
	if self.deadingGridEffectVec and type(self.deadingGridEffectVec) and next(self.deadingGridEffectVec) then
		for tagStr , effectObj in pairs( self.deadingGridEffectVec ) do
			local spriteCom = effectObj:GetComponent("SpriteRenderer")
			local oldColor = spriteCom.color

			oldColor.a = oldColor.a - (self.deadingAlphaSp*dt / 100)

			if oldColor.a <= 0 then
				self.deadingGridEffectVec[tagStr] = nil
				Destroy(effectObj)
			else
				spriteCom.color = Color.New( oldColor.r , oldColor.g , oldColor.b , oldColor.a )
			end

		end
	end
end

function M:dealEffectSprite(dt)
	if not next(self.effectGridVec) then
		self.txAlpha = 255
		return 
	end

	self.txAlpha = self.txAlpha + self.txAlphaSp * self.txAlphaDir * dt
	--print("xxx---------------self.txAlpha:" , self.txAlpha)

	if self.txAlpha > 255 then
		self.txAlphaDir = -self.txAlphaDir
		self.txAlpha = 255
	elseif self.txAlpha < self.minAlpha then
		self.txAlphaDir = -self.txAlphaDir
		self.txAlpha = self.minAlpha
	end

	for key,data in pairs(self.effectGridVec) do
		local spriteCom = data.effect.transform:GetComponent("SpriteRenderer")
		local oldColor = spriteCom.color
		spriteCom.color = Color.New( self.color.r , self.color.g , self.color.b , self.txAlpha / 255 )
	end
end

---- 处理给 范围内的敌人加 debuff
function M:dealCircleGroundDebuff()
	local all_monster = GameInfoCenter.GetAllMonsters()
	--dump(self.effectGridVec , "<color=yellow>xxxx---------------self.effectGridVec:</color>")

	for key , obj in pairs(all_monster) do
		local objPos = obj.transform.position
		local objPosGridTagStr = get_grid_pos( self.object , objPos ) --GetGridPosTagkeyStr( self.object , objPos )

		--print("<color=yellow>xxx------------ monsterTag:</color>" , objPosGridTagStr)

		if self.effectGridVec[objPosGridTagStr] then

			obj.fsmLogic:addWaitStatusForUser( "frozen" )
			--print("<color=yellow> xxx--------------add frozen </color>")
		end

	end

end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
end


--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

function M:createEffectSprite(pos)
	if self.deadingGridEffectVec[GetMapNoByPos( self.object , pos)] then
		local obj = self.deadingGridEffectVec[GetMapNoByPos( self.object , pos)]
		self.deadingGridEffectVec[GetMapNoByPos(self.object , pos)] = nil
		return obj
	end

	local parent = MapManager.GetMapNode()
    local obj = GameObject.Instantiate(GetPrefab("GridBack"),parent.transform)
    obj.transform.position = Vector3.New( pos.x , pos.y , 0 )
    obj.gameObject.name = "CircleEffect_" .. pos.x .. "_" .. pos.y
    
	local spriteCom = obj.transform:GetComponent("SpriteRenderer")
	local oldColor = spriteCom.color
	spriteCom.color = Color.New( self.color.r , self.color.g , self.color.b , self.txAlpha / 255 )

    return obj
end

------------------------
function M:CheckAndCreateCircleGround()
	--print("xxx----------------------CheckCircleGround")
	self.circledGridVec = {}
	self:FindCircle()

	----- 对正在做效果的点集合，做增删
	--- 先删除
	for key , data in pairs( self.effectGridVec ) do
		if not self.circledGridVec[key] then
			--Destroy(data.effect)
			self.effectGridVec[key] = nil

			self.deadingGridEffectVec[key] = data.effect
		end
	end

	for key,data in pairs(self.circledGridVec) do
		if not self.effectGridVec[key] then
			--print("<color=green>xxx-------------create effect sprite </color>")
			self.effectGridVec[key] = {
				pos = data ,
				effect = self:createEffectSprite(data)
			}

		end
	end

	--if next(self.effectGridVec) then
	--	dump(self.effectGridVec , "xxx--------------self.effectGridVec")
	--end

end

--- 从头到尾 检查形成的闭环 
function M:FindCircle()
	--print("xxx-------------------------------FindCircle")
	local heroHead = GameInfoCenter.GetHeroHead()
	local heroHeadPos = heroHead.transform.position
	local heroGridPos = get_grid_pos( self.object , heroHeadPos )
	local heroGridTagStr = GetMapNoByPos( self.object , heroGridPos ) -- GetPosTagKeyStr( self.object , heroGridPos)

	local snakeTailPos = GameInfoCenter.GetHeroPosList()

	local snakeTail = { pos_list = snakeTailPos }
	----- 把从蛇头到蛇尾的位置 格子化 ， 
	--MoveAlgorithm.DealSnakeTailToGridData(snakeTail , heroHeadPos )
	DealSnakeTailToGridData( self.object , snakeTail , heroHeadPos )

	--- 把蛇头的格子点 加进来 , 只要蛇头和 第一个 蛇尾的格子不相同，就加进来
	local firstTail = snakeTail.pos_list[1] or {}
	if next(firstTail) and (not basefunc.float_equal(heroGridPos.x , firstTail.x) or not basefunc.float_equal(heroGridPos.y , firstTail.y) ) then
		table.insert( snakeTail.pos_list , 1 , heroGridPos )
		snakeTail.pos_map[heroGridTagStr] = true
	end

	--dump(snakeTail , "xxx--------------snakeTail:")

	------ 从头开始找 ， 依次放到检查表中
	local checkedTail = {
		list = {} ,  --- key = index , value = pos
		map = {} ,   --- key = tagStr , value = index
	}
	for key,gridPos in ipairs( snakeTail.pos_list ) do
		local tagStr = GetMapNoByPos( self.object , gridPos)   -- GetPosTagKeyStr( self.object , gridPos)
		--- 先看之前有没有
		if checkedTail.map[tagStr] then
			--- 把从重叠点的位置 到 当前点的网格点 都插到一个表中 ， 按蛇头方向在前
			local circleGridList = {}

			for i = checkedTail.map[tagStr] , key  do
				table.insert( circleGridList ,  checkedTail.list[i] )
			end

			self:dealCircleFill( circleGridList )

		else
			---- 记一个 key 位置，只记最小的，这样的圆就是最大的
			checkedTail.map[tagStr] = key

		end

		checkedTail.list[key] = gridPos
	end


end

--- 将闭环的格子list列表，将其中包含的格子 找到
function M:dealCircleFill( _circleGridList )
	--dump(_circleGridList , "<color=red>xxxx-------------------------dealCircleFill</color>")
	local min_x = 99999999
	local max_x = -99999999
	local min_y = 99999999
	local max_y = -99999999

	local grid_size = GetGridSize(self.object) --GameInfoCenter.map.grid_size

	if not next(_circleGridList) then
		return
	end
	--dump(self.circledGridVec , "xxxx-------------------before")
	---- 组装一个map
	local _circleGridMap = {}
	for key,pos in ipairs(_circleGridList) do
		_circleGridMap[ GetMapNoByPos(self.object , pos) ] = key
	end

	--dump(_circleGridMap , "xxx---------------------------_circleGridMap:")

	for key , pos in ipairs(_circleGridList) do
		if pos.x < min_x then
			min_x = pos.x
		end
		if pos.x > max_x then
			max_x = pos.x
		end

		if pos.y < min_y then
			min_y = pos.y
		end
		if pos.y > max_y then
			max_y = pos.y
		end
	end

	--print("xxx----------------min max " , min_x , max_x , min_y , max_y)

	---- 是否有中空的 格子，没有的话全部不加
	local isHaveInsideGrid = false

	local find_vec = {}
	--- 处理这个方向区域的点，判断是否在 环形内
	local x_num = math.floor( (max_x - min_x) / grid_size + 0.5 ) + 1
	local y_num = math.floor( (max_y - min_y) / grid_size + 0.5 ) + 1

	--print("xxx----------------min max " , min_x , max_x  , x_num , min_y , max_y  ,  y_num)

	for ix = 1 , x_num   do
		for iy = 1 , y_num do
			local x = min_x + (ix-1) * grid_size
			local y = min_y + (iy-1) * grid_size

			--print("xxxx----------------for x,y:" , x , y )
			repeat

				local now_grid = { x = x , y = y , isGrid = true }
				local now_grid_tag = GetMapNoByPos( self.object , now_grid ) -- GetPosTagKeyStr( self.object , now_grid)
				------------------------ 是否在线上
				if _circleGridMap[now_grid_tag] then
					find_vec[#find_vec + 1] = { tagStr = now_grid_tag , gridPos = now_grid }

					
					break
				end

				---------------------- 判断是否在内部
				local left_num = 0
				local right_num = 0

				for cx = 1 , x_num  do
					local xCursor = min_x + (cx-1) * grid_size
					--print("xxx------- xCursor,  y:" , xCursor , y)

					--- 如果是与线相交，要判断 上下 
					--local circleIndexKey = _circleGridMap[GetGridPosTagkeyStr( self.object , { x = xCursor , y = y , isGrid = true } )]
					local circleIndexKey = _circleGridMap[ GetMapNoByPos( self.object , { x = xCursor , y = y , isGrid = true }  ) ]
					if circleIndexKey then
						---- 线性圆的 左右边的点
						local leftCircleIndex = circleIndexKey - 1
						local rightCircleIndex = circleIndexKey + 1

						if leftCircleIndex <= 0 then
							leftCircleIndex = #_circleGridList
						end

						if rightCircleIndex > #_circleGridList then
							rightCircleIndex = 1
						end

						local leftCirclePos = _circleGridList[leftCircleIndex]
						local rightCirclePos = _circleGridList[rightCircleIndex]
						--print("xxx---------------leftCirclePos, rightCirclePos:" , leftCirclePos.y , rightCirclePos.y )
						--and _circleGridMap[ GetGridPosTagkeyStr( { x = xCursor , y = y + grid_size } ) ]
						if leftCirclePos.y < y - grid_size/2 or rightCirclePos.y < y - grid_size/2 then
							--print("xxx---------------add one:"  , y , leftCirclePos.y , rightCirclePos.y )
							if xCursor < x then
								left_num = left_num + 1
							elseif xCursor > x then
								right_num = right_num + 1
							end
						end
					end
				end
				--print("xxx-----------------------------end left_num , right_num:" , left_num , right_num )
				if left_num % 2 == 1 and right_num %2 == 1 then
					find_vec[#find_vec + 1] = { tagStr = now_grid_tag , gridPos = now_grid }
					isHaveInsideGrid = true
					
				end

			until true
		end
	end

	---- 找 x 相同的最大个数  [x] = num
	local x_same_data = {  }
	local y_same_data = {  }

	local sameXMax = 0
	local sameYMax = 0
	for key ,data in pairs(find_vec) do
		x_same_data[ data.gridPos.x ] = (x_same_data[ data.gridPos.x ] or 0) + 1
		if x_same_data[ data.gridPos.x ] > sameXMax then
			sameXMax = x_same_data[ data.gridPos.x ]
		end

		y_same_data[ data.gridPos.y ] = (y_same_data[ data.gridPos.y ] or 0) + 1
		if y_same_data[ data.gridPos.y ] > sameYMax then
			sameYMax = y_same_data[ data.gridPos.y ]
		end
	end

	---- 只有中间有中空的才算
	--if #find_vec >= 4 then
	--if isHaveInsideGrid then
	if sameXMax >= 2 and sameYMax >= 2 then
		for key , data in ipairs(find_vec) do
			self.circledGridVec[data.tagStr] = ConvertToPos( self.object , data.gridPos )
		end
	end


	--dump(self.circledGridVec , "xxxx-------------------after")

	return find_vec
end

