-- 创建时间:2021-06-07

CSModel = {}
local M = CSModel

local this
local game_lister
local lister
local m_data
local update
local updateDt = 0.1

-- 是否是2D的游戏
CSModel.Is2D = true

function M.MakeLister()
	-- 游戏相关
    game_lister = {}

    -- 其他
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>proto_name:</color>" .. proto_name)
    local func = lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end

    if data.status_no then
    	-- 断线重连的数据不用判断status_no
    	-- "all_info" 根据具体游戏命名
        if proto_name ~= "all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                dump(data)
                --发送状态编码错误事件
                Event.Brocast("model_status_no_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end
local function InitData()
    M.data = {}
    m_data = M.data
end
function M.Init()
    this = M
    InitData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        game_lister = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

-- 摄像机 用于坐标转化
function M.SetCamera(camera3d, camera2d)
    M.camera3d = camera3d
    M.camera2d = camera2d
end
-- 3D坐标转UI坐标
function M.Get3DToUIPoint(vec)
    vec = M.camera3d:WorldToScreenPoint(vec)
    vec = M.camera2d:ScreenToWorldPoint(vec)
    return vec--tls.pMul(vec,2)
end
-- UI坐标转3D坐标
function M.GetUITo3DPoint(vec)
    vec = M.camera2d:WorldToScreenPoint(vec)
    vec = M.camera3d:ScreenToWorldPoint(vec)
    return vec
end

function M.GetAssetName(name)
    -- dump(name)
    if not string.find( name , ".+_2d$" ) and M.Is2D then
        
    -- dump(name)
        name = name .. "_2d"
    end
    -- dump(name)
    return name
end
