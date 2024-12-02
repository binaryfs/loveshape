local BASE = (...):gsub("[^%.]*$", "")

--- @type loveshape.Bounds
local Bounds = require(BASE .. "Bounds")
--- @type loveshape.Color
local Color = require(BASE .. "Color")
local Object = require(BASE .. "Object")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

local POSITION_INDEX = 1
local UV_INDEX = 2
local COLOR_INDEX = 3

local BORDER_STRIPS = 2
local SMOOTH_BORDER_STRIPS = 4

local lg = love.graphics

--- @alias loveshape.HorizontalAlign "left" | "center" | "right"
--- @alias loveshape.VerticalAlign "top" | "center" | "bottom"

--- Represents the abstract base class for all shapes.
--- @class loveshape.Shape: loveshape.Object
--- @field protected _mesh love.Mesh
--- @field protected _fillColor loveshape.Color Mesh color
--- @field protected _borderMesh love.Mesh? Mesh that represents the border/outline
--- @field protected _borderWidth number
--- @field protected _borderColor loveshape.Color
--- @field protected _borderSmoothing number
--- @field protected _edgeMesh love.Mesh? Mesh for rendering soft edges
--- @field protected _edgeSmoothing number
--- @field protected _dirty boolean If true, messes need to be rebuild
--- @field protected _bounds loveshape.Bounds Bounds including the border
--- @field protected _innerBounds loveshape.Bounds Bounds excluding the border
--- @field protected _textureQuad loveshape.Bounds? Texture area to render on the mesh
local Shape = utils.class("loveshape.Shape", Object)

--- Initialize a new shape with the given amount of vertices.
--- @param vertexCount integer The number of vertices must be at least 3
--- @protected
function Shape:_init(vertexCount)
  assert(type(vertexCount) == "number" and vertexCount >= 3)
  self._mesh = love.graphics.newMesh(vertexCount, "fan", "dynamic")
  self._fillColor = Color.new(1, 1, 1)
  self._borderMesh = nil
  self._borderWidth = 0
  self._borderColor = Color.new(1, 1, 1)
  self._borderSmoothing = 1
  self._edgeMesh = nil
  self._edgeSmoothing = 1
  self._dirty = true
  self._bounds = Bounds.new()
  self._innerBounds = Bounds.new()
  self._textureQuad = nil
end

--- Set the color of the shape.
---
--- Shapes are white (1,1,1) by default.
--- @param r number Red component in the range 0-1
--- @param g number Green component in the range 0-1
--- @param b number Blue component in the range 0-1
--- @param a number? Alpha component in the range 0-1 (default: 1)
--- @return self
--- @overload fun(self: loveshape.Shape, rgba: table): loveshape.Shape
--- @see loveshape.Shape.getFillColor
--- @see loveshape.Shape.setBorderColor
function Shape:setFillColor(r, g, b, a)
  if not self._fillColor:equal(r, g, b, a) then
    self._fillColor:set(r, g, b, a)
    self:_updateFillColor()
  end
  return self
end

--- Get the color of the shape.
--- @return number red Red component in the range 0-1
--- @return number green Green component in the range 0-1
--- @return number blue Blue component in the range 0-1
--- @return number alpha Alpha component in the range 0-1
--- @nodiscard
function Shape:getFillColor()
  return self._fillColor:unpack()
end

--- Set the border color.
---
--- Borders are white (1,1,1) by default.
--- @param r number Red component in the range 0-1
--- @param g number Green component in the range 0-1
--- @param b number Blue component in the range 0-1
--- @param a number? Alpha component in the range 0-1 (default: 1)
--- @return self
--- @overload fun(self: loveshape.Shape, rgba: table): self
--- @see loveshape.Shape.getBorderColor
--- @see loveshape.Shape.setFillColor
function Shape:setBorderColor(r, g, b, a)
  if not self._borderColor:equal(r, g, b, a) then
    self._borderColor:set(r, g, b, a)
    self:_updateBorderColor()
  end
  return self
end

--- @return number red Red component in the range 0-1
--- @return number green Green component in the range 0-1
--- @return number blue Blue component in the range 0-1
--- @return number alpha Alpha component in the range 0-1
--- @nodiscard
--- @see loveshape.Shape.setBorderColor
function Shape:getBorderColor()
  return self._borderColor:unpack()
end

--- Set the width of the border.
---
--- A positive value creates an outer border. A negative value creates an inner border.
--- A value equal to zero removes the border. The border width is 0 by default.
--- @param width number
--- @return self
--- @see loveshape.Shape.getBorderWidth
function Shape:setBorderWidth(width)
  assert(type(width) == "number")

  if self._borderWidth ~= width then
    self._borderWidth = width
    self._dirty = true
  end

  return self
end

--- @return number width
--- @nodiscard
--- @see loveshape.Shape.setBorderWidth
function Shape:getBorderWidth()
  return self._borderWidth
end

--- Set the amount of smoothing for borders. The default value is 1.
--- @param smoothing number
--- @return self
--- @see loveshape.Shape.getBorderSmoothing
function Shape:setBorderSmoothing(smoothing)
  assert(type(smoothing) == "number" and smoothing >= 0)

  if self._borderSmoothing ~= smoothing then
    self._borderSmoothing = smoothing
    self._dirty = true
  end

  return self
end

--- @return number smoothing
--- @nodiscard
--- @see loveshape.Shape.setBorderSmoothing
function Shape:getBorderSmoothing()
  return self._borderSmoothing
end

--- Set the amount of smoothing for the edges of the shape. The default value is 1.
---
--- Please note that smooth edges only work for borderless shapes. If your shape has
--- a border, use `Shape.setBorderSmoothing` instead.
--- @param smoothing number
--- @return self
--- @see loveshape.Shape.getEdgeSmoothing
--- @see loveshape.Shape.setBorderSmoothing
function Shape:setEdgeSmoothing(smoothing)
  assert(type(smoothing) == "number" and smoothing >= 0)

  if self._edgeSmoothing ~= smoothing then
    self._edgeSmoothing = smoothing
    self._dirty = true
  end

  return self
end

--- @return number smoothing
--- @nodiscard
--- @see loveshape.Shape.setEdgeSmoothing
function Shape:getEdgeSmoothing()
  return self._edgeSmoothing
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
---
--- The rectangle includes the border, but it neither includes boorder smoothing nor soft edges.
--- @return number x
--- @return number y
--- @return number width
--- @return number height
--- @nodiscard
--- @see loveshape.Shape.getTransformedBounds
function Shape:getBounds()
  self:_updateMeshes()
  return self._bounds:getRect()
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
--- @see loveshape.Shape.getBounds
function Shape:getTransformedBounds(transform)
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

--- Get the texture that is rendered on the shape.
--- @return (love.Texture)?
--- @nodiscard
--- @see loveshape.Shape.setTexture
function Shape:getTexture()
  return self._mesh:getTexture()
end

--- Set or unset the texture that is rendered on the shape.
---
--- If the `setTextureQuad` parameter is set, the texture coordinates of the mesh will
--- be updated accordingly. Otherwise you have to set them manually by calling the
--- `Shape.setTextureQuad` method.
--- @param texture love.Texture|nil
--- @param setTextureQuad boolean? (default: false)
--- @return self
--- @see loveshape.Shape.getTexture
--- @see loveshape.Shape.setTextureQuad
function Shape:setTexture(texture, setTextureQuad)
  if texture then
    self._mesh:setTexture(texture)

    if self._edgeMesh then
      self._edgeMesh:setTexture(texture)
    end

    if setTextureQuad then
      self:setTextureQuad(0, 0, texture:getDimensions())
    end
  else
    self._mesh:setTexture()

    if self._edgeMesh then
      self._edgeMesh:setTexture()
    end
  end

  return self
end

--- Set the texture area that should be rendered on the shape.
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @return self
--- @see loveshape.Shape.getTextureQuad
--- @see loveshape.Shape.getTexture
function Shape:setTextureQuad(x, y, width, height)
  if not self._textureQuad then
    self._textureQuad = Bounds.new()
  end

  self._textureQuad:set(x, y, x + width, y + height)
  self:_updateTextureCoordinates()

  return self
end

--- Get the texture area that should be rendered on the shape.
--- @return integer x
--- @return integer y
--- @return integer width
--- @return integer height
--- @nodiscard
--- @see loveshape.Shape.setTextureQuad
function Shape:getTextureQuad()
  if not self._textureQuad then
    return 0, 0, 0, 0
  end
  return self._textureQuad:getRect()
end

--- Get the internal mesh that is used to render the shape.
--- @return love.Mesh mesh
--- @nodiscard
--- @see loveshape.Shape.getBorderMesh
--- @see loveshape.Shape.getEdgeMesh
function Shape:getMesh()
  self:_updateMeshes()
  return self._mesh
end

--- Get the internal mesh that is used to render the shape's border.
--- @return (love.Mesh)? mesh The mesh or nil if the shape has no border
--- @nodiscard
--- @see loveshape.Shape.getMesh
--- @see loveshape.Shape.getEdgeMesh
function Shape:getBorderMesh()
  self:_updateMeshes()
  return self._borderMesh
end

--- Get the internal mesh that is used to render the soft edges of the shape.
--- @return (love.Mesh)? mesh The mesh or nil if the shape has no soft edges
--- @nodiscard
--- @see loveshape.Shape.getMesh
--- @see loveshape.Shape.getBorderMesh
function Shape:getEdgeMesh()
  self:_updateMeshes()
  return self._edgeMesh
end

--- Draw the shape on the screen.
--- @param ... any Arguments for `love.graphics.draw`
--- @return self
--- @see loveshape.Shape.drawAligned
function Shape:draw(...)
  self:_updateMeshes()
  lg.draw(self._mesh, ...)

  if self._borderMesh then
    lg.draw(self._borderMesh, ...)
  elseif self._edgeMesh then
    lg.draw(self._edgeMesh, ...)
  end

  return self
end

--- Draw the shape aligned to the specified point.
--- @param align loveshape.HorizontalAlign Horizontal alignment
--- @param valign loveshape.VerticalAlign Vertical alignment
--- @param x number X position
--- @param y number Y position
--- @param angle number? Angle in radians (default: 0)
--- @param scaleX number? X scale (default: 1)
--- @param scaleY number? Y scale (default: 1)
--- @return self
--- @see loveshape.Shape.draw
function Shape:drawAligned(align, valign, x, y, angle, scaleX, scaleY)
  local offsetX, offsetY = 0, 0
  local boundsX, outerY, boundsWidth, boundsHeight = self._bounds:getRect()

  if align == "left" then
    offsetX = boundsX
  elseif align == "right" then
    offsetX = boundsX + boundsWidth
  elseif align == "center" then
    offsetX = boundsX + (boundsWidth / 2)
  else
    error("Invalid horizontal alignment: " .. tostring(align))
  end

  if valign == "top" then
    offsetY = outerY
  elseif valign == "center" then
    offsetY = outerY + (boundsHeight / 2)
  elseif valign == "bottom" then
    offsetY = outerY + boundsHeight
  else
    error("Invalid vertical alignment: " .. tostring(valign))
  end

  return self:draw(x, y, angle or 0, scaleX or 1, scaleY or 1, offsetX, offsetY)
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
  self:_updateEdgeMesh()
  self:_updateTextureCoordinates()
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
  local borderStrips = self._borderSmoothing == 0 and BORDER_STRIPS or SMOOTH_BORDER_STRIPS
  local borderVertexCount = (vertexCount * borderStrips) + borderStrips

  -- Create a new border mesh if necessary
  if self._borderMesh == nil or self._borderMesh:getVertexCount() ~= borderVertexCount then
    self._borderMesh = self:_createBorderMesh(borderVertexCount)
  end

  self._bounds:reset()

  for vertex = 1, vertexCount do
    local borderVertex = (vertex - 1) * borderStrips + 1

    local vx, vy = self._mesh:getVertexAttribute(vertex, POSITION_INDEX)
    self._bounds:addPoint(vx, vy)

    -- In some rare cases (e.g. pill-shaped meshes) adjacent vertices might share the same position.
    -- In those cases we have to find the closest distinct vertex, in order to compute the normals.
    local px, py = utils.previousDistinctVertexPosition(self._mesh, vertex)
    local nx, ny = utils.nextDistinctVertexPosition(self._mesh, vertex)

    if self._borderSmoothing == 0 then
      local normalX, normalY = utils.computeVertexNormal(px, py, vx, vy, nx, ny, self._borderWidth)
      self._borderMesh:setVertexAttribute(borderVertex, POSITION_INDEX, vx, vy)
      self._borderMesh:setVertexAttribute(borderVertex + 1, POSITION_INDEX, vx + normalX, vy + normalY)
      self._bounds:addPoint(vx + normalX, vy + normalY)
    else
      local normalX, normalY = utils.computeVertexNormal(px, py, vx, vy, nx, ny)
      self:_updateSmoothedBorderVertex(borderVertex, vx, vy, normalX, normalY)
    end
  end

  -- Close the border mesh loop.
  for vertex = 0, borderStrips - 1 do
    self._borderMesh:setVertexAttribute(
      borderVertexCount - vertex,
      POSITION_INDEX,
      self._borderMesh:getVertexAttribute(borderStrips - vertex, POSITION_INDEX)
    )
  end

  self:_updateBorderColor()
end

--- @param vertex integer Index of border vertex
--- @param vx number X position of shape vertex
--- @param vy number Y position of shape vertex
--- @param normalX number X position of shape vertex normal (unit vextor!)
--- @param normalY number Y position of shape vertex normal (unit vector!)
--- @protected
function Shape:_updateSmoothedBorderVertex(vertex, vx, vy, normalX, normalY)
  local smoothing, borderWidth = self._borderSmoothing, self._borderWidth
  local smoothX, smoothY = normalX * smoothing, normalY * smoothing
  normalX, normalY = normalX * borderWidth, normalY * borderWidth

  -- Invert normal for inner borders.
  if borderWidth < 0 then
    smoothX, smoothY = -smoothX, -smoothY
  end

  -- Solid core
  self._borderMesh:setVertexAttribute(vertex + 1, POSITION_INDEX, vx, vy)
  self._borderMesh:setVertexAttribute(vertex + 2, POSITION_INDEX, vx + normalX, vy + normalY)

  -- Gradient paddings
  self._borderMesh:setVertexAttribute(vertex, POSITION_INDEX, vx - smoothX, vy - smoothY)
  self._borderMesh:setVertexAttribute(
    vertex + 3,
    POSITION_INDEX,
    vx + normalX + smoothX,
    vy + normalY + smoothY
  )

  -- Note: The bounds do not include border smoothing.
  self._bounds:addPoint(vx + normalX, vy + normalY)
end

--- @param borderVertexCount integer
--- @return love.Mesh mesh
--- @nodiscard
--- @protected
function Shape:_createBorderMesh(borderVertexCount)
  if self._borderSmoothing == 0 then
    return love.graphics.newMesh(borderVertexCount, "strip", "dynamic")
  end

  -- When smoothing is enabled, create a line mesh with an opaque core and
  -- opaque-to-transparent color gradients as padding.
  --
  -- Details: https://www.codeproject.com/Articles/199525/Drawing-nearly-perfect-2D-line-segments-in-OpenGL
  --
  -- This is what a single line segment looks like:
  -- 4 +------------------+ 8
  --   | Gradient padding |
  -- 3 +------------------+ 7
  --   | Opaque core line |
  -- 2 +------------------+ 6
  --   | Gradient padding |
  -- 1 +------------------+ 5

  local vertexMap = {}
  local borderMesh = love.graphics.newMesh(borderVertexCount, "triangles", "dynamic")

  for column = 1, self._mesh:getVertexCount() do
    for row = 1, SMOOTH_BORDER_STRIPS - 1 do
      local vertex = (column - 1) * SMOOTH_BORDER_STRIPS + row
      table.insert(vertexMap, vertex)
      table.insert(vertexMap, vertex + 5)
      table.insert(vertexMap, vertex + 4)
      table.insert(vertexMap, vertex + 1)
      table.insert(vertexMap, vertex + 5)
      table.insert(vertexMap, vertex)
    end
  end

  borderMesh:setVertexMap(vertexMap)

  return borderMesh
end

--- Update the mesh that is used for rendering soft edges.
--- @protected
function Shape:_updateEdgeMesh()
  if self._edgeSmoothing == 0 or self._borderWidth ~= 0 then
    self._edgeMesh = nil
    return
  end

  local vertexCount = self._mesh:getVertexCount()
  local edgeVertexCount = (vertexCount * 2) + 2

  -- Create a new mesh if necessary
  if self._edgeMesh == nil or self._edgeMesh:getVertexCount() ~= edgeVertexCount then
    self._edgeMesh = love.graphics.newMesh(edgeVertexCount, "strip", "dynamic")
    self._edgeMesh:setTexture(self._mesh:getTexture())
  end

  for vertex = 1, vertexCount do
    local vx, vy = self._mesh:getVertexAttribute(vertex, POSITION_INDEX)
    local px, py = utils.previousDistinctVertexPosition(self._mesh, vertex)
    local nx, ny = utils.nextDistinctVertexPosition(self._mesh, vertex)

    local normalX, normalY = utils.computeVertexNormal(px, py, vx, vy, nx, ny, self._edgeSmoothing)
    local edgeVertex = (vertex - 1) * 2 + 1
    self._edgeMesh:setVertexAttribute(edgeVertex, POSITION_INDEX, vx, vy)
    self._edgeMesh:setVertexAttribute(edgeVertex + 1, POSITION_INDEX, vx + normalX, vy + normalY)
  end

  -- Close the mesh loop.
  for vertex = 0, 1 do
    self._edgeMesh:setVertexAttribute(
      edgeVertexCount - vertex,
      POSITION_INDEX,
      self._edgeMesh:getVertexAttribute(2 - vertex, POSITION_INDEX)
    )
  end

  self:_updateEdgeColor()
end

--- @protected
function Shape:_updateFillColor()
  for vertex = 1, self._mesh:getVertexCount() do
    self._mesh:setVertexAttribute(vertex, COLOR_INDEX, self._fillColor:unpack())
  end
end

--- @protected
function Shape:_updateBorderColor()
  if not self._borderMesh then
    return
  end

  if self._borderSmoothing == 0 then
    for vertex = 1, self._borderMesh:getVertexCount() do
      self._borderMesh:setVertexAttribute(vertex, COLOR_INDEX, self._borderColor:unpack())
    end
    return
  end

  local r, g, b, a = self._borderColor:unpack()

  -- Anti-aliased borders
  for vertex = 1, self._mesh:getVertexCount() + 1 do
    local borderVertex = (vertex - 1) * SMOOTH_BORDER_STRIPS + 1

    -- Solid core
    self._borderMesh:setVertexAttribute(borderVertex + 1, COLOR_INDEX, r, g, b, a)
    self._borderMesh:setVertexAttribute(borderVertex + 2, COLOR_INDEX, r, g, b, a)

    -- Gradient paddings
    self._borderMesh:setVertexAttribute(borderVertex, COLOR_INDEX, r, g, b, 0)
    self._borderMesh:setVertexAttribute(borderVertex + 3, COLOR_INDEX, r, g, b, 0)
  end
end

--- Update the color of the edge mesh.
--- @protected
function Shape:_updateEdgeColor()
  if not self._edgeMesh then
    return
  end

  local r, g, b, a = self._fillColor:unpack()

  for vertex = 1, self._edgeMesh:getVertexCount(), 2 do
    self._edgeMesh:setVertexAttribute(vertex, COLOR_INDEX, r, g, b, a)
    self._edgeMesh:setVertexAttribute(vertex + 1, COLOR_INDEX, r, g, b, 0)
  end
end

--- @protected
function Shape:_updateTextureCoordinates()
  local texture = self._mesh:getTexture()

  if not texture or not self._textureQuad or self._innerBounds:isEmpty() then
    return
  end

  local bx, by, bw, bh = self._innerBounds:getRect()
  local qx, qy, qw, qh = self._textureQuad:getRect()

  for vertex = 1, self._mesh:getVertexCount() do
    local vx, vy = self._mesh:getVertexAttribute(vertex, POSITION_INDEX)

    -- Calculate normalized texture coordinates
    local u = (qx + qw * ((vx - bx) / bw)) / texture:getWidth()
    local v = (qy + qh * ((vy - by) / bh)) / texture:getHeight()

    self._mesh:setVertexAttribute(vertex, UV_INDEX, u, v)

    if self._edgeMesh then
      local edgeVertex = (vertex - 1) * 2 + 1
      self._edgeMesh:setVertexAttribute(edgeVertex, UV_INDEX, u, v)
      self._edgeMesh:setVertexAttribute(edgeVertex + 1, UV_INDEX, u, v)
    end
  end
end

return Shape