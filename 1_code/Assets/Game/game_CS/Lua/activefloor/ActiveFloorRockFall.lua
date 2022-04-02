-- 创建时间:2021-08-27
-- Panel:ActiveFloorRockFall
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

ActiveFloorRockFall = basefunc.class(Object)
local M = ActiveFloorRockFall
M.name = "ActiveFloorRockFall"

function M.Create(data)
	return M.New(data)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["StageFinish"] = basefunc.handler(self,self.Exit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:Exit()
	print(debug.traceback())

	self:RemoveListener()
	Destroy(self.gameObject)
end

function M:OnDestroy()
	self:Exit()
end

function M:MyClose()
	self:Exit()
end

function M:Ctor(data)
	M.super.Ctor( self , data )

	local parent = CSPanel.map_node
	if self.data.building and IsEquals(self.data.building.gameObject) then
		self.gameObject = self.data.building.gameObject
	else
		self.gameObject = NewObject(M.name, parent)
	end
	self.transform = self.gameObject.transform
	self.hitObjectList = {}
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.collider = self.rock:GetComponent("ColliderBehaviour")
    self.collider:SetLuaTable(self)
end

function M:Init(data)
	self.warning_time = 4
	self.damage = 600


	local seq = DoTweenSequence.Create()
	seq:AppendInterval(self.warning_time)
	seq:Append(self.rock.transform:DOLocalMove(Vector3.zero, 4):SetEase(Enum.Ease.InQuint))
	seq:AppendCallback(
		function()
			--self.CanEnter = true
		end
	)
	self:MyRefresh()
end

function M:MyRefresh()
end

local range = 3
function M:FrameUpdate(time_elapsed)
	self:Hit(time_elapsed)
	local dis = tls.pGetDistanceSqu(self.rock.transform.localPosition,Vector3.zero)
	if dis <  range * range then
		self.CanEnter = true
	else
		self.CanEnter = false
	end
end

local timeNeed = 0.1
function M:Hit(time_elapsed)
	self.timeUse = self.timeUse or 0
	self.timeUse = self.timeUse + time_elapsed
	if self.timeUse > timeNeed then
		self.timeUse = 0
		dump(self.hitObjectList,"<color=red>666666666666666666666666666666666666666</color>")
		for i = 1,#self.hitObjectList do
			local obj = ObjectCenter.GetObj(self.hitObjectList[i])
			if obj then
				if obj.camp == CampEnum.Monster then
					Event.Brocast("hit_monster",{damage = self.damage,id = self.hitObjectList[i]})
				elseif obj.camp == CampEnum.HeroHead then
					Event.Brocast("hit_hero",{damage = self.damage, id = self.hitObjectList[i]})
				end
			end
		end
		self.hitObjectList = {}
	end
end

function M:OnTriggerEnter2D(collider)

	local object_id = collider.gameObject.name
	if object_id then
		object_id = tonumber(object_id)
	end
	--不重复计算ID
	local IsCanAdd = true
	for i = 1,#self.hitObjectList do
		if self.hitObjectList[i] == object_id then
			IsCanAdd = false
			break
		end
	end
	if IsCanAdd then
		self.hitObjectList[#self.hitObjectList + 1] = object_id
	end
end