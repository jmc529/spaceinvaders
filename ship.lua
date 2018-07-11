local Entity = require("entity")

local Ship = Entity:new(id, x, y, velocity, sprite)

local COOLDOWN = 30
Ship.cooldown = COOLDOWN

function Ship:fire(velocity, source)
	assert(type(velocity) == "table", "Velocity must be a table {xSpeed, ySpeed}")
	if self.cooldown <= 0 then 
		love.audio.play(source)
		local bullets = {}
		if self:getType() == "player" then 
			bullets[1] = Entity:new("bullet", self.x + 7.25, self.y-1, velocity)
		elseif self:getType() == "enemy" then
			bullets[1] = Entity:new("enemy-bullet", self.x + 7.25, self.y+5, velocity)
		end
		self.cooldown = COOLDOWN
		return bullets
	end
end

return Ship