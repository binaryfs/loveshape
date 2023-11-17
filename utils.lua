--- Internal utility functions for the loveshape library.
--- @class loveshape.utils
local utils = {}

--- @param name string
--- @param parent table? Optional parent class
--- @return table newClass
--- @nodiscard
function utils.class(name, parent)
  assert(type(name) == "string" and name ~= "", "Name your class!")

  local newClass = {}

  if parent then
    for key, value in pairs(parent) do
      if type(value) ~= "table" then
        newClass[key] = value
      end
    end
    newClass._parentClass = parent
  end

  newClass._typename = name
  newClass.__index = newClass

  return newClass
end

--- Clamp a value between a lower an an upper bound.
--- @param value number
--- @param min number The lower bound
--- @param max number The upper bound
--- @return number clampedValue
--- @nodiscard
function utils.clamp(value, min, max)
  return value < min and min or (value > max and max or value)
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

--- Given two edges, compute the normal of their shared vertex.
---
--- This function expects the points in clockwise order.
--- @param ax number X position of the starting point of the first edge
--- @param ay number Y position of the starting point of the first edge
--- @param bx number X position of the shared vertex
--- @param by number Y position of the shared vertex
--- @param cx number X position of the end point of the second edge.
--- @param cy number Y position of the end point of the second edge.
--- @param length number Desired length of the normal
--- @return number normalX
--- @return number normalY
--- @nodiscard
function utils.computeVertexNormal(ax, ay, bx, by, cx, cy, length)
  -- Edges from a to b and b to c.
  local edgeAx, edgeAy = utils.vecNormalize(bx - ax, by - ay)
  local edgeBx, edgeBy = utils.vecNormalize(cx - bx, cy - by)

  local crossProduct = utils.vecCross(edgeAx, edgeAy, edgeBx, edgeBy)
  local normalX, normalY

  if math.abs(crossProduct) > 1e-09 then
    normalX = -(length * (edgeBx - edgeAx) / crossProduct)
    normalY = -(length * (edgeBy - edgeAy) / crossProduct)
  else
    -- Special case when edge normals are almost perpendicular.
    normalX = length * edgeBy
    normalY = -(length * edgeBx)
  end

  return normalX, normalY
end

return utils