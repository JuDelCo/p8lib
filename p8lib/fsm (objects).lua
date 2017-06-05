
--------------------------------
-- fsm
--------------------------------

fsm = object:extend()

function fsm:new()
	self.state_current = ""
	self.state_next = ""
	self.state_timer = 0
	self.state_list = {}
	self.state_stack = {}
end

function fsm:add(name, script)
	self.state_list[name] = script
end

function fsm:init(name)
	self.state_current = name
	self.state_next = name
	self.state_stack[0] = name
end

function fsm:switch(name, push)
	self.state_next = name

	if push == true then
		self.state_stack[count(self.state_stack)] = self.state_next
	end
end

function fsm:switch_previous()
	del(self.state_stack, count(self.state_stack) - 1)
	self:switch(self.state_stack[count(self.state_stack) - 1], false)
end

function fsm:update()
	self.state_list[self.state_current](self.state_timer)

	if self.state_next != self.state_current then
		self.state_current = self.state_next
		self.state_timer = 0
	else
		self.state_timer += 1
	end
end
