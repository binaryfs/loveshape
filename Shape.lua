local BASE = (...):gsub("[^%.]*$", "")
local Bounds = require(BASE .. "Bounds")
local Color = require(BASE .. "Color")
local utils = require(BASE .. "utils")

local POSITION_INDEX = 1
local COLOR_INDEX = 3

local lg = love.graphics

--- Represents the abstract base class for all shapes.
--- @class loveshape.Shape
--- @field protected _mesh love.Mesh
--- @field protected _fillColor loveshape.Color
--- @field protected _borderMesh love.Mesh?
--- @field protected _borderWidth number
--- @field protected _borderColor loveshape.Color
--- @field protected _dirty boolean
--- @field protected _bounds loveshape.Bounds
--- @field protected _innerBounds loveshape.Bounds
local Shape = {}
Shape.__index = Shape

--- @param vertexCount integer
--- @protected
function Shape:_init(vertexCount)
  assert(type(vertexCount) == "number" and vertexCount >= 3)
  self._mesh = love.graphics.newMesh(vertexCount, "fan", "dynamic")
  self._fillColor = Color.new(1, 1, 1)
  self._borderMesh = nil
  self._borderWidth = 0
  self._borderColor = Color.new(1, 1, 1)
  self._dirty = true
  self._bounds = Bounds.new()
  self._innerBounds = Bounds.new()
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return self
function Shape:setFillColor(r, g, b, a)
  self._fillColor:set(r, g, b, a)
  self:_updateFillColor()
  return self
end

--- @return number red
--- @return number green
--- @return number blue
--- @return number alpha
--- @nodiscard
function Shape:getFillColor()
  return self._fillColor:unpack()
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number? (default: 1)
--- @return self
function Shape:setBorderColor(r, g, b, a)
  self._borderColor:set(r, g, b, a)
  self:_updateBorderColor()
  return self
end

--- @return number red
--- @return number green
--- @return number blue
--- @return number alpha
--- @nodiscard
function Shape:getBorderColor()
  return self._borderColor:unpack()
end

--- @param width number
--- @return self
function Shape:setBorderWidth(width)
  assert(type(width) == "number" and width >= 0)

  if self._borderWidth ~= width then
    self._borderWidth = width
    self._dirty = true
  end

  return self
end

--- @return number width
--- @nodiscard
function Shape:getBorderWidth()
  return self._borderWidth
end

--- Get the position of the specified point.
--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function Shape:getPoint(index)
  error("Shape.getPoint not implemented!")
end

--- Get the number of points in this shape.
--- @return integer
--- @nodiscard
function Shape:getPointsCount()
  return self._mesh:getVertexCount()
end

--- Get the axis-aligned bounding rectangle enclosing the shape.
--- @return number x
--- @return number y
--- @return number width
--- @return number height
--- @nodiscard
function Shape:getBounds()
  self:_updateMeshes()
  return self._bounds.minX, self._bounds.minY, self._bounds:getWidth(), self._bounds:getHeight()
end

--- Get the axis-aligned bounding rectangle enclosing the shape after applying
--- the specified transform.
---
--- For optimization reasons the returned rectangle might be larger than the shape.
--- It will never be smaller than the shape, though.
--- @param transform love.Transform
--- @return number x
--- @return number y
--- @return number width
--- @return number height
--- @nodiscard
function Shape:getTransformedBounds(transform)
  self:_updateMeshes()

  local bx, by, bw, bh = self:getBounds()
  local topLeftX, topLeftY = transform:transformPoint(bx, by)
  local topRightX, topRightY = transform:transformPoint(bx + bw, by)
  local bottomLeftX, bottomLeftY = transform:transformPoint(bx, by + bh)
  local bottomRightX, bottomRightY = transform:transformPoint(bx + bw, by + bh)

  local minX = math.min(topLeftX, topRightX, bottomLeftX, bottomRightX)
  local minY = math.min(topLeftY, topRightY, bottomLeftY, bottomRightY)
  local maxX = math.max(topLeftX, topRightX, bottomLeftX, bottomRightX)
  local maxY = math.max(topLeftY, topRightY, bottomLeftY, bottomRightY)

  return minX, minY, maxX - minX, maxY - minY
end

function Shape:draw(...)
  self:_updateMeshes()
  lg.draw(self._mesh, ...)

  if self._borderMesh then
    lg.draw(self._borderMesh, ...)
  end
end

--- @protected
function Shape:_updateMeshes()
  if not self._dirty then
    return
  end

  self._innerBounds:reset()

  for vertex = 1, self._mesh:getVertexCount() do
    local x, y = self:getPoint(vertex)
    self._mesh:setVertexAttribute(vertex, POSITION_INDEX, x, y)
    self._innerBounds:addPoint(x, y)
  end

  self:_updateFillColor()
  self:_updateBorderMesh()
  self._dirty = false
end

--- @protected
function Shape:_updateBorderMesh()
  if self._borderWidth == 0 then
    self._borderMesh = nil
    self._bounds:copyFrom(self._innerBounds)
    return
  end

  local vertexCount = self._mesh:getVertexCount()
  local borderVertexCount = (vertexCount * 2) + 2

  -- Create a new border mesh if necessary
  if self._borderMesh == nil or self._borderMesh:getVertexCount() ~= borderVertexCount then
    self._borderMesh = love.graphics.newMesh(borderVertexCount, "strip", "dynamic")
  end

  self._bounds:reset()

  for vertex = 1, vertexCount do
    local previousVertex = vertex == 1 and vertexCount or vertex - 1
    local nextVertex = vertex == vertexCount and 1 or vertex + 1
    local borderVertex = (vertex * 2) - 1

    local px, py = self._mesh:getVertexAttribute(previousVertex, POSITION_INDEX)
    local vx, vy = self._mesh:getVertexAttribute(vertex, POSITION_INDEX)
    local nx, ny = self._mesh:getVertexAttribute(nextVertex, POSITION_INDEX)

    local edgePx, edgePy = utils.vecNormalize(vx - px, vy - py)
    local edgeNx, edgeNy = utils.vecNormalize(nx - vx, ny - vy)

    -- Compute the vertex normal.
    local normalX, normalY
    local crossProduct = utils.vecCross(edgePx, edgePy, edgeNx, edgeNy)

    if math.abs(crossProduct) > 1e-09 then
      normalX = self._borderWidth * (edgeNx - edgePx) / crossProduct
      normalY = self._borderWidth * (edgeNy - edgePy) / crossProduct
    else
      -- Special case when edge normals are almost perpendicular.
      normalX = -(self._borderWidth * edgeNy)
      normalY = self._borderWidth * edgeNx
    end

    self._borderMesh:setVertexAttribute(borderVertex, POSITION_INDEX, vx, vy)
    self._borderMesh:setVertexAttribute(borderVertex + 1, POSITION_INDEX, vx - normalX, vy - normalY)
    self._bounds:addPoint(vx - normalX, vy - normalY)
  end

  -- Close the border mesh loop.
  self._borderMesh:setVertexAttribute(
    borderVertexCount - 1,
    POSITION_INDEX,
    self._borderMesh:getVertexAttribute(1, POSITION_INDEX)
  )
  self._borderMesh:setVertexAttribute(
    borderVertexCount,
    POSITION_INDEX,
    self._borderMesh:getVertexAttribute(2, POSITION_INDEX)
  )

  self:_updateBorderColor()
end

--- @protected
function Shape:_updateFillColor()
  for vertex = 1, self._mesh:getVertexCount() do
    self._mesh:setVertexAttribute(vertex, COLOR_INDEX, self._fillColor:unpack())
  end
end

--- @protected
function Shape:_updateBorderColor()
  if self._borderMesh then
    for vertex = 1, self._borderMesh:getVertexCount() do
      self._borderMesh:setVertexAttribute(vertex, COLOR_INDEX, self._borderColor:unpack())
    end
  end
end

return Shape