local Ellipse = require("Ellipse")
local lovecase = require("libs.lovecase")

local test = lovecase.newTestSet("Ellipse")

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.Ellipse", Ellipse.new(12, 6, 8):type())
  end)
end)

test:group("typeOf()", function ()
  test:run("should determine if the object is the specified type", function (typename, expectedResult)
    test:assertEqual(expectedResult, Ellipse.new(12, 6, 8):typeOf(typename))
  end, {
    {"loveshape.Rectangle", false},
    {"loveshape.Shape", true},
    {"loveshape.Object", true},
    {"loveshape.Ellipse", true},
  })
end)

test:group("new()", function ()
  test:run("should create an ellipse with the specified radius", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    test:assertEqual({12, 6}, {ellipse:getRadius()})
  end)
  test:run("should only accept a positive radius", function ()
    test:assertError(function ()
      local ellipse = Ellipse.new(-12, 6, 8)
    end)
    test:assertError(function ()
      local ellipse = Ellipse.new(12, -6, 8)
    end)
  end)
  test:run("should create an ellipse with the specified number of points", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    test:assertEqual(8, ellipse:getPointsCount())
  end)
  test:run("should require at least 3 points", function ()
    test:assertError(function ()
      local ellipse = Ellipse.new(12, 6, 2)
    end)
  end)
end)

test:group("setRadius()", function ()
  test:run("should set the radius", function ()
    local ellipse = Ellipse.new(12, 6, 8):setRadius(20, 10)
    test:assertEqual({20, 10}, {ellipse:getRadius()})
  end)
  test:run("should only accept positive values", function ()
    test:assertError(function ()
      Ellipse.new(12, 6, 8):setRadius(-12, 6)
    end)
    test:assertError(function ()
      Ellipse.new(12, 6, 8):setRadius(12, -6)
    end)
  end)
end)

test:group("getBounds()", function ()
  test:run("should get the bounding rectangle", function ()
    local ellipse = Ellipse.new(12, 6, 8)
    test:assertAlmostEqual({-12, -6, 24, 12}, {ellipse:getBounds()})
  end)
end)

return test