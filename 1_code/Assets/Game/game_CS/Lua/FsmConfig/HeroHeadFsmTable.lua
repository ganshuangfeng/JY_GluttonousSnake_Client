
local basefunc = require "Game/Common/basefunc"

local base = {
	eatDiamond = { slotName = "curMoveState" , className = "HeadEatDiamondCtrl" } ,
	circleMove = { slotName = "curMoveState" , className = "HeadCircleMoveCtrl" } ,
	intoHole = { slotName = "curMoveState" , className = "HeadIntoHoleCtrl" } ,
	--dizziness = { slotName = "curMoveState" , className = "DizzinessCtrl" } ,
	manualOper = { slotName = "curMoveState" , className = "HeadManualCtrl" } ,
	forceOffset = { slotName = "curMoveState" , className = "HeadForceOffsetCtrl" } ,
	--frozen = { slotName = "curMoveState" , className = "FrozenCtrl" } ,
	stationary = {slotName = "curMoveState" , className = "StationaryCtrl"},
	attack = { slotName = "curJob" , className = "AttackStateCtrl"},
		--curSkill
	
	norAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,

}

local fsm = basefunc.DataTableMap.New({

				curMoveState = basefunc.DataTable.New(
						{	"name"		    ,     "eatDiamond"	,     "circleMove"	     ,     "intoHole"	  ,   "stationary" ,		"manualOper",	"forceOffset" , },
					{
						{	"eatDiamond"    ,     "refresh"     ,     "discardNew"       ,     "discardNew"   ,  "discardNew"   ,	"replace",		"replace"     ,  },
						{	"circleMove"	,     "replace"     ,     "refresh"          ,     "discardNew"   ,  "discardNew"   ,	"replace",		"replace"     ,  },
						{	"intoHole"	    ,     "replace"     ,     "replace"          ,     "discardNew"   ,  "discardCur"   ,	"replace",		"replace"     ,  },
						{	"stationary"		,     "replace"     ,     "replace"          ,     "discardNew"   ,  "refresh"  	,	"replace",		"replace"     ,  },
						{	"manualOper"	,     "replace"     ,     "replace"       ,     "discardNew"   ,  "discardNew"  	,	"refresh",		"refresh"     ,  },
						{	"forceOffset"	,     "replace"     ,     "replace"       	 ,     "discardNew"   ,  "discardNew"  	,	"replace",		"discardCur"  ,  },
					}
				),
				curJob = basefunc.DataTable.New(
						{	"name"			,"idel"        ,   "attack"      ,    "frozen"	 },
					{	
						{	"idel"		    ,"refresh"     ,  "discardNew"   ,   "discardNew"  },
						{	"attack"		,"replace"     ,  "refresh"      ,   "discardNew"  },
						{	"frozen"		,"replace"     ,  "discardCur"   ,   "refresh"  },
                    }
				),
				curSkill = basefunc.DataTable.New(
						{	"name"			,"norAttack"        ,   "superAttack"     , },
					{	
						{	"norAttack"		    ,"refresh"     ,  "replace"  ,  },
						{	"superAttack"		,"replace"     ,  "refresh"     ,  },
                    }
				),

})

------- 继承例子
local fsm2 = basefunc.DataTableMap.New( {

		curMoveState = basefunc.DataTable.New(
				{	"name"		    ,    "intoHole"	  },
			{
				
				{	"manualOper"	,     "discardNew"     },
				
			}
		),
		curSkill = basefunc.DataTable.New(
				{	"name"			,"norAttack"        ,   "superAttack"     , },
			{	
				{	"norAttack"		    ,"<null>"     ,  "replace"  ,  },        --- 新状态的第二个为 <null> 则是删除这个新来状态
				{	"superAttack"		,"replace"     ,  "refresh"     ,  },
                  }
		),

} , fsm )


return { base = base , fsm = fsm2 }