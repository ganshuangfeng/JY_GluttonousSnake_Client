package.loaded["Game.game_StageEditor.Lua.StageEditorModel"] = nil
require "Game.game_StageEditor.Lua.StageEditorModel"

package.loaded["Game.game_StageEditor.Lua.StageEditorPanel"] = nil
require "Game.game_StageEditor.Lua.StageEditorPanel"

StageEditorLogic = {}
local M = StageEditorLogic
local this -- 单例
local MModel
local MView

-- 是不是小的过渡界面
function M.Init()
    this = M

	MModel = StageEditorModel.Init()
	MView = StageEditorPanel.Create()
end

function M.Exit()
	if this then
		MView:Exit()
		MModel.Exit()
		this = nil
	end
end

return M