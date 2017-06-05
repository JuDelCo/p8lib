
--------------------------------
-- camera
--------------------------------

-- todo: rename object "camera_" -> ?

camera_ = object:extend()

function camera_:new(target)
	self.target = target
	self.x = target.x + -25
	self.y = target.y
	self.accel_x = 0
	self.accel_y = 0

	self.pull_threshold = 12.5
	self.pos_min = { x = 64, y = 0 }
	self.pos_max = { x = 264, y = 192 }
end

function camera_:update()
	self.accel_x = approach(self.accel_x, (self.x - self.target.x) * (0.5 / self.pull_threshold), 0.2)
	self.x = approach(self.x, self.target.x, abs(self.accel_x) + 0.01)
	self.x -= self.accel_x

	self.accel_y = approach(self.accel_y, (self.y - self.target.y) * (0.5 / self.pull_threshold), 0.2)
	self.y = approach(self.y, self.target.y, abs(self.accel_y) + 0.01)
	self.y -= self.accel_y

	self.x = mid(self.pos_min.x, self.x, self.pos_max.x)
	self.y = mid(self.pos_min.y, self.y, self.pos_max.y)
end
