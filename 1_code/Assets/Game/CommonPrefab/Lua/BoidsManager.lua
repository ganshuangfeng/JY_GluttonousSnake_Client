------- 敌人的集群管理 
--[[
-- 每个个体都有集群规则：
	个体之间远离，避免过近
	个体 都有自己目标， 从而有个目标方向
	个体 有集群的方向偏移


--- 个体 有很多的移动状态，冰冻，迁移(被黑洞控制)，集群(按群体逻辑来运动)
--- 当蛇过来时，远程兵是否需要逃离
--- 集群时

--]]

local BoidsManager = {}
local C = BoidsManager

----所有的个体的数据
C.all_boid_data = {
	-- [index] = move_driver
}

--- 集群规则
C.move_rule = {
	
}

function C.init()
	
end

function C.add_one_boid_data( _driver_obj )
	C.all_boid_data[#C.all_boid_data + 1] = _driver_obj
end


return C