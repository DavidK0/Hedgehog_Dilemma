

function beginContact(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.beginCollision ~= nil) then
			aObj:beginCollision(bObj, coll)
		end
		if(bObj.beginCollision ~= nil) then
			bObj:beginCollision(aObj, coll)
		end
	end
end

function endContact(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.endCollision ~= nil) then
			aObj:endCollision(bObj, coll)
		end
		if(bObj.endCollision ~= nil) then
			bObj:endCollision(aObj, coll)
		end
	end
end
 
function preSolve(a, b, coll)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.preSolve ~= nil) then
			aObj:preSolve(bObj, coll)
		end
		if(bObj.preSolve ~= nil) then
			bObj:preSolve(aObj, coll)
		end
	end
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	aObj = a:getUserData()
	bObj = b:getUserData()
	if(aObj ~= nil and bObj ~= nil) then 
		if(aObj.postSolve ~= nil) then
			aObj:postSolve(bObj, coll)
		end
		if(bObj.postSolve ~= nil) then
			bObj:postSolve(aObj, coll)
		end
	end
end