
local basefunc = require "Game/Common/basefunc"

local base = {
	--curJob
	idel = { slotName = "curJob" , className = "HeroIdelCtrl" } ,
	attack = { slotName = "curJob" , className = "AttackStateCtrl" } ,
	-- dizziness = { slotName = "curJob" , className = "DizzinessCtrl" } ,
	-- frozen = { slotName = "curJob" , className = "FrozenCtrl" } ,
	stationary = {slotName = "curJob" , className = "StationaryCtrl"},
	--curSkill
	norAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,

}

local fsm = basefunc.DataTableMap.New({

				curMoveState = basefunc.DataTable.New(
						{	"name"		,"breath"	,"walk"		,  "run"	},
					{
						
					}
				),
				curJob = basefunc.DataTable.New(
						{	"name"			,"idel"        ,   "attack"     ,  "stationary"	  , },
					{	
						{	"idel"		    ,"refresh"     ,  "discardNew"  ,  "discardNew"   , },
						{	"attack"		,"replace"     ,  "refresh"     ,  "discardNew"   ,  },
						{	"stationary"		,"replace"     ,  "discardCur"  ,  "refresh"  ,},
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




return { base = base , fsm = fsm }