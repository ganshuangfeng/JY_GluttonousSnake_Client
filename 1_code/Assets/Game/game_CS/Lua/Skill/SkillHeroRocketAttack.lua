--技能：蛇头火箭攻击
local basefunc = require "Game/Common/basefunc"

SkillHeroRocketAttack = basefunc.class(Skill)
local M = SkillHeroRocketAttack

local cd = 3
local defaultTriggerCount = 60
local curTriggerCount = 1

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data

    self.curTriggerCount = curTriggerCount or 1
end

function M:Init(data)
    M.super.Init(self)
    self.data = data or self.data
    self:InitSkillPreTblUI()
    self.requireTriggerCount = self.data.requireTriggerCount or defaultTriggerCount
    self:RefreshSkillPreTblUI()
    self:SetParent()
    self:CD()
end

function M:Exit(data)
    curTriggerCount = self.curTriggerCount
    if self.shootSeq then
        self.shootSeq:Kill()
    end
    if IsEquals(self.skillPre) then
        Destroy(self.skillPre.gameObject)
    end
    M.super.Exit(self)
end


function M:Ready(data)
    M.super.Ready(self)

    -- 发送攻击状态数据包
    self:SendStateData()
end


--CD中
function M:OnCD(dt)
    if self.skillState ~= SkillState.cd then
        return
    end

    if self.curTriggerCount >= self.requireTriggerCount then
        self:Active()
    end
end


--触发中
function M:OnTrigger()
    if self.skillState ~= SkillState.trigger then
        return
    end
    --攻击
    self:CastRocket()

    --攻击完成
    self:After()
end

--------消息 事件通知方式--------------------
function M:MakeLister()
    M.super.MakeLister(self)
	self.lister["ui_game_get_jin_bi_msg"] = basefunc.handler(self,self.on_ui_game_get_jin_bi_msg)
end

--------接口函数--------------------
function M:ResetData()
    M.super.ResetData(self)
    self.curTriggerCount = 0
    curTriggerCount = 0
    self:RefreshSkillPreTblUI()
end

function M:CastRocket()
    local skillCfg = {
		[1] = {
			bulletPrefabName = {"daodan_xiao"},
			attackFrom = "hero",
			moveWay = {"LineMove"},
			hitStartWay = {"IsHitPlane"},
			hitEffect = {"RocketBombHit"},
			hitType = {"SkillRocketSmallShoot"},
			speed = {20,},
			bulletNumDatas = {16,},
			damage = {300,},
			bulletLifeTime = 6,
			remark = "火箭1",
			shouji_pre = "baozha_xiao",
			attr = {},
		},
		[2] ={
			bulletPrefabName = {"daodan_da","daodan_xiao"},
			attackFrom = "hero",
			moveWay = {"LineMove","LineMove"},
			hitStartWay = {"IsHitPlane","IsHitSomeOne"},
			hitEffect = {"RocketBombHit","PenetrateHit"},
			hitType = {"SkillRocketSmallShoot","CircleShoot"},
			speed = {30,10},
			bulletNumDatas = {1,30},
			damage = {300,300},
			bulletLifeTime = 6,
			remark = "火箭2",
			shouji_pre = {"baozha_da","baozha_xiao",},
			attr = {},
		},
    }
    
    local heroQueuePrefab = GameInfoCenter.GetHeroHead()
    local allHero = GameInfoCenter.GetAllHero()
    local fx_guangs = {}
    for k,hero in pairs(allHero) do
        local fx_guang = NewObject("GX_guang",hero.transform)
        fx_guangs[#fx_guangs + 1] = fx_guang
    end
    local HeroHead = GameInfoCenter.GetHeroHead()
    local fx_guang = NewObject("GX_guang",HeroHead.transform:Find("@head_img"))
    fx_guangs[#fx_guangs + 1] = fx_guang

    self.shootSeq = DoTweenSequence.Create()
	for i = 1,2 do
		self.shootSeq:AppendCallback(function()
			local shootData = basefunc.deepcopy(skillCfg[i])
			shootData.fire_pos = heroQueuePrefab.transform.localPosition
			if i == 1 then
				shootData.hitOrgin = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hitTarget = {pos = heroQueuePrefab.transform.localPosition}
				shootData.hero_tran = heroQueuePrefab.transform
			else
				local pos = CSModel.GetUITo3DPoint(Vector3.zero)

				pos = Vector3.New(pos.x,pos.y + 3,pos.z)
				shootData.hitOrgin = {pos = pos}
				shootData.hitTarget = {pos = pos}
			end
			ExtendSoundManager.PlaySound(audio_config.cs.battle_rocket.audio_name)
			Event.Brocast("hero_attack_monster",shootData)
		end)
		if i == 1 then
			self.shootSeq:AppendInterval(2)
		end
	end
	self.shootSeq:AppendInterval(4)
	self.shootSeq:OnForceKill(function()
        --ClientAndSystemManager.SendRequest("cs_set_gold_skill",{skill_gold = 0.2})
        if fx_guangs then
            for k,v in ipairs(fx_guangs) do
                Destroy(v)
            end
            fx_guangs = nil
        end
        CSModel.camera2d.transform.localPosition = Vector3.zero
        CSPanel.map.transform.localPosition = Vector3.zero
        self.shootSeq = nil
	end)

end

function M:on_ui_game_get_jin_bi_msg()
    if self.skillState == SkillState.cd then
        self.curTriggerCount = self.curTriggerCount + 1
        curTriggerCount = self.curTriggerCount
    end
    self:RefreshSkillPreTblUI()
end

-------内部UI控制方法--------------------

function M:InitSkillPreTblUI()
    --创建预制体
    local parent = CSPanel.st_skill_node or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillHeadRocket",parent)
    self.skillPre.gameObject:SetActive(true)
    self.skillPre.transform:Find("@icon_img"):GetComponent("Button").onClick:AddListener(function()
        if self.skillState ~= SkillState.active then return end
        self:Trigger()
    end)
    self.skillPreTbl = LuaHelper.GeneratingVar(self.skillPre.transform)
end

function M:RefreshSkillPreTblUI()
    if self.curTriggerCount >= self.requireTriggerCount then
        if not self.UI_chixu_guangxiao then
            self.UI_chixu_guangxiao = NewObject("UI_chixu_guangxiao",self.skillPre.transform)
        end
        if self.xingxing_fx then
            Destroy(self.xingxing_fx)
            self.xingxing_fx = nil
        end
        self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(false)
        self.skillPreTbl.click_cffect_node.gameObject:SetActive(true)
    else
        if self.UI_chixu_guangxiao then
            Destroy(self.UI_chixu_guangxiao)
            self.UI_chixu_guangxiao = nil
        end
        self.skillPreTbl.rocket_skill_img.fillAmount = self.curTriggerCount / self.requireTriggerCount
        if self.curTriggerCount > 0 then
            if not self.xingxing_fx then
                self.xingxing_fx = NewObject("xingxing",self.skillPre.transform)
            end
            --简单计算一下坐标
            local vec_pos_cfg = {
                [1] = {
                    progress = 0,
                    pos = {x = -105,y = 0},
                },
                [2] = {
                    progress = 0.1,
                    pos = {x = -105,y = 62}
                },
                [3] = {
                    progress = 0.154,
                    pos = {x = -74,y = 90}
                },
                [4] = {
                    progress = 0.373,
                    pos = {x = 104,y = 90}
                },
                [5] = {
                    progress = 0.625,
                    pos = {x = 104, y = -94}
                },
                [6] = {
                    progress = 0.856,
                    pos = {x = -79,y = -94},
                },
                [7] = {
                    progress = 0.895,
                    pos = {x = -105,y = -75.7},
                },
                [8] = {
                    progress = 1,
                    pos = {x = -105,y = 0},
                }

            }
            local progress = self.curTriggerCount / self.requireTriggerCount
            for k,v in ipairs(vec_pos_cfg) do
                if vec_pos_cfg[k] and vec_pos_cfg[k + 1] then
                    if vec_pos_cfg[k].progress <= progress and vec_pos_cfg[k + 1].progress >= progress then
                        local vec_1 = v.pos
                        local vec_2 = vec_pos_cfg[k + 1].pos
                        local cur_progress = (progress - v.progress) / (vec_pos_cfg[k + 1].progress - vec_pos_cfg[k].progress)
                        local xx_pos = {
                            x = (vec_2.x - vec_1.x) * cur_progress + vec_1.x,
                            y = (vec_2.y - vec_1.y) * cur_progress + vec_1.y
                        }
                        self.xingxing_fx.transform.localPosition = Vector3.New(xx_pos.x,xx_pos.y,0)
                        break
                    end
                end
            end
        end
        self.skillPreTbl.rocket_skill_txt.text = self.curTriggerCount .. "/" .. self.requireTriggerCount
        self.skillPreTbl.rocket_skill_cold_node.gameObject:SetActive(true)
        self.skillPreTbl.click_cffect_node.gameObject:SetActive(false)
    end
end

function M:SetParent()
    local parent
	local timer 
    timer = Timer.New(function ()
        parent = GameObject.Find("Canvas/GUIRoot/CSGamePanel/ComponsePanel_New1/@Hero_Pos_Node/@head_pos")
        if IsEquals(parent) then
            self.skillPre.transform.parent = parent.transform
            self.skillPre.transform.localPosition = Vector3.zero
            self.skillPre.gameObject:SetActive(true)
            timer:Stop()
        end
    end,0.1,-1)
    timer:Start()
    self.setParentTimer = timer
end