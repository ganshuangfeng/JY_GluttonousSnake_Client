--[[
	--不允许通过抛消息的方式对技能进行操作，所有操作必须由SkillManager调用
]]

--[[
    data = {
        id = 1, --唯一标识
        type = 1, --技能类型
        release = { --释放者
            type = 1,
            id = 1,
        }
        receive = { --接收者，多个接收者，（外部传入或技能内部确定）
            type = 1,
            id = 1,
        }
        state = 1, --状态
        action = 1, --动作
    }
]]

local basefunc = require "Game/Common/basefunc"

SkillBase = basefunc.class()
local M = SkillBase
M.name = "SkillBase"

--创建前操作，技能冲突处理 -> 需要在创建技能前做处理的实现此方法
function M.CreateBefore(data)
    return true
end

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
	
end

function M:Ctor(data)
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
	ClearTable(self)
end

--初始化相关
function M:Init(data)
	self.data = data
end

function M:Refresh(data)
	self.data = data or self.data
	
end

function M:OnCreate()
end

function M:OnTrigger()
	
end

function M:OnClose()
	
end

function M:OnChange()
	
end