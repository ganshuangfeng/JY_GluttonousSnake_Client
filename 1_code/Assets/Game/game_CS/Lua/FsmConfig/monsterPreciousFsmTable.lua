
local basefunc = require "Game/Common/basefunc"

local base = {
	--curMove
	breath = { slotName = "curMove" , className = "MonsterBreathCtrl" } ,
	walk = { slotName = "curMove" , className = "MonsterWalkCtrl" } ,

	--curJob
	runaway = { slotName = "curJob" , className = "MonsterRunawayCtrl" } ,
	-- dizziness = { slotName = "curJob" , className = "DizzinessCtrl" } ,
	-- frozen = { slotName = "curJob" , className = "FrozenCtrl" } ,
	stationary = {slotName = "curJob" , className = "StationaryCtrl"},
	--curSkill
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
						{	"name"			,"idel"       ,  "runaway"     ,  "stationary"	 , },
					{	
						{	"idel"		    ,"refresh"    ,  "discardNew"  ,  "discardNew"   , },
						{	"runaway"		,"replace"    ,  "refresh"     ,  "discardNew"   , },
						{	"stationary"	,"replace"    ,  "replace"     ,  "refresh"     , },					
                    }
				),
				curSkill = basefunc.DataTable.New(),

})


return { base = base , fsm = fsm }