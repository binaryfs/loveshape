local lovecase = require("libs.lovecase")
local Rectangle = require("Rectangle")

local test = lovecase.newTestSet("Rectangle")

test:group("type()", function ()
  test:run("should return the typename", function ()
    local rect = Rectangle.new(100, 200)
    test:assertEqual("loveshape.Rectangle", rect:type())
  end)
end)

test:group("typeOf()", function ()
  test:run("should determine if the object is the specified type", function (typename, expectedResult)
    local rect = Rectangle.new(100, 200)
    test:assertEqual(expectedResult, rect:typeOf(typename))
  end, {
    {"loveshape.Rectangle", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

test:group("new()", function ()
  test:run("should create a rectangle with the specified size", function ()
    local rect = Rectangle.new(100, 200)
    test:assertEqual({100, 200}, {rect:getSize()})
  end)
  test:run("should not accept negative sizes", function ()
    test:assertError(function ()
      local rect = Rectangle.new(-100, 200)
    end)
    test:assertError(function ()
      local rect = Rectangle.new(100, -200)
    end)
  end)
end)

test:group("setWidth()", function ()
  test:run("should set the width", function ()
    local rect = Rectangle.new(100, 200):setWidth(300)
    test:assertEqual(300, rect:getWidth())
  end)
  test:run("should not accept negative widths", function ()
    test:assertError(function ()
      Rectangle.new(100, 200):setWidth(-100)
    end)
  end)
end)

test:group("setHeight()", function ()
  test:run("should set the height", function ()
    local rect = Rectangle.new(100, 200):setHeight(300)
    test:assertEqual(300, rect:getHeight())
  end)
  test:run("should not accept negative height", function ()
    test:assertError(function ()
      Rectangle.new(100, 200):setHeight(-100)
    end)
  end)
end)

test:group("setSize()", function ()
  test:run("should set the size", function ()
    local rect = Rectangle.new(100, 200):setSize(300, 400)
    test:assertEqual({300, 400}, {rect:getSize()})
  end)
  test:run("should not accept negative dimensions", function ()
    test:assertError(function ()
      Rectangle.new(100, 200):setSize(-100, 200)
    end)
    test:assertError(function ()
      Rectangle.new(100, 200):setSize(100, -200)
    end)
  end)
end)


test:group("getPoint()", function ()
  test:run("should get the specified point", function (index, coords)
    local rect = Rectangle.new(100, 200)
    test:assertEqual({coords[1], coords[2]}, {rect:getPoint(index)})
  end, {
    {1, {0, 0}},
    {2, {100, 0}},
    {3, {100, 200}},
    {4, {0, 200}},
  })
  test:run("should raise an error for invalid indexes", function ()
    test:assertError(function ()
      local _ = Rectangle.new(100, 200):getPoint(-1)
    end)
    test:assertError(function ()
      local _ = Rectangle.new(100, 200):getPoint(99)
    end)
  end)
end)

test:group("getBounds()", function ()
  test:run("should get the bounding rectangle", function ()
    local rect = Rectangle.new(100, 200)
    test:assertEqual({0, 0, 100, 200}, {rect:getBounds()})
  end)
end)

return test