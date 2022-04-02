--沙虫boss(main攻击技能 掌控三个其他boss的攻击)
local basefunc = require "Game/Common/basefunc"

SkillMonsterBossSandWormMainAttack = basefunc.class(Skill)
local M = SkillMonsterBossSandWormMainAttack

function M:Ctor(data)
	M.super.Ctor( self , data )
	self.data = data
	self.cur_attack_num = 0
	self.attack_num_cfg = {
		[1] = {
			[1] = {
				boss_skill_id = 1,
				attack_obj = {1,3},
			}
		},
		[2] = {
			[1] = {
				boss_skill_id = 1,
				attack_obj = {2},
			}
		},
		[3] = {
			[1] = {
				boss_skill_id = 2,
				attack_obj = {1},
			},
			[2] = {
				boss_skill_id = 3,
				attack_obj = {3},
			}
		},
		[4] = {
			[1] = {
				boss_skill_id = 4,
				attack_obj = {2},
			},
		},
		[5] = {
			[1] = {
				boss_skill_id = 1,
				attack_obj = {2}
			},
		},
		[6] = {
			[1] = {
				boss_skill_id = 1,
				attack_obj = {1,3}
			}
		},
		[7] = {
			[1] = {
				random_between = {3,4}
			}
		}
	}
	Event.Brocast("stageRefreshBossNorAttackValue",self.cur_attack_num,#self.attack_num_cfg)
end

function M:Init(data)
	M.super.Init( self )
	self.data = data or self.data
	self:CD()
end


function M:CD()
    self.skillState = SkillState.cd
    self.data.cd = self.data.cd or 3
    self.cd = self.data.cd
end


function M:Ready(data)
	M.super.Ready(self)
	self:Before()
end

function M:Trigger()
	M.super.Trigger(self)
	self.cur_attack_num = self.cur_attack_num + 1
	Event.Brocast("stageRefreshBossNorAttackValue",self.cur_attack_num,#self.attack_num_cfg)
	self:DiliverAttack(self.cur_attack_num)
	self:Finish()
end

--激活中
function M:OnActive(dt)
    if self.skillState ~= SkillState.active then
        return
    end

    self:Ready()
end

function M:Finish()
	self.super.Finish(self)
	if self.cur_attack_num >= #self.attack_num_cfg then
		self.cur_attack_num = 0
	end
end

--------消息 函数调用方式--------------------

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.cd = self.data.cd
end

function M:Exit()
	self.super.Exit(self)
end

function M:DiliverAttack(cur_attack_num)
	local cur_cfg = self.attack_num_cfg[cur_attack_num]
	for k,v in ipairs(cur_cfg) do
		if v.random_between then
			local rdn = math.random(1,#v.random_between)
			self:DiliverAttack(v.random_between[rdn])
		else
			Event.Brocast("SandwormBossDiliverAttack",v)
		end
	end
end