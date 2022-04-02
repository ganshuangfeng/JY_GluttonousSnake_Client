return {
	building=
	{
		[1]=
		{
			id = 1,
			name = "箱子",
			assist_attr = 8,
			box_id = 1,
		},
		[2]=
		{
			id = 2,
			name = "灌木",
			assist_attr = 2,
		},
		[3]=
		{
			id = 3,
			name = "罐子",
			assist_attr = 3,
		},
		[4]=
		{
			id = 4,
			name = "水",
		},
		[5]=
		{
			id = 5,
			name = "地刺",
			assist_attr = 4,
		},
		[6]=
		{
			id = 6,
			name = "电锯",
			assist_attr = 5,
			damage = 5,
			moveSpeed = 6,
		},
		[7]=
		{
			id = 7,
			name = "滚木",
			assist_attr = 6,
		},
		[8]=
		{
			id = 8,
			name = "滚木机关",
			assist_attr = 7,
		},
		[9]=
		{
			id = 9,
			name = "祭坛三选一",
			assist_attr = 9,
		},
		[10]=
		{
			id = 10,
			name = "墙",
			assist_attr = 10,
		},
		[11]=
		{
			id = 11,
			name = "喷火炮台",
			assist_attr = 11,
		},
		[12]=
		{
			id = 12,
			name = "发子弹炮台",
			assist_attr = 12,
		},
	},
	building_assist_attr=
	{
		[1]=
		{
			id = 1,
			isPass = 1,
			isDestroy = 1,
			isItem = 1,
		},
		[2]=
		{
			id = 2,
			isDestroy = 1,
			fixNotDestroy = 1,
			destroyType = {"hero_head","hero_zd",},
		},
		[3]=
		{
			id = 3,
			isPass = 1,
			isDestroy = 1,
			isItem = 1,
			destroyType = {"hero_head","hero_zd",},
		},
		[4]=
		{
			id = 4,
			isPass = 1,
			isDestroy = 1,
		},
		[5]=
		{
			id = 5,
			size = {6,1},
			isPass = 1,
			isDestroy = 1,
		},
		[6]=
		{
			id = 6,
			isPass = 1,
			isDestroy = 1,
			fixNotDestroy = 1,
		},
		[7]=
		{
			id = 7,
			isPass = 1,
			isDestroy = 1,
			fixNotDestroy = 1,
			destroyType = {"hero_head","monster",},
		},
		[8]=
		{
			id = 8,
			isPass = 1,
			isDestroy = 1,
			isItem = 1,
			destroyType = {"hero_head","hero_zd",},
		},
		[9]=
		{
			id = 9,
			isPass = 1,
			fixNotDestroy = 1,
		},
		[10]=
		{
			id = 10,
			-- isDestroy = 1,
			-- fixNotDestroy = 1,
		},
		[11]=
		{
			id = 11,
			-- isDestroy = 1,
			-- fixNotDestroy = 1,
		},
		[12]=
		{
			id = 12,
			-- isDestroy = 1,
			-- fixNotDestroy = 1,
		},
	},
	prop=
	{
		[1]=
		{
			id = 1,
			name = "宝箱",
			box_id = 1,
		},
		[2]=
		{
			id = 2,
			name = "能量",
			data = {10,20},
		},
		[3]=
		{
			id = 3,
			name = "小堆金币",
			data = {1,10,},
		},
		[4]=
		{
			id = 4,
			name = "大堆金币",
			data = {11,50,},
		},
		[5]=
		{
			id = 5,
			name = "巨量金币",
			data = {50,99999999},
		},
		[6]=
		{
			id = 6,
			name = "宝石",
		},
		[7]=
		{
			id = 7,
			name = "天使攻击技能蛋",
			camp_id = 1,
			type_id = 1,
		},
		[8]=
		{
			id = 8,
			name = "天使生成技能蛋",
			camp_id = 1,
			type_id = 2,
		},
		[9]=
		{
			id = 9,
			name = "天使削弱技能蛋",
			camp_id = 1,
			type_id = 3,
		},
		[10]=
		{
			id = 10,
			name = "恶魔攻击技能蛋",
			camp_id = 2,
			type_id = 1,
		},
		[11]=
		{
			id = 11,
			name = "恶魔生成技能蛋",
			camp_id = 2,
			type_id = 2,
		},
		[12]=
		{
			id = 12,
			name = "恶魔削弱技能蛋",
			camp_id = 2,
			type_id = 3,
		},
		[13]=
		{
			id = 13,
			name = "英雄蛋",
			data = 5,
		},
	},
}