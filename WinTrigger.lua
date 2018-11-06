function WinTrigger(world, x, y, width, height)
	local trigger = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width, height)
	}
	trigger.fixture = love.physics.newFixture(trigger.body, trigger.shape)
	trigger.beginCollision = triggerBeginCollision
	trigger.endCollision = triggerEndCollision
	trigger.fixture:setSensor(true)
	trigger.fixture:setUserData(trigger)
	return trigger
end

function triggerBeginCollision(trigger, other, coll)
	if(other.tag == "Player") then
		other.won = true
	end
end

function triggerEndCollision(trigger, other, coll)
	if(other.tag == "Player") then
		other.won = false
	end
end
