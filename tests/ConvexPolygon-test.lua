local ConvexPolygon = require("ConvexPolygon")
local lovecase = require("libs.lovecase")

local test = lovecase.newTestSet("ConvexPolygon")

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.ConvexPolygon", ConvexPolygon.new(3):type())
  end)
end)

test:group("typeOf()", function ()
  test:run("should determine if the object is the specified type", function (typename, expectedResult)
    test:assertEqual(expectedResult, ConvexPolygon.new(3):typeOf(typename))
  end, {
    {"loveshape.ConvexPolygon", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

test:group("new()", function ()
  test:run("should create a polygon with the given number of points", function ()
    local poly = ConvexPolygon.new(6)
    test:assertEqual(6, poly:getPointsCount())
  end)
  test:run("should not accept less than 3 points", function ()
    test:assertError(function ()
      local poly = ConvexPolygon.new(2)
    end)
  end)
end)

test:group("setPoint()", function ()
  test:run("should set the specified point", function ()
    local poly = ConvexPolygon.new(3):setPoint(1, 10, 20)
    test:assertEqual({10, 20}, {poly:getPoint(1)})
  end)
  test:run("should raise an error for invalid indexes", function ()
    test:assertError(function ()
      ConvexPolygon.new(3):setPoint(-1, 10, 20)
    end)
    test:assertError(function ()
      ConvexPolygon.new(3):setPoint(4, 10, 20)
    end)
  end)
end)

test:group("isConvex()", function ()
  test:run("should return true if polygon is convex", function ()
    local poly = ConvexPolygon.new(3)
    poly:setPoint(1, 0, -10)
    poly:setPoint(2, 10, 10)
    poly:setPoint(3, -10, 10)
    test:assertTrue(poly:isConvex())
  end)
  test:run("should return false if polygon is concave", function ()
    local poly = ConvexPolygon.new(5)
    poly:setPoint(1, 0, 0)
    poly:setPoint(2, 5, 5)
    poly:setPoint(3, 10, 0)
    poly:setPoint(4, 10, 10)
    poly:setPoint(5, 0, 10)
    test:assertFalse(poly:isConvex())
  end)
end)

return test