-- LÖVE demo

local loveshape = require("init")
local loveunit = require("loveunit")

local Palette = {
  PURPLE = {137 / 255, 33 / 255, 194 / 255},
  PINK = {254 / 255, 57 / 255, 164 / 255},
  YELLOW = {1, 253 / 255, 187 / 255},
  GREEN = {83 / 255, 232 / 255, 212 / 255},
  BLUE = {37 / 255, 196 / 255, 248 / 255},
  ORANGE = {1, 149 / 255, 53 / 255}
}

-- Show some basic shapes.
local shapesDemo = {
  name = "Shapes",

  init = function (self)
    self.rect = loveshape.Rectangle.new(300, 200)
    self.rect:setFillColor(Palette.PURPLE)

    self.circle = loveshape.Circle.new(180, 40)
    self.circle:setFillColor(Palette.YELLOW)

    self.triangle = loveshape.Circle.new(60, 3)
    self.triangle:setFillColor(Palette.GREEN)
    self.triangle:setEdgeSmoothing(10)

    self.pentagon = loveshape.Circle.new(70, 5)
    self.pentagon:setFillColor(Palette.PINK)

    self.rounded = loveshape.RoundedRectangle.new(200, 100, 14, 4)
    self.rounded:setFillColor(Palette.PINK)

    self.pill = loveshape.RoundedRectangle.new(200, 60, 30, 6)
    self.pill:setFillColor(Palette.ORANGE)

    self.bevel = loveshape.RoundedRectangle.new(200, 120, 20, 2)
    self.bevel:setFillColor(Palette.BLUE)

    self.poly = loveshape.ConvexPolygon.new(4)
    self.poly:setFillColor(Palette.BLUE)
    self.poly:setPoint(1, 0, 0)
    self.poly:setPoint(2, 30, 30)
    self.poly:setPoint(3, 0, 90)
    self.poly:setPoint(4, -30, 30)
  end,

  draw = function (self)
    self.circle:draw(500, 500)
    self.rect:draw(100, 100)
    self.triangle:draw(400, 200)
    self.pentagon:draw(600, 160)
    self.rounded:draw(80, 430)
    self.pill:draw(260, 340)
    self.bevel:draw(560, 250)
    self.poly:draw(190, 150, math.rad(-40))
  end,
}

-- Show textured shapes.
local texturesDemo = {
  name = "Textures",

  init = function (self)
    local wall = love.graphics.newImage("assets/wall.png")
    wall:setWrap("repeat")

    self.circle = loveshape.Circle.new(150, 6)
    self.circle:setBorderColor(Palette.PINK)
    self.circle:setBorderWidth(10)
    self.circle:setTexture(wall, true)

    self.rect = loveshape.Rectangle.new(300, 200)
    self.rect:setTexture(wall)
    self.rect:setTextureQuad(0, 0, 600, 300)
    self.rect:setFillColor(Palette.ORANGE)
  end,

  draw = function (self)
    self.circle:draw(250, 250)
    self.rect:draw(420, 360)
  end
}

-- Show different kind of borders.
local bordersDemo = {
  name = "Borders",

  init = function (self)
    self.rects = {}

    self.rects[1] = loveshape.Rectangle.new(100, 100)
    self.rects[1]:setFillColor(0, 0, 0, 0)
    self.rects[1]:setBorderWidth(1)
    self.rects[1]:setBorderColor(1, 1, 1)

    self.rects[2] = loveshape.Rectangle.new(100, 100)
    self.rects[2]:setFillColor(Palette.PURPLE)
    self.rects[2]:setBorderWidth(1)
    self.rects[2]:setBorderColor(1, 1, 1)

    self.rects[3] = loveshape.Rectangle.new(100, 100)
    self.rects[3]:setFillColor(Palette.PURPLE)
    self.rects[3]:setBorderWidth(10)
    self.rects[3]:setBorderColor(Palette.GREEN)

    self.rects[4] = loveshape.Rectangle.new(100, 100)
    self.rects[4]:setFillColor(Palette.PURPLE)
    self.rects[4]:setBorderWidth(5)
    self.rects[4]:setBorderColor(Palette.GREEN)
    self.rects[4]:setBorderSmoothing(10)

    self.circle = loveshape.Circle.new(100, 100)
    self.circle:setFillColor(Palette.PURPLE)
    self.circle:setBorderWidth(10)
    self.circle:setBorderColor(Palette.ORANGE)

    self.rounded = loveshape.RoundedRectangle.new(200, 100, 14, 6)
    self.rounded:setFillColor(Palette.ORANGE)
    self.rounded:setBorderWidth(2)
    self.rounded:setBorderSmoothing(12)
    self.rounded:setBorderColor(Palette.YELLOW)
  end,

  draw = function (self)
    self.rects[1]:draw(80, 150)
    self.rects[2]:draw(240, 150)
    self.rects[3]:draw(400, 150)
    self.rects[4]:draw(560, 150)
    self.circle:draw(240, 450)
    self.rounded:draw(440, 400)
  end,
}

-- Show axis-aligned bounding rectangles.
local boundsDemo = {
  name = "Bounds",

  init = function (self)
    self.diamonds = {}

    self.diamonds[1] = loveshape.Circle.new(60, 4)
    self.diamonds[1]:setFillColor(Palette.PINK)

    self.diamonds[2] = loveshape.Circle.new(60, 4)
    self.diamonds[2]:setFillColor(Palette.PINK)
    self.diamonds[2]:setBorderWidth(10)
    self.diamonds[2]:setBorderColor(Palette.BLUE)

    self.diamonds[3] = loveshape.Circle.new(60, 4)
    self.diamonds[3]:setFillColor(Palette.PINK)
    self.diamonds[3]:setBorderWidth(10)
    self.diamonds[3]:setBorderSmoothing(20)
    self.diamonds[3]:setBorderColor(Palette.BLUE)

    self.rect = loveshape.Rectangle.new(200, 100)
    self.rect:setFillColor(Palette.ORANGE)

    self.transform = love.math.newTransform()
    self.transform:setTransformation(380, 480, 0, 1, 1)
  end,

  update = function (self, dt)
    self.transform:rotate(dt)
  end,

  draw = function (self)
    self:drawDiamond(1, 200, 200)
    self:drawDiamond(2, 400, 200)
    self:drawDiamond(3, 600, 200)

    self.rect:draw(self.transform)
    love.graphics.rectangle("line", self.rect:getTransformedBounds(self.transform))
  end,

  drawDiamond = function (self, index, x, y)
    local bx, by, bw, bh = self.diamonds[index]:getBounds()
    self.diamonds[index]:draw(x, y)
    love.graphics.rectangle("line", bx + x, by + y, bw, bh)
  end,
}

-- Show aligment of shapes to specified points.
local alignDemo = {
  name = "Alignment",

  init = function (self)
    self.rects = {}

    self.rects[1] = loveshape.Rectangle.new(100, 100)
    self.rects[1]:setFillColor(Palette.PURPLE)

    self.rects[2] = loveshape.Rectangle.new(100, 100)
    self.rects[2]:setFillColor(Palette.PURPLE)
    self.rects[2]:setBorderWidth(10)
    self.rects[2]:setBorderColor(Palette.ORANGE)

    self.circle = loveshape.Circle.new(50, 8)
    self.circle:setFillColor(Palette.GREEN)
  end,

  draw = function (self)
    self:drawAligned(self.rects[1], "left", "top", 100, 100)
    self:drawAligned(self.rects[1], "center", "top", 400, 100)
    self:drawAligned(self.rects[2], "right", "top", 700, 100)

    self:drawAligned(self.rects[1], "left", "center", 100, 330)
    self:drawAligned(self.rects[2], "center", "center", 400, 330)
    self:drawAligned(self.rects[1], "right", "center", 700, 330)

    self:drawAligned(self.rects[2], "left", "bottom", 100, 560)
    self:drawAligned(self.rects[1], "center", "bottom", 400, 560)
    self:drawAligned(self.circle, "right", "bottom", 700, 560)
  end,

  drawAligned = function (self, shape, align, valign, x, y)
    shape:drawAligned(align, valign, x, y)
    self.drawCrossmark(x + 0.5, y + 0.5)
  end,

  drawCrossmark = function (x, y, size)
    size = size or 3
    love.graphics.line(x - size, y, x + size, y)
    love.graphics.line(x, y - size, x, y + size)
  end,
}

local demos = {
  shapesDemo,
  texturesDemo,
  bordersDemo,
  boundsDemo,
  alignDemo,
}

local demoIndex = 1

local function runUnitTests()
  loveunit.runTestFiles("tests")
  local success, report = loveunit.report()

  if not success then
    print(report)
    error("Unit tests failed!")
  end
end

function love.load()
  runUnitTests()

  for index = 1, #demos do
    demos[index]:init()
  end
end

function love.update(dt)
  if demos[demoIndex].update then
    demos[demoIndex]:update(dt)
  end
  love.graphics.setWireframe(love.keyboard.isDown("w"))
end

function love.draw()
  love.graphics.setBackgroundColor(0, 0, 0.1)

  -- Draw tabs
  for index, demo in ipairs(demos) do
    if index == demoIndex then
      love.graphics.rectangle("fill", 10 + (index - 1) * 120, 10, 100, 28)
      love.graphics.setColor(0, 0, 0)
    else
      love.graphics.rectangle("line", 10 + (index - 1) * 120, 10, 100, 28)
    end
    love.graphics.printf(demo.name, 10 + (index - 1) * 120, 16, 100, "center")
    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.print("Press arrow keys to switch demos. Hold W to show wireframes.", 10, 50)

  demos[demoIndex]:draw()
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == "left" and not isrepeat then
    demoIndex = demoIndex == 1 and #demos or demoIndex - 1
  elseif scancode == "right" and not isrepeat then
    demoIndex = demoIndex == #demos and 1 or demoIndex + 1
  end
end