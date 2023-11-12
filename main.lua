local Circle = require("Circle")
local Rectangle = require("Rectangle")
local RoundedRectangle = require("RoundedRectangle")
local ConvexPolygon = require("ConvexPolygon")

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
  init = function (self)
    self.rect = Rectangle.new(100, 80)
    self.rect:setFillColor(Palette.PURPLE)

    self.triangle = Circle.new(50, 3)
    self.triangle:setFillColor(Palette.GREEN)

    self.rounded = RoundedRectangle.new(110, 100, 14, 4)
    self.rounded:setFillColor(Palette.PINK)

    self.poly = ConvexPolygon.new(4)
    self.poly:setFillColor(Palette.BLUE)
    self.poly:setPoint(1, 0, 0)
    self.poly:setPoint(2, 30, 30)
    self.poly:setPoint(3, 0, 90)
    self.poly:setPoint(4, -30, 30)
  end,

  draw = function (self)
    love.graphics.print("Shapes", 20, 260)
    love.graphics.line(300, 0, 300, love.graphics.getHeight())
    love.graphics.line(0, 280, love.graphics.getWidth(), 280)

    self.rect:draw(20, 20)
    self.triangle:draw(200, 70, math.rad(20))
    self.rounded:draw(40, 140)
    self.poly:draw(190, 150, math.rad(-40))
  end,
}

-- Show textured shapes.
local texturesDemo = {
  init = function (self)
    local wall = love.graphics.newImage("assets/wall.png")
    wall:setWrap("repeat")

    self.circle = Circle.new(50, 6)
    self.circle:setBorderColor(Palette.PINK)
    self.circle:setBorderWidth(3)
    self.circle:setTexture(wall, true)

    self.rect = Rectangle.new(200, 100)
    self.rect:setTexture(wall)
    self.rect:setTextureQuad(0, 0, 600, 300)
    self.rect:setFillColor(Palette.ORANGE)
  end,

  draw = function (self)
    love.graphics.print("Textures", 20, love.graphics.getHeight() - 20)
    self.circle:draw(100, 350)
    self.rect:draw(30, 440)
  end
}

-- Show different kind of borders.
local bordersDemo = {
  init = function (self)
    self.rect1 = Rectangle.new(40, 40)
    self.rect1:setFillColor(0, 0, 0, 0)
    self.rect1:setBorderWidth(1)
    self.rect1:setBorderColor(1, 1, 1)

    self.rect2 = Rectangle.new(40, 40)
    self.rect2:setFillColor(Palette.PURPLE)
    self.rect2:setBorderWidth(1)
    self.rect2:setBorderColor(1, 1, 1)

    self.rect3 = Rectangle.new(40, 40)
    self.rect3:setFillColor(Palette.PURPLE)
    self.rect3:setBorderWidth(5)
    self.rect3:setBorderColor(Palette.YELLOW)

    self.rect4 = Rectangle.new(130, 40)
    self.rect4:setFillColor(Palette.PURPLE)
    self.rect4:setBorderWidth(1)
    self.rect4:setBorderColor(Palette.PURPLE)
    self.rect4:setBorderSmoothing(14)

    self.circle = Circle.new(40, 30)
    self.circle:setFillColor(Palette.GREEN)
    self.circle:setBorderWidth(10)
    self.circle:setBorderColor(Palette.PINK)

    self.rounded = RoundedRectangle.new(120, 60, 14, 6)
    self.rounded:setFillColor(Palette.YELLOW)
    self.rounded:setBorderWidth(1)
    self.rounded:setBorderSmoothing(12)
    self.rounded:setBorderColor(Palette.ORANGE)
  end,

  draw = function (self)
    love.graphics.print("Borders", 320, 260)
    self.rect1:draw(340, 40)
    self.rect2:draw(420, 40)
    self.rect3:draw(500, 40)
    self.rect4:draw(600, 40)
    self.circle:draw(400, 170)
    self.rounded:draw(540, 140)
  end,
}

-- Show axis-aligned bounding rectangles.
local boundsDemo = {
  init = function (self)
    self.poly = ConvexPolygon.new(3)
    self.poly:setPoint(1, 0, -30)
    self.poly:setPoint(2, 40, 30)
    self.poly:setPoint(3, -60, 70)
    self.poly:setFillColor(Palette.YELLOW)

    self.rect = Rectangle.new(50, 30)
    self.rect:setFillColor(Palette.ORANGE)
    self.rect:setBorderWidth(3)
    self.rect:setBorderColor(Palette.BLUE)

    self.transform = love.math.newTransform()
    self.transform:setTransformation(380, 480, 0, 1, 1)
  end,

  update = function (self, dt)
    self.transform:rotate(dt)
  end,

  draw = function (self)
    love.graphics.print("Bounds", 320, love.graphics.getHeight() - 20)

    local polyX, polyY = 400, 330
    self.poly:draw(polyX, polyY)
    self.rect:draw(self.transform)

    local x, y, w, h = self.poly:getBounds()
    love.graphics.rectangle("line", x + polyX, y + polyY, w, h)
    love.graphics.rectangle("line", self.rect:getTransformedBounds(self.transform))
  end
}

-- Show aligment of shapes to specified points.
local alignDemo = {
  init = function (self)
    self.rect = Rectangle.new(50, 50)
    self.rect:setFillColor(Palette.BLUE)
  end,

  draw = function (self)
    love.graphics.setBackgroundColor(0, 0, 0.1)
    love.graphics.print("Alignment", 500, love.graphics.getHeight() - 20)
    love.graphics.line(480, 280, 480, love.graphics.getHeight())

    self:drawAligned("left", "top", 520, 320)
    self:drawAligned("center", "top", 630, 320)
    self:drawAligned("right", "top", 740, 320)

    self:drawAligned("left", "center", 520, 430)
    self:drawAligned("center", "center", 630, 430)
    self:drawAligned("right", "center", 740, 430)

    self:drawAligned("left", "bottom", 520, 540)
    self:drawAligned("center", "bottom", 630, 540)
    self:drawAligned("right", "bottom", 740, 540)
  end,

  drawAligned = function (self, align, valign, x, y)
    self.rect:drawAligned(align, valign, x, y)
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

function love.load()
  for index = 1, #demos do
    demos[index]:init()
  end
end

function love.update(dt)
  for index = 1, #demos do
    if demos[index].update then
      demos[index]:update(dt)
    end
  end
end

function love.draw()
  for index = 1, #demos do
    demos[index]:draw()
  end
end