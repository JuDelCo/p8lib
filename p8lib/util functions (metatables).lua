
--------------------------------
-- util functions
--------------------------------

function cpu_usage()
	return flr(stat(1) * 100)
end

function memory_usage()
	return flr((stat(0) / 1024) * 100)
end

function iscallable(x)
	if type(x) == "function" then
		return true
	end

	local mt = getmetatable(x)

	return (mt and mt.__call ~= nil)
end

function contains(str, needle)
	local limit = #str - #needle + 1
	local found = false
	
	for i = 0, limit, 1 do
		found = true

		for j = 0, #needle, 1 do
			if sub(str, i+j, 1) != sub(needle, j, 1) then
				found = false
			end
		end
		
		if found then
			return true
		end
	end

	return false
end

function approach(a, b, amount)
	if a < b then
		return min(a + amount, b)
	else
    	return max(a - amount, b)
	end
end

function lerp(a, b, percent)
	return a + percent * (b - a)
end

function between(value, x, y)
	return (value >= x) and (value <= y)
end

function clamp(value, x, y)
	return max(min(value, y), x)
end

function overlaps(x1, y1, w1, h1, x2, y2, w2, h2)
	local x_distance = x1 - x2
	local x_size = (w1 + w2) * 0.5

	if abs(x_distance) >= x_size then
		return false
	end

	local y_distance = y1 - y2
	local y_size = (h1 + h2) * 0.5

	if abs(y_distance) >= y_size then
		return false
	end

	return true
end

function obj_overlaps(obj_a, obj_b)
	return overlaps(
		obj_a.x, obj_a.y, obj_a.w, obj_a.h,
		obj_b.x, obj_b.y, obj_b.w, obj_b.h
	)
end

function round(value)
	return flr(value + 0.5)
end

function print_outline(text, x, y, c1, c2)
	print(text, x + 1, y - 1, c1)
	print(text, x + 1, y, c1)
	print(text, x + 1, y + 1, c1)
	print(text, x, y + 1, c1)
	print(text, x - 1, y + 1, c1)
	print(text, x - 1, y, c1)
	print(text, x - 1, y - 1, c1)
	print(text, x, y - 1, c1)
	print(text, x, y, c2)
end

function print_shadow(text, x, y, c1, c2)
	print(text, x, y + 1, c1)
	print(text, x, y, c2)
end

function num(value)
	return value and 1 or 0
end

function lpad(str, len, char)
	if char == nil then
		char = " "
	end

	str = str .. ""
	local padding = ""

	for i = 1, (len - #str) do
		padding = padding .. char
	end
	
	return padding .. str
end

function music_play(n)
	if _.music_active != n then
		music_stop()
		
		if _.settings.music == 1 then
			music(n)
			_.music_active = n
		end
	end
end

function music_stop()
	music(-1, 100)
	_.music_active = -1
end

function sfx_play(n)
	if _.settings.sfx == 1 then
		sfx(n)
	end
end
