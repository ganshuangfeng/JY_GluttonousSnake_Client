local basefunc = require "Game/Common/basefunc"

Portal = basefunc.class(Object)
local M = Portal

function M:Ctor(data)
	M.super.Ctor( self , data )
	
	self.data = data

	self:CreateUI()

end

function M:CreateUI()
	
	local pos = self.data.pos

	if not pos then

		--local mapSize = MapManager.GetMapSize()
		--local gsz = MapManager.GetGridSize()
		local mapSize = GetSceenSize(self)
		local gsz = GetGridSize(self)

		pos = get_grid_pos( self , Vector3.New(0, mapSize.height/2 - gsz, 0) , true )

	end

	-- self:Award(pos)

    -- CSEffectManager.PlayShowAndHideAndCall(
    --                                         CSPanel.map_node,
    --                                         "SG_sg",
    --                                         20,
    --                                         pos,
    --                                         0.8,
    --                                         nil,
    --                                         nil,
    --                                         function (obj)
    --                                         	-- obj.localPosition = Vector3.New(0+r, 1.2+r2, 0)
    --                                     	end)


	self.portal_prefab = GameObject.Instantiate(GetPrefab("ZY_jiantou_JT"), CSPanel.map_node).gameObject

	self.portal_prefab.transform.position = pos--Vector3.New(pos.x,pos.y,pos.x)

	if self.data and self.data.callback then
		self.data.callback(pos)
	end

end


function M:Award(pos)

	-- if not self.data or not self.data.award then
	-- 	return
	-- end

	--local mapSize = MapManager.GetMapSize()
	--local gsz = MapManager.GetGridSize()
	local mapSize = GetSceenSize(self)
	local gsz = GetGridSize(self)
	local p = get_grid_pos(self , Vector3.New(pos.x, pos.y  - 2*gsz, 0) , true )

	-- if self.data.award[1] == 1 then

 --        local cfg = {type=6,jb=self.data.award[2],pos=p}
 --        CreateFactory.CreateGoods(cfg)

	-- elseif self.data.award[1] == 2 then

        -- local cfg = {type=5,heroType=self.data.award[2],pos=p}
        local cfg = {type=5,heroType=math.random(1,4),pos=p}
        CreateFactory.CreateGoods(cfg)

	-- end

end



function M:Exit()

	M.super.Exit( self )

	Destroy(self.portal_prefab)

end
