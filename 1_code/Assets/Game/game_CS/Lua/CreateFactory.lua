-- 创建时间:2021-07-27
local basefunc = require "Game/Common/basefunc"
CreateFactory = {}

local M = CreateFactory
CampEnum = {
	Hero = "hero",
	HeroHead = "heroHead",
	Monster = "monster"
}

------------------------------------------------------创建英雄
------------------------------------------------------创建英雄
------------------------------------------------------创建英雄
--[[function M.GetHeroSkill(id)
	local config = {
		[1] = {   --- bullet_id = 1  , ext_bullet_id = nil
			classname="Hero",--星星
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[2] = {
			classname="Hero",--星星
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[3] = {
			classname="Hero",--星星
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[4] = {
			classname="Hero",--星星
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[5] = {--- bullet_id = 2  , ext_bullet_id = nil
			classname="Hero",--弓箭
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[6] = {
			classname="Hero",--弓箭
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[7] = {
			classname="Hero",--弓箭
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[8] = {
			classname="Hero",--弓箭
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[9] = {--- bullet_id = 22  , ext_bullet_id = 8
			classname="Hero",--瓶子炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperPZP2Attack",},
			},
		[10] = {
			classname="Hero",--瓶子炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperPZP2Attack",},
			},
		[11] = {
			classname="Hero",--瓶子炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperPZP2Attack",},
			},
		[12] = {
			classname="Hero",--瓶子炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperPZP2Attack",},
			},
		[13] = {--- bullet_id = 4  , ext_bullet_id = nil
			classname="Hero",--毒液
			skill = {"SkillHeroDuyeNorAttack","SkillHeroDuyeSuperAttack",},
			},
		[14] = {
			classname="Hero",--毒液
			skill = {"SkillHeroDuyeNorAttack","SkillHeroDuyeSuperAttack",},
			},
		[15] = {
			classname="Hero",--毒液
			skill = {"SkillHeroDuyeNorAttack","SkillHeroDuyeSuperAttack",},
			},
		[16] = {
			classname="Hero",--毒液
			skill = {"SkillHeroDuyeNorAttack","SkillHeroDuyeSuperAttack",},
			},
		[17] = {--- bullet_id = 5  , ext_bullet_id = nil
			classname="Hero",--回血炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperHealAttack",},
			},
		[18] = {
			classname="Hero",--回血炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperHealAttack",},
			},
		[19] = {
			classname="Hero",--回血炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperHealAttack",},
			},
		[20] = {
			classname="Hero",--回血炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperHealAttack",},
			},
		[21] = {--- bullet_id = 6  , ext_bullet_id = nil
			classname="Hero",--加速炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperFreshAttack",},
			},
		[22] = {
			classname="Hero",--加速炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperFreshAttack",},
			},
		[23] = {
			classname="Hero",--加速炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperFreshAttack",},
			},
		[24] = {
			classname="Hero",--加速炮台
			skill = {"SkillHeroNorAttack","SkillHeroSuperFreshAttack",},
			},
		[25] = {--- bullet_id = 10  , ext_bullet_id = 11
			classname="Hero",--回旋镖
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[26] = {
			classname="Hero",--回旋镖
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[27] = {
			classname="Hero",--回旋镖
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[28] = {
			classname="Hero",--回旋镖
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
				
		[29] = {--- bullet_id = 12  , ext_bullet_id = 14
			classname="Hero",--毒花
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[30] = {
			classname="Hero",--毒花
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[31] = {
			classname="Hero",--毒花
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[32] = {
			classname="Hero",--毒花
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[33] = {--- bullet_id = 17  , ext_bullet_id = 18
			classname="Hero",--激光炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[34] = {
			classname="Hero",--激光炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[35] = {
			classname="Hero",--激光炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[36] = {
			classname="Hero",--激光炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[37] = {--- bullet_id = 15  , ext_bullet_id = 16
			classname="Hero",--毒炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[38] = {
			classname="Hero",--毒炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[39] = {
			classname="Hero",--毒炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[40] = {
			classname="Hero",--毒炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperAttack",},
			},
		[41] = {--- bullet_id = 19  , ext_bullet_id = 20
			classname="Hero",--魔法炮
			skill = {"SkillHeroShanDianAttack","SkillHeroSuperAttack",},
			},
		[42] = {
			classname="Hero",--魔法炮
			skill = {"SkillHeroShanDianAttack","SkillHeroSuperAttack",},
			},
		[43] = {
			classname="Hero",--魔法炮
			skill = {"SkillHeroShanDianAttack","SkillHeroSuperAttack",},
			},
		[44] = {
			classname="Hero",--魔法炮
			skill = {"SkillHeroShanDianAttack","SkillHeroSuperAttack",},
			},	
		[45] = {--- bullet_id = 21  , ext_bullet_id = 16
			classname="Hero",--火箭炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperRocketAttack",},
			},
		[46] = {
			classname="Hero",--火箭炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperRocketAttack",},
			},
		[47] = {
			classname="Hero",--火箭炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperRocketAttack",},
			},
		[48] = {
			classname="Hero",--火箭炮
			skill = {"SkillHeroNorAttack","SkillHeroSuperRocketAttack",},
			},	
	}
	return config[id]
end--]]
function M.CreateHero(data)
	--type2createFunc
	data = data or {}
	
	data.config = GameConfigCenter.GetHeroConfig(data.type,data.star , data.level )
	--dump( data.config , "xx------------CreateHero__config" )
	--local skill_cfg = M.GetHeroSkill(data.config.id)

	--data.classname = skill_cfg.classname
	--data.skill = skill_cfg.skill

	data.classname = data.config.classname

	data.poolName = "hero"
	local obj = ObjectCenter.Create(data)
	obj.camp = CampEnum.Hero
    GameInfoCenter.AddHero(obj)

    --- 创建技能
    if data.config.skill and type(data.config.skill) == "table" then
	    for skill_id,_c_data in pairs(data.config.skill) do
	    	local skill_obj = M.CreateSkillById( skill_id , { object = obj } , ( type(_c_data) == "table") and _c_data or nil  )
	    end
	end


	return obj
end

function M.CreateHeroList( data )
	local type2star = {}

	
    for i,v in ipairs(data) do
        type2star[v.type] = type2star[v.type] or 0
		type2star[v.type] = type2star[v.type] + 1
    end
	

    for i,v in ipairs(data) do
		v.star = type2star[v.type]

		v.level = HeroDataManager.GetHeroLevelByType( v.type )
        M.CreateHero(v)
    end
end

------------------------------------------------------创建怪物
------------------------------------------------------创建怪物
------------------------------------------------------创建怪物
--[[
	data参数表，必要项，use_id 
--]]
function M.CreateMonster( data )
	--[[local MonsterTypeObj = {
		[1] = {classname="Monster", skill = 
			{
				{type="SkillMonsterView", },
				{type="SkillMonsterNorAttack",beforeCd = 1}
			} },

		[2] = {classname="Monster", skill = 
			{
				{type="SkillMonsterView"},
				{type="SkillMonsterNorAttack", beforeCd = 1 ,afterCd=0.5}
			} },

		[3] = {classname="Monster", skill = 
			{
				{type="SkillMonsterView"},
				{type="SkillMonsterNorAttack", beforeCd = 1 ,afterCd=0.5}
			}, },

		[4] = {classname="Monster", skill = 
			{
				{type="SkillMonsterView"},
				{type="SkillMonsterDashAttack",beforeCd = 0.5 ,afterCd=0.5}
			} },

		[5] = {classname="Monster", skill = 
			{
				{type="SkillMonsterShiRenFlowerNorAttack", beforeCd = 1 ,afterCd=0.1}
			}, },

		[6] = {classname="Monster", skill = 
			{
				{type="SkillMonsterSRHAttack", beforeCd = 2.3 ,afterCd=0.5,is_flash = true}
			},
			fsmTable = monsterFsmSRHTable },
		[8] = {classname="MonsterTotem", skill = 
		{
			{type="SkillMonsterTotemAttack",dir = "left"}
		},
		fsmTable = monsterFsmSRHTable },
		[9] = {classname="MonsterTotem", skill = 
		{
			{type="SkillMonsterTotemAttack",dir = "down"}
		},
		fsmTable = monsterFsmSRHTable },
		[10] = {classname="MonsterTotem", skill = 
		{
			{type="SkillMonsterTotemAttack",dir = "right"}
		},
		fsmTable = monsterFsmSRHTable },
		[11] = {classname="MonsterTotem", skill = 
		{
			{type="SkillMonsterTotemAttack",dir = "up"}
		},
		fsmTable = monsterFsmSRHTable },

		[101] = {classname="MonsterBoss", skill = 
			{
				{type="SkillMonsterBossNorAttack",beforeCd = 1}, 
				{type="SkillMonsterBossSuperAttack", beforeCd = 2, isBreak=true}, 
				{type="SkillMonsterBossSuperJetAttack",beforeCd = 2,is_flash = true}
			} },

		[102] = {classname="MonsterPrecious", skill = 
			{
				{type="SkillMonsterPreciousAttack",}
			} },

		[103] = {classname="MonsterBossCrab", skill = 
			{
				{type="SkillMonsterBossCrabNorAttack",},
				{type="SkillMonsterBossCrabSuperSandAttack",},
				{type="SkillMonsterBossCrabSuperRollDownAttack"}
			} },

		[104] = {classname="MonsterBossMummy", skill = 
			{
				{type="SkillMonsterBoss3NorAttack",},
				{type="SkillMonsterBoss3SuperAttack",}
			} },

		[105] = {classname="MonsterBossBaWangFlower", skill = 
			{
				{type="SkillMonsterBossBaWangFlowerNorAttack"},
				{type="SkillMonsterBossBaWangFlowerSuperAttack"}
			} },

		[106] = {classname="MonsterBossFireSnakeKing", skill = 
			{
				{type="SkillMonsterView"},
				{type="SkillMonsterBossFireSnakeKingNorAttack"},
				{type="SkillMonsterBossFireSnakeKingSuperAttack"}
			} },

		[107] = {classname="MonsterBossStoneFigure", skill = 
			{
				{type="SkillMonsterBossStoneFigurerNorAttack",}
			} },
	}--]]
	--local cfg = MonsterTypeObj[data.type]
	data = data or {}

	data.keyType = "monster"

	--data.config = GameConfigCenter.GetMonsterConfig(data.type, data.level)
	data.config = GameConfigCenter.GetMonsterConfig( data)

	-- dump( data.config , "xxx-----------------GetMonsterConfig" )

	data.classname = data.config.classname
	data.poolName = "monster"
	--data.skill = data.config.skill
	--data.fsmTable = data.config.fsmTable
	-- dump(data.config ,"<color=red>一个怪物++++++++++++++++++++++++++++++++++++++</color>")
	local obj = ObjectCenter.Create(data)
	obj.camp = CampEnum.Monster
	GameInfoCenter.AddMonster(obj)
	
	-- dump(data.config.skill , "xxx---------createMonsterSKill")

	--- 创建技能
    if data.config.skill and type(data.config.skill) == "table" then
	    for skill_id , _c_data in pairs(data.config.skill) do
	    	local skill_obj = M.CreateSkillById( skill_id , { object = obj,cd = data.config.hit_space } )
	    end
	end

    -- 创建怪物指示器
    CreateFactory.CreateTargetIndicator({monster_id = obj.id})

	return obj
end

function M.CreateMonsterGroup( datas , roomNo)

	for i,data in ipairs(datas) do

	    for _,m in pairs(data.monsters) do

	        local md = {}
	    	for k,v in pairs(m) do
	    		md[k] = v
	    	end
	    	
	        for i=1,m.num or 1 do

	            md.pos = data.pos or Vector3.zero
	            if data.radius then
	                local x = math.random(-data.radius*100,data.radius*100)*0.01
	                local y = math.random(-data.radius*100,data.radius*100)*0.01
	                md.pos.x = md.pos.x + x
	                md.pos.y = md.pos.y + y
	            end

	            -- if md.type > 100 then
	            --     md.pos = CSPanel.camera3d.transform.position
	            --     md.pos.y = md.pos.y + 6
	            -- end
	            
	            md.roomNo = roomNo
				md.stage = GameInfoCenter.stageData.curLevel
				M.CreateMonster(md)

	        end

	    end

	end

end


------------------------------------------------------创建物件
------------------------------------------------------创建物件
------------------------------------------------------创建物件

function M.CreateGoods( data )

	local GoodsType = 
	{
		[1] = {
			class = "GoodsGem",
			key = "goodsGem",
			prefabName = "BS_baoshi",
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[2] = {
			class = "GoodsSkill",
			prefabName = "wujian_skill_",
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[3] = {
			class = "GoodsBuildings",
			prefabName = {
				shuiguoche="wujian1",
				daocao="wujian2",
				caikuang="wujian3",
				time="time_item",
				map2wujian1="map2wujian1",
			},
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[4] = {
			class = "GoodsGoldBox",
			key = "goodsGoldBox",
			prefabName = "BS_baoXiang",
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[5] = {
			class = "GoodsHero",
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[6] = { 
			class = "GoodsGoldCoin",
			prefabName = "prop_gold_coin",
			parent = CSPanel.map_node,
			isAdsorb = true ,
		},
		[7] = {
			class = "GoodsItem",
			--1增加伤害2增加攻击速度3增加移动速度4恢复血量
			prefabName = {"dj_sd_tb_dj_1","dj_sd_tb_dj_1","dj_sd_tb_dj_3","dj_sd_tb_dj_2"},
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
		[8] = {
			class = "GoodsPower",
			prefabName = "nengliang",
			parent = CSPanel.map_node,
			isAdsorb = true ,
		},
		[9] = {
			class = "GoodsHero",
			prefabName = "hero_egg",
			parent = CSPanel.map_node,
			hero_3in1 = true,
			isAdsorb = false ,
		},
		[10] = {
			class = "GoodsAddSkillTime",
			prefabName = "GoodsAddSkillTime",
			parent = CSPanel.map_node,
			isAdsorb = false ,
		},
	}

	--- 给 d 加一些额外配置
	local d = GoodsType[data.type]
	d.type = data.type
	if d.type == 2 then
		d.prefabName = "wujian_" .. d.prefab_name
	elseif d.type == 3 then
		d.prefabName = d.prefabName[d.buildingsName]
	elseif d.type == 5 then
		d.prefabName = d.prefabName
	elseif d.type == 6 then
		d.prefabName = d.prefabName .. data.level
		d.key = "goldCoin" .. data.level 
	else
		d.prefabName = d.prefabName
	end

	----- 拿取 配置表中 配置，
	if d.key then
		DataInfoToConfig(d)

		NorStageFinalDataToDataInfo(d)

	    NorStageValueFactorToDataInfo(d)
	end

	---- 金币处理 
	if data.type == 6 then
		if type(d.data) == "table" then
			d.jb = math.random(d.data[1],d.data[2])
		elseif type(d.data) == "number" then
			d.jb = d.data
		end
		--dump(d , "xxx-----------createGoods 1")
	end

	--- 把 外部的数据 附加到 配置数据中
	data = basefunc.merge( data , d )

	--dump(data , "xxx-----------createGoods 2")
	
	data.parent = d.parent
	data.hero_3in1 = d.hero_3in1
	

	if not data.isUsePos then
		data.pos = get_grid_pos( MapManager.GetAStar( data.roomNo or GameInfoCenter.GetCurRoomNo() ) , data.pos , true )
	end

	data.classname = d.class
	data.poolName = "goods"
	
	local obj = ObjectCenter.Create(data)
	if d.isAdsorb then
		AdsorbAnim.Create(obj)
	end
	GameInfoCenter.AddGoods(obj)

	return obj
end


--建筑技能配置表
local building_bind_map = {
	building = {
		classname = "Building",
		type = 1,
	},
	spike = {
		classname = "GoodsSpike",
		type = 2,
	},
	saw = {
		classname = "ActiveFloorSaw",
		type = 3,
	},
	rockFall  = {
		classname = "ActiveFloorRockFall",
		type = 4,
	},
	rollWood  = {
		classname = "RollWood",
		type = 5,
	},
	gearRollWood  = {
		classname = "BuildingGeraRollWood",
		type = 6,
	},
	rollWoodContinue  = {
		classname = "RollWoodContinue",
		type = 7,
	},
	gearRollWoodContinue   = {
		classname = "BuildingGeraRollWoodContinue",
		type = 8,
	},
	goldCoin1 = {
		classname = "GoodsGoldCoin",
		type = 9,
		level = 1,
	},
	goldCoin2 ={
		classname = "GoodsGoldCoin",
		type = 9,
		level = 2,
	},
	goldCoin3 ={
		classname = "GoodsGoldCoin",
		type = 9,
		level = 3,
	},
	goodsHero = {
		classname = "GoodsHero",
		type = 10,
	},
	goodsGem = {
		classname = "GoodsGem",
		type = 11,
	},
	goodsGoldBox = {
		classname = "GoodsGoldBox",
		type = 12,
	},
	goodsPower = {
		classname = "GoodsPower",
		type = 13,
	},
	MonsterHatch_1 = {
		classname = "MonsterHatch",
		type = 14,
	},
	MonsterHatch_2 = {
		classname = "MonsterHatch",
		type = 15,
	},
	MonsterHatch_3 = {
		classname = "MonsterHatch",
		type = 16,
	},
	MonsterHatch_4 = {
		classname = "MonsterHatch",
		type = 17,
	},
	MonsterHatch_5 = {
		classname = "MonsterHatch",
		type = 18,
	},
	MonsterHatch_6 = {
		classname = "MonsterHatch",
		type = 19,
	},
	MonsterHatch_7 = {
		classname = "MonsterHatch",
		type = 20,
	},
	MonsterHatch_8 = {
		classname = "MonsterHatch",
		type = 21,
	},
	MonsterHatch_9 = {
		classname = "MonsterHatch",
		type = 22,
	},
	MonsterHatch_10 = {
		classname = "MonsterHatch",
		type = 23,
	},
	MonsterHatch_11 = {
		classname = "MonsterHatch",
		type = 24,
	},
	MonsterHatch_12 = {
		classname = "MonsterHatch",
		type = 25,
	},
	MonsterHatch_13 = {
		classname = "MonsterHatch",
		type = 25,
	},
	MonsterHatch_14 = {
		classname = "MonsterHatch",
		type = 25,
	},
	MonsterHatch_15 = {
		classname = "MonsterHatch",
		type = 25,
	},
	MonsterHatch_101 = {
		classname = "MonsterHatch",
		type = 26,
	},
	MonsterHatch_103 = {
		classname = "MonsterHatch",
		type = 27,
	},
	MonsterHatch_104 = {
		classname = "MonsterHatch",
		type = 28,
	},
	MonsterHatch_106 = {
		classname = "MonsterHatch",
		type = 29,
	},
	MonsterHatch_107 = {
		classname = "MonsterHatch",
		type = 30,
	},
	eggofskill_angel_attack = {
		classname = "EggOfSkill",
		type = 31,
	},
	eggofskill_angel_subsist = {
		classname = "EggOfSkill",
		type = 32,
	},
	eggofskill_angel_weaken = {
		classname = "EggOfSkill",
		type = 33,
	},
	eggofskill_demon_attack = {
		classname = "EggOfSkill",
		type = 34,
	},
	eggofskill_demon_subsist = {
		classname = "EggOfSkill",
		type = 35,
	},
	eggofskill_demon_weaken = {
		classname = "EggOfSkill",
		type = 36,
	},
	ThreeChooseOne = {
		classname = "ThreeChooseOne",
		type = 37,
	},
	MonsterHatch_16 = {
		classname = "MonsterHatch",
		type = 26,
	},
	speedUpBoard = {
		classname = "GoodsSpeedUpBoard",
		type = 2,
	},
	ActiveFloorPeng = {
		classname = "ActiveFloorPeng",
		type = 38,
	},
	ActiveFloorZiDan = {
		classname = "ActiveFloorZiDan",
		type = 39,
	},
	TNT = {
		classname = "GoodsTNT",
		type = 40,
	}
}
------------------------------------------------------绑定建筑
function M.BindingBuilding(building)
	--建筑类型，按建筑名字的前缀来分
	--dump(building,"<color=red>xxxxxx------------create_factory__building</color>")
	---- 普通关卡的数据附加
    NorStageFinalDataToDataInfo(building)

    NorStageValueFactorToDataInfo(building)
	local data = {}
	local _build_type = building.key
	local _data = building_bind_map[_build_type] or {}

	if _data.type == 9 then
		if type(building.data) == "table" then
			data.jb = math.random(building.data[1],building.data[2])
		elseif type(building.data) == "number" then
			data.jb = building.data
		end
	end

	data.building = building
	data.classname = _data.classname or "Building"
	data.skill = _data.skill or {}
	data.poolName = "goods"
	data.type = _data.type or 1
	data.level = _data.level
	data.roomNo = GameInfoCenter.GetStageData().roomNo
	local obj = ObjectCenter.Create(data)
	GameInfoCenter.AddGoods(obj)

	return obj
end

------------------------------------------------------创建蛇头
------------------------------------------------------创建蛇头
------------------------------------------------------创建蛇头
function M.CreateHeroHead( data )
	dump(data,"<color=yellow>创建蛇头？？？？？</color>")
    data = data or {}
    data.heroId = -888

	data.pos = data.pos

	data.config = GameConfigCenter.GetHeroHeadConfig(data.type)
	data.headData = GameConfigCenter.GetHeroHeadDataConfig(data.type)
	data.group = 1
	data.classname = "HeroHead"
	data.poolName = "heroHead"

	print("<color=red>xxx---------------heroHead Data:</color>" , data)

	local obj = ObjectCenter.Create(data)
	obj.camp = CampEnum.HeroHead
	GameInfoCenter.AddHeroHead(obj)
	-- GameInfoCenter.AddHero(obj)
	HeroHeadSkillManager.InitDefaultSkill()
	return obj

end

------------------------------------------------------创建技能
------------------------------------------------------创建技能
------------------------------------------------------创建技能

function M.CreateSkill(data)

	--- 在这之前可以做，已有就刷新的逻辑，暂时先不管
	-- dump( {data.type }, "xxx---------CreateSkill")

	local obj = _G[data.type].New(data)

	obj:Init(data)
	return obj
end

---- 根据id，数据来创建
function M.CreateSkillById( id , data , _change_data )
	-- dump(data , "xxx----------CreateSkillById 1" )
	local skill_config = GameConfigCenter.GetSkillConfig( id , _change_data )
	-- dump(skill_config , "xxx----------CreateSkillById 2" )

	
	--- 用传的参数覆盖 配置
	basefunc.merge( data , skill_config )
	return M.CreateSkill(skill_config)
end

------------------------------------------------------创建 修改器
------------------------------------------------------创建 修改器
------------------------------------------------------创建 修改器


function M.CreateModifier( data )

	local className = data.className

	local obj = _G[className].New(data)

	if not data.object then
		error("xxx-----no object for modifier:" , className)
	end

	obj:Init()

	

	return obj
end

------------------------------------------------------创建 logicObj
------------------------------------------------------创建 logicObj
------------------------------------------------------创建 logicObj

function M.CreateLogicObj(data)
	local className = data.className

	local obj = _G[className].New(data)

	if not data.object then
		error("xxx-----no object for LogicObj:" , className)
	end

	obj:Init()


	return obj
end



------------------------------------------------------创建 地图目标指示器
------------------------------------------------------创建 地图目标指示器
------------------------------------------------------创建 地图目标指示器

function M.CreateTargetIndicator(data)
	
	data = data or {}
	data.classname = "TargetIndicator"
	data.poolName = "TargetIndicator"

	local obj = ObjectCenter.Create(data)
	
	return obj
end


------------------------------------------------------创建 传送门
------------------------------------------------------创建 传送门
------------------------------------------------------创建 传送门

function M.CreatePortal(data)
	
	data = data or {}
	data.classname = "Portal"
	data.poolName = "Portal"

	local obj = ObjectCenter.Create(data)
	
	return obj
end


------------------------------------------------------创建 活动地面元素
------------------------------------------------------创建 活动地面元素
------------------------------------------------------创建 活动地面元素

function M.CreateActiveFloorObject(data)
	local config = {
		ActiveFloorRockFall = "ActiveFloorRockFall",
		ActiveFloorSaw = "ActiveFloorSaw",
	}
	local className = config[data.type]
	data.classname = className
	data.poolName = "ActiveFloor"
	local obj = ObjectCenter.Create(data)
	return obj
end




------------------------------------------------------创建关卡模式对象
------------------------------------------------------创建关卡模式对象
------------------------------------------------------创建关卡模式对象

function M.CreateStageObj(data)

    local curStageConfig = GameConfigCenter.GetStageConfig(data.stage,data.roomNo)

	data.classname = "StageMode" .. curStageConfig.mode
	data.poolName = "StageObj"

	local obj = ObjectCenter.Create(data)
	
	return obj
end


------------------------------------------------------创建关卡连接器对象
------------------------------------------------------创建关卡连接器对象
------------------------------------------------------创建关卡连接器对象

function M.CreateConnector(data)
	
	data.classname = "Connector" .. data.connect_type
	data.poolName = "Connector"

	local obj = ObjectCenter.Create(data)
	
	return obj
end
