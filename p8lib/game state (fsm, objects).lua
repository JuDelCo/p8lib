
--------------------------------
-- game state
--------------------------------

game_state = fsm:extend()

function game_state:new()
	self.super:new()
	self.state_list_draw = {}
end

function game_state:add(name, update_script, draw_script)
	self.super:add(name, update_script)
	self.state_list_draw[name] = draw_script
end

function game_state:update()
	self.state_list[self.state_current](self.state_timer)
end

function game_state:draw()
	self.state_list_draw[self.state_current](self.state_timer)
	
	if self.state_next != self.state_current then
		self.state_current = self.state_next
		self.state_timer = 0
	else
		self.state_timer += 1
	end
end
