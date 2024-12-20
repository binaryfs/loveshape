local BASE = (...):gsub("[^%.]*$", "")

local Object = require(BASE .. "Object")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

local clamp = utils.clamp

--- Represents an RGBA color. Each color component is given as a floating point
--- value in the range from 0 to 1.
---
--- This class is used internally by loveshape.
--- @class loveshape.Color: loveshape.Object
local Color = utils.class("loveshape.Color", Object)

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return loveshape.Color
--- @overload fun(rgba: table): loveshape.Color
function Color.new(r, g, b, a)
  if type(r) == "table" then
    r, g, b, a = unpack(r)
  end
  return setmetatable({
    clamp(assert(r, "red required"), 0, 1),
    clamp(assert(g, "green required"), 0, 1),
    clamp(assert(b, "blue required"), 0, 1),
    clamp(a or 1, 0, 1)
  }, Color)
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return loveshape.Color self
--- @overload fun(self: loveshape.Color, rgba: table): loveshape.Color
function Color:set(r, g, b, a)
  if type(r) == "table" then
    r, g, b, a = unpack(r)
  end

  self[1] = clamp(assert(r, "red required"), 0, 1)
  self[2] = clamp(assert(g, "green required"), 0, 1)
  self[3] = clamp(assert(b, "blue required"), 0, 1)
  self[4] = clamp(a or 1, 0, 1)

  return self
end

--- @return number red
--- @return number green
--- @return number blue
--- @return number alpha
--- @nodiscard
function Color:unpack()
  return self[1], self[2], self[3], self[4]
end

--- Determine if the color is equal to another color.
--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return boolean
--- @overload fun(self: loveshape.Color, rgba: table): boolean
function Color:equal(r, g, b, a)
  if type(r) == "table" then
    r, g, b, a = unpack(r)
  end
  return self[1] == r and self[2] == g and self[3] == b and self[4] == (a or 1)
end

return Color