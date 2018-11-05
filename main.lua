require "Load"
require "Player"
require "Wall"
require "Door"
require "Maths"
require "Button"
require "PushableWall"
require "Camera"
require "WinTrigger"
require "GlassWall"
require "Physics"
gamera = require "Gamera"

function love.load()
	loadImgs("/assets/")
	respawn = false
	hasWon = false
	spikeDeathRespawnDelay = 80
	respawnTimer = 0
	width = love.graphics.getWidth() --Screen width
	height = love.graphics.getHeight() --Screen height
	world = love.physics.newWorld(0, 0, true) -- meter defaults to 30
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	player1 = Player(world, width/2, height/2, {up = "w", down = "s", left = "a", right = "d"}, 4.0)
	player2 = Player(world, width/2 + 50, height/2, {up = "up", down = "down", left  = "left", right = "right"}, 3.0)
	objects = {}
	walls = {}
	buttons = {}
	wallThickness = 600.0/14
	worldWidth, worldHeight = loadMap("/assets/map.txt")
	src1:setLooping(true)
	--src1:play()
	cam = gamera.new(0,0,77*worldWidth,77*worldHeight)
	gameState = "title" --"title", "mainMenu", "game", or "win"
	menuTimer = newTimer()
	titleDelay = 1
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
	if tonumber(k) and gameState == "mainMenu" then
	
	elseif gameState == "mainMenu" then
		gameState = "game"
	end
end

function love.update(dt)
	menuTimer:update(dt)
	if gameState == "game" then
		player1:update(dt)
		player2:update(dt)
		world:update(dt)
		constrainToScreen()
		for k, v in ipairs(objects) do
			v:update(dt)
		end
		for k, v in ipairs(walls) do 
			v:update(dt)
		end
		if respawn then
			if respawnTimer <= 0 then
				for k = #objects, 1, -1 do
					objects[k].fixture:destroy()
					table.remove(objects, k)
				end
				player1.body:setLinearVelocity(0, 0)
				player1.body:setPosition(player1.spawn.x, player1.spawn.y)
				player1.flashTimer.time = 0
				player2.body:setLinearVelocity(0, 0)
				player2.body:setPosition(player2.spawn.x, player2.spawn.y)
				player2.flashTimer.time = 0
				respawn = false
				player1.respawn = false
				player2.respawn = false
			end
			respawnTimer = respawnTimer - 1
		end
		updateAcres(dt)
		if hasWon then gameState = "win" end
	end
end

function love.draw()
	if gameState == "title" then
		love.graphics.setColor(1,1,1,math.tanh((4*menuTimer.time)/titleDelay))
		love.graphics.draw(titleImg, 0, 0)
		if menuTimer.time>=titleDelay then gameState = "mainMenu" end
	elseif gameState == "mainMenu" then
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(mainMenuImg, 0, 0)
	elseif gameState == "game" then
		cam:draw(function(l,t,w,h)
			--love.graphics.setColor(1, 0, 0);
			love.graphics.draw(background, 0, 0, 0, 2)
			for k, v in pairs(buttons) do 
				v:draw()
			end
			for k, v in ipairs(objects) do
				v:draw()
			end
			
			for k, v in ipairs(walls) do
				v:draw()
			end
			player1:draw()
			player2:draw()
		end)
	elseif gameState == "win" then
		love.graphics.draw(winImg, 0, 0)
	end
end