local Circle = require("Circle")
local lovecase = require("libs.lovecase")

local expect = lovecase.expect
local suite = lovecase.newSuite("Circle")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    expect.equal("loveshape.Circle", Circle.new(10, 3):type())
  end)
end)

suite:describe("typeOf()", function ()
  suite:test("should determine if the object is the specified type", function (typename, expectedResult)
    expect.equal(expectedResult, Circle.new(50, 3):typeOf(typename))
  end, {
    {"loveshape.Rectangle", false},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", true},
  })
end)

suite:describe("new()", function ()
  suite:test("should create a circle with the specified radius", function ()
    local circle = Circle.new(100, 3)
    expect.equal(100, circle:getRadius())
  end)
  suite:test("should only accept a positive radius", function ()
    expect.error(function ()
      local circle = Circle.new(-100, 3)
    end)
  end)
  suite:test("should create a circle with the specified number of points", function ()
    local circle = Circle.new(100, 6)
    expect.equal(6, circle:getPointsCount())
  end)
  suite:test("should require at least 3 points", function ()
    expect.error(function ()
      local circle = Circle.new(100, 2)
    end)
  end)
end)

suite:describe("setRadius()", function ()
  suite:test("should set the radius", function ()
    local circle = Circle.new(100, 3):setRadius(200)
    expect.equal(200, circle:getRadius())
  end)
  suite:test("should only accept positive values", function ()
    expect.error(function ()
      Circle.new(100, 2):setRadius(-100)
    end)
  end)
end)

suite:describe("getBounds()", function ()
  suite:test("should get the bounding rectangle", function ()
    local circle = Circle.new(100, 4)
    expect.equal({-100, -100, 200, 200}, {circle:getBounds()})
  end)
end)

return suite