local basefunc = require "Game/Common/basefunc"

TargetIndicator = basefunc.class(Object)
local M = TargetIndicator

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

	self.target_indicator_data = {
		prefab = CachePrefabManager.Take("target_indicator", CSPanel.transform).prefab.prefabObj.gameObject,
		state = nil,
	}
	self.target_indicator_data.prefab:SetActive(false)

	--[[
		monster 模式
		monster_id 怪物死了就把自己移除

		pos 模式
		永远标记这个点
	]]

end

function M:FrameUpdate(dt)

	local tp = nil
	local ti = nil
	if self.data.monster_id then

		local obj = GameInfoCenter.GetMonsterById(self.data.monster_id)
		if not obj then
			self.isLive = false
			return
		else
			ti = "monster"
			if obj.data.config.type > 100 then
				ti = "boss"
			end
			tp = obj.transform.position
		end

	elseif self.data.pos then
		tp = self.data.pos
		ti = self.data.type
	else

		local td = GameInfoCenter.GetHeroHeadTargetData()
		if not td then
			self.target_indicator_data.prefab:SetActive(false)
			return
		end

		tp = td.pos
		ti = td.type
	end

	local imgData = {
		gem = 
			{img="2D_ts_bs",scale=1,},
		box = 
			{img="2d_img_bx_g_1",scale=1,},
		boss = 
			{img="boss_target_indicator",scale=0.3,},
		monster = 
			{img="monster_target_indicator",scale=0.3,},
		csm = 
			{img="2D_map_csm",scale=0.1,},
	}
	local d = imgData[ti]

	if not d then
		return
	end

	local imgSp = self.target_indicator_data.prefab.transform:Find("img"):GetComponent("Image")
	imgSp.sprite = GetTexture(d.img)
	imgSp:SetNativeSize()
	imgSp.gameObject.transform.localScale = Vector3.New(d.scale,d.scale,d.scale)

	local cp = CSPanel.camera3d.transform.position

	local tup = CSModel.Get3DToUIPoint(tp)

	local dp = Vector3.New(tp.x - cp.x,tp.y - cp.y,0)
	
	local lx,rx = -540,540
	local uy,by = 1170,-770

	local zsq_lx,zsq_rx = -470,470
	local zsq_uy,zsq_by = 826,-700

	local pos = Vector3.zero
	local zsq_pos = Vector3.zero
	local x_inside,y_inside = false,false

	if tup.x < lx then
		pos.x = lx
		zsq_pos.x = zsq_lx
	elseif tup.x > rx then
		pos.x = rx
		zsq_pos.x = zsq_rx
	else
		pos.x = math.min(math.max(tup.x, lx), rx)
		zsq_pos.x = math.min(math.max(tup.x, zsq_lx), zsq_rx)
		x_inside = true
	end

	if tup.y < by then
		pos.y = by
		zsq_pos.y = zsq_by
	elseif tup.y > uy then
		pos.y = uy
		zsq_pos.y = zsq_uy
	else
		pos.y = math.min(math.max(tup.y, by), uy)
		zsq_pos.y = math.min(math.max(tup.y, zsq_by), zsq_uy)
		y_inside = true
	end


	if x_inside and y_inside then
		self.target_indicator_data.prefab:SetActive(false)
	else
		self.target_indicator_data.prefab:SetActive(true)
	end


	local dup = Vector3.New(pos.x - zsq_pos.x, pos.y - zsq_pos.y,0)
	local angle = tls.pToAngleSelf(dup)*180/3.1415926
	angle = angle+180

	self.target_indicator_data.prefab.transform:Find("bg").rotation = Quaternion.Euler(0, 0, angle)

	self.target_indicator_data.prefab.transform.position = zsq_pos
end

function M:Exit()

	M.super.Exit( self )

	Destroy(self.target_indicator_data.prefab)
	self.target_indicator_data = nil

end
