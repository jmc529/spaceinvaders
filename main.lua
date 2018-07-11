local Horde = require("horde")
local Ship = require("ship")
local World = require("world")
local utf8 = require("utf8")

local playerSprite, enemySprite
local title, start, gameover, name, lives, score, menu, save
local zero, one, two, three, four, five, six, seven, eight, nine

local laserSource

local player, horde, bullets
local winWidth, winHeight
local cooldown, blink = 20, true
local fireRate, hordeSpeed = 160, 20
local username, savedScore = "", 0
local GAMESTATE = "menu"

local function newGame()
	bullets = {}
	horde = Horde:new(4, 16, 5, 3, hordeSpeed, fireRate, enemySprite)
	player = Ship:new("player", 5, 182, {1, 0}, playerSprite)
	cooldown, blink = 20, true
	fireRate, hordeSpeed = 160, 20
	username = ""
	World.reset()
end

function love.draw()
	if GAMESTATE == "menu" then 			
		love.graphics.draw(title, winWidth/2.5, winHeight/4, 0, 5, 5)
		if cooldown <= 0 then
			if blink then 
				blink = false	
			else 
				blink = true 
			end
			cooldown = 35
		elseif blink then 
			love.graphics.draw(start, winWidth/2.5+16, winHeight/2, 0, 5, 5)
		end
	elseif GAMESTATE == "gameplay" then
		love.graphics.scale(3)
		love.graphics.line(4, winHeight/3-24, winWidth/3-4, winHeight/3-24)
		player:draw()
		horde:draw()
		World.infobar(score, lives, {one, two, three, four, five, six, seven, eight, nine, zero})
		World.draw(bullets)
	elseif GAMESTATE == "gameover" then
	    love.graphics.draw(gameover, winWidth/2.5, winHeight/2.5, 0, 5, 5)
		--display highscores
		-- love.graphics.draw(name, winWidth/2.5-64, winHeight/1.5, 0, 5, 5)
		-- love.graphics.printf(username, winWidth/1.5-120, winHeight/1.485, winWidth/1.5, "left", 0, 3, 3)
		love.graphics.draw(menu, winWidth/2.5+24, winHeight/1.25, 0, 5, 5)
		-- love.graphics.draw(save, winWidth/2.5+128, winHeight/1.25, 0, 5, 5)
	end
end

-- function love.keypressed(key)
--     if key == "backspace" then
--         -- get the byte offset to the last UTF-8 character in the string.
--         local byteoffset = utf8.offset(username, -1)
 
--         if byteoffset then
--             -- remove the last UTF-8 character.
--             -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
--             username = string.sub(username, 1, byteoffset - 1)
--         end
--     end
-- end

function love.load()		
	winWidth, winHeight = love.graphics.getDimensions()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setDefaultFilter("nearest", "nearest")

	playerSprite = love.graphics.newImage("resources/images/player.png")
	enemySprite = love.graphics.newImage("resources/images/enemy.png")

	title = love.graphics.newImage("resources/images/title.png")
	start = love.graphics.newImage("resources/images/pressEnter.png")
	gameover = love.graphics.newImage("resources/images/gameover.png")
	name = love.graphics.newImage("resources/images/name.png")
	lives = love.graphics.newImage("resources/images/lives.png")
	score = love.graphics.newImage("resources/images/score.png")
	menu = love.graphics.newImage("resources/images/menu.png")
	save = love.graphics.newImage("resources/images/save.png")

	zero = love.graphics.newImage("resources/images/numbers/0.png")
	one = love.graphics.newImage("resources/images/numbers/1.png")
	two = love.graphics.newImage("resources/images/numbers/2.png")
	three = love.graphics.newImage("resources/images/numbers/3.png")
	four = love.graphics.newImage("resources/images/numbers/4.png")
	five = love.graphics.newImage("resources/images/numbers/5.png")
	six = love.graphics.newImage("resources/images/numbers/6.png")
	seven = love.graphics.newImage("resources/images/numbers/7.png")
	eight = love.graphics.newImage("resources/images/numbers/8.png")
	nine = love.graphics.newImage("resources/images/numbers/9.png")

	laserSource = love.audio.newSource("resources/sounds/laser.wav", "static")
	World.gameInit(love.image.newImageData("resources/images/icon.png"))
end

function love.textinput(text)
	if GAMESTATE == "gameover" then 
		username = username .. text
	end
end

function love.update()
	GAMESTATE = World.gameState(GAMESTATE)
	if GAMESTATE == "menu" then 			
		if love.keyboard.isScancodeDown("return") then 
			newGame()
			GAMESTATE = "gameplay"
		end

		cooldown = cooldown - 1
	elseif GAMESTATE == "gameplay" then
		if horde:isDefeated() then
			fireRate = fireRate > 40 and fireRate - 40 or fireRate
			hordeSpeed = hordeSpeed > 1 and hordeSpeed - 2 or hordeSpeed
			horde = Horde:new(4, 16, 5, 3, hordeSpeed, fireRate, enemySprite)
		end

		World.updatePlayerPosition(player, 0, winWidth/3 - 16)
		horde:update(winWidth/3 - horde.width*20, winHeight/3 - horde.height*20)
	
		World.newPlayerBullets(player, bullets, laserSource)
		horde:fire(bullets, laserSource)
		World.update(bullets, winHeight/3)

		local playerAlive = World.collosion(player, horde, bullets)

		if not playerAlive then 
			GAMESTATE = "gameover"
			savedScore = score
		end

		player.cooldown = player.cooldown - 1
		horde.cooldown = horde.cooldown - 1
		horde.fireCooldown = horde.fireCooldown - 1
	elseif GAMESTATE == "gameover" then
		local mouseX, mouseY = love.mouse.getPosition()
		if mouseY >= winHeight/1.25 and mouseY <= winHeight/1.25 + 40 then
			if mouseX >= winWidth/2.5+24 and mouseX <= winWidth/2.5+134 then
				if love.mouse.isDown(1) then 
					GAMESTATE = "menu"
				end
			end
		end
	end
end