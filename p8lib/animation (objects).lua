
--------------------------------
-- animation
--------------------------------

animation = object:extend()

function animation:new()
	self.animations = {}
	self.anim_current = ""
	self.anim_current_index = 1
	self.anim_timer = 0
	self.current_frame = 0
end

function animation:add(name, frames, speed, loop)
	self.animations[name] = {}
	self.animations[name].frames = frames
	self.animations[name].speed = speed
	self.animations[name].loop = loop
end

function animation:play(name)
	assert(self.animations[name] != nil, "animation name doesn't exist")

	self.anim_current = name
	self.anim_timer = 0
	self.anim_current_index = 1
	self.current_frame = self.animations[name].frames[1]
end

function animation:update()
	if self.animations == "" then
		return
	end

	self.anim_timer += 1

	if not self.animations[self.anim_current].loop and self.anim_current_index == #self.animations[self.anim_current].frames then
		return
	end

	if self.anim_timer > self.animations[self.anim_current].speed then
		self.anim_current_index += 1
		self.anim_timer = 0
		
		if self.anim_current_index > #self.animations[self.anim_current].frames then
			self.anim_current_index = 1
		end

		self.current_frame = self.animations[self.anim_current].frames[self.anim_current_index]
	end
end

function animation:current()
	return self.current_frame
end
