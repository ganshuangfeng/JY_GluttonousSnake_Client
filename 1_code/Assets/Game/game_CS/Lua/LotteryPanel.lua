-- 创建时间:2021-06-25
-- Panel:LotteryPanel
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

LotteryPanel = basefunc.class()
local C = LotteryPanel
C.name = "LotteryPanel"

function C.Create(parent,lottery_data)
	return C.New(parent,lottery_data)
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
	if self.lottery_seqs and next(self.lottery_seqs) then
		for k,v in pairs(self.lottery_seqs) do
			self.lottery_seqs[k] = nil
		end
		self.lottery_seqs = {}
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

function C:Ctor(parent,lottery_data)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = NewObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.lottery_data = lottery_data or LotteryManager.m_data.lottery_data

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.lottery_btn.onClick:AddListener(function()
		if self.lottery_seqs and next(self.lottery_seqs) then
			LittleTips.Create("正在抽奖中！")
			return
		end
		local lottery_data = {
			[1] = {id = math.random(1,4),},
			[2] = {id = math.random(1,4),},
			[3] = {id = math.random(1,4),},
		}
		self:PlayLottery(lottery_data)
	end)
	self.lottery_seqs = {}
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh(lottery_data)
	self.lottery_data = lottery_data or self.lottery_data
	self:RefreshLotteryItems()
end

function C:RefreshLotteryItems()
	self.lottery_objs = self.lottery_objs or {}
	local lottery_data = lottery_data or self.lottery_data
	for lottery_obj_id,lottery_obj_data in ipairs(self.lottery_data) do
		if not self.lottery_objs[lottery_obj_id] then
			local obj = GameObject.Instantiate(self.lottery_obj.gameObject,self.lottery_parent.transform)
			self.lottery_objs[lottery_obj_id] = {
				obj = obj,
				tbl = LuaHelper.GeneratingVar(obj.transform)
			}
			obj.gameObject:SetActive(true)
		end
		local lottery_obj = self.lottery_objs[lottery_obj_id]
		lottery_obj.lottery_items = lottery_obj.lottery_items or {}
		for k,v in ipairs(lottery_obj_data) do
			local type_cfg = {
				[0] = {
					color = Color.New(1,1,1),
				},
				[1] = {
					color = Color.New(1,0,1),
				},
				[2] = {
					color = Color.New(1,0,0),
				},
				[3] = {
					color = Color.New(0,1,0)
				},
				[4] = {
					color = Color.New(0,0,1)
				}
			}
			local rotate_cfg = {
				[1] = {
					rotate = Quaternion.Euler(0,0,0)
				},
				[2] = {
					rotate = Quaternion.Euler(0,0,-90)
				},
				[3] = {
					rotate = Quaternion.Euler(0,0,-180)
				},
				[4] = {
					rotate = Quaternion.Euler(0,0,-270)
				}
			}
			local lottery_item = lottery_obj.lottery_items[k]
			if not lottery_item then
				lottery_item = GameObject.Instantiate(lottery_obj.tbl.lottery_item.gameObject,lottery_obj.tbl.lottery_item_parent)
				lottery_item.gameObject:SetActive(true)
				lottery_obj.lottery_items[k] = lottery_item
			end
			lottery_item.transform:GetComponent("Image").color = type_cfg[v.type].color
			local tbl = LuaHelper.GeneratingVar(lottery_item.transform)
			tbl.lottery_item_txt.text = v.name
			lottery_item.transform.localRotation = rotate_cfg[k].rotate
		end
	end
end

function C:PlayLotteryItemRotateAnim(obj_id,end_item_id,interval,callback)
	local rotate_item = self.lottery_objs[obj_id]

	if not rotate_item then return end
	if rotate_item.lottery_items and rotate_item.lottery_items[end_item_id] then
		local cur_rotate = rotate_item.tbl.rotate_parent.transform.eulerAngles.z
		local item_count = #rotate_item.lottery_items
		local single_angle = 360/item_count

		local target_angle = (end_item_id - 1) * single_angle + single_angle / 2
		local random_range = single_angle * 0.2

		local end_angle = target_angle + math.random() * random_range * (math.random(1,2) == 1 and 1 or -1)
		local move_angle = end_angle - (cur_rotate % 360)
		if move_angle < 0 then move_angle = move_angle + 360 end
		local seq = DoTweenSequence.Create()
		self.lottery_seqs = self.lottery_seqs or {}
		self.lottery_seqs[obj_id] = seq
		local circle_count = 10
		local use_time = 3
		local total_time 
		local speed_down_time
		if move_angle < 90 then
			total_time = use_time * ((circle_count - 1) * 360) / ((circle_count - 1) * 360 + move_angle)
			speed_down_time = use_time * ((move_angle + 360) / 360)
		else
			total_time = use_time * (circle_count * 360) / (circle_count * 360 + move_angle)
			speed_down_time = use_time * (move_angle / 360)
		end
		-- seq:Append(rotate_item.tbl.rotate_parent.transform:DORotate(Vector3.New(0,0,360),total_time / circle_count,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.InQuad))

		-- seq:AppendCallback(function()
		-- 	for k,v in ipairs(rotate_item.lottery_items) do
		-- 		v.transform:GetComponent("Image").material = GetMaterial("xuhua")
		-- 	end
		-- end)
		-- seq:Append(rotate_item.tbl.rotate_parent.transform:DORotate(Vector3.New(0,0,(circle_count - 1) * 360),(circle_count - 1) * total_time / circle_count,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.Linear))
		-- seq:AppendCallback(function()
		-- 	for k,v in ipairs(rotate_item.lottery_items) do
		-- 		v.transform:GetComponent("Image").material = nil
		-- 	end
		-- end)
		-- seq:Append(rotate_item.tbl.rotate_parent.transform:DORotate(Vector3.New(0,0,move_angle > 90 and move_angle or (360 + move_angle)),speed_down_time,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.OutQuad))
		-- seq:AppendCallback(function()
		-- 	if callback then callback() end
		-- end)
		local interval = interval or 0
		
		seq:AppendInterval(interval)

		seq:Append(rotate_item.tbl.rotate_parent.transform:DORotate(Vector3.New(0,0,circle_count * 360 + move_angle),total_time,Enum.RotateMode.WorldAxisAdd):SetEase(Enum.Ease.InOutQuad))
		seq:InsertCallback(interval + total_time * 0.2,function()
			for k,v in ipairs(rotate_item.lottery_items) do
				v.transform:GetComponent("Image").material = GetMaterial("xuhua")
			end
		end)
		seq:InsertCallback(interval + total_time * 0.8,function()
			for k,v in ipairs(rotate_item.lottery_items) do
				v.transform:GetComponent("Image").material = nil
			end
		end)
		seq:AppendCallback(function()
			if self.lottery_seqs then
				self.lottery_seqs[obj_id] = nil
			end
			if callback then callback() end
		end)
	end
end

function C:PlayLottery(lottery_data)
	local check_func = function(id)
		lottery_data[id].seq_end = true
		for k,v in ipairs(lottery_data) do
			if not v.seq_end then return false end
		end

		return true
	end
	for k,v in ipairs(lottery_data) do
		self:PlayLotteryItemRotateAnim(k,v.id,v.id / 10,function()
			if check_func(k) then
				--广播消息)
				Event.Brocast("lottery_panel_lottery_end_data",lottery_data)
			end
		end)
	end
end