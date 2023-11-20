local BASE = (...):gsub("[^%.]*$", "")

local Object = require(BASE .. "Object")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

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
    utils.clamp(assert(r, "red required"), 0, 1),
    utils.clamp(assert(g, "green required"), 0, 1),
    utils.clamp(assert(b, "blue required"), 0, 1),
    utils.clamp(a or 1, 0, 1)
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

  self[1] = utils.clamp(assert(r, "red required"), 0, 1)
  self[2] = utils.clamp(assert(g, "green required"), 0, 1)
  self[3] = utils.clamp(assert(b, "blue required"), 0, 1)
  self[4] = utils.clamp(a or 1, 0, 1)

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

return Color