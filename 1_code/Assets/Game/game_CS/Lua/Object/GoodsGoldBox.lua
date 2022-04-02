--[[物品  金币宝箱

]]
local basefunc = require "Game/Common/basefunc"
GoodsGoldBox = basefunc.class(Object)
local M = GoodsGoldBox

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data
	local obj
	if self.data.building and IsEquals(self.data.building.gameObject) then
		obj = self.data.building.gameObject
	else
		obj = GameObject.Instantiate(GetPrefab(self.data.prefabName), self.data.parent).gameObject
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject.name = self.id
	LuaHelper.GeneratingVar(self.transform, self)
	self.collider = self.gameObject:GetComponent("ColliderBehaviour")
	if IsEquals(self.collider) then
		self.collider:SetLuaTable(self)
		self.collider.luaTableName = "GoodsGoldBox"
	end

	--self.anim_pay = self.transform:GetComponent("Animator")

	self.open.gameObject:SetActive(false)


	self.state = "normal"
end

function M:Init()
	M.super.Init( self )
	self:MakeLister()
	self:AddMsgListener()

	if self.data.pos then
		self.transform.position = self.data.pos
	end


	if self.data.initCallback then
		self.data.initCallback(self)
	end
end

function M:MakeLister()
    self.lister = {}
end

function M:AddMsgListener()
    for m,func in pairs(self.lister) do
        Event.AddListener(m, func)
    end
end

function M:RemoveListener()
    for m,func in pairs(self.lister) do
        Event.RemoveListener(m, func)
    end
    self.lister = {}
end

function M:Exit()
	self:RemoveListener()
	Destroy(self.gameObject)

	---- 从 info Center 中移除
	GameInfoCenter.RemoveGoodsById( self.id )
end

function M:OnDestroy()

	if self.data.destoryCallback then
		self.data.destoryCallback(self)
	end

	self:Exit()


end


function M:OnCollisionEnter2D(collision)


	if self.state ~= "normal" then
		return
	end
	
	self.state = "die"

	ExtendSoundManager.PlaySound(audio_config.cs.battle_get_crystal.audio_name)

	if self.data.collisionCallback then
		self.data.collisionCallback(self)
	end

end


function M:DieByGoldMonster(n)
	local lightVec = {}

	for i = 1 , n do
		lightVec[#lightVec + 1] = CachePrefabManager.Take( "TW_jinbi" , self.transform )
		lightVec[#lightVec].prefab.prefabObj.transform.localPosition = Vector3.zero
	end
	
	local totalTime = 0.8
	
	local anim_func = function (obj)
		local tran = obj.transform

		local seq = DoTweenSequence.Create()
		
		
		local randomAngle = math.random( 0 , 360 )
		local neiR = 300
		local waiR = 1000

		local randomR = math.random( neiR , waiR ) / 100
		local tarPos = Vector3.New( randomR * math.cos( randomAngle / 180 * math.pi ) , randomR * math.sin( randomAngle / 180 * math.pi ) , 0 ) 

		seq:Append(tran:DOLocalMoveX( tarPos.x  , totalTime ):SetEase(Enum.Ease.Linear))

		local upY = (tarPos.y > 0) and (tarPos.y + math.random(150,300)/100) or ( math.random(150,300)/100 )

        seq:Insert(0 , tran:DOLocalMoveY( upY , totalTime/2 ):SetEase(Enum.Ease.OutCirc));
 
        --下落
        seq:Insert(totalTime/2 , tran:DOLocalMoveY( tarPos.y , totalTime/2 ):SetEase(Enum.Ease.InCirc));

        seq:OnKill(function ()

			---- 创建一个金币怪
			CreateFactory.CreateMonster( { use_id = 3 , level = 1 , pos = obj.transform.position } )

			--- 删掉光体
			Destroy(obj)

		end)

	end

	---- dotween
	local upTime = 0.2
	local seq = DoTweenSequence.Create()
	seq:Append( self.transform:DOLocalMoveY( self.transform.localPosition.y + 2  , upTime ):SetEase(Enum.Ease.Linear))
	seq:AppendCallback(function()
		---- 播放一个盒子打开动画，
		self.open.gameObject:SetActive(true)
		self.close.gameObject:SetActive(false)

		for key , obj in pairs(lightVec) do
			anim_func(obj.prefab.prefabObj.gameObject)
		end
	end)

	
	Timer.New(function ()
		self.gameObject:SetActive(false)
	end, totalTime + upTime + 0.2 , 1):Start()

	Timer.New(function ()
		self:OnDestroy()
	end, 6 , 1):Start()

	if self.data.aniOverCallback then
		self.data.aniOverCallback(self)
	end
end

-- 简单的结束
function M:Over()

	CSEffectManager.PlayWjBoom(self.transform, function ()

		if self.data.aniOverCallback then
			self.data.aniOverCallback(self)
		end

		GameInfoCenter.RemoveGoodsById(self.id)

	end)

end