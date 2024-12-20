local Circle = require("Circle")
local lovecase = require("libs.lovecase")

local test = lovecase.newTestSet("Circle")

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.Circle", Circle.new(10, 3):type())
  end)
end)

test:group("typeOf()", function ()
  test:run("should determine if the object is the specified type", function (typename, expectedResult)
    test:assertEqual(expectedResult, Circle.new(50, 3):typeOf(typename))
  end, {
    {"loveshape.Rectangle", false},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Circle", true},
  })
end)

test:group("new()", function ()
  test:run("should create a circle with the specified radius", function ()
    local circle = Circle.new(100, 3)
    test:assertEqual(100, circle:getRadius())
  end)
  test:run("should only accept a positive radius", function ()
    test:assertError(function ()
      local circle = Circle.new(-100, 3)
    end)
  end)
  test:run("should create a circle with the specified number of points", function ()
    local circle = Circle.new(100, 6)
    test:assertEqual(6, circle:getPointsCount())
  end)
  test:run("should require at least 3 points", function ()
    test:assertError(function ()
      local circle = Circle.new(100, 2)
    end)
  end)
end)

test:group("setRadius()", function ()
  test:run("should set the radius", function ()
    local circle = Circle.new(100, 3):setRadius(200)
    test:assertEqual(200, circle:getRadius())
  end)
  test:run("should only accept positive values", function ()
    test:assertError(function ()
      Circle.new(100, 2):setRadius(-100)
    end)
  end)
end)

test:group("getBounds()", function ()
  test:run("should get the bounding rectangle", function ()
    local circle = Circle.new(100, 4)
    test:assertEqual({-100, -100, 200, 200}, {circle:getBounds()})
  end)
end)

return test