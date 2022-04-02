-- 创建时间:2018-07-23

GuideModel = {}

local this
local m_data
local lister

local SaveGuide = nil

GuideModel.trigger_pos = nil
local function AddLister()
    lister={}
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
end

-- 初始化Data
local function InitMatchData()
    GuideModel.data={}
    m_data = GuideModel.data
end

function GuideModel.Init()
    if not GameGlobalOnOff.IsOpenGuide then
        return
    end
    this = GuideModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.LoadGuide()
    this.CompareGuideLocalAndServer()
    m_data.currGuideId = this.GetRunGuideID()
    m_data.currGuideStep = 1
    SaveGuide()
    return this
end
function GuideModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

-- 获取路径
local function getGuidePath()
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return path
end
-- 获取路径
local function getGuideDescPath()
    local path = getGuidePath() .. "/guide.txt"
    return path
end
function GuideModel.SendXSYD(val)
    print("<color=red><size=16>set_xsyd_status = " .. val .. " </size></color>")
    MainModel.UserInfo.xsyd_status = val
    Network.SendRequest("set_xsyd_status", {status = val})
end
-- 保存ID列表
SaveGuide = function ()
    local descPath = getGuideDescPath()
    local idstr = ""
    for i,v in ipairs(m_data.GuideIDs) do
        idstr = idstr .. v
        if i < #m_data.GuideIDs then
            idstr = idstr .. ","
        end
    end
    print("<color=red>保存新手引导到本地 </color>" .. idstr)
    File.WriteAllText(descPath, idstr)

    if m_data.currGuideId and m_data.currGuideId ~= MainModel.UserInfo.xsyd_status then
        if m_data.currGuideId == -1 then
            GuideModel.SendXSYD(-1)
        else
            if #m_data.GuideIDs > 0 then
                GuideModel.SendXSYD(m_data.GuideIDs[#m_data.GuideIDs])
            end
        end
    end
end


-- 加载本地引导进度
function GuideModel.LoadGuide()
    m_data.GuideIDs = {}
    local path = getGuidePath()
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local descPath = getGuideDescPath()
    if not File.Exists(descPath) then
        return
    end
    local data = File.ReadAllText(descPath)
    if not data or data == "" then
        return
    end
    dump(data)
    local ns = StringHelper.Split(data, ",")
    for _,v in ipairs(ns) do
        m_data.GuideIDs[#m_data.GuideIDs + 1] = tonumber(v)
    end
end

-- 同步本地与服务器引导步骤
function GuideModel.CompareGuideLocalAndServer()
    -- 服务器记录是完成状态
    if MainModel.UserInfo.xsyd_status == -1 then
        m_data.GuideIDs = {}
        for k,v in ipairs(GuideConfig) do
            m_data.GuideIDs[#m_data.GuideIDs + 1] = tonumber(k)
        end
        return
    end

    -- 本地条件判断
    local map = {}
    for k,v in ipairs(GuideConfig) do
        local b = GuideModel.CheckGuideFinish(k)
        dump(b)
        if b then
            map[k] = 1
        end
    end
    if MainModel.UserInfo.xsyd_status > 0 then
        for i = 1, MainModel.UserInfo.xsyd_status do
            map[i] = 1
        end
    end

    for k,v in ipairs(m_data.GuideIDs) do
        map[v] = 1
    end

    m_data.GuideIDs = {}
    for k,v in pairs(map) do
        m_data.GuideIDs[#m_data.GuideIDs + 1] = tonumber(k)
    end
    dump(m_data.GuideIDs, "<color=red>GuideIDs 同步本地与服务器引导步骤</color>")
end

-- 第一个引导的ID
local OneGuideId = 1
function GuideModel.GetRunGuideID()
    local id = OneGuideId
    local map = {}
    for k,v in ipairs(m_data.GuideIDs) do
        map[v] = 1
    end
    for k,v in pairs(map) do
        if GuideConfig[k] then
            local ii = GuideConfig[k].next
            if not map[ii] then
                return ii
            end
        end
    end
    return id
end

function GuideModel.Trigger( cfPos)
    if GuideConfig[GuideModel.data.currGuideId] and GuideModel.data.currGuideStep == 1 then
        for k,v in ipairs(GuideConfig[GuideModel.data.currGuideId].stepList) do
            if v.cfPos == cfPos then
                GuideModel.trigger_pos = k
                return true
            end
        end
    end
end

function GuideModel.GetStepList(id)
    local cfg = GuideConfig[id]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        return cfg.stepList[GuideModel.trigger_pos].step
    end
end

function GuideModel.GetStepConfig(id, stepIndex)
    local cfg = GuideConfig[id]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        local index = cfg.stepList[GuideModel.trigger_pos].step[GuideModel.data.currGuideStep]
        return GuideStepConfig[index]
    end
end

-- 引导完成或点击跳过
function GuideModel.GuideFinishOrSkip()
    m_data.GuideIDs[#m_data.GuideIDs + 1] = m_data.currGuideId
    m_data.currGuideId = GuideConfig[m_data.currGuideId].next
    m_data.currGuideStep = 1
    SaveGuide()

    if m_data.currGuideId == -1 then
        GuideModel.GuideAllFinish()
    end 
end

function GuideModel.StepFinish()
    local cfg = GuideModel.GetStepConfig(m_data.currGuideId, m_data.currGuideStep)
    m_data.currGuideStep = m_data.currGuideStep + 1
    print("<color=red>点击完成，下一个m_data.currGuideStep = " .. m_data.currGuideStep .. "</color>")
    local stepList = GuideModel.GetStepList(m_data.currGuideId)
    if m_data.currGuideId > 0 and GuideConfig[m_data.currGuideId] and m_data.currGuideStep > #stepList then
        GuideModel.GuideFinishOrSkip()
    elseif cfg and cfg.isSave then --提前保存数据（非大步骤的最后一个小步）
        m_data.GuideIDs[#m_data.GuideIDs + 1] = m_data.currGuideId
        SaveGuide()
        -- m_data.GuideIDs[#m_data.GuideIDs] = nil
    end
end

function GuideModel.GuideAllFinish()
    Event.Brocast("newplayer_guide_finish")
end

-- 根据一些数据判断新手引导是否完成
function GuideModel.CheckGuideFinish(id)
    if id == 2 and HeroDataManager.GetHeroLevelByType(19) > 0 then
        return true
    end
    return false
end
-- 条件是否满足
function GuideModel.CheckCondition(id, stepIndex)
    if id == 2 and stepIndex == 1 then
        if HeroDataManager.GetHeroLevelByType(19) == 0 then
            return true
        else
            return false
        end
    end
    
    return true
end
-- 条件是否满足
function GuideModel.IsMeetCondition()
    return GuideModel.CheckCondition(m_data.currGuideId, m_data.currGuideStep)
end
