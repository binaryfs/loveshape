local loveunit = require("loveunit")
local Rectangle = require("Rectangle")
local Shape = require("Shape")

local test = loveunit.newTestCase("Shape")

--- @return loveshape.Shape
--- @nodiscard
--- @package
local function newShape()
  local shape = setmetatable({}, Shape)
  shape:_init(4)
  return shape
end

--- @param width number
--- @param height number
--- @return loveshape.Shape
--- @nodiscard
--- @package
local function newRectangleShape(width, height)
  -- Some tests cannot be performed by the abstract Shape class.
  -- For these cases we use a rectangle instead.
  return Rectangle.new(width, height)
end

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.Shape", newShape():type())
  end)
end)

test:group("setFillColor()", function ()
  test:run("should set the fill color", function ()
    local shape = newShape()
    shape:setFillColor(0.1, 0.2, 0.3, 0.4)
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, {shape:getFillColor()})
  end)
  test:run("should accept a table argument", function ()
    local shape = newShape()
    shape:setFillColor({0.1, 0.2, 0.3, 0.4})
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, {shape:getFillColor()})
  end)
  test:run("should clamp color components between 0 and 1", function ()
    local shape = newShape()
    shape:setFillColor(-1, 255, 200, -100)
    test:assertAlmostEqual({0, 1, 1, 0}, {shape:getFillColor()})
  end)
end)

test:group("getFillColor()", function ()
  test:run("should initially return opaque white", function ()
    local shape = newShape()
    test:assertAlmostEqual({1, 1, 1, 1}, {shape:getFillColor()})
  end)
end)

test:group("setBorderColor()", function ()
  test:run("should set the border color", function ()
    local shape = newShape()
    shape:setBorderColor(0.1, 0.2, 0.3, 0.4)
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, {shape:getBorderColor()})
  end)
  test:run("should accept a table argument", function ()
    local shape = newShape()
    shape:setBorderColor({0.1, 0.2, 0.3, 0.4})
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, {shape:getBorderColor()})
  end)
  test:run("should clamp color components between 0 and 1", function ()
    local shape = newShape()
    shape:setBorderColor(-1, 255, 200, -100)
    test:assertAlmostEqual({0, 1, 1, 0}, {shape:getBorderColor()})
  end)
end)

test:group("getBorderColor()", function ()
  test:run("should initially return opaque white", function ()
    local shape = newShape()
    test:assertAlmostEqual({1, 1, 1, 1}, {shape:getBorderColor()})
  end)
end)

test:group("setBorderWidth()", function ()
  test:run("should set the border width", function ()
    local shape = newShape():setBorderWidth(3)
    test:assertEqual(3, shape:getBorderWidth())
  end)
  test:run("should disable soft edges", function ()
    local shape = newRectangleShape(100, 100):setEdgeSmoothing(10)
    shape:setBorderWidth(2)
    test:assertEqual(nil, shape:getEdgeMesh())
  end)
end)

test:group("getBorderWidth()", function ()
  test:run("should initially return 0", function ()
    test:assertEqual(0, newShape():getBorderWidth())
  end)
end)

test:group("setBorderSmoothing()", function ()
  test:run("should set the border smoothing", function ()
    local shape = newShape():setBorderSmoothing(3)
    test:assertEqual(3, shape:getBorderSmoothing())
  end)
  test:run("should not accept negative values", function ()
    test:assertError(function ()
      newShape():setBorderSmoothing(-1)
    end)
  end)
end)

test:group("getBorderSmoothing()", function ()
  test:run("should initially return 1", function ()
    test:assertEqual(1, newShape():getBorderSmoothing())
  end)
end)

test:group("setEdgeSmoothing()", function ()
  test:run("should set the edge smoothing", function ()
    local shape = newShape():setEdgeSmoothing(3)
    test:assertEqual(3, shape:getEdgeSmoothing())
  end)
  test:run("should not accept negative values", function ()
    test:assertError(function ()
      newShape():setEdgeSmoothing(-1)
    end)
  end)
end)

test:group("getEdgeSmoothing()", function ()
  test:run("should initially return 1", function ()
    test:assertEqual(1, newShape():getEdgeSmoothing())
  end)
end)

test:group("getPointsCount()", function ()
  test:run("should return the number of vertices", function ()
    test:assertEqual(4, newShape():getPointsCount())
  end)
end)

test:group("getBounds()", function ()
  test:run("should get the bounding rectangle", function ()
    local rect = newRectangleShape(100, 200)
    test:assertEqual({0, 0, 100, 200}, {rect:getBounds()})
  end)
  test:run("should include outer borders", function ()
    local rect = newRectangleShape(100, 200):setBorderWidth(10)
    test:assertEqual({-10, -10, 120, 220}, {rect:getBounds()})
  end)
  test:run("should not include outer border smoothing", function ()
    local rect = newRectangleShape(100, 200):setBorderWidth(10):setBorderSmoothing(5)
    test:assertEqual({-10, -10, 120, 220}, {rect:getBounds()})
  end)
  test:run("should include inner borders", function ()
    local rect = newRectangleShape(100, 200):setBorderWidth(-10)
    test:assertEqual({0, 0, 100, 200}, {rect:getBounds()})
  end)
  test:run("should include inner border smoothing", function ()
    local rect = newRectangleShape(100, 200):setBorderWidth(-10):setBorderSmoothing(5)
    test:assertEqual({0, 0, 100, 200}, {rect:getBounds()})
  end)
  test:run("should not include soft edges", function ()
    local rect = newRectangleShape(100, 200):setEdgeSmoothing(5)
    test:assertEqual({0, 0, 100, 200}, {rect:getBounds()})
  end)
end)

test:group("setTexture()", function ()
  local image = love.graphics.newImage("assets/wall.png")

  test:run("should set the mesh texture", function ()
    local shape = newShape():setTexture(image)
    test:assertSame(image, shape:getTexture())
  end)
  test:run("should optionally set the texture quad", function ()
    local shape = newShape()
    shape:setTexture(image)
    test:assertEqual({0, 0, 0, 0}, {shape:getTextureQuad()})
    shape:setTexture(image, true)
    test:assertEqual({0, 0, 256, 256}, {shape:getTextureQuad()})
  end)
end)

test:group("getTexture()", function ()
  test:run("should initially return nil", function ()
    test:assertEqual(nil, newShape():getTexture())
  end)
end)

test:group("setTextureQuad()", function ()
  test:run("should set the texture quad", function ()
    local shape = newShape():setTextureQuad(10, 20, 30, 40)
    test:assertEqual({10, 20, 30, 40}, {shape:getTextureQuad()})
  end)
end)

test:group("getTextureQuad()", function ()
  test:run("should initially return an empty quad", function ()
    test:assertEqual({0, 0, 0, 0}, {newShape():getTextureQuad()})
  end)
end)

test:group("getBorderMesh()", function ()
  test:run("should initially return nil", function ()
    test:assertEqual(nil, newRectangleShape(10, 10):getBorderMesh())
  end)
  test:run("should return a mesh if a border is set", function ()
    local shape = newRectangleShape(10, 10):setBorderWidth(1)
    test:assertEqual("userdata", type(shape:getBorderMesh()))
  end)
end)

test:group("getEdgeMesh()", function ()
  test:run("should initially return a mesh", function ()
    test:assertEqual("userdata", type(newRectangleShape(10, 10):getEdgeMesh()))
  end)
  test:run("should return nil if soft edges are disabled", function ()
    local shape = newRectangleShape(10, 10):setEdgeSmoothing(0)
    test:assertEqual(nil, shape:getEdgeMesh())
  end)
end)