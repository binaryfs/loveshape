local Circle = require("Circle")
local Rectangle = require("Rectangle")
local RoundedRectangle = require("RoundedRectangle")

local rect
local roundedRect
local circle

function love.load()
  rect = Rectangle.new(200, 100)
  rect:setFillColor(1, 1, 1, 1)
  rect:setBorderWidth(10)
  rect:setBorderColor(1, 0, 0)

  roundedRect = RoundedRectangle.new(200, 100, 30, 6)
  roundedRect:setFillColor(1, 0, 1)
  roundedRect:setBorderWidth(5)
  roundedRect:setBorderColor(0, 1, 1)

  circle = Circle.new(50, 6)
  circle:setFillColor(0, 1, 0)
  circle:setBorderWidth(5)
end

function love.draw()
  rect:draw(100, 100)
  circle:draw(400, 100)
  roundedRect:draw(50, 400)
end