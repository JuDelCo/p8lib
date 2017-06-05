
--------------------------------
-- task manager
--------------------------------

task_manager = object:extend()
task_obj = object:extend()
task_callback = object:extend()

function task_callback:new()
	self.ready = false
end

function task_callback:__call(...)
	self.args = {...}
	self.ready = true
end

function task_obj:new(fn, parent)
	self.routine = cocreate(fn)
	self.parent = parent
	self.pausecount = 0
end

function task_obj:pause()
	self.pausecount = self.pausecount + 1
end

function task_obj:resume()
	assert(self.pausecount > 0, "used resume() in a not paused task")
	self.pausecount = self.pausecount - 1
end

function task_obj:stop()
	task_manager.remove(self.parent, self)
end

function task_manager:update()
	if #self == 0 then
		return
	end

	for i = #self, 1, -1 do 
		local task = self[i]

		if task.wait then
			if type(task.wait) == "number" then
				task.wait = task.wait - 1

				if task.wait <= 0 then
					task.wait = nil
				end
			elseif type(task.wait) == "table" then
				if task.wait.ready then
					task.wait = nil
				end
			end
		end

		if not task.wait and task.pausecount == 0 then
			task_manager.current = task

			if costatus(task.routine) != "dead" then
				coresume(task.routine)
			else
				task_manager:remove(i)
			end
		end
	end

	task_manager.current = nil
end

function task_manager:add(fn)
	local task = task_obj(fn, self)
	self[#self + 1] = task

	return task
end

function task_manager:remove(t)
	if type(t) == "number" then
		self[t] = self[#self]
		self[#self] = nil

		return
	end

	for i = 1, #self do
		if self[i] == t then
			return self:remove(i)
		end
	end
end

function task_manager.wait(x, y)
	x = getmetatable(x) == task_manager and y or x

	local c = task_manager.current
	assert(c, "wait() called from outside a coroutine")

	if type(x) == "number" then
		c.wait = x

		if c.wait <= 0 then
			return
		end
	else
		assert(x == nil or x:is(task_callback), "wait() expected number, task_callback or nil as argument")
		c.wait = x
	end

	yield()

	if type(x) == "table" then
		local function create_arg(l, ...)
			if l == 0 then
				return ...
			else
				return create_arg(l - 1, x.args[l], ...)
			end
		end

		return create_arg(#x.args)
	end
end

function task_manager.callback()
	return task_callback()
end
