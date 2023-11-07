local BASE = (...):gsub("[^%.]*$", "")
local Rectangle = require(BASE .. "Rectangle")
local utils = require(BASE .. "utils")

--- Represents a rectangle with rounded corners.
--- @class loveshape.RoundedRectangle: loveshape.Rectangle
--- @field protected _cornerRadius number
--- @field protected _pointsPerCorner integer
local RoundedRectangle = utils.copyTable(Rectangle)
RoundedRectangle.__index = RoundedRectangle

--- @param width number
--- @param height number
--- @param cornerRadius number
--- @param pointsPerCorner integer Number of points to represent a rounded corner
--- @return loveshape.RoundedRectangle
--- @nodiscard
function RoundedRectangle.new(width, height, cornerRadius, pointsPerCorner)
  --- @type loveshape.RoundedRectangle
  local self = setmetatable({}, RoundedRectangle)
  self:_init(width, height, cornerRadius, pointsPerCorner)
  return self
end

--- @param width number
--- @param height number
--- @param cornerRadius number
--- @param pointsPerCorner integer
--- @protected
function RoundedRectangle:_init(width, height, cornerRadius, pointsPerCorner)
  assert(type(cornerRadius) == "number" and cornerRadius > 0)
  assert(type(pointsPerCorner) == "number" and pointsPerCorner >= 2)

  Rectangle._init(self, pointsPerCorner * 4, width, height)
  self._cornerRadius = cornerRadius
  self._pointsPerCorner = pointsPerCorner
end

--- Get the position of the specified point.
--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function RoundedRectangle:getPoint(index)
  if index < 1 or index > self:getPointsCount() then
    error("Invalid point index: " .. tostring(index))
  end

  local corner = math.ceil(index / self._pointsPerCorner)
  local centerX, centerY
  local cornerRadius = math.min(self._cornerRadius, self._width / 2, self._height / 2)

  if corner == 1 then
    centerX = cornerRadius
    centerY = cornerRadius
  elseif corner == 2 then
    centerX = self._width - cornerRadius
    centerY = cornerRadius
  elseif corner == 3 then
    centerX = self._width - cornerRadius
    centerY = self._height - cornerRadius
  elseif corner == 4 then
    centerX = cornerRadius
    centerY = self._height - cornerRadius
  end

  local anglePerSegment = (math.pi / 2) / (self._pointsPerCorner - 1)
  local cornerPointIndex = (index - 1) % self._pointsPerCorner
  local cornerAngleOffset = (math.pi / 2) * (corner + 1)
  local x, y = utils.vecFromAngle(anglePerSegment * cornerPointIndex + cornerAngleOffset, cornerRadius)

  return centerX + x, centerY + y
end

return RoundedRectangle