local BASE = (...):gsub("[^%.]*$", "")

local Shape = require(BASE .. "Shape")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

--- @class loveshape.Ellipse: loveshape.Shape
--- @field protected _radiusX number Horizontal radius
--- @field protected _radiusY number Vertical radius
local Ellipse = utils.class("loveshape.Ellipse", Shape)

--- @param radiusX number Horizontal radius
--- @param radiusY number Vertical radius
--- @param pointsCount integer Number of points used to draw the ellipse
--- @return loveshape.Ellipse
--- @nodiscard
function Ellipse.new(radiusX, radiusY, pointsCount)
  --- @type loveshape.Ellipse
  local self = setmetatable({}, Ellipse)
  self:_init(radiusX, radiusY, pointsCount)
  return self
end

--- @param radiusX number
--- @param radiusY number
--- @param pointsCount integer
--- @protected
function Ellipse:_init(radiusX, radiusY, pointsCount)
  assert(type(radiusX) == "number" and radiusX > 0)
  assert(type(radiusY) == "number" and radiusY > 0)

  Shape._init(self, pointsCount)
  self:setRadius(radiusX, radiusY)
end

--- @return number radiusX
--- @return number radiusY
--- @nodiscard
function Ellipse:getRadius()
  return self._radiusX, self._radiusY
end

--- @param radiusX number Horizontal radius
--- @param radiusY number Vertical radius
--- @return self
function Ellipse:setRadius(radiusX, radiusY)
  assert(type(radiusX) == "number" and radiusX > 0)
  assert(type(radiusY) == "number" and radiusY > 0)

  if self._radiusX ~= radiusX then
    self._radiusX = radiusX
    self._dirty = true
  end

  if self._radiusY ~= radiusY then
    self._radiusY = radiusY
    self._dirty = true
  end

  return self
end

--- Get the position of the specified point.
---
--- Requesting a non-extisting point will raise an error.
--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function Ellipse:getPoint(index)
  local pointsCount = self:getPointsCount()

  if index < 1 or index > pointsCount then
    error("Invalid point index: " .. tostring(index))
  end

  local angle = (math.pi * 2) / pointsCount
  local x, y = utils.vecFromAngle(angle * (index - 1))

  return x * self._radiusX, y * self._radiusY
end

return Ellipse