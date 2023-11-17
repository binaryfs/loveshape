local BASE = (...):gsub("[^%.]*$", "")
local Shape = require(BASE .. "Shape")
--- @type loveshape.utils
local utils = require(BASE .. "utils")

--- @class loveshape.Rectangle: loveshape.Shape
--- @field protected _width number
--- @field protected _height number
local Rectangle = utils.class("loveshape.Rectangle", Shape)

--- Create a new rectangle with the specified dimensions.
--- @param width number
--- @param height number
--- @return loveshape.Rectangle
--- @nodiscard
function Rectangle.new(width, height)
  --- @type loveshape.Rectangle
  local self = setmetatable({}, Rectangle)
  self:_init(4, width, height)
  return self
end

--- @param vertexCount integer
--- @param width number
--- @param height number
--- @protected
function Rectangle:_init(vertexCount, width, height)
  assert(type(width) == "number" and width >= 0)
  assert(type(height) == "number" and height >= 0)

  Shape._init(self, vertexCount)
  self._width = width
  self._height = height
end

--- @param width number
--- @param height number
--- @return self
function Rectangle:setSize(width, height)
  self:setWidth(width)
  self:setHeight(height)
  return self
end

--- @return number width
--- @return number height
--- @nodiscard
function Rectangle:getSize()
  return self._width, self._height
end

--- @param width number
--- @return self
function Rectangle:setWidth(width)
  assert(type(width) == "number" and width >= 0)

  if self._width ~= width then
    self._width = width
    self._dirty = true
  end

  return self
end

--- @return number width
--- @nodiscard
function Rectangle:getWidth()
  return self._width
end

--- @param height number
--- @return self
function Rectangle:setHeight(height)
  assert(type(height) == "number" and height >= 0)

  if self._height ~= height then
    self._height = height
    self._dirty = true
  end

  return self
end

--- @return number height
--- @nodiscard
function Rectangle:getHeight()
  return self._height
end

--- @param index integer
--- @return number x
--- @return number y
--- @nodiscard
function Rectangle:getPoint(index)
  if index == 1 then
    return 0, 0
  elseif index == 2 then
    return self._width, 0
  elseif index == 3 then
    return self._width, self._height
  elseif index == 4 then
    return 0, self._height
  end

  error("Invalid vertex index: " .. tostring(index))
end

return Rectangle