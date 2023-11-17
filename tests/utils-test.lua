local loveunit = require("loveunit")
local utils = require("utils")

local test = loveunit.newTestCase("utils")

test:group("clamp()", function ()
  test:run("should clamp a value between a lower an an upper bound", function (value, min, max, result)
    test:assertEqual(result, utils.clamp(value, min, max))
  end, {
    {5, 10, 20, 10},
    {30, 10, 20, 20},
    {10, 10, 20, 10},
    {20, 10, 20, 20},
    {15, 10, 20, 15},
  })
end)

test:group("vecLength()", function ()
  test:run("should return the length of a vector", function (x, y, length)
    test:assertAlmostEqual(length, utils.vecLength(x, y))
  end, {
    {10, 0, 10},
    {0, 10, 10},
    {0, 0, 0},
    {-10, 0, 10},
    {10, 10, math.sqrt(2) * 10},
  })
end)

test:group("vecNormalize()", function ()
  test:run("should normalize a vector to unit length", function (x, y, nx, ny)
    test:assertAlmostEqual({nx, ny}, {utils.vecNormalize(x, y)})
  end, {
    {10, 0, 1, 0},
    {0, 10, 0, 1},
  })
  test:run("should normalize a vector to the specified length", function ()
    test:assertAlmostEqual(4, utils.vecLength(utils.vecNormalize(10, 20, 4)))
  end)
end)

test:group("computeVertexNormal()", function ()
  test:run("should compute the vertex normal", function (ax, ay, bx, by, cx, cy, length, nx, ny)
    test:assertAlmostEqual({nx, ny}, {utils.computeVertexNormal(ax, ay, bx, by, cx, cy, length)})
  end, {
    -- a--b--c
    {0, 0, 10, 0, 20, 0, 5, 0, -5},
    -- c--b--a
    {0, 0, -10, 0, -20, 0, 6, 0, 6},
    -- a
    -- |
    -- b
    -- |
    -- c
    {0, 0, 0, 10, 0, 20, 7, 7, 0},
    -- a--b
    --    |
    --    c
    {0, 0, 10, 0, 10, 20, 8, 8, -8},
    -- c
    -- |
    -- b--a
    {0, 0, -10, 0, -10, -10, 9, -9, 9},
  })
end)