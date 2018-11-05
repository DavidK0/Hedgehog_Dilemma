--loads all game images
function loadImgs(root)
	root = root or "/assets/" --defaults to the "/assets" root for all images
	
	spikeImgs = {}
	for i = 1, 1 do
		table.insert(spikeImgs, love.graphics.newImage(root .. "spikes/spike" .. i .. ".png"))
	end
	wallImg = love.graphics.newImage(root .. "tiles.png")
	doorImg = love.graphics.newImage(root .. "door.png")
	doorImg2 = love.graphics.newImage(root .. "door2.png")
	buttonImg = love.graphics.newImage(root .. "button.png")
	hedgeTexture = love.graphics.newImage(root .. "hedge.png")
	background = love.graphics.newImage(root .. "background.png")
	
	titleImg = love.graphics.newImage(root .. "title.png")
	mainMenuImg = love.graphics.newImage(root .. "mainMenu.png")
	winImg = love.graphics.newImage(root .. "win.png")
	
	src1 = love.audio.newSource("assets/track6.mp3", "static")
	kongrad = love.audio.newSource("assets/ending kongrad.mp3", "static")
end