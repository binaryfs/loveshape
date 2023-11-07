local BASE = (...):gsub("[^%.]*$", "")
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
--- @field protected _dirtyMesh boolean
--- @field protected _dirtyBorder boolean
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
  self._dirtyMesh = true
  self._dirtyBorder = true
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
    self._dirtyBorder = true
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

function Shape:draw(...)
  self:_updateMeshes()
  lg.draw(self._mesh, ...)

  if self._borderMesh then
    lg.draw(self._borderMesh, ...)
  end
end

--- @protected
function Shape:_updateMeshes()
  if self._dirtyMesh then
    for vertex = 1, self._mesh:getVertexCount() do
      self._mesh:setVertexAttribute(vertex, POSITION_INDEX, self:getPoint(vertex))
    end

    self:_updateFillColor()
    self._dirtyMesh = false
    self._dirtyBorder = true
  end

  self:_updateBorderMesh()
end

--- @protected
function Shape:_updateBorderMesh()
  if not self._dirtyBorder then
    return
  end

  if self._borderWidth == 0 then
    self._borderMesh = nil
    self._dirtyBorder = false
    return
  end

  local vertexCount = self._mesh:getVertexCount()
  local borderVertexCount = (vertexCount * 2) + 2

  if self._borderMesh == nil or self._borderMesh:getVertexCount() ~= borderVertexCount then
    self._borderMesh = love.graphics.newMesh(borderVertexCount, "strip", "dynamic")
  end

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
  self._dirtyBorder = false
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