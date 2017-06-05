
--------------------------------
-- objects
--------------------------------

object = {}
object.__index = object

function object:new()
	-- prototype
end

function object:extend()
	local new_class = {}

	for k, v in pairs(self) do
		if contains(k, "__") then
			new_class[k] = v
		end
	end

	new_class.__index = new_class
	new_class.super = self
	setmetatable(new_class, self)

	return new_class
end

function object:implement(...)
	for _, class in pairs({...}) do
		for k, v in pairs(class) do
			if self[k] == nil and type(v) == "function" then
				self[k] = v
			end
		end
	end
end

function object:is(t)
	local mt = getmetatable(self)

	while mt do
		if mt == t then
			return true
		end

		mt = getmetatable(mt)
	end

	return false
end

function object:__tostring()
	return "object"
end

function object:__call(...)
	local obj = setmetatable({}, self)
	obj:new(...)

	return obj
end
