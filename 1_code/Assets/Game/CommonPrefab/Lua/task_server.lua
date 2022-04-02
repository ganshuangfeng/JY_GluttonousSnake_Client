return {
	task=
	{
		[1]=
		{
			id = 1,
			enable = 1,
			name = "通过第一关",
			own_type = "normal",
			task_enum = "common",
			process_id = 1,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[2]=
		{
			id = 2,
			enable = 1,
			name = "击杀小怪总数",
			own_type = "normal",
			task_enum = "common",
			process_id = 2,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[3]=
		{
			id = 3,
			enable = 1,
			name = "击杀特定小怪总数",
			own_type = "normal",
			task_enum = "common",
			process_id = 3,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[4]=
		{
			id = 4,
			enable = 1,
			name = "选择特定英雄",
			own_type = "normal",
			task_enum = "common",
			process_id = 4,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[5]=
		{
			id = 5,
			enable = 1,
			name = "解锁英雄次数",
			own_type = "normal",
			task_enum = "common",
			process_id = 5,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[6]=
		{
			id = 6,
			enable = 1,
			name = "升级英雄次数",
			own_type = "normal",
			task_enum = "common",
			process_id = 6,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[7]=
		{
			id = 7,
			enable = 1,
			name = "升级头部次数",
			own_type = "normal",
			task_enum = "common",
			process_id = 7,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
		[8]=
		{
			id = 8,
			enable = 1,
			name = "累积登陆天数",
			own_type = "normal",
			task_enum = "common",
			process_id = 8,
			is_reset = 1,
			reset_delay = 1,
			start_valid_time = 1634227200,
			end_valid_time = 1636905600,
		},
	},
	process_data=
	{
		[1]=
		{
			id = 1,
			process_id = 1,
			source_id = 1,
			process = {10,20},
			awards = 1,
			get_award_type = "nor",
		},
		[2]=
		{
			id = 2,
			process_id = 2,
			source_id = 2,
			process = 10,
			awards = 2,
			get_award_type = "nor",
		},
		[3]=
		{
			id = 3,
			process_id = 3,
			source_id = 3,
			process = 10,
			awards = 3,
			get_award_type = "nor",
		},
		[4]=
		{
			id = 4,
			process_id = 4,
			source_id = 4,
			process = 10,
			awards = 4,
			get_award_type = "nor",
		},
		[5]=
		{
			id = 5,
			process_id = 5,
			source_id = 5,
			process = 10,
			awards = 5,
			get_award_type = "nor",
		},
		[6]=
		{
			id = 6,
			process_id = 6,
			source_id = 6,
			process = 10,
			awards = 6,
			get_award_type = "nor",
		},
		[7]=
		{
			id = 7,
			process_id = 7,
			source_id = 7,
			process = 10,
			awards = 7,
			get_award_type = "nor",
		},
		[8]=
		{
			id = 8,
			process_id = 8,
			source_id = 8,
			process = 10,
			awards = 8,
			get_award_type = "nor",
		},
	},
	source=
	{
		[1]=
		{
			id = 1,
			source_id = 1,
			source_type = "pass_stage",
			condition_id = 1,
		},
		[2]=
		{
			id = 2,
			source_id = 2,
			source_type = "kill_monster",
		},
		[3]=
		{
			id = 3,
			source_id = 3,
			source_type = "kill_monster",
			condition_id = 3,
		},
		[4]=
		{
			id = 4,
			source_id = 4,
			source_type = "select_hero",
			condition_id = 4,
		},
		[5]=
		{
			id = 5,
			source_id = 5,
			source_type = "unlock_hero",
			condition_id = 5,
		},
		[6]=
		{
			id = 6,
			source_id = 6,
			source_type = "upgrade_hero",
			condition_id = 6,
		},
		[7]=
		{
			id = 7,
			source_id = 7,
			source_type = "upgrade_head",
		},
		[8]=
		{
			id = 8,
			source_id = 8,
			source_type = "login_count",
		},
	},
	condition=
	{
		[1]=
		{
			id = 1,
			condition_id = 1,
			condition_name = "stage_num",
			condition_value = 1,
			judge_type = 2,
		},
		[2]=
		{
			id = 2,
			condition_id = 3,
			condition_name = "monster_id",
			condition_value = 2,
			judge_type = 2,
		},
		[3]=
		{
			id = 3,
			condition_id = 4,
			condition_name = "hero_id",
			condition_value = 2,
			judge_type = 2,
		},
		[4]=
		{
			id = 4,
			condition_id = 5,
			condition_name = "hero_id",
			condition_value = 1,
			judge_type = 2,
		},
		[5]=
		{
			id = 5,
			condition_id = 6,
			condition_name = "hero_id",
			condition_value = 4,
			judge_type = 2,
		},
	},
	award_data=
	{
		[1]=
		{
			id = 1,
			award_id = 1,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[2]=
		{
			id = 2,
			award_id = 2,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[3]=
		{
			id = 3,
			award_id = 3,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[4]=
		{
			id = 4,
			award_id = 4,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[5]=
		{
			id = 5,
			award_id = 5,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[6]=
		{
			id = 6,
			award_id = 6,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[7]=
		{
			id = 7,
			award_id = 7,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
		[8]=
		{
			id = 8,
			award_id = 8,
			asset_type = "prop_jin_bi",
			asset_count = 10,
		},
	},
}