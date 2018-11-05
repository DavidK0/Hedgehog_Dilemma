width = love.graphics.getWidth() --Screen width
height = love.graphics.getHeight() --Screen height
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
gamera = require "Gamera"
loadImgs("/assets/")
respawn = false
hasWon = false
spikeDeathRespawnDelay = 80
respawnTimer = 0
function love.load()
	--love.physics.setMeter(1)
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	player1 = Player(world, width/2, height/2, {up = "w", down = "s", left = "a", right = "d"}, 4.0)
	player2 = Player(world, width/2 + 50, height/2, {up = "up", down = "down", left  = "left", right = "right"}, 3.0)
	objects = {}
	walls = {}
	buttons = {}
	wallThickness = 600.0/14
	--table.insert(walls, Wall(world, 0,height/2, wallThickness, height))
	--table.insert(walls, Wall(world, width,height/2, wallThickness, height))
	--table.insert(walls, Wall(world, width/2,0, width, wallThickness))
	--table.insert(walls, Wall(world, width/2,height, width, wallThickness))
	worldWidth, worldHeight = loadMap("/assets/map.txt")
	src1:setLooping(true)
	--src1:play()
	cam = gamera.new(0,0,77*worldWidth,77*worldHeight)
end

function beginContact(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.beginCollision ~= nil) then
			aObj:beginCollision(bObj, coll)
		end
		if(bObj.beginCollision ~= nil) then
			bObj:beginCollision(aObj, coll)
		end
	end
end

function table.removeValue(t, value)
	for k, v in pairs(t) do
		if(v == value) then
			t[k] = nil
		end
	end
end

function endContact(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.endCollision ~= nil) then
			aObj:endCollision(bObj, coll)
		end
		if(bObj.endCollision ~= nil) then
			bObj:endCollision(aObj, coll)
		end
	end
end
 
function preSolve(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.preSolve ~= nil) then
			aObj:preSolve(bObj, coll)
		end
		if(bObj.preSolve ~= nil) then
			bObj:preSolve(aObj, coll)
		end
	end
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
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
			player2.body:setLinearVelocity(0, 0)
			player2.body:setPosition(player2.spawn.x, player2.spawn.y)
			respawn = false
			player1.respawn = false
			player2.respawn = false
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
			--print("ok")
		end
		for k, v in ipairs(objects) do
			v:draw()
		end
		
		for k, v in ipairs(walls) do
			v:draw()
		end
		--print(buttons["b"])
		player1:draw()
		player2:draw()
	end)
	end
end

function concatTable(t1, t2)
	for k, v in ipairs(t2) do
		table.insert(t1, v)
	end
end