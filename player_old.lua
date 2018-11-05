require "Spikes"
require "Timer"
loadSpikes()
function Player(world, x, y, c)
	local player = {
		height = 50,
		width = 25,
		body = love.physics.newBody(world, x, y, "dynamic"),
		speed = 200000,
		acceleration = 4000,
		update = playerUpdate,
		draw = drawPlayer,
		controls = c,
		texture = love.graphics.newImage("assets/hedge.png"),
		prickleTime = 120,
		prickleTimer = 0,
		flashBPM = 120.0/4,
		currColor = 0.0
	}
	player.shape = love.physics.newRectangleShape(player.width, player.height)
	player.fixture = love.physics.newFixture(player.body, player.shape)
	player.body:setLinearDamping(10.0)
	player.body:setFixedRotation(true)
	player.fixture:setUserData("Player")
	player.flashDelay = player.flashBPM / 60.0
	player.flashTimer = newTimer()
	--player.body:setAngularDamping(10.0)
	return player
end

function playerUpdate(player, dt)
	local vx, vy = player.body:getLinearVelocity()
	local x, y = player.body:getPosition()
	if(love.keyboard.isDown(player.controls.up) and vy > -player.speed) then
		player.body:applyForce(0, -player.acceleration)
	elseif (love.keyboard.isDown(player.controls.down) and vy < player.speed) then
		player.body:applyForce(0, player.acceleration)
	end
	if (love.keyboard.isDown(player.controls.left) and vx > -player.speed) then
		player.body:applyForce(-player.acceleration, 0)
	elseif (love.keyboard.isDown(player.controls.right) and vx < player.speed) then
		player.body:applyForce(player.acceleration, 0)
	end
	
	if player.flashTimer:everySec(4.0) then
		
		concatTable(objects, createSpikes(player))
		
	end
	player.flashTimer:update(dt)
	player.currColor = (math.cos(player.flashTimer.time%player.flashDelay) + 1)/2
end

function drawPlayer(player)
	local x, y = player.body:getPosition()
	love.graphics.setColor(1.0, player.currColor, player.currColor)
	love.graphics.draw(player.texture, x - player.texture:getWidth()/4, y - player.texture:getHeight()/4, player.body:getAngle(), 0.5, 0.5)
	--love.graphics.polygon("empty", player.body:getWorldPoints(player.shape:getPoints()))
end	