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
--comment
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
	wallThickness = 600.0/14
	worldWidth, worldHeight = loadMap("/assets/map.txt")
	--currentTrack:setLooping(true)
	--currentTrack:play()
	cam = gamera.new(0,0,77*worldWidth,77*worldHeight)
	gameState = "title" --"title", "mainMenu", "controls", "game", or "win"
	menuTimer = newTimer()
	titleDelay = 1
	killedByDoor = false
	camShake = 50
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
	if tonumber(k) and gameState == "mainMenu" then
		gameState = "controls"
	elseif gameState == "mainMenu" then
		gameState = "game"
	elseif gameState == "controls" then
		gameState = "mainMenu"
	end
end

function love.update(dt)
	menuTimer:update(dt)
	if gameState == "mainMenu" then
		playRandomTrack()
	elseif gameState == "game" then
		playRandomTrack()
		player1:update(dt)
		player2:update(dt)
		world:update(dt)
		constrainToScreen()
		for k, v in ipairs(objects) do
			if(v.update ~= nil) then
				v:update(dt)
			end
		end
		if respawn then
			if respawnTimer <= 0 then
				for k = #objects, 1, -1 do
					v = objects[k]
					if(v.reset ~= nil) then
						v:reset()
					end
					if(v.tag == "Spike") then
						v.fixture:destroy()
						table.remove(objects, k)
					end
				end
				player1.body:setLinearVelocity(0, 0)
				player1.body:setAngle(math.pi)
				player1.body:setPosition(player1.spawn.x, player1.spawn.y)
				player1.flashTimer.time = 0
				player2.body:setLinearVelocity(0, 0)
				player2.body:setAngle(math.pi)
				player2.body:setPosition(player2.spawn.x, player2.spawn.y)
				player2.flashTimer.time = 0
				respawn = false
				player1.respawn = false
				player2.respawn = false
				killedByDoor = false
			end
			respawnTimer = respawnTimer - 1
			
		end
		updateAcres(dt)
		if hasWon then
			gameState = "win"
			kongrad:play()
		end
	elseif gameState == "win" then
		if not kongrad:isPlaying() then
			love.event.quit()
		end
	end
	if(player1.won and player2.won) then
		hasWon = true
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
	elseif gameState == "controls" then
		love.graphics.draw(controlsImg, 0, 0)
	elseif gameState == "game" then
		cam:draw(function(l,t,w,h)
			for x = 1, 10000, background:getWidth() do
				for y = 1, 10000, background:getHeight() do
					love.graphics.draw(background, x, y, 0, 1)
				end
			end
			for k, v in ipairs(objects) do
				if(v.draw ~= nil) then
					v:draw()
				end
			end
			player1:draw()
			player2:draw()
		end)
		if respawn then
			if killedByDoor then
				love.graphics.setColor(0, 0, 0)
				--print(width * (1 - (spikeDeathRespawnDelay - respawnTimer)/spikeDeathRespawnDelay))
				love.graphics.rectangle("fill", width * (1 - 4*(spikeDeathRespawnDelay - respawnTimer)/spikeDeathRespawnDelay), 0, width*4, height)
				love.graphics.setColor(1, 1, 1)				
				love.graphics.print("You got crushed", width * (1 - (spikeDeathRespawnDelay - respawnTimer)/spikeDeathRespawnDelay), height/2, 0.0, 2.0) 
			end
			love.graphics.setColor(1, 0, 0)
		else
			love.graphics.setColor(1, 1, 1)
		end
	elseif gameState == "win" then
		currentTrack:stop()
		love.graphics.draw(winImg, 0, 0)
	end
end