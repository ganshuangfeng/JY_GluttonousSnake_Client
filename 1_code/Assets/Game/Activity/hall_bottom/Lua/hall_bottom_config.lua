return {
	{
		id = 1,
		is_show = true,
		is_lock = true,
		icon = "mx_img_mx05",
		name = "挑 战",
		order = 1,
	},
	{
		
		id = 2,
		is_show = true,
		is_lock = false,
		icon = "mx_img_mx02",
		name = "工 厂",
		goto_ui = {"factory", "panel"},
		order = 2,
	},
	{
		
		id = 3,
		is_show = true,
		is_lock = false,
		icon = "mx_img_mx01",
		name = "冒 险",
		goto_ui = {"adventure", "panel"},
		order = 3,
	},
	{
		id = 4,
		is_show = true,
		is_lock = false,
		icon = "mx_img_mx03",
		name = "科 技",
		goto_ui = {"technology", "panel"},
		order = 4,
		condi_key = "technology"
	},
	{
		id = 5,
		is_show = true,
		is_lock = false,
		icon = "mx_img_mx04",
		name = "商 城",
		goto_ui = {"shop", "panel"},
		order = 5,
		condi_key = "shop",
	},
}