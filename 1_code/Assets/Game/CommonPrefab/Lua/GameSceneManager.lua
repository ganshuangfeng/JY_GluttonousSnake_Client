-- 创建时间:2021-06-01
GameSceneManager = {}

--[[
    与游戏相关的设置参数和接口
--]]

-- 从登陆进入的第一个场景
GameSceneManager.EnterFirstScene = "game_Hall"

-- 设计分辨率
GameSceneManager.GameScreenWidth = 1080
GameSceneManager.GameScreenHeight = 2340

-- 可分场景设置不一样的属性，默认不开放
function GameSceneManager.SetScreenOrientation (parm)
    -- if parm then
    --     -- 竖屏
    --     Screen.orientation = Enum.ScreenOrientation.Portrait
    --     Screen.autorotateToPortrait = true
    --     Screen.autorotateToPortraitUpsideDown = true
    --     Screen.autorotateToLandscapeLeft = false
    --     Screen.autorotateToLandscapeRight = false
    -- else
    --     -- 横屏
    --     Screen.orientation = Enum.ScreenOrientation.AutoRotation
    --     Screen.autorotateToPortrait = false
    --     Screen.autorotateToPortraitUpsideDown = false
    --     Screen.autorotateToLandscapeLeft = true
    --     Screen.autorotateToLandscapeRight = true
    -- end
end

-- 获取适配策略
function GameSceneManager.GetScene_MatchWidthOrHeight(width, height)
    -- 1是高适配 0是宽适配
    if width / height < GameSceneManager.GameScreenWidth / GameSceneManager.GameScreenHeight then
        return 0
    else
        return 1
    end
end
-- 控制背景缩放的方法
function GameSceneManager.SetGameBGScale(bg)
    local width = Screen.width
    local height = Screen.height
    if width / height > 1 then
        width,height = height,width
    end
    local matchWidthOrHeight = GameSceneManager.GetScene_MatchWidthOrHeight(width, height)
    local scale
    if matchWidthOrHeight == 1 then
        scale = (width * GameSceneManager.GameScreenHeight) / (height * GameSceneManager.GameScreenWidth)
        if scale < 1 then
            scale = 1
        end
    else
        scale = (height * GameSceneManager.GameScreenWidth) / (width * GameSceneManager.GameScreenHeight)
        if scale < 1 then
            scale = 1
        end
    end
    if IsEquals(bg) then
        bg.transform.localScale = Vector3.New(scale, scale, 1)
    end
end