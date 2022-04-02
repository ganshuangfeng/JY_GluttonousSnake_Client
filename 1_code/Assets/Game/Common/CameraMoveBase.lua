-- 创建时间:2021-07-19
require "Game.Common.CameraMove"
require "Game.Common.CameraMoveEasy"
require "Game.Common.CameraMoveLock"
require "Game.Common.CameraMoveMiddle"
require "Game.Common.CameraMoveHigh"
require "Game.game_CS.Lua.CameraMoveDebug"


CameraMoveBase = {}
CameraMoveBase.IsDebug = false
CameraMoveBase.IsLock = false
local M = CameraMoveBase
local instance

local _type = "lock"
CameraMoveBase.base_size = 20

CameraMoveBase.min_size = 20
CameraMoveBase.max_size = 25

CameraMoveBase.CMBType = {
	CMBT_Null = "Null",
	CMBT_Easy = "Easy",
	CMBT_Lock = "Lock",
	CMBT_Middle = "Middle",
	CMBT_High = "High",
}

CameraMoveBase.curType = CameraMoveBase.CMBType.CMBT_High
local instanceMap
local speed = 10 -- 镜头跟随的速度，>1000就取消速度，直接赋值

local lister
function M.AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.MakeLister()
    lister = {}
	lister["ExitScene"] = M.Exit
	lister["hero_head_room_no_change_msg"] = M.on_hero_head_room_no_change_msg
	lister["room_door_open_msg"] = M.on_room_door_open_msg
end

function M.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

function M.Start(data)
	if TableIsNull( instanceMap ) then
		M.MakeLister()
		M.AddMsgListener()

		instanceMap = {}
		instanceMap[CameraMoveBase.CMBType.CMBT_Easy] = CameraMoveEasy.Start()
		instanceMap[CameraMoveBase.CMBType.CMBT_Lock] = CameraMoveLock.Start()
		instanceMap[CameraMoveBase.CMBType.CMBT_Middle] = CameraMoveMiddle.Start()
		instanceMap[CameraMoveBase.CMBType.CMBT_High] = CameraMoveHigh.Start()
	end

	-- 初始化镜头
    CSPanel.camera3d.transform.position = Vector3.New(0, 0, 0)
	CSPanel.camera3d.orthographicSize = CameraMoveBase.base_size

	M.Awake()
end

function M.Awake()
	for k,v in pairs(instanceMap) do	
		if v.Awake then
			v:Awake()
		end
	end
end

function M.Exit()
	M.RemoveListener()
	for k,v in pairs(instanceMap) do	
		if v.Exit then
			v:Exit()
		end
	end
	instanceMap = {}
end

function M.on_room_door_open_msg(data)
	dump(data, "<color=red>on_room_door_open_msg +=========== </color>")
	M.door_map = M.door_map or {}
	M.door_map[data.roomNo] = data
	CameraMoveBase.SetPattern(data.dir)
end

function M.on_hero_head_room_no_change_msg(data)
	dump(data, "<color=red><size=15>OnHeroHeadRoomNoChange data</size></color>")
	if data and data.roomNo then
		instanceMap[CameraMoveBase.curType]:OnHeroHeadRoomNoChange(data)
		if data.roomNo < 0 then
			if not M.door_map or not M.door_map[data.roomNo] then
				CameraMoveBase.SetPattern("top")
			else
				CameraMoveBase.SetPattern(M.door_map[data.roomNo].dir)
			end
		else
		end
	end
end
function M.SetPattern( data )
	instanceMap[CameraMoveBase.curType]:SetPattern(data)
end
function M.FrameUpdate(time_elapsed)
	if CameraMoveBase.IsLock then
		return
	end
	local pos
	local instance = instanceMap[CameraMoveBase.curType]
	if instance and instance.FrameUpdate then
		pos = instance:FrameUpdate(time_elapsed)
	end

	if pos then
		local heroHead = GameInfoCenter.GetHeroHead()
		local _speed = speed
		if heroHead then
			_speed = speed *  heroHead.vehicle:Speed() / 7
		end

		if _speed > 1000 then
			CSPanel.camera3d.transform.position = Vector3.New(pos.x, pos.y, 0)
		else
			local _pos = {x=pos.x-CSPanel.camera3d.transform.position.x,
							y=pos.y-CSPanel.camera3d.transform.position.y,
							z=0}
			if Vec2DLength(_pos) > _speed*time_elapsed then
				_pos = Vec2DTruncate(_pos, _speed*time_elapsed)
			end
			if CameraMoveBase.IsDebug then
				-- dump(_pos, "<color=red>1111111111111111111111</color>")
			end

			CSPanel.camera3d.transform.position = Vector3.New(	CSPanel.camera3d.transform.position.x + _pos.x,
																CSPanel.camera3d.transform.position.y + _pos.y, 0)
		end
	else
		if CameraMoveBase.IsDebug then
			-- dump(_pos, "<color=red>22222222222222222222222222222</color>")
		end
	end
end

function CameraMoveBase.SetCameraPos( pos )
	CSPanel.camera3d.transform.position = Vector3.New(pos.x, pos.y, 0)
end

function M.SetOrthographicSize(size)
	if instance and instance.SetOrthographicSize then
		instance:SetOrthographicSize(size)
	end
end

function M.RunDistant(size)
	if instance and instance.RunDistant then
		instance:RunDistant(size)
	end
end
function M.SetDistantLock(b)
	if instance and instance.SetDistantLock then
		instance:SetDistantLock(b)
	end
end
