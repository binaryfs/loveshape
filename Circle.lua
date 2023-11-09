local BASE = (...):gsub("[^%.]*$", "")
local Shape = require(BASE .. "Shape")
local utils = require(BASE .. "utils")

--- @class loveshape.Circle: loveshape.Shape
--- @field protected _radius number
local Circle = utils.copyTable(Shape)
Circle.__index = Circle

--- @param radius number
--- @param pointsCount integer
--- @return loveshape.Circle
--- @nodiscard
function Circle.new(radius, pointsCount)
  --- @type loveshape.Circle
  local self = setmetatable({}, Circle)
  self:_init(radius, pointsCount)
  return self
end

--- @param radius number
--- @param pointsCount integer
--- @protected
function Circle:_init(radius, pointsCount)
  assert(type(radius) == "number" and radius > 0)

  Shape._init(self, pointsCount)
  self._radius = radius
end

--- @return number radius
--- @nodiscard
function Circle:getRadius()
  return self._radius
end

--- @param radius number
--- @return self
function Circle:setRadius(radius)
  assert(type(radius) == "number" and radius > 0)

  if self._radius ~= radius then
    self._radius = radius
    self._dirty = true
  end

  return self
end

--- Get the position of the specified point.
--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function Circle:getPoint(index)
  local pointsCount = self:getPointsCount()

  if index < 1 or index > pointsCount then
    error("Invalid point index: " .. tostring(index))
  end

  local angle = (math.pi * 2) / pointsCount
  return utils.vecFromAngle(angle * (index - 1), self._radius)
end

return Circle