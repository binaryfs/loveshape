local utils = {}

--- Create a flat copy of the specified table.
--- @param t table
--- @return table copy
--- @nodiscard
function utils.copyTable(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

--- Return a vector with a certain angle.
--- @param angle number The angle in radians
--- @param length? number The length of the vector (defaults to 1)
--- @return number x
--- @return number y
--- @nodiscard
function utils.vecFromAngle(angle, length)
  length = length or 1
  return math.cos(angle) * length, math.sin(angle) * length
end

--- Return the length of a vector.
--- @param x number
--- @param y number
--- @return number length
--- @nodiscard
function utils.vecLength(x, y)
  return math.sqrt(x * x + y * y)
end

--- Normalize a vector to a certain length.
--- @param x number
--- @param y number
--- @param newLength? number The new length of the vector (defaults to 1)
--- @return number x Normalized x
--- @return number y Normalized y
--- @nodiscard
function utils.vecNormalize(x, y, newLength)
  local length = utils.vecLength(x, y)
  if length > 0 then
    x = x / length * (newLength or 1)
    y = y / length * (newLength or 1)
  end
  return x, y
end

--- Compute the cross product of two vectors.
---
--- Cross products with vectors in 2D space are not defined. This method computes the length
--- of a vector c that would result from a regular 3D cross product of vector a and vector b with
--- their z-components equal to zero.
--- @param ax number
--- @param ay number
--- @param bx number
--- @param by number
--- @return number crossProduct
--- @nodiscard
function utils.vecCross(ax, ay, bx, by)
  return ax * by - ay * bx
end

return utils