local basefunc = require "Game/Common/basefunc"

------- 怪物的职业管理  ， 这里只负责 fsm 的状态转换
MonsterProfessionManager = {}

local C = MonsterProfessionManager

---- 职业对应表
C.professionMap = {
	---- 职业类型
	hold = { 
		fsmTable = "holdFsmTable" ,
		---- 消息处理
		msgDeal = {
			---- 
			monster_create_after = { deal_func = "DealMonsterCreateAfter" , newState = "idel" } ,
		}, 
	} ,
	
	---- 先站岗，进入视线之后，一直追击
	holdChase = {
		fsmTable = "holdChaseFsmTable" ,
		---- 消息处理
		msgDeal = {
			---- 
			monster_create_after = { deal_func = "DealMonsterCreateAfter" , newState = "idel" } ,
			--- 视野找到目标
			monster_view_check_target = { deal_func = "DealMonsterViewFindTarget" , newState = "chase" } ,
		}, 
	},

	---- 先站岗，进入视线之后，脱离视野不会追击
	holdViewChase = {
		fsmTable = "holdViewChaseFsmTable" ,
		---- 消息处理
		msgDeal = {
			---- 
			monster_create_after = { deal_func = "DealMonsterCreateAfter" , newState = "idel" } ,
			--- 视野找到目标
			monster_view_find_target = { deal_func = "DealMonsterViewFindTarget" , newState = "chase" } ,
		}, 
	},

	---- 站岗，逃离
	flee = {
		fsmTable = "fleeFsmTable" ,
		---- 消息处理
		msgDeal = {
			---- 
			monster_create_after = { deal_func = "DealMonsterCreateAfter" , newState = "runaway" } ,
			--- 视野找到目标
			monster_view_find_target = { deal_func = "DealMonsterViewFindTarget" , newState = "flee" } ,
		},
	}


}

--- 初始化 职业 的消息监听
function C.InitProfession( _monsterObj , _professionType )
	if not _professionType then
		return
	end

	-------------------------------------------------------------------------- 处理状态表
	local fsmConfig = require ("Game.game_CS.Lua.MonsterProfession." .. C.professionMap[_professionType].fsmTable )

	--- 把以前的 状态表 存进去
	_monsterObj.oldFsmConfig = _monsterObj.fsmLogic:GetFsmConfig()

	local oldFsmConfig = basefunc.deepcopy( _monsterObj.oldFsmConfig )
	local newFsmConfig = {}

	newFsmConfig.base = basefunc.merge( fsmConfig.base , oldFsmConfig.base )
	newFsmConfig.fsm = basefunc.DataTableMap.New( fsmConfig.orgFsm , _monsterObj.oldFsmConfig.fsm )

	_monsterObj.fsmLogic:SetFsmConfig(newFsmConfig)

	------------------------------------------------------------------------- 处理消息监听
	_monsterObj.professionLister = _monsterObj.professionLister or {}

	if C.professionMap[_professionType] and C.professionMap[_professionType].msgDeal then
		local tarMsgDeal = C.professionMap[_professionType].msgDeal


		for msgName,data in pairs(tarMsgDeal) do

			---- 封成一个 函数
			local func = function(...)
				return C[data.deal_func]( _monsterObj , data.newState , ... )
			end

			_monsterObj.professionLister[msgName] = func

	        Event.AddListener(msgName, func)
	    end

	end
end

--- 删除 职业 的消息监听
function C.DeleteProfession(_monsterObj)
	---- 还原状态表
	if _monsterObj.oldFsmConfig then
		_monsterObj.fsmLogic:SetFsmConfig( _monsterObj.oldFsmConfig )
	end

	---- 还原 消息监听
	if _monsterObj.professionLister and type(_monsterObj.professionLister) == "table" then
		for msgName , func in pairs(_monsterObj.professionLister) do
			Event.RemoveListener(msgName, func)
		end
	end
end

--- 改变fsm状态
function C.changeFsmState( _monsterObj , _newState )
	_monsterObj.fsmLogic:addWaitStatusForUser( _newState )
end

--------------------------------------------------- 其他 消息监听函数 ↓ --------------------------------------------
----
function C.DealMonsterCreateAfter( _monsterObj , _newState , _monster_id )
	if _monsterObj.id == _monster_id then
		C.changeFsmState( _monsterObj , _newState )
	end
end

function C.DealMonsterViewFindTarget( _monsterObj , _newState , _monster_id )
	if _monsterObj.id == _monster_id then
		C.changeFsmState( _monsterObj , _newState )
	end
end
