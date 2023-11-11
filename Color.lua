--- Represents an RGBA color. Each color component is given as a floating point
--- value in the range from 0 to 1.
--- @class loveshape.Color
local Color = {}
Color.__index = Color

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return loveshape.Color
function Color.new(r, g, b, a)
  return setmetatable({
    assert(r, "red required"),
    assert(g, "green required"),
    assert(b, "blue required"),
    a or 1
  }, Color)
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return loveshape.Color self
function Color:set(r, g, b, a)
  self[1] = assert(r, "red required")
  self[2] = assert(g, "green required")
  self[3] = assert(b, "blue required")
  self[4] = a or 1
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