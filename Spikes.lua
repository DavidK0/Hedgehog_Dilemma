--normalizes a vector2
function math.normalize(vector)
	local mag = math.sqrt(vector[1]^2 + vector[2]^2)
	return {vector[1]/mag, vector[2]/mag}
end

--run once in love.load; initializes values used for working with spikes
function loadSpikes(num) --optional number of spikes
	numSpikes =  num or 20 --the total number of spikes that eject for hedge
	spikes = {} --array to hold each spike object
	spikeWidth = 3 --the collision box width
	spikeHeight = 16 --the collision box height
	spikeSpeed = 2700 --the speed of a spike in ? units
	spikeDelay = 2 --number of seconds the spikes display until they fire
	spikeWiggle = 3 --amount the spikes wiggle; 0 for no wiggle
	spikeVariation = 3 --variation in the way spikes are spread around the ellipse
	spikeGrowR = 10 --distance the spikes grow during spikeDelay
end

--initializes some spikes at the hedgehogs position
function createSpikes(parent)
	--create some spikes
	spikes = {}
	for spikeNum = 1, numSpikes do
		table.insert(spikes, newSpike(spikeNum, parent))
	end
	return spikes
end

--creats and invidual spike
function newSpike(spikeNum, parent)
	--spike object
	local spike = {}
	
	--caluculate /spike
	spike.angle = 2 * math.pi * (spikeNum/numSpikes) * (math.random()/10+.95)
	
	spike.parent = parent --parent hedgehog to the spike
	spike.age = 0 --age of spike in seconds
	local x, y = calculateSpikePos(spike)
	
	spike.body = love.physics.newBody(world, x, y, "dynamic")
	spike.shape = love.physics.newRectangleShape(spikeWidth, spikeHeight)
	spike.fixture = love.physics.newFixture(spike.body, spike.shape)
	
	spike.dx, spike.dy = calculateSpikeDir(spike)
	
	offCicle = 0
	spike.update = updateSpike --update funtion
	spike.draw = drawSpike --draw function
	
	spike.fixture:setUserData(spike) --andrew uses this for something
	spike.tag = "Spike"
	spike.fixture:setSensor(true) --initilize spike to not collide with hedge hog
	spike.ejected = false --whether or not the spike has been ejected/launched
	spike.beginCollision = spikeBeginCollision
	spike.destroy = destroySpike
	spike.stuck = false
	--spike.body:applyForce(spike.dx, spike.dy)
	return spike
end

--updates position and velocity 
function updateSpike(obj, dt) --TODO: check spike collision with hedgehog while in sensor mode
	--update position and velocity
	obj.age = obj.age + dt
	if obj.age >= spikeDelay then --only eject spikes after spikeDelay
		if not obj.ejected then
			local tempAngle = math.atan2(obj.dy,obj.dx)-- + obj.parent.body:getAngle()
			
			obj.body:applyForce(math.cos(tempAngle) * spikeSpeed, math.sin(tempAngle) * spikeSpeed)
			obj.ejected = true
		else
			
			--if obj.age >= 10 then spik
		end
		local vx, vy = obj.body:getPosition()
		obj.DrawAngle = -math.atan2(vy, vx) 
	else --spike is not ready to be ejected
		local x, y = calculateSpikePos(obj)
		obj.body:setPosition(x, y) --keep spike with hedgehog
		--obj.drawAngle = obj.angle + obj.parent.body:getAngle()
		local a, b = calculateSpikeDir(obj)
		obj.dx = a
		obj.dy = b
		obj.drawAngle = math.atan2(b,a) +math.pi
	end
	
end

--simply draws the spike; will be updated later
function drawSpike(obj)
	--drawObject
	local x, y = obj.body:getPosition()
	local ori = obj.body:getAngle()
	
	local wigAngle = (math.random() * spikeWiggle/20)-spikeWiggle/2/20
	love.graphics.draw(spikeImgs[1], x, y, obj.drawAngle - math.pi/2 + wigAngle, 1, 1, 1, 1) --don't know why multiply obj.parent.body:getAngle() by two, but it works
end

--calculate where the spike should be when connected to hedge
function calculateSpikePos(obj)
	local pX, pY = obj.parent.body:getPosition()
	--equation for ellipse based on major axis, minor axis, and angle
	--spike wiggle
	--[[local wigX = (math.random() * spikeWiggle)-spikeWiggle/2
	local wigY = (math.random() * spikeWiggle)-spikeWiggle/2
	--angle is shifted by parent angle
	----local x = x + (obj.parent.width/1.5 - offset + spikeHeight*.2) * math.cos(obj.angle + obj.parent.body:getAngle()) + wigX
	----local y = y + (obj.parent.height/1.5 - offset + spikeHeight*.2) * math.sin(obj.angle + obj.parent.body:getAngle()) + wigY]]
	
	local offset = spikeGrowR * math.max((spikeDelay*1.5)/(2*obj.age+spikeDelay)-.5,0)
	local x = (obj.parent.width/1.5 - offset) * math.cos(obj.angle)
	local y = (obj.parent.height/1.5 - offset) * math.sin(obj.angle)
	
	local yVec = math.normalize({math.cos(obj.parent.body:getAngle()-math.pi/2),math.sin(obj.parent.body:getAngle()-math.pi/2)})
	local xVec = math.normalize({math.cos(obj.parent.body:getAngle()-math.pi),math.sin(obj.parent.body:getAngle()-math.pi)})
	
	return math.magXvec(y,yVec)[1]+math.magXvec(x,xVec)[1]+pX, math.magXvec(y,yVec)[2]+math.magXvec(x,xVec)[2]+pY
end

--calculate the direction of the spike when connected to hedge
function calculateSpikeDir(obj)
	local x1, y1 = obj.body:getPosition()
	local x2, y2 = obj.parent.body:getPosition()
	local dir = math.normalize({(x1 - x2),(y1 - y2)})
	local dx = dir[1]
	local dy = dir[2]
	
	return dx, dy
end

function destroySpike(spike)
	for k, v in ipairs(objects) do
		if(v == spike) then
			table.remove(objects, k)
		end
	end
	spike.fixture:destroy()
end

function spikeBeginCollision(spike, other, coll) 
	if(other.tag == "GlassWall") then
		other:destroy()
		spike:destroy()
	end
	if(other.tag == "Wall" or other.tag == "Door") then
		if(math.random() < 0.5) then
			spike.body:setLinearDamping(150)
			spike.stuck = true
		else
			spike:destroy()
		end
	end
end

function spikeEndCollision(spike, other, coll)
	
end