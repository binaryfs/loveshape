local BASE = (...):gsub("[^%.]*$", "")

local Object = require(BASE .. "Object")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

--- Represents an axis-aligned bounding rectangle.
---
--- This class is used internally by loveshape.
--- @class loveshape.Bounds: loveshape.Object
--- @field minX number X coordinate of top-left corner
--- @field minY number Y coordinate of top-left corner
--- @field maxX number X coordinate of bottom-right corner
--- @field maxY number Y coordinate of bottom-right corner
local Bounds = utils.class("loveshape.Bounds", Object)

--- Create a new bounds object with infinite dimensions.
--- @return loveshape.Bounds
--- @nodiscard
function Bounds.new()
  --- @type loveshape.Bounds
  local self = setmetatable({}, Bounds)
  return self:reset()
end

--- Set the dimensions of the bounds.
--- @param minX number
--- @param minY number
--- @param maxX number
--- @param maxY number
--- @return self
function Bounds:set(minX, minY, maxX, maxY)
  self.minX = assert(minX, "minX required")
  self.minY = assert(minY, "minY required")
  self.maxX = assert(maxX, "maxX required")
  self.maxY = assert(maxY, "maxY required")
  return self
end

--- Get the dimensions of the bounds.
--- @return number minX
--- @return number minY
--- @return number maxX
--- @return number maxY
--- @nodiscard
function Bounds:unpack()
  return self.minX, self.minY, self.maxX, self.maxY
end

--- Get a rectangle of the bounds.
--- @return number x
--- @return number y
--- @return number width
--- @return number height
--- @nodiscard
function Bounds:getRect()
  return self.minX, self.minY, self:getWidth(), self:getHeight()
end

--- @return boolean empty
--- @nodiscard
function Bounds:isEmpty()
  return self.maxX < self.minX or self.maxY < self.minY
end

--- Reset the bounds to infinite dimensions.
--- @return self
function Bounds:reset()
  self.minX = math.huge
  self.minY = math.huge
  self.maxX = -math.huge
  self.maxY = -math.huge
  return self
end

--- Copy the dimensions of the given bounds into this bounds.
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