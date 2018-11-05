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
		texture = buttonImg,
		tag = "Button"
	}
	button.fixture = love.physics.newFixture(button.body, button.shape)
	button.fixture:setUserData(button)
	button.fixture:setSensor(true)
	return button
end

function BlockButton(world, x, y, width, height, doors)
	blockButton = Button(world, x, y, width, height, doors)
	blockButton.fixture:setUserData("BlockButton")
	blockButton.beginCollision = blockButtonBeginCollision
	blockButton.endCollision = blockButtonEndCollision
	return blockButton
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
	love.graphics.setColor(1.0, 1.0, 1.0)
	--love.graphics.polygon("fill", button.body:getWorldPoints(button.shape:getPoints()))
	local x, y = button.body:getPosition()
	love.graphics.draw(button.texture, x - wallThickness/2, y - wallThickness/2, 0.0,0.5, 0.5)
	--love.graphics.rectangle("fill", x - button.width/2, y - button.height/2, button.width, button.height)
		
end

 