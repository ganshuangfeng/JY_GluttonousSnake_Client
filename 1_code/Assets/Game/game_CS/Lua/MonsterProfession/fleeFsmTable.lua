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
	runaway = { slotName = "curJob" , className = "MonsterRunawayCtrl" } ,

	--curSkill
	norAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
	superAttack = { slotName = "curSkill" , className = "SkillStateCtrl" } ,
}

local fsm = {

		curJob = basefunc.DataTable.New(
						{	"name"			,  "runaway"     ,   "idel"       ,    "chase"     ,   "attack"     ,  "dizziness"	 ,   "frozen"	 },
					{	
						
						{	"runaway"		,  "refresh"     ,   "replace"    ,   "replace"     ,  "wait"       ,   "discardNew" ,   "discardNew"  },
						{	"idel"		    ,  "discardNew"   } ,
						{	"chase"		    ,  "discardNew"   } ,
						{	"attack"		,  "replace"   } ,
						{	"dizziness"		,  "replace"   } ,
						{	"frozen"		,  "replace"   } ,
                    }
				),

}




return { base = base , orgFsm = fsm }