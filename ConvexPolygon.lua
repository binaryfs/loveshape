local BASE = (...):gsub("[^%.]*$", "")
local Shape = require(BASE .. "Shape")
local utils = require(BASE .. "utils")

--- @class loveshape.ConvexPolygon: loveshape.Shape
--- @field protected _points table
local ConvexPolygon = utils.copyTable(Shape)
ConvexPolygon.__index = ConvexPolygon

--- @param pointsCount integer Number of polygon points
--- @return loveshape.ConvexPolygon
--- @nodiscard
function ConvexPolygon.new(pointsCount)
  --- @type loveshape.ConvexPolygon
  local self = setmetatable({}, ConvexPolygon)
  self:_init(pointsCount)
  return self
end

--- @param pointsCount integer
--- @protected
function ConvexPolygon:_init(pointsCount)
  Shape._init(self, pointsCount)
  self._points = {}

  for index = 1, self:getPointsCount() * 2 do
    self._points[index] = 0
  end
end

--- @return boolean
--- @nodiscard
function ConvexPolygon:isConvex()
  return love.math.isConvex(self._points)
end

--- Get the position of the specified point.
--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function ConvexPolygon:getPoint(index)
  if index < 1 or index > self:getPointsCount() then
    error("Invalid point index: " .. tostring(index))
  end

  local offset = (index - 1) * 2
  return self._points[offset + 1], self._points[offset + 2]
end

--- Set the position of the specified point.
--- @param index integer
--- @param x number
--- @param y number
--- @return self
function ConvexPolygon:setPoint(index, x, y)
  if index < 1 or index > self:getPointsCount() then
    error("Invalid point index: " .. tostring(index))
  end

  local offset = (index - 1) * 2
  self._points[offset + 1] = x
  self._points[offset + 2] = y

  return self
end

return ConvexPolygon