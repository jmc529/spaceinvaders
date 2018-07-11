local Entity = {}

function Entity:new(id, x, y, velocity, sprite)
	local newEntity = {
		id = id,
		x = x,
		y = y,
		velocity = velocity,
		sprite = sprite,
		remove = false
	}
	self.__index = self
	return setmetatable(newEntity, self)
end

function Entity:draw()
	if string.find(self.id, "bullet") then 
		love.graphics.rectangle("fill", self.x, self.y, 1, 5)
	else
		love.graphics.draw(self.sprite, self.x, self.y)
	end
end

function Entity:getType()
	return self.id
end

function Entity:moveHorizontally()
	self.x = self.x + self.velocity[1]
end

function Entity:moveVertically()
	self.y = self.y + self.velocity[2]
end

function Entity:setVelocity(velocity)
	assert(type(velocity) == "table" and #velocity == 2, "Velocity must be assigned as a table, {xSpeed, ySpeed}")
	self.velocity = velocity
end

function Entity:terminate()
	self.remove = true
end

return Entity