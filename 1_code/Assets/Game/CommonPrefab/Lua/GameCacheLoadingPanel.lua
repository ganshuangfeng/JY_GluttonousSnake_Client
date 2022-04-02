-- 创建时间:2019-03-19
-- Panel:FishingLoadingPanel
local basefunc = require "Game/Common/basefunc"

GameCacheLoadingPanel = basefunc.class()
local C = GameCacheLoadingPanel
C.name = "GameCacheLoadingPanel"

C.LoadingState = 
{
	LS_Res = "加载资源",
	LS_Ready = "发送准备",
	LS_Recover = "恢复场景",
	LS_Finish = "加载完成",
}

function C.Create(call, data)
	return C.New(call, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_recover_finish"] = basefunc.handler(self, self.model_recover_finish)
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:onExitScene()
	self:Exit()
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	if self.timerUpdate then
		self.timerUpdate:Stop()
		self.timerUpdate = nil
	end
	if self.call and type(self.call) == "function" then
		self.call("exit")
	end
	self.call = nil
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:Ctor(call, data)
	self.data = data
	self.call = call
	local prefab_name = "GameCacheLoadingPanel"

	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = NewObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)	

	self.width = 958
	self.load_state = C.LoadingState.LS_Res
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	local sd = GameInfoCenter.GetStageData()
	if sd.curLevel == 0 then
		self.ShowGameHistroyNode.gameObject:SetActive(true)
	else
		self.ShowGameHistroyNode.gameObject:SetActive(false)
	end

end

function C:InitUI()
	self.progress_img.fillAmount = 0
	self.progress_txt.text = "0%"

	self.rate_val = 0
	self.currLoadCount = 0

	self.allLoadCount = #self.data.cache_list
	print("self.allLoadCount:" .. self.allLoadCount)

	self.timerUpdate = Timer.New(function ()
		self:Update()
	end, -1, -1, true)
	self.timerUpdate:Start()
end

function C:LoadAssetAsync()
    -- 加载
    for k,v in ipairs(self.data.cache_list) do
		if not CachePrefabManager.CheckCacheExist(v.prefab) and v.isOnOff == 1 then
			CachePrefabManager.InitCachePrefab(v.prefab, v.cache_count, true)
			Yield(0)
		end
        self.currLoadCount = self.currLoadCount + 1
    end
end

function C:Update()
	if self.load_state == C.LoadingState.LS_Res then
		coroutine.start(function ( )
			self:LoadAssetAsync()
		end)
		self.load_state = C.LoadingState.LS_Res_Loading
	elseif self.load_state == C.LoadingState.LS_Res_Loading then
		if not self.allLoadCount or self.allLoadCount <= 0 then
			self.load_state = C.LoadingState.LS_Ready
			return
		end
		self.rate_val = self.currLoadCount / self.allLoadCount * 0.9
		self:UpdateRate(self.rate_val)
		if self.rate_val >= 0.899999 then
			self.load_state = C.LoadingState.LS_Ready
		end
	elseif self.load_state == C.LoadingState.LS_Ready then
	    self.load_state = C.LoadingState.LS_Recover
		coroutine.start(function ( )
			Yield(0)
			if self.call and type(self.call) == "function" then
				self.call("finish")
			end
		end)
	elseif self.load_state == C.LoadingState.LS_Recover then

	else
		Event.Brocast("loding_finish")
		self:Exit()
	end
end

function C:model_recover_finish()
	self.load_state = C.LoadingState.LS_Finish
end

function C:UpdateRate(val)
	self.move_node.localPosition = Vector3.New(val * self.width, 0, 0)
	self.progress_img.fillAmount = val
	self.progress_txt.text = string.format("%.2f", val * 100) .. "%"
end
