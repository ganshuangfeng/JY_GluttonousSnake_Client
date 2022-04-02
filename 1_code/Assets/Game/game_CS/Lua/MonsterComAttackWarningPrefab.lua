-- 创建时间:2021-09-02
-- 通用怪物攻击提示

local basefunc = require "Game/Common/basefunc"

MonsterComAttackWarningPrefab = basefunc.class()
local C = MonsterComAttackWarningPrefab
C.name = "MonsterComAttackWarningPrefab"

function C.Create(object,warning_time, call,backCall,flashTime)
	return C.New(object,warning_time, call,backCall,flashTime)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:Exit()
	if self.flash_seq then self.flash_seq:Kill() end
	if self.backCall then
		self.backCall()
	end
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(object,warning_time, call,backCall,flashTime)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.object = object
	self.backCall = backCall
	self.call = call
	LuaHelper.GeneratingVar(self.transform, self)
	self.warning_time = warning_time
	self.is_flash  = false
	if flashTime then
		--如果需要闪烁则留出0.6秒的闪烁时间
		self.warning_time = self.warning_time - flashTime
		if self.warning_time < 0 then self.warning_time = 0 end
		self.is_flash  = true
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.cur_show_time = 0
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshCD()
end

function C:RefreshCD()
	if self.cur_show_time >= self.warning_time then
		if self.is_flash then
			--播放闪烁动画
			self.cd_img.fillAmount = 1
			self.flashing = true
			self.flash_seq = DoTweenSequence.Create()
			for i = 1,3 do
				self.flash_seq:AppendCallback(function()
					self.cd_img.gameObject:SetActive(true)
				end)
				self.flash_seq:AppendInterval(0.1)
				self.flash_seq:AppendCallback(function()
					self.cd_img.gameObject:SetActive(false)
				end)
				self.flash_seq:AppendInterval(0.1)
			end
			self.flash_seq:OnForceKill(function()
				self.flash_seq = nil
				self.cd_img.fillAmount = 0
				self:Exit()
				if self.call then
					self.call()
					self.call = nil
				end
			end)
		else
			self.cd_img.fillAmount = 0
			self:Exit()
			if self.call then
				self.call()
			end
		end
	else
		self.cd_img.fillAmount = self.cur_show_time / self.warning_time
	end
end

function C:FrameUpdate(dt)
	if self.object and IsEquals(self.object.transform) then
		self.transform.position = CSModel.Get3DToUIPoint(self.object.transform.position)
	else
		self:Exit()
		return
	end
	if not self.flashing then
		self.cur_show_time = self.cur_show_time + dt
		self:RefreshCD()
	end
end
