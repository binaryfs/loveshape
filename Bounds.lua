--- Represents an axis-aligned bounding rectangle.
--- @class loveshape.Bounds
--- @field minX number X coordinate of top-left corner
--- @field minY number Y coordinate of top-left corner
--- @field maxX number X coordinate of bottom-right corner
--- @field maxY number Y coordinate of bottom-right corner
local Bounds = {}
Bounds.__index = Bounds

--- @return loveshape.Bounds
--- @nodiscard
function Bounds.new()
  --- @type loveshape.Bounds
  local self = setmetatable({}, Bounds)
  return self:reset()
end

--- @return self
function Bounds:reset()
  self.minX = math.huge
  self.minY = math.huge
  self.maxX = -math.huge
  self.maxY = -math.huge
  return self
end

--- @param other loveshape.Bounds
--- @return self
function Bounds:copyFrom(other)
  self.minX = other.minX
  self.minY = other.minY
  self.maxX = other.maxX
  self.maxY = other.maxY
  return self
end

--- @return number width
--- @nodiscard
function Bounds:getWidth()
  return self.maxX - self.minX
end

--- @return number height
--- @nodiscard
function Bounds:getHeight()
  return self.maxY - self.minY
end

--- Update the bounding rect so that it contains the specified point.
--- @param x number
--- @param y number
--- @return self
function Bounds:addPoint(x, y)
  self.minX = x < self.minX and x or self.minX
  self.minY = y < self.minY and y or self.minY
  self.maxX = x > self.maxX and x or self.maxX
  self.maxY = y > self.maxY and y or self.maxY
  return self
end

return Bounds