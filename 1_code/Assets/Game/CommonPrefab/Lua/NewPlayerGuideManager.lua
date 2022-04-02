--这个引导触发条件是新玩家第一次进入游戏

local basefunc = require "Game/Common/basefunc"
NewPlayerGuideManager = {}
local M = NewPlayerGuideManager

ExtRequire("Game.CommonPrefab.Lua.NewPlayerGuidePanel")
ExtRequire("Game.CommonPrefab.Lua.BossTalk")

local this
local lister

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end

local function MakeLister()
    lister = {}
    lister["hall_game_in"] = this.on_hall_game_in
	lister["StageFinish"] = this.On_StageFinish
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
	lister["BossStoneSuperBoomCharge"] = this.OnBossStoneSuperBoomCharge
end

function M.Init()
	M.Exit()

	this = NewPlayerGuideManager
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

local can_go_step2 = false
function M.on_hall_game_in(result)
	if not M.IsFinshThisGuide() then
		print("<color=red>账号没有完成初次新手引导</color>")

		if GameGlobalOnOff.IsOpenGuide  then
			NewPlayerGuidePanel.Create(1)
		end
	end
end

function M.OnReConnecteServerSucceed()

end
--是否已经完成了此项引导
--存在本地上
function M.IsFinshThisGuide()
	if MainModel.UserInfo.xsyd_status == 0 then
		return false
	else
		return true
	end
end

--标记账号已经完成这项新手引导
function M.SetThisGuideFinsh()
	GuideModel.SendXSYD(1)
end

function M.On_StageFinish()
	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		can_go_step2 = true
	end
end
--Boss开始对话
function M.OnBossStoneSuperBoomCharge()
	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		BossTalk.Create({pos = Vector3.New(1,130,0)})
	end
end