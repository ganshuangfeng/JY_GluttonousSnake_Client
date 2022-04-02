local basefunc = require "Game/Common/basefunc"

DropAsset = basefunc.class()
local M = DropAsset
M.name = "DropAsset"
--没有解锁的英雄不会掉落
function M.Create(data)
	return M.New(data)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["StageFinish"] = basefunc.handler(self,self.Exit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(data)
	data = data or {}
	ExtPanel.ExtMsg(self)
	local parent = data.parent or CSPanel.map_node
	local obj = NewObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.transform.position = data.pos or Vector3.New(0,0,0)
	self.config = data.config
	LuaHelper.GeneratingVar(self.transform, self)
	self.data = data 
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	local config = self.config
	local nowLevel = 1
	if not config then
		return
	end
	--GameConfigCenter.GetGoldLevelBeiShu( sd.curLevel , nowLevel , judgeLevel )
	local sd = GameInfoCenter.GetStageData()
	local re = {}
	local radius = 3
	for i = #config,1,-1 do
		local num = 12
		if config[i].key == "prop_gold_coin2" then
			num = GameConfigCenter.GetGoldLevelBeiShu( sd.curLevel , 2 , 1 )
			num = num * config[i].value		
			local pos_list = {}	
			for ii = 1,num do
				local data = {}
				data.jb    = math.floor(config[i].jb / num)
				data.key  = "prop_gold_coin1"
				data.value = 1
				data.default_pos = DropAsset.CalculateGoldPos(ii,pos_list,self.transform.position)

				config[#config + 1] = data
			end

			table.remove(config,i)
		elseif config[i].key == "prop_gold_coin3" then
			num = GameConfigCenter.GetGoldLevelBeiShu( sd.curLevel , 3 , 1 )
			num = num * config[i].value
			local pos_list = {}	
			for ii = 1,num do
				local data = {}
				data.jb    = math.floor(config[i].jb / num)
				data.key  = "prop_gold_coin1"
				data.value = 1
				data.default_pos = DropAsset.CalculateGoldPos(ii,pos_list,self.transform.position)

				config[#config + 1] = data
			end

			table.remove(config,i)
		end

	end
	if config then
		self:AnimObj(config)
	end
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:AnimObj(config)
	local lightVec = {}
	local index = 1
	for i = 1 , #config do
		lightVec[#lightVec + 1] = CachePrefabManager.Take("TW_jinbi" , self.transform )
		if self.data.parent_pos then
			lightVec[#lightVec].prefab.prefabObj.transform.position = self.data.parent_pos
		else
			lightVec[#lightVec].prefab.prefabObj.transform.localPosition = Vector3.zero
		end
	end
	local totalTime = 0.4
	--local size = GameInfoCenter.GetMapSize()
	local size = GetSceenSize( MapManager.GetCurRoomAStar() )
	local width = size.width - 6
	local height =  size.height - 6
	local set_right_pos = function(pos)
		local new_pos = {z = 0}
		if math.abs(pos.x) > width / 2 then
			new_pos.x = pos.x/math.abs(pos.x) * (width / 2)
		else
			new_pos.x = pos.x
		end
		if math.abs(pos.y) > height /2 then
			new_pos.y = pos.y/math.abs(pos.y) * (height / 2)
		else
			new_pos.y = pos.y
		end
		return new_pos
	end

	

	local anim_func = function (prefab,key)
		local obj = prefab.prefab.prefabObj.gameObject
		local tran = obj.transform
		local config_data = config[key]

		local seq = DoTweenSequence.Create()
		
		local randomAngle = math.random( 0 , 360 )
		local neiR = 160
		local waiR = 200

		local randomR = math.random( neiR , waiR ) / 100
		if self.data.close_random_pos then
			randomR = 0
		end
		local tarPos = config_data.default_pos or Vector3.New( randomR * math.cos( randomAngle / 180 * math.pi ) , randomR * math.sin( randomAngle / 180 * math.pi ) , 0 ) 
		local parentPos = { x = self.transform.position.x , y = self.transform.position.y }
		local worldPos = { x = parentPos.x + tarPos.x , y = parentPos.y + tarPos.y }

		worldPos = ConvertToGrid( MapManager.GetCurRoomAStar() , worldPos )

		worldPos = set_right_pos(worldPos)

		local npg = GetMapNotPassGridData( MapManager.GetCurRoomAStar() )

		local k = GetMapNoByPos( MapManager.GetCurRoomAStar() , ConvertToPos(  MapManager.GetCurRoomAStar() , worldPos) ) --GetPosTagKeyStr( get_grid_pos( pos ) )
		if npg[k] then
			local cpg = GetMapCanPassGridData(MapManager.GetCurRoomAStar())
			local coordine = GetMapCoordByNo(MapManager.GetCurRoomAStar(),k)
			for i = 1,10 do
				--在附近寻找合适的格子
				for j = 1,2 do
					local x_change = false
					local y_change = false
					local offset = i
					if j == 2 then offset = -i end
					local new_no = GetMapNoByCoord(MapManager.GetCurRoomAStar(),coordine.x + offset,coordine.y)
					if cpg[new_no] then
						k = new_no
						x_change = true
						break
					end
					new_no = GetMapNoByCoord(MapManager.GetCurRoomAStar(),coordine.x,coordine.y + offset)
					if cpg[new_no] then
						k = new_no
						y_change = true
						break
					end
					if not x_change and not y_change then
						worldPos = ConvertToGrid( MapManager.GetCurRoomAStar() , { x = parentPos.x , y = parentPos.y } )
					else
						local default_offset = -0.5
						if j == 2 then default_offset = -default_offset end
						wolrdPos = GetMapPosByNo(MapManager.GetCurRoomAStar(),k)
						if x_change then
							worldPos.x = worldPos.x + default_offset
						elseif y_change then
							worldPos.y = worldPos.y + default_offset
						end
					end
				end
			end
		end
		worldPos = set_right_pos(worldPos)

		worldPos = ConvertToPos(  MapManager.GetCurRoomAStar() , worldPos)

		tarPos = { x = worldPos.x - parentPos.x , y = worldPos.y - parentPos.y }
		

		seq:Append(tran:DOLocalMoveX( tarPos.x  , totalTime ):SetEase(Enum.Ease.Linear))

		local upY = (tarPos.y > 0) and (tarPos.y + math.random(150,300)/100) or ( math.random(150,300)/100 )

        seq:Insert(0 , tran:DOLocalMoveY( upY , totalTime/2 ):SetEase(Enum.Ease.OutCirc));
        --下落
        seq:Insert(totalTime/2 , tran:DOLocalMoveY( tarPos.y , totalTime/2 ):SetEase(Enum.Ease.InCirc));
        seq:AppendInterval(0.2)
        seq:OnKill(function ()
			--
			local data = config[index]
			data.pos = obj.transform.position
			
			--dump( { self.transform.position , tarPos , {x = data.pos.x , y = data.pos.y } } , "<color=yellow>xxx-------------dropAsset </color>" )

			self:CreatePrefab(data)
			index = index + 1
			CachePrefabManager.Back(prefab)
		end)
	end

	for key , obj in pairs(lightVec) do
		anim_func(obj,key)
	end
end

function M:CreatePrefab(data)
	local key = data.key
	local value = data.value
	local aniOverCallback = self.data.aniOverCallback
	if key == "prop_jin_jb" then
		value = value * (1 + (TechnologyManager.GetGoldGetUp() / 100))
		CreateFactory.CreateGoods({type = 6,parent = CSPanel.map_node,pos = data.pos,jb = value,destroy_time = self.data.destroy_time,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif key == "prop_power_nl" then
		CreateFactory.CreateGoods({type = 8,parent = CSPanel.map_node,pos = data.pos,nl = value,destroy_time = self.data.destroy_time,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif key == "hero_3in1" then
		CreateFactory.CreateGoods({type = 9,parent = CSPanel.map_node,pos = data.pos,heroConfig = data.heroConfig,destroy_time = self.data.destroy_time,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif string.sub(key, 1, 10) == "prop_hero_" then
		local hero_type = tonumber(string.sub(key, 11))
		if not HeroDataManager.IsHeroUnlock(hero_type) then
			hero_type = HeroDataManager.GetRandomHeroTypeUnLock()
		end
		CreateFactory.CreateGoods({type = 5,parent = CSPanel.map_node,pos = data.pos,heroType = tonumber(hero_type),destroy_time = 999,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif key == "item_heal" then
		CreateFactory.CreateGoods({type = 7,parent = CSPanel.map_node,pos = data.pos,skill = 4,disableAutoMove = true,destroy_time = 999,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif key == "hit_speed_up" then
		CreateFactory.CreateGoods({type = 7,parent = CSPanel.map_node,pos = data.pos,skill = 2,disableAutoMove = true,destroy_time = 999,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif key == "run_speed_up" then
		CreateFactory.CreateGoods({type = 7,parent = CSPanel.map_node,pos = data.pos,skill = 3,disableAutoMove = true,destroy_time = 999,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	elseif string.sub(key,1,14) == "prop_gold_coin" then
		local level = tonumber(string.sub(key, 15))
		local jb = data.jb
		for i=1,value do
			local pos = Vector3.New(data.pos.x,data.pos.y,0) -- Vector3.New(data.pos.x,data.pos.y+(i-1)*0.8,0)
			--dump( pos , "<color=blue>xxxx------------posTem:</color>:")
			CreateFactory.CreateGoods({type = 6 , isUsePos = true ,parent = CSPanel.map_node,pos = pos , jb=jb,level = level,destroy_time = self.data.destroy_time,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
		end
	elseif key == "connector" then
		data.data.pos = data.pos
		local obj = CreateFactory.CreateConnector(data.data)
	elseif key == "add_extra_skill_usetime" then
		CreateFactory.CreateGoods({type = 10,parent = CSPanel.map_node,pos = data.pos,disableAutoMove = true,destroy_time = 999,roomNo=self.data.roomNo,aniOverCallback=aniOverCallback})
	else
		dump(key,"<color=red>没有这种掉落物</color>")
	end
end

function M.Init()
	M.gold_pos_map = {}
end

function M.CalculateGoldPos(index,pos_list,parent_pos)
	local spac_pos = 2
	--以自己的位置为原点的格子坐标
	local pos_list = pos_list or {}
	
	local start_radius = 3
	local cur_circle = 1
	local radius_spac = 2
	local cur_radius = start_radius
	
	local circle_count_func = function(radius)
		return radius * radius - (radius - 2) * (radius - 2)
	end
	local circle_total = circle_count_func(start_radius)
	local count_total = circle_count_func(start_radius)
	while cur_circle < 100 do
		if index <= count_total then
			break
		else
			cur_circle = cur_circle + 1
			cur_radius = cur_radius + radius_spac
			circle_total = circle_count_func(cur_radius)
			count_total = count_total + circle_total
		end
	end
	local rdn_list = {}
	for i = count_total - circle_total + 1,count_total do
		if pos_list[i] then
		else
			rdn_list[#rdn_list + 1] = i
		end
	end
	local cur_pos_index = count_total - circle_total + 1
	if rdn_list and next(rdn_list) then
		cur_pos_index = rdn_list[math.random(1,#rdn_list)]
	end
	pos_list[cur_pos_index ] = true
	
	--根据cur_pos_index计算出偏移坐标
	local cur_pos_index_incircle = cur_pos_index - count_total + circle_total
	local row = math.ceil(cur_pos_index_incircle / (circle_total / 4))
	local x = - cur_circle
	local y = cur_circle
	if row == 1 then
		y = cur_circle
		x = - cur_circle + cur_pos_index_incircle
	elseif row == 2 then
		x = cur_circle
		y = cur_circle - (cur_pos_index_incircle - (circle_total / 4)) 
	elseif row == 3 then
		x = cur_circle - (cur_pos_index_incircle - (circle_total /4) * 2)
		y = - cur_circle
	elseif row == 4 then
		x = -cur_circle
		y = - cur_circle + (cur_pos_index_incircle - (circle_total /4) * 3)
	end
	local pos = Vector3.New(x,y,0) * spac_pos
	if not parent_pos then
		return pos,pos_list
	else
		if not M.gold_pos_map then
			M.gold_pos_map = {}
		end
		--将位置归为能被2整除的整数
		local parent_x = parent_pos.x
		local parent_y = parent_pos.y
		local get_coordine = function(_num)
			_num = _num / 2
			if _num - math.floor(_num) > 0.5 then
				_num = math.ceil(_num)
			else
				_num = math.floor(_num)
			end
			return _num
		end
		parent_x = get_coordine(parent_x)
		parent_y = get_coordine(parent_y)
		local pos_coordine = {
			x = parent_x + x,
			y = parent_y + y,
		}
		M.gold_pos_map[pos_coordine.x] = M.gold_pos_map[pos_coordine.x] or {}
		if M.gold_pos_map[pos_coordine.x][pos_coordine.y] then
			local change_flag = false
			for i = 1,10 do
				--在附近寻找合适的格子
				for j = 1,2 do
					local offset = i
					if j == 2 then offset = -i end
					M.gold_pos_map[pos_coordine.x + offset] = M.gold_pos_map[pos_coordine.x + offset] or {}
					if not M.gold_pos_map[pos_coordine.x + offset][pos_coordine.y] then
						pos_coordine.x = pos_coordine.x + offset
						change_flag = true
						break
					end
					if not M.gold_pos_map[pos_coordine.x][pos_coordine.y + offset] then
						pos_coordine.y = pos_coordine.y + offset
						change_flag = true
						break
					end
				end
				if change_flag then break end
			end
			if not change_flag then
				return pos,pos_list
			end
		end
		M.gold_pos_map[pos_coordine.x][pos_coordine.y] = true
		pos = Vector3.New(pos_coordine.x,pos_coordine.y,0) * spac_pos - parent_pos
		return pos,pos_list
	end
end

function M.ClearGoldPos(position)
	local x = position.x
	local y = position.y
	local get_coordine = function(_num)
		_num = _num / 2
		if _num - math.floor(_num) > 0.5 then
			_num = math.ceil(_num)
		else
			_num = math.floor(_num)
		end
	end
	x = get_coordine(x)
	y = get_coordine(y)
	if M.gold_pos_map[x] and M.gold_pos_map[x][y] then
		M.gold_pos_map[x][y] = nil
	end
end