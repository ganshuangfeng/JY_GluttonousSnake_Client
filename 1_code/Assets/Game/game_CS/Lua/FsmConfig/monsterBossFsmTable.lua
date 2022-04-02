
local basefunc = require "Game/Common/basefunc"

local base = {
	--curMove
	

	--curJob
	idel = { slotName = "curJob" , className = "MonsterBossIdelCtrl" } ,
	create = { slotName = "curJob" , className = "MonsterBossCreateCtrl" } ,
	chase = { slotName = "curJob" , className = "MonsterBossChaseCtrl" } ,
	attack = { slotName = "curJob" , className = "MonsterBossAttackCtrl" } ,
	superAttack = { slotName = "curJob" , className = "MonsterBossSuperAttackCtrl" } ,
	-- dizziness = { slotName = "curJob" , className = "DizzinessCtrl" } ,
	-- frozen = { slotName = "curJob" , className = "FrozenCtrl" } ,
	stationary = {slotName = "curJob" , className = "StationaryCtrl"},

	--curSkill
	norAttackSkill = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttackSkill = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
}

local fsm = basefunc.DataTableMap.New({

				curMove = basefunc.DataTable.New(
						{	"name"		,"breath"	,"walk"		},
					{

					}
				),
				curJob = basefunc.DataTable.New(
						{	"name"			,"idel"       ,    "create"       ,   "chase"      ,   "attack"     ,   "superAttack"   ,  "stationary"	  , },
					{	
						{	"idel"		    ,"refresh"    ,    "wait"         ,  "discardNew"  ,  "discardNew"  ,  "discardNew"     ,  "discardNew"   , },
						{	"create"		,"refresh"    ,    "discardNew"   ,  "replace"     ,  "replace"     ,  "replace"        ,  "replace"      , },
						{	"chase"		    ,"replace"    ,    "wait"         ,  "refresh"     ,  "discardNew"  ,  "discardNew"     ,  "discardNew"   , },
						{	"attack"		,"replace"    ,    "wait"         ,  "replace"     ,  "refresh"     ,  "wait"        ,  "discardNew"      , },
						{	"superAttack"	,"replace"    ,    "wait"         ,  "replace"     ,  "discardCur"     ,  "refresh"     ,  "discardNew"   ,  },
						{	"stationary"		,"replace"    ,    "wait"         ,  "discardCur"  ,  "discardCur"  ,  "discardCur"     ,  "refresh"  ,  },
                    }
				),
				curSkill = basefunc.DataTable.New(
						{	"name"			      ,"norAttackSkill"        ,   "superAttackSkill"     , },
					{	
						{	"norAttackSkill"		,"refresh"     ,  "discardCur"  ,  },
						{	"superAttackSkill"		,"replace"     ,  "refresh"     ,  },
                    }
				),

})


return { base = base , fsm = fsm }