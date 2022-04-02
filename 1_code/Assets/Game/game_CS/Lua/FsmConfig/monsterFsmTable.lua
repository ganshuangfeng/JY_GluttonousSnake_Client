
local basefunc = require "Game/Common/basefunc"

local base = {
	--curMove
	breath = { slotName = "curMove" , className = "MonsterBreathCtrl" } ,
	walk = { slotName = "curMove" , className = "MonsterWalkCtrl" } ,

	--curJob
	idel = { slotName = "curJob" , className = "MonsterIdelCtrl" } ,
	chase = { slotName = "curJob" , className = "MonsterChaseCtrl" } ,
	attack = { slotName = "curJob" , className = "AttackStateCtrl" } ,
	-- dizziness = { slotName = "curJob" , className = "DizzinessCtrl" } ,
	-- frozen = { slotName = "curJob" , className = "FrozenCtrl" } ,
	stationary = {slotName = "curJob" , className = "StationaryCtrl"},


	--curSkill
	norAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
}

local fsm = basefunc.DataTableMap.New({

				curMove = basefunc.DataTable.New(
						{	"name"		,"breath"	,"walk"		},
					{
						{	"breath",	"refresh",	"replace",	},
						{	"walk",		"replace",	"refresh",	},
					}
				),
				curJob = basefunc.DataTable.New(
						{	"name"			,"idel"       ,   "chase"      ,   "attack"     ,  "stationary"	  , },
					{	
						{	"idel"		    ,"refresh"    ,  "discardNew"  ,  "discardNew"  ,  "discardNew"   , },
						{	"chase"		    ,"replace"    ,  "refresh"     ,  "discardNew"  ,  "discardNew"   , },
						{	"attack"		,"replace"    ,  "replace"     ,  "refresh"     ,  "discardNew"   , },
						{	"stationary"	,"replace"    ,  "discardCur"  ,  "discardCur"  ,  "refresh"      , },						
                    }
				),
				curSkill = basefunc.DataTable.New(
						{	"name"			,"norAttack"        ,   "superAttack"     , },
					{	
						{	"norAttack"		    ,"refresh"     ,  "discardNew"  ,  },
						{	"superAttack"		,"replace"     ,  "refresh"     ,  },
                    }
				),

})




return { base = base , fsm = fsm }