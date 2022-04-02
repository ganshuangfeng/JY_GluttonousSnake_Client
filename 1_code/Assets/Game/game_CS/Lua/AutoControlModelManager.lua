------- 自动控制模式 管理器

AutoControlModelManager = {}
local M = AutoControlModelManager

--- 是否起作用
M.isEnable = false

M.lister = {}

M.checkAutoMoveDelay = 0.1
M.checkAutoMoveCount = M.checkAutoMoveDelay

M.checkAutoSkillDelay = 0.1
M.checkAutoSkillCount = M.checkAutoSkillDelay

function M.Init()
	M.MakeLister()
	M.AddListener()
end



function M.MakeLister()
	
	--M.lister["auto_control_model_enable_change"] =  M.on_auto_control_model_enable_change 
	--M.lister["vehicle_finish_step"] = M.on_vehicle_finish_step 
end

function M.AddListener()
	for proto_name,func in pairs(M.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.RemoveListener()
	for proto_name,func in pairs(M.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.GetIsEnable()

	return M.isEnable
end

function M.SetIsEnable( isEnable )
	print("xxx------------SetIsEnable 1:")
	if isEnable ~= M.isEnable then

		M.isEnable = isEnable
		print("xxx------------SetIsEnable 2:" , M.isEnable)
		----- 发一个消息
		Event.Brocast("auto_control_model_enable_change" , M.isEnable )

	end
end

----- 检查自动释放技能
function M.CheckAutoSkill()

	local skillCdData = ExtSkillSP2Panel.GetSkillCDData()

	if skillCdData and type(skillCdData) == "table" then
		for key,cd_value in pairs(skillCdData) do
			if cd_value <= 0 then
				ExtSkillSP2Panel.TriggerExtSkill( key )

			end
		end
	end

end

----- 检查自动移动
function M.CheckAutoMove()
	--print("xxx-------------CheckAutoMove 1")
	---- 根据优先级 ， 判断是否有要吃的东西
	local selectVec = {}

	--- 要移动到的目标 goods 类型
	local goodsType = { 
		[1] = true , 
		[4] = true , 
		[5] = true , 
		[6] = true ,
	 }  

	local allGoods = GameInfoCenter.GetAllGoods()

	for _type , data in pairs(allGoods) do
		if goodsType[_type] then
			for id , obj in pairs(data) do
				selectVec[#selectVec + 1] = obj
			end
		end
	end

	local heroHead = GameInfoCenter.GetHeroHead()
	local heroHeadPos = heroHead.transform.position
	--local gridHeadPos = get_grid_pos(heroHeadPos)
	local gridHeadPos = get_grid_pos( MapManager.GetCurRoomAStar()  , heroHeadPos , true )

	--dump(gridHeadPos , "xxx----------gridHeadPos:")
	--dump(selectVec , "xxx----------selectVec:")
	---- 找到最小的，并且发出去
	if next(selectVec) then
		local min_dis = 9999999
		local tarPos = nil
		for key , obj in pairs(selectVec) do

			local disSeq = Vec2DDistanceSq( heroHeadPos , obj.transform.position )
			--local gridPos = get_grid_pos( obj.transform.position )
			local gridPos = get_grid_pos( MapManager.GetCurRoomAStar()  ,  obj.transform.position , true )
			--dump(gridPos , "xxx----------gridPos:")
			if disSeq < min_dis and ( gridPos.x ~= gridHeadPos.x or gridPos.y ~= gridHeadPos.y ) then
				min_dis = disSeq
				tarPos = obj.transform.position
			end
		end

		if tarPos then
			--print("xxx-------------CheckAutoMove 2 success set tarPos :" , tarPos.x , tarPos.y )
			GameInfoCenter.SetHeroHeadTargetData( { pos = tarPos } )

			heroHead.fsmLogic:addWaitStatusForUser( "eatDiamond" )

			return
		end
	else
		GameInfoCenter.SetHeroHeadTargetData( nil )
	end

	---- 判断如果有 boss , 绕圈
	local monsterBoss = GameInfoCenter.GetMonsterBossObj()

	if monsterBoss then
		--print("xxx----------------- monsterBoss :")
		heroHead.fsmLogic:addWaitStatusForUser( "circleMove" , { circleTargetObj = monsterBoss , radius = 6 } )
	end

end

function M.FrameUpdate(dt)

	if not M.isEnable then
		return
	end

	M.checkAutoMoveCount = M.checkAutoMoveCount + dt
	if M.checkAutoMoveCount > M.checkAutoMoveDelay then
		M.checkAutoMoveCount = 0
		M.CheckAutoMove()
	end

	M.checkAutoSkillCount = M.checkAutoSkillCount + dt
	if M.checkAutoSkillCount > M.checkAutoSkillDelay then
		M.checkAutoSkillCount = 0
		M.CheckAutoSkill()
	end

end



