local basefunc = require "Game/Common/basefunc"

local base = {
	StateName = { slotName = "curJob" , className = "xxxx_ctrl" } ,

}

local fsm = basefunc.DataTableMap.New({

				curMoveState = basefunc.DataTable.New(
						{	"name"		,"breath"	,"walk"		,  "run"	},
					{
						{	"breath"		,"refresh"	,"replace"	,"replace"	},
						{	"walk"		,"replace"	,"refresh"	,"replace"	},
						{	"run"		,"replace"	,"replace"	,"refresh"	}
					}
				),
				curJob = basefunc.DataTable.New(
						{	"name"			,"patrol"		,"guard"	,"alert"		,"chase"		,"lookAround"		,"check"		,"goToPos",		"attack",	     "vertigo",     "syncope",		"outDoor",		"returnBuild",		"die", "frozen"         ,"oilSlide"    ,"inBlockArea"       ,  "waitInBuild"  , "shock" },
					{	
						{	"patrol"		,"discardNew"	,"replace"	,"wait"			,"wait"			,"wait"				,"wait"			,"wait"			,"wait"	,	     "wait",         "wait",		"wait",			"wait",			    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "wait"      ,   "discardNew"    },
						{	"guard"			,"wait"			,"refresh"	,"wait"			,"wait"			,"wait"				,"wait"			,"wait"			,"wait"	,	     "wait",         "wait",		"wait",			"wait",			    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"alert"			,"replace"		,"replace"	,"discardNew"	,"discardNew"	,"discardCur"		,"discardNew"	,"discardCur"	,"discardNew",   "discardNew",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "discardNew",  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"chase"			,"replace"		,"replace"	,"wait"			,"refresh"		,"discardCur"		,"discardCur"	,"discardCur"	,"wait"		 ,   "discardNew",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "discardNew",  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"lookAround"	,"replace"		,"replace"	,"wait"			,"wait"			,"discardNew"		,"wait"			,"replace"		,"wait",          "wait",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"        , "discardNew",  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"check"			,"replace"		,"replace"	,"wait"			,"discardNew"	,"discardCur"		,"refresh"		,"discardCur"	,"discardNew",   "discardNew",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "discardNew",  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"goToPos"		,"replace"		,"replace"	,"discardNew"	,"discardNew"	,"discardCur"		,"discardNew"	,"refresh"		,"discardNew",   "discardNew",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "discardNew",   "discardNew"},
						{	"attack"		,"replace"		,"replace"	,"discardCur"	,"replace"		,"discardCur"		,"discardCur"	,"discardCur"	,"discardNew",   "discardNew",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "discardNew",  "discardNew"       ,  "discardNew",   "discardNew"},
                        {	"vertigo"		,"replace"		,"replace"	,"discardCur"	,"discardCur"	,"discardCur"		,"discardCur"	,"discardCur"	,"discardCur",   "refresh"	 ,   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "discardCur",  "discardNew"       ,  "discardNew",   "discardNew"},
                        {	"syncope"		,"replace"		,"replace"	,"discardCur"	,"discardCur"	,"discardCur"		,"discardCur"	,"discardCur"	,"discardCur",   "discardCur",   "discardNew",	"wait",			"replace",		    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "discardNew",   "discardCur"},
						--目前设定在出建筑过程中不能攻击
						{	"outDoor"		,"replace"		,"replace"	,"discardCur"	,"discardCur"	,"discardCur"		,"discardCur"	,"discardCur"	,"discardCur",   "discardCur",   "discardNew",	"discardNew",	"replace",		    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "discardCur",   "discardNew"},
						{	"returnBuild"	,"replace"		,"replace"	,"wait"			,"wait"			,"wait"				,"wait"			,"wait"			,"wait"		 ,   "wait"		 ,   "wait"		 ,	"wait"		,   "refresh",		    "discardNew", "wait"    , "wait"      ,  "discardNew"       ,  "discardNew",   "wait"},
                        {	"die"	        ,"replace"		,"replace"	,"replace"		,"replace"		,"replace"			,"replace"		,"replace"		,"replace"	 ,   "replace"	 ,   "replace"	 ,	"replace"	,   "replace",		    "discardNew", "replace" , "replace"   ,  "discardNew"       ,  "discardNew",   "discardCur"},
                        {"frozen"           ,"replace"      ,"replace"  ,"replace"      ,"replace"      ,"replace"          ,"replace"      ,"replace"      ,"discardCur"      ,"replace"      ,"replace"      ,"replace"      ,"replace"          ,"discardNew","replace","replace"  ,  "discardNew"       ,  "discardNew",   "discardNew"},
					    {"oilSlide"         ,"replace"      ,"replace"  ,"wait"         ,"discardCur"   ,"replace"             ,"discardCur"   ,"discardCur"   ,"replace"      ,"discardNew"   ,"replace"      ,"replace"      ,"replace"     ,"discardNew","wait"      ,"discardNew" ,  "discardNew"       ,  "discardNew",   "discardNew"},
                        {"inBlockArea"      ,"replace"      ,"replace"  ,"replace"      ,"replace"      ,"replace"          ,"replace"      ,"replace"      ,"replace"   ,"replace"      ,"replace"      ,"replace"     ,   "replace",            "replace","replace"   ,"replace"    ,  "discardNew"       ,  "discardNew",   "discardNew"},
                        {"waitInBuild"      ,"replace"		,"discardCur","discardCur"  ,"discardCur"   ,"discardCur"   	,"discardCur"  	,"discardCur"   ,"discardCur",	 "discardCur",	 "discardCur",  "discardCur",  	"discardCur",     "discardNew",	"wait",		"discardCur",	"discardCur",		  "discardNew" ,   "discardNew"},
                        {	"shock"         ,"replace"		,"replace"	,"replace"		,"replace"		,"replace"			,"replace"		,"replace"		,"replace",      "discardCur",   "discardNew",	"replace",      "replace",          "discardNew","discardNew","replace",     "discardNew",      "replace"         ,"discardNew"},
                    }
				),

				curSkill = basefunc.DataTable.New(
					{})
})


return { base = base , fsm = fsm }