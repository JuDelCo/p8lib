
--------------------------------
-- tick manager
--------------------------------

tick_manager = object:extend()
tick_event = object:extend()

function tick_event:new(parent, fn, delay, recur)
	self.parent = parent
	self.delay = delay
	self.timer = delay
	self.fn = fn
	self.recur = recur
end

function tick_event:after(fn, delay)
	assert(self.recur == false, "cannot chain a recurring event")

	-- chain tick_event
	local oldfn = self.fn
	local e = tick_event(self.parent, fn, delay, false)
	self.fn = function()
		oldfn()
		self.parent:add(e)
	end

	return e
end

function tick_event:stop()
	tick_manager.remove(self.parent, self)
end

function tick_manager:add(e)
	self[e] = true
	self[#self + 1] = e

	return e
end

function tick_manager:event(fn, delay, recur)
	delay = delay + 0

	assert(iscallable(fn), "expected 'fn' to be callable")
	assert(type(delay) == "number", "expected 'delay' to be a number")
	assert(delay >= 0, "expected 'delay' of zero or greater")

	return self:add(tick_event(self, fn, delay, recur))
end

function tick_manager:update()
	for i = #self, 1, -1 do
		local e = self[i]
		e.timer = e.timer - 1

		if e.timer <= 0 then
			if e.recur then
				e.timer = e.timer + e.delay
			else
				self:remove(i) 
			end

			e.fn()
		end
	end
end

function tick_manager:delay(fn, delay)
	return self:event(fn, delay, false)
end

function tick_manager:recur(fn, delay)
	return self:event(fn, delay, true)
end

function tick_manager:remove(e)
	if type(e) == "number" then
		local idx = e
		e = self[idx]
		self[e] = nil
		self[idx] = self[#self]
		self[#self] = nil

		return e
	end

	self[e] = false

	for i = 1, #self do
		if self[i] == e then
			return self:remove(i)
		end
	end
end
