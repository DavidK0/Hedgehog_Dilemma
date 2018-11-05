function GlassWall(world, x, y, width, height)
	local glassWall = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width, height),
		draw = drawWall,
		texture = wallImg,
		update = wallUpdate,
		tag = "GlassWall",
		destroy = destroyGlassWall
	}	
	glassWall.fixture = love.physics.newFixture(glassWall.body, glassWall.shape)
	glassWall.fixture:setUserData(glassWall)
	return glassWall
end

function destroyGlassWall(glassWall)
	for k, v in ipairs(walls) do
		if(v == glassWall) then
			table.remove(walls, k)
		end
	end
	glassWall.fixture:destroy()
end