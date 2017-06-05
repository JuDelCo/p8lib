
--------------------------------
-- easing manager
--------------------------------

easing_manager = object:extend()
easing = object:extend()

-- todo: test easings (some fails)
easings = {
	linear       = function(p) return p end,
	quadin       = function(p) return p * p end,
	cubicin      = function(p) return p * p * p end,
	quartin      = function(p) return p * p * p * p end,
	quintin      = function(p) return p * p * p * p * p end,
	expoin       = function(p) return 2 ^ (10 * (p - 1)) end,
	sinein       = function(p) return -cos(p * .5) + 1 end,
	circin       = function(p) return -(sqrt(1 - (p * p)) - 1) end,
	backin       = function(p) return p * p * (2.7 * p - 1.7) end,
	elasticin    = function(p) return -(2^(10 * (p - 1)) * sin((p - 1.075) / .3)) end,
	quadout      = function(p) p = 1 - p return 1 - (p * p) end,
	cubicout     = function(p) p = 1 - p return 1 - (p * p * p) end,
	quartout     = function(p) p = 1 - p return 1 - (p * p * p * p) end,
	quintout     = function(p) p = 1 - p return 1 - (p * p * p * p * p) end,
	expoout      = function(p) p = 1 - p return 1 - (2 ^ (10 * (p - 1))) end,
	sineout      = function(p) p = 1 - p return 1 - (-cos(p * .5) + 1) end,
	circout      = function(p) p = 1 - p return 1 - (-(sqrt(1 - (p * p)) - 1)) end,
	backout      = function(p) p = 1 - p return 1 - (p * p * (2.7 * p - 1.7)) end,
	elasticout   = function(p) p = 1 - p return 1 - (-(2^(10 * (p - 1)) * sin((p - 1.075) / .3))) end,
	quadinout    = function(p) p = p * 2 if p < 1 then return .5 * (p * p) else p = 2 - p return .5 * (1 - (p * p)) + .5 end end,
	cubicinout   = function(p) p = p * 2 if p < 1 then return .5 * (p * p * p) else p = 2 - p return .5 * (1 - (p * p * p)) + .5 end end,
	quartinout   = function(p) p = p * 2 if p < 1 then return .5 * (p * p * p * p) else p = 2 - p return .5 * (1 - (p * p * p * p)) + .5 end end,
	quintinout   = function(p) p = p * 2 if p < 1 then return .5 * (p * p * p * p * p) else p = 2 - p return .5 * (1 - (p * p * p * p * p)) + .5 end end,
	expoinout    = function(p) p = p * 2 if p < 1 then return .5 * (2 ^ (10 * (p - 1))) else p = 2 - p return .5 * (1 - (2 ^ (10 * (p - 1)))) + .5 end end,
	sineinout    = function(p) p = p * 2 if p < 1 then return .5 * (-cos(p * .5) + 1) else p = 2 - p return .5 * (1 - (-cos(p * .5) + 1)) + .5 end end,
	circinout    = function(p) p = p * 2 if p < 1 then return .5 * (-(sqrt(1 - (p * p)) - 1)) else p = 2 - p return .5 * (1 - (-(sqrt(1 - (p * p)) - 1))) + .5 end end,
	backinout    = function(p) p = p * 2 if p < 1 then return .5 * (p * p * (2.7 * p - 1.7)) else p = 2 - p return .5 * (1 - (p * p * (2.7 * p - 1.7))) + .5 end end,
	elasticinout = function(p) p = p * 2 if p < 1 then return .5 * (-(2^(10 * (p - 1)) * sin((p - 1.075) / .3))) else p = 2 - p return .5 * (1 - (-(2^(10 * (p - 1)) * sin((p - 1.075) / .3)))) + .5 end end,
}

function easing:new(obj, time, vars)
	self.obj = obj
	self.rate = time > 0 and 1 / time or 0
	self.progress = time > 0 and 0 or 1
	self._delay = 0
	self._ease = "quadout"
	self.vars = {}

	for k, v in pairs(vars) do
		assert(type(v) == "number", "bad value for key, expected number")
		self.vars[k] = v
	end
end

function easing:ease(x)
	assert(easings[x] != nil, "bad easing type")
	self._ease = x

	return self
end

function easing:delay(x)
	assert(type(x) == "number", "bad delay time, expected number")
	self._delay = x
	
	return self
end

function easing:onstart(x)
	assert(iscallable(x), "expected function or callable")
	local old = self._onstart
	self._onstart = old and function() old() x() end or x

	return self
end

function easing:onupdate(x)
	assert(iscallable(x), "expected function or callable")
	local old = self._onupdate
	self._onupdate = old and function() old() x() end or x

	return self
end

function easing:oncomplete(x)
	assert(iscallable(x), "expected function or callable")
	local old = self._oncomplete
	self._oncomplete = old and function() old() x() end or x

	return self
end

function easing:init()
	for k, v in pairs(self.vars) do
		local x = self.obj[k]
		assert(type(x) == "number", "bad value on object key, expected number")

		self.vars[k] = { start = x, diff = v - x }
	end

	self.inited = true
end

function easing:after(...)
	local t

	if #{...} == 2 then
		t = easing(self.obj, ...)
	else
		t = easing(...)
	end

	t.parent = self.parent
	self:oncomplete(function() easing_manager.add(self.parent, t) end)

	return t
end

function easing:stop()
	easing_manager.remove(self.parent, self)
end

function easing_manager:new()
	self.tweens = {}
end

function easing_manager:clear(obj, vars)
	for t in pairs(self[obj]) do
		if t.inited then
			for k in pairs(vars) do
				t.vars[k] = nil
			end
		end
	end
end

function easing_manager:add(easing)
	local obj = easing.obj
	self[obj] = self[obj] or {}
	self[obj][easing] = true

	self[#self + 1] = easing
	easing.parent = self

	return easing
end

function easing_manager:to(obj, time, vars)
	return easing_manager:add(easing(obj, time, vars))
end

function easing_manager:update()
	for i = #self, 1, -1 do
		local t = self[i]

		if t._delay > 0 then
			t._delay = t._delay - 1
		else
			if not t.inited then
				easing_manager:clear(t.obj, t.vars)
				t:init()
			end

			if t._onstart then
				t._onstart()
				t._onstart = nil
			end

			t.progress = t.progress + t.rate
			local p = t.progress
			local x = p >= 1 and 1 or easings[t._ease](p)

			for k, v in pairs(t.vars) do
				t.obj[k] = v.start + x * v.diff
			end

			if t._onupdate then
				t._onupdate()
			end

			if p >= 1 then
				easing_manager:remove(i)

				if t._oncomplete then
					t._oncomplete()
				end
			end
		end
	end
end

function easing_manager:remove(x)
	if type(x) == "number" then
		local obj = self[x].obj
		self[obj][self[x]] = nil

		local is_empty = true

		for k, v in pairs(self[obj]) do
			is_empty = false
			break
		end

		if is_empty then
			self[obj] = nil
		end

		self[x] = self[#self]
		self[#self] = nil
		
		return self[x]
	end

	for i = 1, #self do
		if self[i] == x then
			return self:remove(i)
		end
	end
end
