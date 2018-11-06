function Button(world, x, y, width, height, doors)
	local button = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width, height),
		draw = drawbutton,
		update = updatebutton,
		doors = doors,
		width = width,
		height = height,
		active = 0,
		beginCollision = buttonBeginCollision,
		endCollision = buttonEndCollision,
		textureUp = buttonUpImg,
		textureDown = buttonDownImg,
		tag = "Button",
		reset = resetButton
	}
	button.fixture = love.physics.newFixture(button.body, button.shape)
	button.fixture:setUserData(button)
	button.fixture:setSensor(true)
	return button
end

function BlockButton(world, x, y, width, height, doors)
	blockButton = Button(world, x, y, width, height, doors)
	blockButton.fixture:setUserData(blockButton)
	blockButton.beginCollision = blockButtonBeginCollision
	blockButton.endCollision = blockButtonEndCollision
	return blockButton
end

function resetButton(button)
	button.active = 0
end

function buttonBeginCollision(button, other, coll)
	if(other.tag == "Player") then
		button.active = button.active + 1
	end
end

function buttonEndCollision(button, other, coll)
	if(other.tag == "Player") then
		button.active = button.active - 1
	end 
end

function blockButtonBeginCollision(button, other, coll) 
	if(other.tag == "PushableWall") then
		button.active = button.active + 1
	end
end

function blockButtonEndCollision(button, other, coll)
	if(other.tag == "PushableWall") then
		button.active = button.active - 1
	end 
end

function drawbutton(button)
	if(button.active < 0) then
		button.active = 0
	end
	love.graphics.setColor(1.0, 1.0, 1.0)
	--love.graphics.polygon("fill", button.body:getWorldPoints(button.shape:getPoints()))
	local x, y = button.body:getPosition()
	
	if (button.active > 0) then
		love.graphics.draw(button.textureDown, x - wallThickness/2, y - wallThickness/2, 0.0,0.5, 0.5)
	end
	if (button.active < 1) then
		love.graphics.draw(button.textureUp, x - wallThickness/2, y - wallThickness/2, 0.0,0.5, 0.5)
	end
	--love.graphics.rectangle("fill", x - button.width/2, y - button.height/2, button.width, button.height)
		
end

 