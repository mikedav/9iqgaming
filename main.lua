local map -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles
 
local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.
 
local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local zoomX, zoomY
 
local tilesetImage
local tileSize = 32-- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles
local tilesetSprite
 
function love.load()
  setupMap()
  setupMapView()
  setupTileset()
  love.physics.setMeter(tileSize) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 2*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  objects = {}

  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, mapWidth*tileSize/2, love.graphics.getHeight()+1000-25) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(mapWidth*tileSize/2, 50) --make a rectangle with a width of 650 and a height of 50
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
 
  --let's create a ball
  objects.ball = {}
  objects.ball.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  objects.ball.shape = love.physics.newCircleShape( 20) --the ball's shape has a radius of 20
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
  objects.ball.fixture:setRestitution(0.9)
  --love.graphics.setFont(12)
end
 
function setupMap()
  mapWidth = 1000
  mapHeight = 500
 
  map = {}
  for x=1,mapWidth do
    map[x] = {}
    for y=1,mapHeight do
      map[x][y] = love.math.random(0,2)
    end
  end
end
 
function setupMapView()
  mapX = 1
  mapY = 1
  tilesDisplayWidth = love.graphics.getWidth()/tileSize+1;
  tilesDisplayHeight = love.graphics.getHeight()/tileSize+2;
 
  zoomX = 1
  zoomY = 1
end
 
function setupTileset()
  tilesetImage = love.graphics.newImage( "res/tileset1.png" )
  tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
  
 
  -- grass
  tileQuads[0] = love.graphics.newQuad(0 * tileSize, 0 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- kitchen floor tile
  tileQuads[1] = love.graphics.newQuad(0 * tileSize, 1 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- parquet flooring
  tileQuads[2] = love.graphics.newQuad(0 * tileSize, 2 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- middle of red carpet
  tileQuads[3] = love.graphics.newQuad(3 * tileSize, 9 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
 
  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, tilesDisplayWidth * tilesDisplayHeight)
 
  updateTilesetBatch()
end
 
function updateTilesetBatch()
  tilesetBatch:clear()
  for x=0, tilesDisplayWidth-1 do
    for y=0, tilesDisplayHeight-1 do
      	if(x + mapX>0 and y + mapY>0 and x + mapX<mapWidth and y + mapY<mapHeight) then
      		tilesetBatch:add(tileQuads[map[x+math.floor(mapX)][y+math.floor(mapY)]],
        	x*tileSize, y*tileSize)
        else
        	tilesetBatch:add(tileQuads[0],
        	x*tileSize, y*tileSize)
  		end
    end
  end
  tilesetBatch:flush()
end
 
-- central function for moving the map
function moveMap(dx, dy)
  oldMapX = mapX
  oldMapY = mapY
  mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
  mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
  -- only update if we actually moved
  if math.floor(mapX) ~= math.floor(oldMapX) or math.floor(mapY) ~= math.floor(oldMapY) then
    updateTilesetBatch()
  end
end
 
function love.update(dt)
	world:update(dt);
	if(objects.ball.body:getLinearVelocity()>-200) then
  		if love.keyboard.isDown("left")  then
    	--moveMap(-0.2 * tileSize * dt, 0)
    		objects.ball.body:applyForce(-500,0);
  		end
  	end;
  	if(objects.ball.body:getLinearVelocity()<200) then
  		if love.keyboard.isDown("right")  then
    		--moveMap(0.2 * tileSize * dt, 0)
    		objects.ball.body:applyForce(500,0);
  		end
  	end
  mapX = objects.ball.body:getX()/tileSize;
  mapY = objects.ball.body:getY()/tileSize;
  updateTilesetBatch()
end
 
function love.draw()
  love.graphics.draw(tilesetBatch,
    math.floor(-zoomX*(mapX%1)*tileSize), math.floor(-zoomY*(mapY%1)*tileSize),
    0, zoomX, zoomY)
  -- draw a "filled in" polygon using the ground's coordinates
 
  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.circle("fill", love.graphics.getWidth()	/2, love.graphics.getHeight()/2, objects.ball.shape:getRadius())
  love.graphics.polygon("fill", objects.ground.shape:getPoints());
  love.graphics.setColor(0,0,0);
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
  love.graphics.print(objects.ball.body:getX(),10, 40);
  love.graphics.print(objects.ball.body:getY(),10,60);
  love.graphics.print(objects.ball.body:getLinearVelocity(),10, 80);
  love.graphics.setColor(150, 150, 150)

end