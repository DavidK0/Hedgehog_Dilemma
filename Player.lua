require "Spikes"
require "Timer"
loadSpikes()

hedgehogScale =2.1

function Player(world, x, y, c, p, f)
	local player = {
		height = 50,
		width = 25,
		body = love.physics.newBody(world, x, y, "dynamic"),
		speed = 200000,
		acceleration = 4000,
		update = playerUpdate,
		draw = drawPlayer,
		controls = c,
		texture = hedgeTexture,
		flashBPM = 120.0/4,
		currColor = 0.0,
		turning = 80000,
		prickleTime = p or 4.0,
		tag = "Player",
		respawn = false,
		deathPointX = 0,
		deathPointY = 0,
		doorCollision = nil,
		won = false,
		fireSpikes = f
	}
	
	player.width = player.texture:getWidth()/hedgehogScale
	player.height = player.texture:getHeight()/hedgehogScale
	
	player.shape = love.physics.newPolygonShape(-player.width/2*.9, 0,
												-player.width/2*.8, player.height/2*.8,
												0, player.height/2,
												player.width/2*.8, player.height/2*.8,
												player.width/2*.9, 0,
												0, -player.height/2)
	player.fixture = love.physics.newFixture(player.body, player.shape)
	player.body:setLinearDamping(10.0)
	player.body:setFixedRotation(false)
	player.fixture:setUserData(player)
	player.flashTimer = newTimer()
	player.body:setMass(1.5)
	player.body:setAngularDamping(15.0)
	
	player.body:setAngle(math.pi)
	
	player.beginCollision = playerBeginCollision
	player.endCollision = playerEndCollision
	player.preSolve = playerPreSolve
	return player
end

function playerBeginCollision(player, other, coll) 
	if(other.tag == "Spike") then
		if(not(other.stuck) and other.parent ~= player) then
			player.respawn = true
			startRespawn(player, spikeDeathRespawnDelay)
		end
	end
end

function startRespawn(player, delay)
	if(not(respawn)) then
		respawn = true
		respawnTimer = delay or 0
		local x, y = player.body:getPosition()
		player.deathPointX = x
		player.deathPointY = y
	end
end

function playerEndCollision(player, other, coll) 

end

function playerPreSolve(player, other, coll)
	if(other.tag == "Door" and not(respawn)) then
		local px, py = player.body:getPosition()
		local wx, wy = other.body:getPosition()
		if(other.axis == 0) then 
			if(math.abs(py-wy) < 20.0 and math.abs(wx - other.minx) < 20.0) then
				player.respawn = true
				killedByDoor = true
				startRespawn(player, spikeDeathRespawnDelay)
			end
		else
			if(math.abs(px-wx) < 20.0 and math.abs(wy - other.minx) < 20.0) then
				player.respawn = true
				killedByDoor = true
				startRespawn(player, spikeDeathRespawnDelay)
			end
		end
	end
end

function playerUpdate(player, dt)
	if(not(player.respawn)) then
		vXOld1, vYOld1 = player1.body:getLinearVelocity()
		vXOld2, vYOld2 = player2.body:getLinearVelocity()
		
		pXOld1, pYOld1 = player1.body:getPosition()
		pXOld2, pYOld2 = player2.body:getPosition()
		
		local x1, y1 = cam:toScreen(pXOld1,pYOld1)
		local x2, y2 = cam:toScreen(pXOld2,pYOld2)
		
		local vx, vy = player.body:getLinearVelocity()
		local x, y = player.body:getPosition()
		
		local playerVector2 = math.normalize({math.cos(player.body:getAngle()-math.pi/2),math.sin(player.body:getAngle()-math.pi/2)})
		if player.body:getAngle() < 0 then
			player.body:setAngle(player.body:getAngle() + math.pi*2)
		elseif player.body:getAngle() > math.pi*2 then
			player.body:setAngle(player.body:getAngle() - math.pi*2)
		end
		
		local quad = getQuadrant(player.body:getAngle())
		
		local numKeys = 0
		if love.keyboard.isDown(player.controls.up) then numKeys = numKeys+1 end
		if love.keyboard.isDown(player.controls.down) then numKeys = numKeys+1 end
		if love.keyboard.isDown(player.controls.left) then numKeys = numKeys+1 end
		if love.keyboard.isDown(player.controls.right) then numKeys = numKeys+1 end
		local moveSpeed = player.acceleration/numKeys
		
		if(love.keyboard.isDown(player.controls.up) and vy > -player.speed) then
			player.body:applyForce(playerVector2[1]*moveSpeed, playerVector2[2]*moveSpeed)
			if  quad==1 or quad==2 then
				player.body:applyTorque(-player.turning*smallestAngle(player.body:getAngle(),0))
			else
				player.body:applyTorque(player.turning*smallestAngle(player.body:getAngle(),0))
			end
		end
		if (love.keyboard.isDown(player.controls.down) and vy < player.speed) then
			player.body:applyForce(playerVector2[1]*moveSpeed, playerVector2[2]*moveSpeed)
			if  quad==1 or quad==2 then
				player.body:applyTorque(player.turning*smallestAngle(player.body:getAngle(),math.pi))
			else
				player.body:applyTorque(-player.turning*smallestAngle(player.body:getAngle(),math.pi))
			end
		end
		if (love.keyboard.isDown(player.controls.left) and vx > -player.speed) then
			player.body:applyForce(playerVector2[1]*moveSpeed, playerVector2[2]*moveSpeed)
			if  quad==1 or quad==4 then
				player.body:applyTorque(-player.turning*smallestAngle(player.body:getAngle(),math.pi*1.5))
			else
				player.body:applyTorque(player.turning*smallestAngle(player.body:getAngle(),math.pi*1.5))
			end
		end
		if (love.keyboard.isDown(player.controls.right) and vx < player.speed) then
			player.body:applyForce(playerVector2[1]*moveSpeed, playerVector2[2]*moveSpeed)
			if  quad==1 or quad==4 then
				player.body:applyTorque(player.turning*smallestAngle(player.body:getAngle(),math.pi*.5))
			else
				player.body:applyTorque(-player.turning*smallestAngle(player.body:getAngle(),math.pi*.5))
			end
		end
		
		--[[if love.keyboard.isDown("q") then --allows for direct controlling of turning for testing purposes
			player.body:applyTorque(-10000)
		elseif love.keyboard.isDown("e") then
			player.body:applyTorque(10000)
		end]]
		
		if player.flashTimer:everySec(player.prickleTime) and player.flashTimer.time > 0 then
			if(player.fireSpikes) then
				concatTable(objects, createSpikes(player))
			end
		end
		player.flashTimer:update(dt)
		--player.currColor = (math.cos(player.flashTimer.time%player.flashDelay) + 1)/2
	else
		local x, y = player.body:getPosition()
		player.body:setPosition(x + (player.spawn.x-x)/20, y+(player.spawn.y-y)/20)
		
	end
end

function drawPlayer(player)
	local x, y = player.body:getPosition()
	--love.graphics.setColor(1.0, player.currColor, player.currColor)
	--local x, y = player.body:getWorldPoints(player.shape:getPoints())
	if player.respawn then
		love.graphics.setColor(1,.5,.5,1)
	else
		love.graphics.setColor(1,1,1,1)
	end
	if not(player.respawn) then
		local hedgeHogPixelWidth = 57/hedgehogScale
		local hedgeHogPixelHeight = 97/hedgehogScale
		local angle = player.body:getAngle()
		love.graphics.draw(player.texture, x, y, angle, hedgeHogPixelWidth/player.texture:getWidth(), hedgeHogPixelHeight/player.texture:getHeight(), hedgeHogPixelWidth, hedgeHogPixelHeight)
		love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
	else	
		love.graphics.setColor(1,0,0)
		for i=0,2*math.pi,0.1 do
			local mag = (spikeDeathRespawnDelay - respawnTimer)*10
			love.graphics.rectangle("fill",player.deathPointX + mag*math.cos(i), player.deathPointY + mag*math.sin(i), 10, 10)
		end
	end
	--love.graphics.polygon("line", player.body:getWorldPoints(player.shape:getPoints()))
end	