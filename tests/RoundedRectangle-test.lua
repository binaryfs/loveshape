local lovecase = require("libs.lovecase")
local RoundedRectangle = require("RoundedRectangle")

local expect = lovecase.expect
local suite = lovecase.newSuite("RoundedRectangle")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    expect.equal("loveshape.RoundedRectangle", RoundedRectangle.new(100, 200, 10, 3):type())
  end)
end)

suite:describe("typeOf()", function ()
  suite:test("should determine if the object is the specified type", function (typename, expectedResult)
    expect.equal(expectedResult, RoundedRectangle.new(100, 100, 10, 3):typeOf(typename))
  end, {
    {"loveshape.Rectangle", true},
    {"loveshape.RoundedRectangle", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

suite:describe("new()", function ()
  suite:test("should create a rectangle with the specified size", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    expect.equal({100, 200}, {rect:getSize()})
  end)
  suite:test("should create a rectangle with the specified corner radius", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    expect.equal(10, rect:getCornerRadius())
  end)
  suite:test("should create a rectangle with the specified number of points per corner", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    expect.equal(3, rect:getPointsPerCorner())
  end)
  suite:test("should not accept a corner radius <= 0", function ()
    expect.error(function ()
      local rect = RoundedRectangle.new(100, 200, -10, 3)
    end)
  end)
  suite:test("should not accept less than 2 points per corner", function ()
    expect.error(function ()
      local rect = RoundedRectangle.new(100, 200, 10, 1)
    end)
  end)
end)

return suite