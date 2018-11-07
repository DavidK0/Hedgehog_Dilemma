--[[require "Camera"
gamera = require "Gamera"
cam = gamera.new(0,0,77*3*14,77*3*14)
updateAcres(dt)]]

function defineAcreLayout(file)
	file = file or "/assets/acreMap.txt"
	local f = love.filesystem.newFile(file, "r")
	
	local acreSize = 14
	
	local y = 0
	for line in f:lines() do
		local x = 0
		for s in line:gmatch"." do
			if (s ~= " ") then
				loadMap("/assets/acres/acre" .. s .. ".txt", x, y)
			end
			x = x + acreSize
		end
		y = y + acreSize
	end
end

function updateAcres(dt)
	local x1, y1 = player1.body:getPosition()
	local x2, y2 = player2.body:getPosition()
	if not respawn then
		cam:setWorld(0,0,77*worldWidth,77*worldHeight)
		cam:setPosition((x1 + x2)/2, (y1 + y2)/2)
	else
		camShake = camShake + dt*8
		local xShake = (math.random()*camShake-camShake/2)
		local yShake = (math.random()*camShake-camShake/2)
		local x = (x1 + x2)/2
		local y = (y1 + y2)/2
		cam:setWorld(0-xShake,0-yShake,77*worldWidth+xShake,77*worldHeight-yShake)
		cam:setPosition(x+xShake,y+yShake)
	end
end

--slides to the left/up: ({[<
--slides to the right/down: )}]>
--<> --stay open, toggle open
--[] --stay open, push to open
--{} --open/close, toggle open
--() --open/close, push to open
function loadMap(file)
	local f = love.filesystem.newFile(file, "r")
	local x = 0
	local y = 0
	
	local maxX, maxY = 0,0
	
	for line in f:lines() do
		local x = 0
		for s in line:gmatch".." do
			
			c = string.sub(s,1,1)
			
			d = string.sub(s,2,2)
		
			local toggle = d == "!"
			local mode
			if(d == "]") or (d == "[") or (d == "<") or (d == ">") then 
				mode = 2
			else
				mode = 1
			end
			
			local toggleType
			if(d == "<") or (d == ">") or (d == "{") or (d == "}") then
				toggleType = true
			else
				toggleType = false
			end
			
			local direction
			if (d == "(") or (d == "{") or (d == "[") or (d == "<") then
				direction = -1
			else--if (d == ")") or (d == "}") or (d == "]") or (d == ">") then
				direction = 1
			end
			if c == "#" then
				table.insert(objects, Wall(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness))
			elseif string.match(c, "[A-M]") then
				table.insert(objects, Door(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, wallThickness * (2)*direction, 0, c, toggleType, mode, direction))
			elseif string.match(c, "[N-Z]") then
				table.insert(objects ,  Door(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, wallThickness * (2)*direction, 1, c, toggleType, mode, direction))
			elseif c == "1" then
				player1.spawn = {}
				player1.spawn.x = x*wallThickness + wallThickness/2
				player1.spawn.y = y*wallThickness + wallThickness/2
				player1.body:setPosition(player1.spawn.x, player1.spawn.y)
			elseif c == "2" then
				
				player2.spawn = {}
				player2.spawn.x = x*wallThickness + wallThickness/2
				player2.spawn.y = y*wallThickness + wallThickness/2
				player2.body:setPosition(player2.spawn.x, player2.spawn.y)
			elseif string.match(c, '[a-z]')then
				if(not(toggle)) then
					table.insert(objects, Button(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, c))
				else
					table.insert(objects, BlockButton(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, c))
				end
			elseif c == "&" then
				table.insert(objects, PushableWall(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, true))
			elseif c == "@" then
				table.insert(objects, PushableWall(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness, false))				
			elseif c == "$" then
				WinTrigger(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness)
			elseif c == "%" then
				table.insert(objects, GlassWall(world, x*wallThickness + wallThickness/2, y*wallThickness + wallThickness/2, wallThickness, wallThickness))
			end
			x = x + 1
		end
		
		if (x>maxX) then maxX=x end
		y = y + 1
	end
	maxY=y
	for k, v in pairs(objects) do
		for kw, w in pairs(objects) do 
			if(w.tag == "Door" and v.tag == "Button") then
				if(string.lower(w.button) == v.doors) then 
					table.insert(w.buttons, v)
				end
			end
		end
	end
	
	return maxX, maxY
end

function constrainToScreen()
	local x1, y1 = player1.body:getPosition()
	x1, y1 = cam:toScreen(x1,y1)
	local x2, y2 = player2.body:getPosition()
	x2, y2 = cam:toScreen(x2,y2)
	
	if (x1 < 0) or (x1 > width) then
		local tempPX, tempPY = player1.body:getPosition()
		player1.body:setPosition(pXOld1, tempPY)
		local tempVX, tempVY = player1.body:getLinearVelocity()
		player1.body:setLinearVelocity(0, tempVY)
	end
	if (y1 < 0) or (y1 > height) then
		local tempPX, tempPY = player1.body:getPosition()
		player1.body:setPosition(tempPX, pYOld1)
		local tempVX, tempVY = player1.body:getLinearVelocity()
		player1.body:setLinearVelocity(tempVX, 0)
	end
	if (x2 < 0) or (x2 > width) then
		local tempPX, tempPY = player2.body:getPosition()
		player2.body:setPosition(pXOld2, tempPY)
		local tempVX, tempVY = player2.body:getLinearVelocity()
		player2.body:setLinearVelocity(0, tempVY)
	end
	if (y2 < 0) or (y2 > height) then
		local tempPX, tempPY = player2.body:getPosition()
		player2.body:setPosition(tempPX, pYOld2)
		local tempVX, tempVY = player2.body:getLinearVelocity()
		player2.body:setLinearVelocity(tempVX, 0)
	end
end