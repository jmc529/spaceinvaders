local Ship = require("ship")

local title = "Space Invader"
local paused, pauseText, pauseButtons = false, "A recreation of the spaceinvaders game, by Josee", {"Help", "Menu", "Continue", escapebutton = 3}
local controls = {up = "w", down = "s", left = "a", right = "d", shoot = "space", pause = "escape"}
local World = {}

local lives = 3
local score = 0

function World.collosion(player, horde, bullets)
	for i,bullet in ipairs(bullets) do
		if bullet:getType() == "enemy-bullet" then
			if (bullet.x >= player.x and bullet.x <= player.x + 16) and (bullet.y >= player.y and bullet.y <= player.y + 8) then
				if lives <= 1 then 
					return false
				else
					lives = lives - 1
					bullet:terminate()
				end  
			end
		elseif bullet:getType() == "bullet" then
			for i=1, horde.width do 
				local temp = horde.enemies[i]
				for j=1, horde.height do
					if #temp > 0 then 
						local enemy = temp[j]
						if enemy ~= nil then
							if (bullet.x >= enemy.x and bullet.x <= enemy.x + 16) and (bullet.y >= enemy.y and bullet.y <= enemy.y + 8) then
								enemy:terminate()
								bullet:terminate()
								score = score + 1
							end
						end
					end
				end
			end
		end
	end
	for i=1, horde.width do 
				local temp = horde.enemies[i]
				for j=1, horde.height do
					if #temp > 0 then 
						local enemy = temp[j]
						if enemy ~= nil then
							if enemy.y >= 160 then
								return false
							end
						end
					end
				end
			end
	return true
end

function World.draw(drawableEntites)
	if #drawableEntites > 0 then 
		for i,entity in ipairs(drawableEntites) do
			entity:draw()
		end
	end
end

function World.gameInit(imageData)
	local major = love.getVersion()
	love.window.setTitle(title)
	love.window.setIcon(imageData)
	assert(major>=11, "This code was developed for love 11.1+")
end

function World.gameState(state)
	if love.keyboard.isScancodeDown(controls.pause) or love.window.isMinimized() or not love.window.hasFocus() and not paused then
		local pressedButton = love.window.showMessageBox(title, pauseText, pauseButtons, "info", true) --or love.timer.sleep(s) with new window
		if pressedButton == 1 then
			love.window.showMessageBox("Controls", "Use \'a\' to move your ship left and \'d\' to move it right. \nYou can fire a lazer with \'space\'. \nThis menu can be accessed with \'Esc\'.", "info", true)
		elseif pressedButton == 2 then
			return "menu"
		end
	end
	return state
end

function World.infobar(scoreIcon, livesIcon, numbers)
	love.graphics.draw(scoreIcon, 32, 4)
	local strScore = tostring(score)
	for i=1, string.len(strScore) do 
		local n = tonumber(string.sub(strScore, i, i))
		local number = n > 0 and numbers[n] or numbers[10]	
		love.graphics.draw(number, 56+i*8, 4)
	end
	love.graphics.draw(livesIcon, 180, 4)
	local number = lives > 0 and numbers[lives] or numbers[10]
	love.graphics.draw(number, 210, 4)
end

function World.newPlayerBullets(player, bullets, source)
	if love.keyboard.isScancodeDown(controls.shoot) and player.cooldown <= 0 then
		local temp = player:fire({0, -5}, source)
		for i=1,#temp do 
			bullets[#bullets+1] = temp[i]
		end
	end
end

function World.reset()
	score = 0
	lives = 3
end

function World.update(tblOfEntities, max)
	assert(type(tblOfEntities) == "table", "Param must be a table of NPC entites.")
	for i,entity in ipairs(tblOfEntities) do 
		if string.find(entity:getType(), "bullet") and (entity.y <= 0 or entity.y >= max)then
			entity:terminate()
		end

		if entity.remove == true then 
			table.remove(tblOfEntities, i)
		elseif string.find(entity:getType(), "bullet") then
			entity:moveVertically()
		end
	end
end

function World.updatePlayerPosition(player, min, max)
	assert(player:getType() == "player", "Must be a player.")
	if love.keyboard.isScancodeDown(controls.left) and player.x >= min then				
		player:setVelocity({-3, 0})
		if love.keyboard.isScancodeDown(controls.right) then
			player:setVelocity({0, 0})
		end
		player:moveHorizontally()
	end
	if love.keyboard.isScancodeDown(controls.right) and player.x <= max then
		player:setVelocity({3, 0})
		if love.keyboard.isScancodeDown(controls.left) then
			player:setVelocity({0, 0})
		end
		player:moveHorizontally()
	end
end

return World