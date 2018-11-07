function Door(world, x, y, width, height, movement, axis, button, toggle, mode)
	local door = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width, height),
		width = width,
		draw = drawdoor,
		texture = doorImg,
		texture2 = doorImg2,
		update = doorUpdate,
		direction = true,
		axis = axis,
		speed = 120,
		state = 0,
		button = button,
		buttons = {},
		mode = mode,
		toggle = toggle,
		goal = x,
		tag = "Door",
		reset = doorReset,
		--facing = facing --the direction the door opens, 1 for right/up, -1 for left/down
	}
	if axis == 1 then
		door.minx = y
		door.maxx = y+movement
	else --axis == 0
		door.minx = x
		door.maxx = x+movement
	end
	door.fixture = love.physics.newFixture(door.body, door.shape)
	door.fixture:setUserData(door)
	door.beginCollision = wallUpdate
	door.endCollision = wallUpdate
	return door
end

function doorReset(door)
	door.state = 0
end

function doorUpdate(door, dt)
	
	local x, y = door.body:getPosition()
	if(door.axis == 0) then
		if(math.abs(door.goal-x) > door.speed*dt/2) then
			door.body:setPosition(x + door.speed*dt*((door.goal-x)/math.abs(door.goal-x)), y)
		end
	else
		if(math.abs(door.goal-y) > door.speed*dt/2) then
			door.body:setPosition(x , y + door.speed*dt*((door.goal-y)/math.abs(door.goal-y)))
		end	
	end
	if(door.state == 1) then 
		if(door.axis == 0) then
			if(math.abs(door.goal-x) < door.speed*dt/2) then
				if(door.goal == door.maxx) then
					door.goal = door.minx
				else
					door.goal = door.maxx
				end
			end
		else
			if(math.abs(door.goal-y) < door.speed*dt/2) then
				if(door.goal == door.maxx) then
					door.goal = door.minx
				else
					door.goal = door.maxx
				end
			end
		end
	elseif(door.state == 2) then
	
		door.goal = door.maxx
	elseif(door.state == 0) then
		
		door.goal = door.minx
	end
	--print(#door.buttons)
	if(#door.buttons > 0) then 
		local active = true
		for k, v in pairs(door.buttons) do
			
			if(not(v.active  > 0)) then
				active = false
			end
		end
		
		if(active) then
			door.state = door.mode
		elseif(not(door.toggle)) then
			door.state = 0
		end
		
	else
		state = 1
	end
end

function drawdoor(door)
	local x,y = door.body:getPosition()
	love.graphics.setColor(1.0, 1.0, 1.0)
	if(door.axis == 0) then
		love.graphics.draw(door.texture2, x - wallThickness/2, y - wallThickness/4, 0.0, wallThickness/door.texture2:getWidth() , wallThickness/door.texture2:getHeight()/2)
	else
		love.graphics.draw(door.texture, x - wallThickness/4, y - wallThickness/2, 0.0, wallThickness/door.texture:getWidth()/2 , wallThickness/door.texture:getHeight())		
	end
	--[[for k, button in ipairs(door.buttons) do
		if(button.active > 0) then
			love.graphics.setColor(0.0, 1.0, 0.0)
		else
			love.graphics.setColor(0.1, 0.1, 0.1)
		end
		local bx, by = button.body:getPosition()
		love.graphics.line(x, y, x, by, bx, by)
	end]]
end

