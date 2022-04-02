-- 创建时间:2021-09-29

GameSetCenter = {}

-- 玩家操作模式
GameSetCenter.GetPlayerMO = function ()
	return PlayerPrefs.GetInt("PlayerCzms_" .. MainModel.UserInfo.user_id, 0)
end
GameSetCenter.SetPlayerMO = function (mo)
	PlayerPrefs.SetInt("PlayerCzms_" .. MainModel.UserInfo.user_id, mo)
	Event.Brocast("global_player_mo_change")
end
