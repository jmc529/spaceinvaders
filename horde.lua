local Ship = require("ship")

love.math.setRandomSeed(os.time())

local Horde = {}
local VELOCITY = {x = 1, y = 6}
Horde.fireCooldown = love.math.random(160, 240)
Horde.right = true
local baseCooldown 

function Horde:new(x, y, width, height, COOLDOWN, fireRate, sprite)
	local newHorde = {
		x = x, 
		y = y,
		width = width,
		height = height,
		cooldown = COOLDOWN,
		fireRate = fireRate,
		sprite = sprite,
		count = width * height,
		enemies = {}
	}
	for i=0, newHorde.width-1 do
		local temp = {}
		for j=0, newHorde.height-1 do 
			temp[j+1] = Ship:new("enemy", newHorde.x + i*20, newHorde.y + j*20, {VELOCITY.x,VELOCITY.y}, newHorde.sprite)
			temp[j+1].cooldown = 0
		end
		newHorde.enemies[i+1] = temp
	end
	baseCooldown = COOLDOWN
	self.__index = self
	return setmetatable(newHorde, self)
end

function Horde:isDefeated()
	if self.count < 1 then 
		return true 
	end
	return false
end

function Horde:draw()
	for i=1,#self.enemies do
		local temp = self.enemies[i]
		if temp ~= nil then 
			for j=1,#temp do
				local enemy = temp[j]
				if enemy ~= nil then 
					if enemy.remove == true then
						table.remove(temp, j)
						self.count = self.count - 1
					else
						enemy:draw()
					end
				end
			end
		end
	end
end

function Horde:fire(bullets, source)
	if self.fireCooldown <= 0 then 
		local tempWidth = love.math.random(1,self.width)
		local tempHeight = love.math.random(1,self.height)
		local temp = self.enemies[tempWidth]
		if temp[tempHeight] ~= nil then
			local tblBullets = temp[tempHeight]:fire({0, 5}, source)
			temp[tempHeight].cooldown = 0
			bullets[#bullets+1] = tblBullets[1]
		end
		self.fireCooldown = love.math.random(self.fireRate, self.fireRate + 80)
	end
end

--@param direct corresponds to the vertical or horizontal movement of an enemy
--where any true parameter directs to vertical and false relates to horizontal
function Horde:move(direct)
	for i=1,#self.enemies do
		local temp = self.enemies[i]
		for j=1,#temp do
			if direct then
				if temp[j].velocity[1] > 0 then
					temp[j]:setVelocity({-1*VELOCITY.x,VELOCITY.y})
				elseif temp[j].velocity[1] < 0 then
				    temp[j]:setVelocity({VELOCITY.x,VELOCITY.y})
				end
				temp[j]:moveVertically()
				temp[j]:draw()
			elseif not direct then
				temp[j]:moveHorizontally()
				temp[j]:draw()
			end
		end
	end
end

function Horde:update(xConstraint, yConstraint)
	if self.cooldown <= 0 then
		if self.right and self.x >= xConstraint then
			self.y = self.y + VELOCITY.y
			self.right = false
			self:move(true)
		elseif (not self.right) and self.x <= 4 then
			self.y = self.y + VELOCITY.y
			self.right = true
			self:move(true)
		else
			if self.right and self.x <= xConstraint then
				self.x = self.x +  VELOCITY.x
				self:move(false)
			elseif not self.right and self.x >= 4 then 
				self.x = self.x - VELOCITY.x
				self:move(false)
			end
		end
		self.cooldown = baseCooldown
	end
end

return Horde