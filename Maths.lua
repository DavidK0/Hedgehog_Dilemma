--normalizes a vector2
function math.normalize(vector)
	local mag = math.sqrt(vector[1]^2 + vector[2]^2)
	return {vector[1]/mag, vector[2]/mag}
end

--takes angle and returns the quadrant that the angle is in (1,2,3,4)
--USES LOVES INCORRECT ANGLE SYSTEM
--  4 | 1
--  --|--
--  3 | 2
function getQuadrant(angle)
	if angle >= 0 and angle < math.pi/2 then
		return 1
	elseif angle >= math.pi/2 and angle < math.pi then
		return 2
	elseif angle >= math.pi and angle < math.pi*1.5 then
		return 3
	elseif angle >= math.pi*1.5 and angle < math.pi*2 then
		return 4
	else
		return "bad angle"
	end
end

function smallestAngle(a,b)
	if b>a then
		local c = a
		a = b
		b = c
	end
	
	return math.abs(math.atan2(math.sin(a-b), math.cos(a-b)))
end

function math.magXvec(mag, vec)
	return {mag*vec[1],mag*vec[2]}
end