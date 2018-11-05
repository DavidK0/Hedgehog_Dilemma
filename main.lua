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
	killedByDoor = false
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
end

function love.update(dt)
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
			killedByDoor = false
		end
		respawnTimer = respawnTimer - 1
	end
	updateAcres(dt)
end

function love.draw()
	if not hasWon then
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
	end
end