local basefunc = require "Game/Common/basefunc"
local monsterFsmTable = require "Game.game_CS.Lua.FsmConfig.monsterFsmTable"

Monster = basefunc.class(Object)
local M = Monster

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

	-------------------------- 基础数据 ↓
	self.hp = self.config.hp
	self.maxHp = self.hp
	--- 攻击间隔
	self.hit_space = self.config.hit_space or 0.5
	self.elite = self.config.elite == 1
	--- 攻击距离
	self.attack_range = self.config.attack_range or 3
	self.damage = self.config.damage
	-------------------------- 基础数据 ↑

	self.damageCd = 0.1
	self.damageCt = self.damageCd
	self.damageSum = 0

	self.skill = {}	

	self.modifier = {}
	
	self.state = "normal"

	-- 启用移动(一定不能转向)
	self.enableMove = false
	-- 不能转向(能转向不一定能移动)
	self.enableRot = true

	self.fsmLogic = FsmLogic.New( self , data.fsmTable or monsterFsmTable )
end



function M:CreateUI(data)
	local prefab_name = CSModel.GetAssetName(self.config.prefab_name)
	--self.prefab = CachePrefabManager.Take(prefab_name, CSPanel.monster_node, 20)
	self.gameObject = NewObject(prefab_name,CSPanel.monster_node)
	self.transform = self.gameObject.transform
	self.transform.position = self.data.pos
	self.transform.parent = CSPanel.monster_node
	self.gameObject:SetActive(true)
	self.gameObject.name = self.id
	self.transform.localScale = Vector3.one * (self.config.size or 1)

	ChangeLayer(self.gameObject, 11000 + self.data.config.type * 20, true)
	
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = data.luaTableName
	end

	LuaHelper.GeneratingVar(self.transform, self)
	self.anim_pay = self.transform:GetComponent("Animator")

	if self.eyeNode then
		self.animEye = self.eyeNode:GetComponent("Animator")
	end
	if self.sprite then
		self.spriteRenderer = self.sprite:GetComponent("SpriteRenderer")
		self.spriteRenderer.color = Color.New(1, 1, 1, 1)
	end
	SetLayer(self.gameObject,"Monster")
	self.transform.position = Vector3.New(self.data.pos.x,self.data.pos.y,0)

	local MinSpeed,MaxSpeed = self.config.move_speed[1],self.config.move_speed[2]

	self.vehicle = VehicleManager.CreateMonster(
							{
								m_vPos={
									x=self.transform.position.x, 
									y=self.transform.position.y,
								},
								m_dMinSpeed = MinSpeed,
								m_dMaxSpeed = MaxSpeed,
								m_dMaxTurnRate = 360,
							}, self)
	self.vehicle:Start()
	self:UpdateHp()
	if self.elite then
		self.elite_tx = NewObject("gw_fazhen",self.transform)
		if self.config.name == "食人花-精英" then
			self.elite_tx.transform.localPosition = Vector3.New(0,-0.628,0)
		end
	end
	if self.data.config.name ~= "金币怪" then
		self:PlayMonserApearAnim()
	else
		self.is_stop = true
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.65)
		seq:AppendCallback(function()
			self.is_stop = false
		end)
	end
	if self.data.config.type > 100 then
        -- Event.Brocast("stage_state_change","boss_coming")
		ExtendSoundManager.PlaySceneBGM(audio_config.cs.battle_BOSS_BGM.audio_name)
	end
end

function M:PlayMonserApearAnim()
	self.is_stop = true
	self.gameObject:SetActive(false)
	self.vehicle:Stop()
	local seq = DoTweenSequence.Create()
	local fx_pre = CachePrefabManager.Take("CS_guaiwu_chuchang",MapManager.GetMapNode())
	if self.sprite then
		fx_pre.prefab.prefabObj.transform.position = self.sprite.transform.position
	else
		fx_pre.prefab.prefabObj.transform.position = self.transform.position
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.95)
	seq:AppendCallback(function()
		self.gameObject:SetActive(true)
		self.vehicle:Start()
		self.is_stop = false

		----- 发一个消息，怪物创建完成
		Event.Brocast( "monster_create_after" , self.id )

	end)
	seq:AppendInterval(3)
	seq:OnForceKill(function()
		CachePrefabManager.Back(fx_pre)
	end)
end

function M:Init(data)
	M.super.Init( self )

	self:CreateUI({luaTableName="Monster"})

	self:MakeLister()
	self:AddMsgListener()

	---- 职业代码
	MonsterProfessionManager.InitProfession( self , self.config.professionType ) 

	--self.fsmLogic:addWaitStatusForUser( "breath"  )
	--self.fsmLogic:addWaitStatusForUser( "idel"  )

	self:InitSkill()
	self.isZm = true
end

function M:InitSkill()

	if self.data.skill then
		for i,v in ipairs(self.data.skill) do
			local skill = CreateFactory.CreateSkill({object = self, data=v, type = v.type, cd = self.hit_space, bullet_id = self.config.bullet_id})
			self.skill[skill.id] = skill
		end
	end

end

function M:UpdateTransform(pos, r)

	if CSModel.Is2D then
		self:UpdateRot(pos,r)
		self.transform.position = Vector3.New(pos.x, pos.y, 0)
	else
		self.transform.position = Vector3.New(pos.x, pos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
	end
end
function M:UpdateRot(pos)
	local head = GameInfoCenter.GetHeroHead()
	if not head then
		return
	end

	local oldPos = self.transform.position
	local headPos = head.transform.position
	pos = pos or oldPos

	local s = math.abs(self.node.localScale.x)

	if math.abs(oldPos.x - pos.x) > 0.01 then
		if oldPos.x > pos.x then
			self.node.localScale = Vector3.New(-1*s, s, 1)
		else
			self.node.localScale = Vector3.New(s, s, 1)
		end
	else
		if math.abs(headPos.x - pos.x) > 0.01 then
			if headPos.x < pos.x then
				self.node.localScale = Vector3.New(-1*s, s, 1)
			else
				self.node.localScale = Vector3.New(s, s, 1)
			end
		end
	end

	if math.abs(oldPos.y - pos.y) > 0.01 then
		if oldPos.y < pos.y then
			if self.isZm then
				self.isZm = false
				self.anim_pay:Play("fm", 0, 0)
			end
		else
			if not self.isZm then
				self.isZm = true
				self.anim_pay:Play("zm", 0, 0)
			end
		end
	else
		if math.abs(headPos.y - pos.y) > 0.01 then
			if headPos.y > pos.y then
				if self.isZm then
					self.isZm = false
					self.anim_pay:Play("fm", 0, 0)
				end
			else
				if not self.isZm then
					self.isZm = true
					self.anim_pay:Play("zm", 0, 0)
				end
			end
		end
	end

	if math.abs(headPos.y - pos.y) > math.abs(headPos.x - pos.x) then
		if headPos.y > pos.y then
			if self.animEye then
				self.animEye:Play("U", 0, 0)
			end
		else
			if self.animEye then
				self.animEye:Play("D", 0, 0)
			end
		end
	else
		if headPos.x > pos.x then
			if self.animEye then
				self.animEye:Play("R", 0, 0)
			end
		else
			if self.animEye then
				self.animEye:Play("L", 0, 0)
			end
		end
	end
end

function M:FrameUpdate(dt)
	if self.is_stop then return end
	M.super.FrameUpdate( self , dt )

	self.fsmLogic:Update(dt)

	if self.enableMove then
    	self.vehicle:FrameUpdate(dt)
    else
    	if self.enableRot then
    		self:UpdateRot()
    	end
    end
    
	for id,skill in pairs(self.skill) do
		skill:FrameUpdate(dt)
	end

	self.damageCt = self.damageCt - dt
end

function M:OnCollisionEnter2D(collision)
	-- if not self.is_enter then
	-- 	self.is_enter = true
	-- 	local pos = collision.gameObject.transform.position
	-- 	VehicleManager.Stop(self.vehicle.ID)
	-- 	local tpos = Vector3.New(self.transform.position.x, self.transform.position.y, 0)
	-- 	local cha = tpos - pos
	-- 	local len = Vec2DLength({x=cha.x, y=cha.y})
	-- 	local max_len = 3
	-- 	if len > max_len then
	-- 		len = max_len
	-- 	end
	-- 	local mass = 1
	-- 	local scale = (max_len-len) / max_len * mass
	-- 	local epos = Vector3.Normalize(cha) * 3 * scale + tpos

	-- 	local seq = DoTweenSequence.Create()
	-- 	seq:Append(self.transform:DOMove(epos, 0.5):SetEase(Enum.Ease.OutQuint))
	-- 	seq:OnKill(function ()
	-- 		self.is_enter = false
	-- 		if IsEquals(self.transform) then
	-- 			VehicleManager.Recover(self.vehicle.ID, self.transform.position)
	-- 		end
	-- 	end)
	-- end
end

function M:PlayHitBackAnim(collision)
	local is_right_pos = function(pos)
		--local size = GameInfoCenter.GetMapSize()
		local size = GetSceenSize(self)

		local new_pos = {z = 0}
		if math.abs(pos.x) > size.width / 2 then
			return false
		end
		if math.abs(pos.y) > size.height /2 then
			return false
		end
		return true
	end
	if not self.is_enter then
		self.is_enter = true
		local pos = collision.gameObject.transform.position
		VehicleManager.Stop(self.vehicle.ID)
		local tpos = Vector3.New(self.transform.position.x, self.transform.position.y, 0)
		local cha = tpos - pos
		local len = Vec2DLength({x=cha.x, y=cha.y})
		local max_len = 3
		if len > max_len then
			len = max_len
		end
		local mass = 1
		local scale = (max_len-len) / max_len * mass
		local epos = Vector3.Normalize(cha) * 3 * scale + tpos
		
		--local notGrid = GameInfoCenter.GetMapNotPassGridData()
		local notGrid = GetMapNotPassGridData( self )
		if notGrid and notGrid[ GetMapNoByPos( self , epos ) ] or not is_right_pos(epos) then
			self.is_enter = false
			if IsEquals(self.transform) then
				VehicleManager.Recover(self.vehicle.ID, self.transform.position)
			end
		else
			local seq = DoTweenSequence.Create()
			seq:Append(self.transform:DOMove(epos, 0.5):SetEase(Enum.Ease.OutQuint))
			seq:OnKill(function ()
				self.is_enter = false
				if IsEquals(self.transform) then
					VehicleManager.Recover(self.vehicle.ID, self.transform.position)
				end
			end)
		end

	end
end

function M:Exit()
	if self.damage_hp_seq then
		self.damage_hp_seq:Kill()
	end
	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
			self.skill[key] = nil
		end
		self.skill = nil
	end

	M.super.Exit( self )

	
	self:RemoveListener()
	--- 职业删除
	MonsterProfessionManager.DeleteProfession( self ) 

	self.fsmLogic:Delete()
	if self.defaultSpriteMaterials then
		local ps = self.transform.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
		for i = 0,ps.Length - 1 do
			local _renderer = ps[i]
			_renderer.material = self.defaultSpriteMaterials[i]
		end
	end
	if self.elite_tx then
		Destroy(self.elite_tx)
	end
	Destroy(self.gameObject)
end

function M:OnDie()
	
	if self.skill then
		for key , skill in pairs(self.skill) do
			skill:Exit()
			self.skill[key] = nil
		end
	end
	
	self.gameObject:SetActive(false)
			
	CSEffectManager.PlayMonsterOnDead(self.transform.position, nil, function ()
		GameInfoCenter.RemoveMonsterById(self.id)
	end)
	
	local config = StageManager.OutputGoods("monster")
	if config then
		DropAsset.Create(
				{
					config = config,
					pos = self.transform.position,
					destroy_time = 9999,
					roomNo = self.data.roomNo,
			})
	end
	
end

--超能时刻技能 转换为掉金币状态
function M:SetGoldRushState(bool)
	if self.goldRushState ~= bool then
		if bool then
			self.goldRushDropPosList = {}
			self.goldRushDropCount = 0
		end
		self.goldRushState = bool
		local ps = self.transform.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
		self.defaultSpriteMaterials = self.defaultSpriteMaterials or {}
		for i = 0,ps.Length - 1 do
			local _renderer = ps[i]
			if bool then
				self.defaultSpriteMaterials[i] = _renderer.material
				_renderer.material = GetMaterial("A_gw_caizhi")
			else
				_renderer.material = self.defaultSpriteMaterials[i]
			end
		end
	end

end

--超能时刻技能 受击时掉金币
function M:CreateOnHitGoldCoin(data)
	local dropCount = 1
	for i = 1, dropCount do
		self:CreateHitDropCoin()
	end
end

function M:CreateHitDropCoin()
	local jb = 5
	self.goldRushDropPosList = self.goldRushDropPosList or {}
	self.goldRushDropCount = self.goldRushDropCount or 0
	self.goldRushDropCount = self.goldRushDropCount + 1
	local pos = DropAsset.CalculateGoldPos(self.goldRushDropCount,self.goldRushDropPosList,self.transform.position)
	DropAsset.Create({
		config = {
			[1] = {
				key = "prop_gold_coin1",
				value = 1,
				jb = jb,
			}
		},
		close_random_pos = true,
		pos = pos + self.transform.position,
		destroy_time = 9999,
		roomNo = self.data.roomNo,
		parent_pos = self.transform.position
	})
end

function M:OnHit(data)
	local damage = data.damage
	self.hp = self.hp - damage
	if self.state == "die" then
		return
	end

	if self.skill then
		for key , skill in pairs(self.skill) do
			if skill.OnHit then
				skill:OnHit(data)
			end
		end
	end
	if self.goldRushState then
		self:CreateOnHitGoldCoin({damage = damage})
	end

	if not data.extra then
		self.damageSum = self.damageSum + damage
	end
	--扣血动画
	if self.hp > 0 and self.hp_spr then
		if self.damage_hp_seq then
			self.damage_hp_seq:Kill()
		end
		local obj = GameObject.Instantiate(self.hp_spr.gameObject,self.hp_spr.transform.parent)
		obj.transform:GetComponent("SpriteRenderer").material = GetMaterial("SpriteWhite")
		obj.transform:GetComponent("SpriteRenderer").sortingOrder = obj.transform:GetComponent("SpriteRenderer").sortingOrder - 1
		obj.transform.localPosition = self.hp_spr.transform.localPosition
		obj.transform.localScale = self.hp_spr.transform.localScale
		local width = self.hp_spr.size.x
		local h = self.hp / self.maxHp
	
		local px = (h - 1) * width * 0.5
		local sx = h
		local lp = self.hp_spr.transform.localPosition
		local ls = self.hp_spr.transform.localScale
		local interval = 1
		self.damage_hp_seq  = DoTweenSequence.Create()
		self.damage_hp_seq:Append(obj.transform:DOLocalMove(Vector3.New(px,lp.y,lp.z),interval))
		self.damage_hp_seq:Join(obj.transform:DOScale(Vector3.New(sx,ls.y,ls.z),interval))
		self.damage_hp_seq:OnForceKill(function()
			self.damage_hp_seq = nil
			if IsEquals(obj) then
				Destroy(obj.gameObject)
			end
		end)
	end

	self:UpdateHp()



	if self.hp <= 0 then
		self.state = "die"
		self:OnDie()
		self:DamageTxt(self.damageSum)
		self.damageCt = self.damageCd
		return
	end

	if self.damageCt<0 then
		if self.damageSum > 0 and self.hp > 0 then
			self:DamageTxt(self.damageSum)
			self.damageSum = 0
			self.damageCt = self.damageCd
		end
	end

	self.spriteRenderer.color = Color.New(253/255,105/255,105/255)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:OnKill(function ()
		if IsEquals(self.spriteRenderer) then
			self.spriteRenderer.color = Color.white
		end
	end)
end


function M:UpdateHp()

	if not self.hp_spr then
		return
	end
	local width = self.hp_spr.size.x

	self.hp = math.max(self.hp,0)

	local h = self.hp / self.maxHp

	local px = (h - 1) * width * 0.5
	local sx = h

	local lp = self.hp_spr.transform.localPosition
	self.hp_spr.transform.localPosition = Vector3.New(px,lp.y,lp.z)
	local ls = self.hp_spr.transform.localScale
	self.hp_spr.transform.localScale = Vector3.New(sx,ls.y,ls.z)
end

function M:DamageTxt(d,prefab,desc)
	desc = desc or ""
	if d == 0 then return end
	local pos = CSModel.Get3DToUIPoint(self.node.position)
	self.curr_index = self.curr_index or 0
	if self.reset_timer then
		self.reset_timer:Stop()
	end

	self.reset_timer = Timer.New(
		function()
			self.curr_index = 0
		end
	,0.8,1)
	self.reset_timer:Start()
	local offsetPos = {
		Vector3.New(0, 2, 0),
		Vector3.New(1.5, 2, 0),
		Vector3.New(-1.3, 2, 0),
		Vector3.New(-1.2, 2, 0),
		Vector3.New(1.9, 2, 0),
		Vector3.New(-1.9, 3, 0),
		Vector3.New(2, 3, 0),
		Vector3.New(-2, 3, 0),
		Vector3.New(-3, 3, 0),
	}
	self.curr_index = self.curr_index + 1
	if self.curr_index > #offsetPos then
		self.curr_index = 1
	end
    CSEffectManager.PlayShowAndHideAndCall(
                                            MapManager.GetMapNode(),
											prefab or "Damage",
                                            20,
                                            Vector3.New(0, 2, 0),
                                            1,
                                            nil,
                                            nil,
                                            function (obj)
                                            	obj.position = self.transform.position + offsetPos[self.curr_index]
                                            	local anim = obj.transform:GetComponent("Animator")
                                            	anim:Play("damage_anim", 0, 0)
                                            	obj.transform:Find("txt"):GetComponent("TMP_Text").text = 
												desc.."-"..StringHelper.ToAbbrNum( d )
												obj.transform.parent = CSPanel.attack_node

                                        	end)
	
end

function M:CreatForzenPrefab()

	local forzenPrefab = CachePrefabManager.Take("forzen", self.forzenNode, 10)
	forzenPrefab.prefab.prefabObj.transform.localScale = Vector3.one
	forzenPrefab.prefab.prefabObj.transform.localPosition = Vector3.zero

	return forzenPrefab

end