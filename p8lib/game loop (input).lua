--------------------------------
-- game loop
--------------------------------

_ = {}

function _init()
	_.input = input()
	_.state = implement_your_game() -- todo: inherited from "game_state" class
end

function _update60()
	_.input:update()
	_.state:update()
end

function _draw()
	_.state:draw()
end
