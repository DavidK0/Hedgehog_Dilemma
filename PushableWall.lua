function PushableWall(world, x, y, width, height, destroyable)
	local pushableWall = {
		body = love.physics.newBody(world, x, y, "dynamic"),
		shape = love.physics.newRectangleShape(width*0.95, height*0.95),
		draw = drawpushableWall,
		texture = wallImg,
		update = pushableWallUpdate,
		reset = pushableWallReset,
		toReset = false,
		x = x,
		destroyable = destroyable,
		y = y,
		tag = "PushableWall"
	}
	pushableWall.fixture = love.physics.newFixture(pushableWall.body, pushableWall.shape)
	pushableWall.fixture:setUserData(pushableWall)
	pushableWall.body:setLinearDamping(10.0)
	pushableWall.beginCollision = pushableWallBeginCollision
	pushableWall.endCollision = pushableWallEndCollision
	return pushableWall
end

function pushableWallBeginCollision(wall, other, coll)
	if(other.tag == "Spike" and wall.destroyable) then
		wall:reset()
	end
end

function pushableWallEndCollision(wall, other, coll)

end

function pushableWallUpdate(pushableWall, dt)
		if(pushableWall.toReset) then
			pushableWall.body:setPosition(pushableWall.x, pushableWall.y)
			pushableWall.body:setLinearVelocity(0,0)
			pushableWall.toReset = false
		end
end

function pushableWallReset(pushableWall) 
	
	pushableWall.toReset = true
end

function drawpushableWall(pushableWall)
	love.graphics.setColor(1.0, 1.0, 1.0)
	--love.graphics.polygon("fill", pushableWall.body:getWorldPoints(pushableWall.shape:getPoints()))
	local x, y = pushableWall.body:getPosition()
	love.graphics.draw(pushableWall.texture, x - wallThickness/2, y - wallThickness/2, 0.0,wallThickness/pushableWall.texture:getWidth(), wallThickness/pushableWall.texture:getHeight())
end