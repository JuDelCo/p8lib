
--------------------------------
-- physics
--------------------------------

physics_object = object:extend()

function physics_object:new()
	self.x = 0
	self.y = 0
	self.x_remainder = 0
	self.y_remainder = 0

	self.w = 2
	self.h = 2
	self.half_w = 1
	self.half_h = 1
end

function physics_object:left()
	return self.x - flr(self.half_w)
end

function physics_object:right()
	return self.x + flr(self.half_w) - ((self.w + 1) % 2)
end

function physics_object:top()
	return self.y - flr(self.half_h)
end

function physics_object:bottom()
	return self.y + flr(self.half_h) - ((self.h + 1) % 2)
end

function physics_object:draw(color)
	rectfill(self:left(), self:top(), self:right(), self:bottom(), color)
end

actor = physics_object:extend()
actors = {}

function actor:new(x, y, w, h)
	self.super:new()

	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.half_w = w / 2
	self.half_h = h / 2
	
	add(actors, self)
end

function actor:move_x(amount, on_collide)
	self.x_remainder += amount
	local move = round(self.x_remainder)

	if move != 0 then
		self.x_remainder -= move
		local sign = sgn(move)

		while move != 0 do
			if not self:collides(sign , 0) then
				self.x += sign
			else
				if on_collide != nil then
					on_collide()
				end

				break
			end
			
			move -= sign
		end
	end
end

function actor:move_y(amount, on_collide)
	self.y_remainder += amount
	local move = round(self.y_remainder)

	if move != 0 then
		self.y_remainder -= move
		local sign = sgn(move)

		while move != 0 do
			if not self:collides(0, sign) then
				self.y += sign
			else
				if on_collide != nil then
					on_collide()
				end

				break
			end
			
			move -= sign
		end
	end
end

function actor:is_riding(solid)
	-- virtual
end

function actor:squish()
	-- virtual
end

function actor:collides(add_x, add_y)
	-- todo: spatial hashing
	for solid in all(solids) do
		if solid.collidable and overlaps(
			(self.x + add_x), (self.y + add_y), self.w, self.h,
			solid.x, solid.y, solid.w, solid.h
		) then
			return true
		end
	end

	if  fget(mget((add_x + self:left()) / 8,  (add_y + self:top()) / 8), 0) or
		fget(mget((add_x + self.x) / 8,       (add_y + self:top()) / 8), 0) or
		fget(mget((add_x + self:right()) / 8, (add_y + self:top()) / 8), 0) or
		fget(mget((add_x + self:left()) / 8,  (add_y + self.y) / 8), 0) or
		fget(mget((add_x + self:right()) / 8, (add_y + self.y) / 8), 0) or
		fget(mget((add_x + self:left()) / 8,  (add_y + self:bottom()) / 8), 0) or
		fget(mget((add_x + self.x) / 8,       (add_y + self:bottom()) / 8), 0) or
		fget(mget((add_x + self:right()) / 8, (add_y + self:bottom()) / 8), 0) then
		return true
	end
	
	if add_y > 0 then
		if  fget(mget((add_x + self.x) / 8, (add_y + self:bottom()) / 8), 1) and not
			fget(mget((add_x + self.x) / 8, (add_y + self:bottom() - 1) / 8), 1) then
			return true
		end
	end

	return false
end

function actor:destroy()
	del(actors, self)
end

solid = physics_object:extend()
solids = {}

function solid:new(x, y, w, h)
	self.super:new()

	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.half_w = w / 2
	self.half_h = h / 2
	
	self.collidable = true
	
	add(solids, self)
end

function solid:move(amount_x, amount_y)
	self.x_remainder += amount_x
	self.y_remainder += amount_y
	local move_x = round(self.x_remainder)
	local move_y = round(self.y_remainder)

	if move_x != 0 or move_y != 0 then
		local riding = self:get_riding_actors()
		self.collidable = false

		if move_x != 0 then
			self.x_remainder -= move_x
			self.x += move_x

			-- todo: spatial hashing
			for actor in all(actors) do
				if obj_overlaps(self, actor) then
					local distance = self:right() - actor:left()
					if move_x < 0 then
						distance = self:left() - actor:right()
					end

					actor:move_x(distance + sgn(move_x), function() actor:squish() end)
				else
					for r in all(riding) do
						if r == actor then
							actor:move_x(move_x, nil)
							break
						end
					end
				end
			end
		end

		if move_y != 0 then
			self.y_remainder -= move_y
			self.y += move_y

			-- todo: spatial hashing
			for actor in all(actors) do
				if obj_overlaps(self, actor) then
					local distance = self:bottom() - actor:top()
					if move_y < 0 then
						distance = self:top() - actor:bottom()
					end

					actor:move_y(distance + sgn(move_y), function() actor:squish() end)
				else
					for r in all(riding) do
						if r == actor then
							actor:move_y(move_y, nil)
							break
						end
					end
				end
			end
		end

		self.collidable = true
	end
end

function solid:get_riding_actors()
	local riding = {}

	-- todo: spatial hashing
	for actor in all(actors) do
		if actor:is_riding(self) then
			add(riding, actor)
		end
	end

	return riding
end

function solid:destroy()
	del(solids, self)
end
