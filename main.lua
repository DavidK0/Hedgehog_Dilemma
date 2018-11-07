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
	loadImgs("/assets/") -- loads .png, .jpg, jpeg, and .mp3
	respawn = false -- global variable, true if either player has died
	hasWon = false -- true if both players have readed the $
	spikeDeathRespawnDelay = 50
	respawnTimer = 0 -- delay between death of player and reset of player/objects
	screenWidth = love.graphics.getWidth() --Screen width
	screenHeight = love.graphics.getHeight() --Screen height
	world = love.physics.newWorld(0, 0, true) -- meter defaults to 30
	world:setCallbacks(beginContact, endContact, preSolve, postSolve) -- callbuack functions used by the physics engine
	player1 = Player(world, screenWidth/2, screenHeight/2, {up = "w", down = "s", left = "a", right = "d"}, 4.0, true) -- player 1 w/ controls
	player2 = Player(world, screenWidth/2 + 50, screenHeight/2, {up = "up", down = "down", left  = "left", right = "right"}, 3.0, true) --player 2 w/ controls
	objects = {} -- array to hold all objects
	tilesOnScreen = 14 --number of tile that are displayed in one screen
	tileThickness = screenWidth/tilesOnScreen -- size of each tile
	worldWidth, worldHeight = loadMap("/assets/map.txt") --loads the map
	cam = gamera.new(0,0,77*worldWidth,77*worldHeight) --sets camera based on map size; later changed for camera shake
	gameState = "title" --"title", "mainMenu", "controls", "game", or "win"
	menuTimer = newTimer() -- timer used for title screen fade in
	titleDelay = 1 -- amount of seconds the title fades in
	killedByDoor = false -- if cause of death is a door; used in door death animation
	camShake = 0 -- intensity of camShake; increases over time
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
		playRandomTrack() -- play music
		
		player1:update(dt)
		player2:update(dt)
		world:update(dt)
		
		constrainToScreen() --constrain players' position to visable screen
		
		--update all objects
		for k, v in ipairs(objects) do
			if(v.update ~= nil) then
				v:update(dt)
			end
		end
		if respawn then -- if a player has died
			if respawnTimer <= 0 then -- if respawnTimer has hit zero, reset all objects and destroy all spikes
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
				
				-- reset players
				resetPlayer(player1)
				resetPlayer(player2)
				
				-- reset death trackers
				respawn = false
				player1.respawn = false
				player2.respawn = false
				killedByDoor = false
			end
			respawnTimer = respawnTimer - 1
			
		end
		updateCamera(dt) -- update camera position/camera shake
		if (player1.won and player2.won) then -- both players reached $
			gameState = "win"
			kongrad:play()
		end
	elseif gameState == "win" then -- both players reached $
		if not kongrad:isPlaying() then
			love.event.quit()
		end
	end
	--[[if(player1.won and player2.won) then  -- both players reached $
		hasWon = true
	end]]
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
		cam:draw(function(l,t,w,h) -- draw most things relative to the camera
			for x = -background:getWidth(), 10000, background:getWidth() do
				for y = -background:getHeight(), 10000, background:getHeight() do
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
				local doorAnimationX = math.max(-((spikeDeathRespawnDelay - respawnTimer)/spikeDeathRespawnDelay)+.5,0)
				--print(doorAnimationX)
				love.graphics.rectangle("fill", screenWidth * doorAnimationX, 0, screenWidth*4, screenHeight)
				love.graphics.setColor(1, 1, 1)		
				love.graphics.setFont(doorDeathFont)
				love.graphics.print("You got crushed", screenWidth * doorAnimationX + screenWidth/2 - doorDeathFont:getWidth("You got crushed"), screenHeight/2 - doorDeathFont:getHeight("You got crushed"), 0.0, 2.0) 
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