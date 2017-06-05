
--------------------------------
-- input
--------------------------------

-- todo: multiplayer/multipad support

input = object:extend()

function input:new()
	self.pad_left_counter = 0
	self.pad_right_counter = 0
	self.pad_up_counter = 0
	self.pad_down_counter = 0
	self.pad_z_counter = 0
	self.pad_x_counter = 0
	
	poke(0x5f2d, 1)
	
	self.mouse_left_counter = 0
	self.mouse_middle_counter = 0
	self.mouse_right_counter = 0
	self.mouse_last_x_pos = stat(32)
	self.mouse_last_y_pos = stat(33)
	self.mouse_rest_counter = 0
end

function input:update()
	if btn(0) then self.pad_left_counter += 1
	elseif self.pad_left_counter > 0 then self.pad_left_counter = -1
	else self.pad_left_counter = 0 end
	
	if btn(1) then self.pad_right_counter += 1
	elseif self.pad_right_counter > 0 then self.pad_right_counter = -1
	else self.pad_right_counter = 0 end
	
	if btn(2) then self.pad_up_counter += 1
	elseif self.pad_up_counter > 0 then self.pad_up_counter = -1
	else self.pad_up_counter = 0 end
	
	if btn(3) then self.pad_down_counter += 1
	elseif self.pad_down_counter > 0 then self.pad_down_counter = -1
	else self.pad_down_counter = 0 end

	if btn(4) then self.pad_z_counter += 1
	elseif self.pad_z_counter > 0 then self.pad_z_counter = -1
	else self.pad_z_counter = 0 end
	
	if btn(5) then self.pad_x_counter += 1
	elseif self.pad_x_counter > 0 then self.pad_x_counter = -1
	else self.pad_x_counter = 0 end

	if band(shr(stat(34), 0), 1) == 1 then self.mouse_left_counter += 1
	elseif self.mouse_left_counter > 0 then self.mouse_left_counter = -1
	else self.mouse_left_counter = 0 end
	
	if band(shr(stat(34), 2), 1) == 1 then self.mouse_middle_counter += 1
	elseif self.mouse_middle_counter > 0 then self.mouse_middle_counter = -1
	else self.mouse_middle_counter = 0 end
	
	if band(shr(stat(34), 1), 1) == 1 then self.mouse_right_counter += 1
	elseif self.mouse_right_counter > 0 then self.mouse_right_counter = -1
	else self.mouse_right_counter = 0 end
	
	if self.mouse_last_x_pos != stat(32) or self.mouse_last_y_pos != stat(33) or
		self:mouse_left() > 0 or self:mouse_middle() > 0 or self:mouse_right() > 0 then
		self.mouse_rest_counter = 0
	else
		self.mouse_rest_counter += 1
	end
	
	self.mouse_last_x_pos = stat(32)
	self.mouse_last_y_pos = stat(33)
end

function input:pad_left()
	return self.pad_left_counter
end

function input:pad_right()
	return self.pad_right_counter
end

function input:pad_up()
	return self.pad_up_counter
end

function input:pad_down()
	return self.pad_down_counter
end

function input:pad_z()
	return self.pad_z_counter
end

function input:pad_x()
	return self.pad_x_counter
end

function input:mouse_x()
	return stat(32)
end

function input:mouse_y()
	return stat(33)
end

function input:mouse_left()
	return self.mouse_left_counter
end

function input:mouse_middle()
	return self.mouse_middle_counter
end

function input:mouse_right()
	return self.mouse_right_counter
end

function input:mouse_is_resting()
	return self.mouse_rest_counter
end
