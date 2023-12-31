local Color = require("Color")
local loveunit = require("loveunit")

local test = loveunit.newTestCase("Color")

test:group("type()", function ()
  test:run("should return the typename", function ()
    test:assertEqual("loveshape.Color", Color.new(1, 1, 1):type())
  end)
end)

test:group("new()", function ()
  test:run("should create a color with the specified components", function ()
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, Color.new(0.1, 0.2, 0.3, 0.4))
  end)
  test:run("should set alpha to 1 by default", function ()
    test:assertAlmostEqual({0, 0, 0, 1}, Color.new(0, 0, 0))
  end)
  test:run("should clamp components between 0 and 1", function ()
    test:assertAlmostEqual({0, 1, 1, 0}, Color.new(-1, 255, 100, -100))
  end)
  test:run("should accept a table argument", function ()
    test:assertAlmostEqual({1, 1, 0, 1}, Color.new{1, 1, 0, 1})
  end)
end)

test:group("set()", function ()
  test:run("should set the color components", function ()
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, Color.new(0, 0, 0):set(0.1, 0.2, 0.3, 0.4))
  end)
  test:run("should set alpha to 1 by default", function ()
    test:assertAlmostEqual({0, 0, 0, 1}, Color.new(0, 0, 0):set(0, 0, 0))
  end)
  test:run("should clamp components between 0 and 1", function ()
    test:assertAlmostEqual({0, 1, 1, 0}, Color.new(0, 0, 0):set(-1, 255, 100, -100))
  end)
  test:run("should accept a table argument", function ()
    test:assertAlmostEqual({1, 1, 0, 1}, Color.new(0, 0, 0):set{1, 1, 0, 1})
  end)
end)

test:group("unpack()", function ()
  test:run("should return the color components", function ()
    test:assertAlmostEqual({0.1, 0.2, 0.3, 0.4}, {Color.new(0.1, 0.2, 0.3, 0.4):unpack()})
  end)
end)
