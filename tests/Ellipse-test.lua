local Ellipse = require("Ellipse")
local lovecase = require("libs.lovecase")

local expect = lovecase.expect
local suite = lovecase.newSuite("Ellipse")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    expect.equal("loveshape.Ellipse", Ellipse.new(12, 6, 8):type())
  end)
end)

suite:describe("typeOf()", function ()
  suite:test("should determine if the object is the specified type", function (typename, expectedResult)
    expect.equal(expectedResult, Ellipse.new(12, 6, 8):typeOf(typename))
  end, {
    {"loveshape.Rectangle", false},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Ellipse", true},
  })
end)

suite:describe("new()", function ()
  suite:test("should create an ellipse with the specified radius", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    expect.equal({12, 6}, {ellipse:getRadius()})
  end)
  suite:test("should only accept a positive radius", function ()
    expect.error(function ()
      local ellipse = Ellipse.new(-12, 6, 8)
    end)
    expect.error(function ()
      local ellipse = Ellipse.new(12, -6, 8)
    end)
  end)
  suite:test("should create an ellipse with the specified number of points", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    expect.equal(8, ellipse:getPointsCount())
  end)
  suite:test("should require at least 3 points", function ()
    expect.error(function ()
      local ellipse = Ellipse.new(12, 6, 2)
    end)
  end)
end)

suite:describe("setRadius()", function ()
  suite:test("should set the radius", function ()
    local ellipse = Ellipse.new(12, 6, 8):setRadius(20, 10)
    expect.equal({20, 10}, {ellipse:getRadius()})
  end)
  suite:test("should only accept positive values", function ()
    expect.error(function ()
      Ellipse.new(12, 6, 8):setRadius(-12, 6)
    end)
    expect.error(function ()
      Ellipse.new(12, 6, 8):setRadius(12, -6)
    end)
  end)
end)

suite:describe("getBounds()", function ()
  suite:test("should get the bounding rectangle", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    expect.almostEqual({-12, -6, 24, 12}, {ellipse:getBounds()})
  end)
end)

return suite