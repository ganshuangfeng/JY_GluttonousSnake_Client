-- 创建时间:2021-07-08
-- Panel:HeroWait
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

HeroWait = basefunc.class(Base)
local C = HeroWait
C.name = "HeroWait"

function C.Create(parent,data)
	return C.New(parent,data)
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
	self.Timer:Stop()
	self.Timer = nil
	self:RemoveListener()
	Destroy(self.gameObject)
end

function C:OnDestroy()
	self:Exit()
end

function C:MyClose()
	self:Exit()
end

function C:Ctor(parent,data)
	C.super.Ctor( self , data )
	
	self.data = data
	self.data.pos_id = self.data.location

	local base_name = CSModel.GetAssetName(data.base_name)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(base_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = data.heroId
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.transform.localPosition = Vector3.New(0,0,0)
	self.transform.localScale = Vector3.New(90,90,90)
	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOScale(Vector3.New(1.2 * 100, 1.2 * 100, 1.2 * 100), 0.2))
	seq:Append(self.transform:DOScale(Vector3.New(0.9 * 100, 0.9 * 100, 0.9 * 100), 0.1))
	seq:Append(self.transform:DOScale(Vector3.New(100, 100, 100), 0.05))
	SetLayer(self.transform,"UI")
	self.level_txt = self.hero_level.transform:GetComponent("TMP_Text")
	self.level.gameObject:SetActive(true)
	self.level_txt.text =  data.level
	self.life_time = 0
	self.Timer = Timer.New(
		function()
			self.life_time = self.life_time + 0.02
		end
	,0.02,-1)
	self.Timer:Start()
	self:SetLayerDown()
	self.gameObject.tag = "HeroWait"
end

function C:InitUI()
	if self.data.level >= 2 then
		self.canno_pre = NewObject(CSModel.GetAssetName(self.data.prefab_name .. "_levelup"),self.cannon_parent.transform)
	else
		self.canno_pre = NewObject(CSModel.GetAssetName(self.data.prefab_name),self.cannon_parent.transform)
	end
	self:MyRefresh()
end

function C:SetLocation(location)
	self.data.location = location
end

function C:ShowCanComponse()
	if self.CanComponseTX then
		self.CanComponseTX.gameObject:SetActive(true)
	else
		self.CanComponseTX = NewObject("HC_kuangxuan",self.transform)
		self.CanComponseTX.transform.localScale = Vector3.New(0.02,0.02,0.02)
	end
end

function C:HideCanComponse()
	if self.CanComponseTX then
		self.CanComponseTX.gameObject:SetActive(false)
	end
end

function C:SetLayerUp()
	SetOrderInLayer(self.model,11)
	SetOrderInLayer(self.level,14)
	SetOrderInLayer(self.level_txt,15)
	SetOrderInLayer(self.canno_pre,12)
	if self.speed_up_fx_pre and IsEquals(self.speed_up_fx_pre.fx_pre) then
		self.speed_up_fx_pre.fx_pre:GetComponent("Canvas").sortingOrder = 13
	end
end

function C:SetLayerDown()
	SetOrderInLayer(self.model,1)
	SetOrderInLayer(self.level,4)
	SetOrderInLayer(self.level_txt,5)
	SetOrderInLayer(self.canno_pre,2)
	if self.speed_up_fx_pre and IsEquals(self.speed_up_fx_pre.fx_pre) then
		self.speed_up_fx_pre.fx_pre:GetComponent("Canvas").sortingOrder = 3
	end
end
function C:SetLevel(level)
	if level > self.data.level then
		local seq = DoTweenSequence.Create()
		seq:Append(self.transform:DOScale(Vector3.New(1.2 * 100, 1.2 * 100, 1.2 * 100), 0.2))
		seq:Append(self.transform:DOScale(Vector3.New(0.9 * 100, 0.9 * 100, 0.9 * 100), 0.1))
		seq:Append(self.transform:DOScale(Vector3.New(100, 100, 100), 0.05))
		if self.hctx then
			self.hctx.gameObject:SetActive(false)
			self.hctx.gameObject:SetActive(true)
		else
			self.hctx = NewObject("HC_guangxiao",self.transform)
			self.hctx.transform.localScale = Vector3.New(0.02,0.02,0.02)
		end
	end
	if level == 2 and self.data.level ~= 2 then
		Destroy(self.canno_pre.gameObject)
		self.canno_pre = NewObject(CSModel.GetAssetName(self.data.prefab_name .. "_levelup"),self.cannon_parent.transform)
		SetLayer(self.canno_pre.transform,"UI")
		SetOrderInLayer(self.canno_pre,2)
	end
	self.data.level = level
	self.level_txt.text =  level
end

function C:MyRefresh()
end
