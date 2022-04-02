--技能：蛇头火箭攻击
local basefunc = require "Game/Common/basefunc"

SkillHeroTankAttack = basefunc.class(Skill)
local M = SkillHeroTankAttack

function M:Ctor(data)
    M.super.Ctor(self, data)
    self.data = data
    self.curTriggerCount = data.curTriggerCount or 0
end

function M:Init(data)
    M.super.Init(self)
    self.data = data or self.data
    self:InitSkillPreTblUI()
    self.curTriggerCount = 1
    self.requireTriggerCount = self.data.requireTriggerCount or 1
    self:RefreshSkillPreTblUI()
    self:SetParent()
    self:CD()
end

function M:Exit(data)
    if self.shootSeq then
        self.shootSeq:Kill()
    end
    if IsEquals(self.skillPre) then
        Destroy(self.skillPre.gameObject)
    end
    M.super.Exit(self)
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
    self:CastTank()

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
    self:RefreshSkillPreTblUI()
end

function M:CastTank()
    local skillCfg = {
		[1] = {
			bulletPrefabName = {"YX_chetou_zj"},
			attackFrom = "hero",
			moveWay = {"SkillTankMove"},
			hitStartWay = {"IsHitSomeOne"},
			hitEffect = {"PenetrateHit"},
			hitType = {"SkillTankShoot"},
			speed = {40,},
			bulletNumDatas = {1,},
			damage = {300,},
			bulletLifeTime = 6,
			remark = "火箭1",
			shouji_pre = "baozha_xiao",
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
	for i = 1,#skillCfg do
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
    end
    self:RefreshSkillPreTblUI()
end

-------内部UI控制方法--------------------

function M:InitSkillPreTblUI()
    dump(debug.traceback(),"<color=yellow>调用生成skillPreTbl</color>")
    --创建预制体
    local parent = self.data.parent or GameObject.Find("Canvas/GUIRoot").transform
    self.skillPre = NewObject("SkillHeadTank",parent)
    self.skillPre.gameObject:SetActive(false)
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
                    pos = {x = -67.4,y = 0},
                },
                [2] = {
                    progress = 0.125,
                    pos = {x = -67.4,y = 57.4}
                },
                [3] = {
                    progress = 0.375,
                    pos = {x = 59.7,y = 57.4}
                },
                [4] = {
                    progress = 0.625,
                    pos = {x = 59.7,y = -56.3}
                },
                [5] = {
                    progress = 0.875,
                    pos = {x = -67.4, y = -56.3}
                },
                [6] = {
                    progress = 1,
                    pos = {x = -67.4,y = 0},
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