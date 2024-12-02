local abs = math.abs
local cos = math.cos
local max = math.max
local sin = math.sin
local sqrt = math.sqrt

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

--- Return whether the two numbers `a` and `b` are close to each other.
--- @param a number
--- @param b number
--- @param epsilon number? Tolerated margin of error (default: 1e-09)
--- @return boolean equal
--- @nodiscard
function utils.almostEqual(a, b, epsilon)
  epsilon = epsilon or 1e-09
  return abs(a - b) <= epsilon * max(abs(a), abs(b))
end

--- Return a vector with a certain angle.
--- @param angle number The angle in radians
--- @param length? number The length of the vector (defaults to 1)
--- @return number x
--- @return number y
--- @nodiscard
function utils.vecFromAngle(angle, length)
  length = length or 1
  return cos(angle) * length, sin(angle) * length
end

--- Return the length of a vector.
--- @param x number
--- @param y number
--- @return number length
--- @nodiscard
function utils.vecLength(x, y)
  return sqrt(x * x + y * y)
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

--- Determine if two vectors are equal.
--- @param ax number
--- @param ay number
--- @param bx number
--- @param by number
--- @return boolean
--- @nodiscard
function utils.vecEquals(ax, ay, bx, by)
  return utils.almostEqual(ax, bx) and utils.almostEqual(ay, by)
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
--- @param length number? Desired length of the normal (default: 1)
--- @return number normalX
--- @return number normalY
--- @nodiscard
function utils.computeVertexNormal(ax, ay, bx, by, cx, cy, length)
  length = length or 1

  -- Edges from a to b and b to c.
  local edgeAx, edgeAy = utils.vecNormalize(bx - ax, by - ay)
  local edgeBx, edgeBy = utils.vecNormalize(cx - bx, cy - by)

  local crossProduct = utils.vecCross(edgeAx, edgeAy, edgeBx, edgeBy)
  local normalX, normalY

  if abs(crossProduct) > 1e-09 then
    normalX = (edgeAx - edgeBx) / crossProduct
    normalY = (edgeAy - edgeBy) / crossProduct
  else
    -- Special case when edge normals are almost perpendicular.
    normalX = edgeBy
    normalY = -edgeBx
  end

  return normalX * length, normalY * length
end

--- Get the next distinct vertex position from a mesh.
---
--- If two vertices share the same position, they are considered not distinct.
--- @param mesh love.Mesh
--- @param vertex integer
--- @return number x
--- @return number y
--- @nodiscard
function utils.nextDistinctVertexPosition(mesh, vertex)
  local startVertex = vertex
  local vx, vy = mesh:getVertexAttribute(vertex, 1)

  repeat
    vertex = vertex == mesh:getVertexCount() and 1 or vertex + 1
    local nx, ny = mesh:getVertexAttribute(vertex, 1)

    if not utils.vecEquals(nx, ny, vx, vy) then
      return nx, ny
    end
  until vertex == startVertex

  return vx, vy
end

--- Get the previous distinct vertex position from a mesh.
---
--- If two vertices share the same position, they are considered not distinct.
--- @param mesh love.Mesh
--- @param vertex integer
--- @return number x
--- @return number y
--- @nodiscard
function utils.previousDistinctVertexPosition(mesh, vertex)
  local startVertex = vertex
  local vx, vy = mesh:getVertexAttribute(vertex, 1)

  repeat
    vertex = vertex == 1 and mesh:getVertexCount() or vertex - 1
    local px, py = mesh:getVertexAttribute(vertex, 1)

    if not utils.vecEquals(px, py, vx, vy) then
      return px, py
    end
  until vertex == startVertex

  return vx, vy
end

return utils