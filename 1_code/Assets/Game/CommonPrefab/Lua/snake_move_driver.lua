--- 蛇形移动的 driver

local basefunc = require "Game/Common/basefunc"

snake_move_driver = basefunc.class( BoidsMoveDriver )
local C = snake_move_driver

function C:Ctor( _game_obj , _data )
	snake_move_driver.super.Ctor( self , _game_obj , _data )


	--- 添加一个力
	self:set_force( "test" , Vector2.New( 100 , 100 ) )

end

function C:Update(_dt)
	snake_move_driver.super.Update( self , _dt)

	
end


return C