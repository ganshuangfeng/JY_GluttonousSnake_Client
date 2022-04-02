---- 站岗 ，只站岗 , 不追击 ，进入视野就攻击

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
				{	"name"      ,  "idel" 	 },
			{	
				
				{	"chase"		,  "discardNew"  },
				
            }
		),

}




return { base = base , orgFsm = fsm }