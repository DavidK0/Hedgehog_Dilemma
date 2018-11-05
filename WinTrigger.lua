function WinTrigger(world, x, y, width, height)
	local trigger = {
		body = love.physics.newBody(world, x, y),
		shape = love.physics.newRectangleShape(width, height)
	}
	trigger.fixture = love.physics.newFixture(trigger.body, trigger.shape)
	trigger.beginCollision = triggerBeginCollision
	trigger.fixture:setSensor(true)
	trigger.fixture:setUserData(trigger)
	return trigger
end

function triggerBeginCollision(trigger, other, coll)
	if(other.tag == "Player") then
		hasWon = true
	end
end
