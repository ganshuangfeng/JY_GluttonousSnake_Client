---- 

local basefunc = require "Game/Common/basefunc"

local base = {
	--curMove
	breath = { slotName = "curMove" , className = "MonsterBreathCtrl" } ,
	walk = { slotName = "curMove" , className = "MonsterWalkCtrl" } ,

	--curJob
	idel = { slotName = "curJob" , className = "MonsterIdelCtrl" } ,
	chase = { slotName = "curJob" , className = "MonsterChaseCtrl" } ,
	attack = { slotName = "curJob" , className = "AttackStateCtrl" } ,
	dizziness = { slotName = "curJob" , className = "DizzinessCtrl" } ,
	frozen = { slotName = "curJob" , className = "FrozenCtrl" } ,

	--curSkill
	norAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
}

local fsm = {

		curJob = basefunc.DataTable.New(
						{	"name"			,"idel"       ,   "chase"      ,   "attack"     ,  "dizziness"	  ,    "frozen"	 },
					{	
						{	"idel"		    ,"refresh"    ,  "discardNew"  ,  "discardNew"  ,  "discardNew"   ,   "discardNew"  },
						{	"chase"		    ,"replace"    ,  "refresh"     ,  "discardNew"  ,  "discardNew"   ,   "discardNew"  },
						{	"attack"		,"replace"    ,  "replace"     ,  "refresh"     ,  "discardNew"   ,   "discardNew"  },
						{	"dizziness"		,"replace"    ,  "discardCur"  ,  "discardCur"  ,  "refresh"      ,   "discardNew"  },
						{	"frozen"		,"replace"    ,  "replace"     ,  "discardCur"  ,  "discardCur"   ,   "refresh"  },
                    }
				),

}




return { base = base , orgFsm = fsm }