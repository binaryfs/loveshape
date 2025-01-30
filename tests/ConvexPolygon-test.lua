local ConvexPolygon = require("ConvexPolygon")
local lovecase = require("libs.lovecase")

local expect = lovecase.expect
local suite = lovecase.newSuite("ConvexPolygon")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    expect.equal("loveshape.ConvexPolygon", ConvexPolygon.new(3):type())
  end)
end)

suite:describe("typeOf()", function ()
  suite:test("should determine if the object is the specified type", function (typename, expectedResult)
    expect.equal(expectedResult, ConvexPolygon.new(3):typeOf(typename))
  end, {
    {"loveshape.ConvexPolygon", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

suite:describe("new()", function ()
  suite:test("should create a polygon with the given number of points", function ()
    local poly = ConvexPolygon.new(6)
    expect.equal(6, poly:getPointsCount())
  end)
  suite:test("should not accept less than 3 points", function ()
    expect.error(function ()
      local poly = ConvexPolygon.new(2)
    end)
  end)
end)

suite:describe("setPoint()", function ()
  suite:test("should set the specified point", function ()
    local poly = ConvexPolygon.new(3):setPoint(1, 10, 20)
    expect.equal({10, 20}, {poly:getPoint(1)})
  end)
  suite:test("should raise an error for invalid indexes", function ()
    expect.error(function ()
      ConvexPolygon.new(3):setPoint(-1, 10, 20)
    end)
    expect.error(function ()
      ConvexPolygon.new(3):setPoint(4, 10, 20)
    end)
  end)
end)

suite:describe("isConvex()", function ()
  suite:test("should return true if polygon is convex", function ()
    local poly = ConvexPolygon.new(3)
    poly:setPoint(1, 0, -10)
    poly:setPoint(2, 10, 10)
    poly:setPoint(3, -10, 10)
    expect.isTrue(poly:isConvex())
  end)
  suite:test("should return false if polygon is concave", function ()
    local poly = ConvexPolygon.new(5)
    poly:setPoint(1, 0, 0)
    poly:setPoint(2, 5, 5)
    poly:setPoint(3, 10, 0)
    poly:setPoint(4, 10, 10)
    poly:setPoint(5, 0, 10)
    expect.isFalse(poly:isConvex())
  end)
end)

return suite