local Circle = require("Circle")
local Rectangle = require("Rectangle")
local RoundedRectangle = require("RoundedRectangle")
local ConvexPolygon = require("ConvexPolygon")

local rect
local roundedRect
local circle
local convex

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

  convex = ConvexPolygon.new(3)
  convex:setFillColor(1, 0, 0)
  convex:setBorderWidth(5)
  convex:setPoint(1, 0, -20):setPoint(2, 20, 30):setPoint(3, -20, 50)
end

function love.draw()
  rect:draw(100, 100)
  circle:draw(400, 100)
  roundedRect:draw(50, 400)
  convex:draw(200, 200)
end