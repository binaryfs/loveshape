local loveunit = require("loveunit")
local RoundedRectangle = require("RoundedRectangle")

local test = loveunit.newTestCase("RoundedRectangle")

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.RoundedRectangle", RoundedRectangle.new(100, 200, 10, 3):type())
  end)
end)

test:group("typeOf()", function ()
  test:run("should determine if the object is the specified type", function (typename, expectedResult)
    test:assertEqual(expectedResult, RoundedRectangle.new(100, 100, 10, 3):typeOf(typename))
  end, {
    {"loveshape.Rectangle", true},
    {"loveshape.RoundedRectangle", true},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", false},
  })
end)

test:group("new()", function ()
  test:run("should create a rectangle with the specified size", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    test:assertEqual({100, 200}, {rect:getSize()})
  end)
  test:run("should create a rectangle with the specified corner radius", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    test:assertEqual(10, rect:getCornerRadius())
  end)
  test:run("should create a rectangle with the specified number of points per corner", function ()
    local rect = RoundedRectangle.new(100, 200, 10, 3)
    test:assertEqual(3, rect:getPointsPerCorner())
  end)
  test:run("should not accept a corner radius <= 0", function ()
    test:assertError(function ()
      local rect = RoundedRectangle.new(100, 200, -10, 3)
    end)
  end)
  test:run("should not accept less than 2 points per corner", function ()
    test:assertError(function ()
      local rect = RoundedRectangle.new(100, 200, 10, 1)
    end)
  end)
end)