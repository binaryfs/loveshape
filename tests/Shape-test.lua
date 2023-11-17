local loveunit = require("loveunit")
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
  test:run("should not accept negative values", function ()
    test:assertError(function ()
      newShape():setBorderWidth(-1)
    end)
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

test:group("getPointsCount()", function ()
  test:run("should return the number of vertices", function ()
    test:assertEqual(4, newShape():getPointsCount())
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