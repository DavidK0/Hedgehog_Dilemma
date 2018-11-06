--loads all game images
function loadImgs(root)
	root = root or "/assets/" --defaults to the "/assets" root for all images
	
	spikeImgs = {}
	for i = 1, 1 do
		table.insert(spikeImgs, love.graphics.newImage(root .. "spikes/spike" .. i .. ".png"))
	end
	
	math.randomseed(os.time())
	math.random()
	math.random()
	math.random()
	
	tracks = {}
	for i = 1, 10 do
		table.insert(tracks, love.audio.newSource("assets/music/track"..i..".mp3", "static"))
	end
	
	wallImgs = {}
	for i = 1, 5 do
		table.insert(wallImgs, love.graphics.newImage("assets/walls/wall"..i..".png"))
	end
	
	currentTrack = tracks[math.random(10)]
	doorImg = love.graphics.newImage(root .. "door.png")
	doorImg2 = love.graphics.newImage(root .. "door2.png")
	buttonUpImg = love.graphics.newImage(root .. "buttonUp.png")
	buttonDownImg = love.graphics.newImage(root .. "buttonDown.png")
	hedgeTexture = love.graphics.newImage(root .. "hedge.png")
	background = love.graphics.newImage(root .. "background.png")
	
	titleImg = love.graphics.newImage(root .. "title.png")
	mainMenuImg = love.graphics.newImage(root .. "mainMenu.png")
	winImg = love.graphics.newImage(root .. "win.png")
	controlsImg = love.graphics.newImage(root .. "controls.png")
	pushableWallNoDestroyImage = love.graphics.newImage(root .. "movebox.jpg")
	pushableWallDestroyImage = love.graphics.newImage(root .. "glass.png")
	
	
	src1 = love.audio.newSource("assets/track6.mp3", "static")
	kongrad = love.audio.newSource("assets/ending kongrad.mp3", "static")
end

function playRandomTrack()
	if not currentTrack:isPlaying() then
		currentTrack = tracks[math.random(10)]
		currentTrack:play()
	end
end