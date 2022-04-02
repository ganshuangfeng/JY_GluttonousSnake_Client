-- 创建时间:2021-07-15

local basefunc = require "Game/Common/basefunc"

SkillDizziness = basefunc.class()
local M = SkillDizziness
M.name = "SkillDizziness"

--创建前操作，技能冲突处理 -> 需要在创建技能前做处理的实现此方法
function M.CreateBefore(data)
    local skills = SkillManager.GetAll()
    for k,skill in pairs(skills) do
        if skill.data.type == "attack_speed" and skill.state == "coolDown" then
            return false
        end
    end
    return true
end

function M.Create(data)
	return M.New(data)
end

function M:FrameUpdate(time_elapsed)
	if self.cd then
		self.cd = self.cd - time_elapsed
		if self.cd < 0 then
			SkillManager.SkillClose(self.data)
			return
		end
	end
end

function M:Ctor(data)
	self:Init(data)
	self:Refresh(data)
end

function M:Exit()
	self:CloseXy()
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
	SkillManager.SkillTrigger(self.data)
end

function M:OnTrigger()
	self.cd = 1
	local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    if heroQueuePrefab then
		--heroQueuePrefab.is_stop = true
		self:CloseXy()
		if heroQueuePrefab.heros then
			--[[for k,v in pairs(heroQueuePrefab.heros) do
				local obj = GameObject.Instantiate(GetPrefab("YX_xuanyun"), v.transform)
				obj.transform.localPosition = Vector3.New(0, 0, 0)
				self.xuanyun_list[#self.xuanyun_list + 1] = obj
			end--]]

			heroQueuePrefab.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = 3,tag = "dizziness",})
			-- dump( heroQueuePrefab.heros , "xx--------------heroQueuePrefab.heros:" )
			for k,v in pairs(heroQueuePrefab.heros) do
				
				v.fsmLogic:addWaitStatusForUser( "stationary" ,{keep_time = 3,tag = "dizziness",})
			end

		end
    end
end

function M:OnClose()
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    if heroQueuePrefab then
		heroQueuePrefab.is_stop = false
    end
end

function M:OnChange()
	
end

function M:CloseXy()
	if self.xuanyun_list then
		for k,v in ipairs(self.xuanyun_list) do
			Destroy(v)
		end
	end
	self.xuanyun_list = {}
end
