--returns a new timer object
function newTimer()
	timer = {time = 0,
			frame = 0,
			update = timerUpdate,
			everySec = timerSecond,
			everyFrame = timerFrame,
			prevTime = 0
			}
	return timer
end

--updates timer objects time and frame count every frame
function timerUpdate(obj, dt)
	obj.prevTime = obj.time
	obj.time = obj.time + dt
	obj.frame = obj.frame + 1
end

--returns true every 'sec' seconds
function timerSecond(obj, sec)
	if (obj.prevTime%sec > obj.time%sec) then
		return true
	else
		return false
	end
end

--returns true every 'frame' frames
function timerFrame(object, frame)
	if (obj.frame == frame) then
		return true
	else
		return false
	end
end