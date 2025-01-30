local lovecase = require("libs.lovecase")
local Rectangle = require("Rectangle")

local expect = lovecase.expect
local suite = lovecase.newSuite("Rectangle")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    local rect = Rectangle.new(100, 200)
    expect.equal("loveshape.Rectangle", rect:type())
  end)
end)

suite:describe("typeOf()", function ()
  suite:test("should determine if the object is the specified type", function (typename, expectedResult)
    local rect = Rectangle.new(100, 200)
    expect.equal(expectedResult, rect:typeOf(typename))
  end, {
    {"loveshape.Rectangle", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

suite:describe("new()", function ()
  suite:test("should create a rectangle with the specified size", function ()
    local rect = Rectangle.new(100, 200)
    expect.equal({100, 200}, {rect:getSize()})
  end)
  suite:test("should not accept negative sizes", function ()
    expect.error(function ()
      local rect = Rectangle.new(-100, 200)
    end)
    expect.error(function ()
      local rect = Rectangle.new(100, -200)
    end)
  end)
end)

suite:describe("setWidth()", function ()
  suite:test("should set the width", function ()
    local rect = Rectangle.new(100, 200):setWidth(300)
    expect.equal(300, rect:getWidth())
  end)
  suite:test("should not accept negative widths", function ()
    expect.error(function ()
      Rectangle.new(100, 200):setWidth(-100)
    end)
  end)
end)

suite:describe("setHeight()", function ()
  suite:test("should set the height", function ()
    local rect = Rectangle.new(100, 200):setHeight(300)
    expect.equal(300, rect:getHeight())
  end)
  suite:test("should not accept negative height", function ()
    expect.error(function ()
      Rectangle.new(100, 200):setHeight(-100)
    end)
  end)
end)

suite:describe("setSize()", function ()
  suite:test("should set the size", function ()
    local rect = Rectangle.new(100, 200):setSize(300, 400)
    expect.equal({300, 400}, {rect:getSize()})
  end)
  suite:test("should not accept negative dimensions", function ()
    expect.error(function ()
      Rectangle.new(100, 200):setSize(-100, 200)
    end)
    expect.error(function ()
      Rectangle.new(100, 200):setSize(100, -200)
    end)
  end)
end)


suite:describe("getPoint()", function ()
  suite:test("should get the specified point", function (index, coords)
    local rect = Rectangle.new(100, 200)
    expect.equal({coords[1], coords[2]}, {rect:getPoint(index)})
  end, {
    {1, {0, 0}},
    {2, {100, 0}},
    {3, {100, 200}},
    {4, {0, 200}},
  })
  suite:test("should raise an error for invalid indexes", function ()
    expect.error(function ()
      local _ = Rectangle.new(100, 200):getPoint(-1)
    end)
    expect.error(function ()
      local _ = Rectangle.new(100, 200):getPoint(99)
    end)
  end)
end)

suite:describe("getBounds()", function ()
  suite:test("should get the bounding rectangle", function ()
    local rect = Rectangle.new(100, 200)
    expect.equal({0, 0, 100, 200}, {rect:getBounds()})
  end)
end)

return suite