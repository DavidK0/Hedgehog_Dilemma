function Wall(world, x, y, width, height)
	local wall = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width*0.95, height*0.95),
		draw = drawWall,
		texture = wallImgs[math.random(5)],
		update = wallUpdate,
		tag = "Wall",
		reset = wallUpdate
	}
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	wall.fixture:setUserData(wall)
	wall.beginCollision = wallUpdate
	wall.endCollision = wallUpdate
	return wall
end

function wallUpdate() end

function drawWall(wall)
	love.graphics.setColor(1.0, 1.0, 1.0)
	--love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	local x, y = wall.body:getPosition()
	love.graphics.draw(wall.texture, x - wallThickness/2, y - wallThickness/2, 0.0,wallThickness/wall.texture:getWidth(), wallThickness/wall.texture:getHeight())
end