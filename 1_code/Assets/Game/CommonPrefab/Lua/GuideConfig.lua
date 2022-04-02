-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
GuideConfig = {
	[1] = { stepList = { { step = {6}, cfPos = "three" }, }, next = 2, isSkip = 0 },
	[2] = { stepList = { { step = { 1, 2 ,3,7,4,5}, cfPos = "hall" }, }, next = -1, isSkip = 0 },
}

--[[ Style
button:将按钮显示在最高层，点击按钮执行按钮点击事件和进入下一步
GuideStyle1:高亮组件可不是按钮，点击进入下一步（即使有按钮也不触发按钮的点击）
GuideStyle2:不改变层级，高亮区域由配置决定
unforce:非强制引导，无高亮和非高亮之分，满足进入条件和在当前大步骤时可进
--]]


GuideStepConfig = {
	[1] = {
		id = 1,
		type="button",
		name="hall_bottom_2",
		isHideBG=false, 
		auto=true, 
		isSave=false,
		desc="进入<color=red>工厂</color>\n开发新型炮台",
		descPos={x=-210, y=138, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
		descRot = {x = 0,y = 0,z = 180}
	},
    [2] = {
		id = 2,
		type="button",
		name="turret_item_19",
		isHideBG=false, 
		auto=false, 
		isSave=false,
		desc="点击<color=red>解锁</color>新型炮台",
		descPos={x=261, y=-197, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
	},
	[3] = {
		id = 3,
		type="button",
		name="@unlock_btn",
		isHideBG=false, 
		auto=true, 
		isSave=true,
		desc="",
		descPos={x=40, y=-154, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
	},
	[4] = {
		id = 4,
		type="button",
		name="hall_bottom_3",
		isHideBG=false, 
		auto=true, 
		isSave=false,
		desc="",
		descPos={x=336, y=-169, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
	},
	[5] = {
		id = 5,
		type="button",
		name="@enter_game_btn",
		isHideBG=false, 
		auto=true, 
		isSave=false,
		desc="再次前往遗迹寻找更多<color=red>炮台</color>",
		descPos={x=364, y=-131, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
	},
	[6] = {
		id = 6,
		type="button",
		name="hero_threechose_one_2",
		isHideBG=false, 
		auto=true, 
		isSave=true,
		desc="选择队伍中<color=red>相同</color>炮台\n可触发羁绊<color=red>增强</color>效果",
		descPos={x=283, y=-404, z=0},
		headPos={x=0, y=0},
		uiName="three",
		isHideSZ = false,
	},
	[7] = {
		id = 7,
		type="button",
		name="@hero_show_close_btn",
		isHideBG=false, 
		auto=true, 
		isSave=false,
		desc="",
		descPos={x=40, y=-154, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		isHideSZ = false,
	},
}