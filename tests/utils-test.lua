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

test:group("almostEqual()", function ()
  test:run("should determine if two numbers are almost equal", function (a, b, equal)
    test:assertEqual(utils.almostEqual(a, b), equal)
  end, {
    {1, 1, true},
    {1, 2, false},
    {100000000000000.01, 100000000000000.011, true},
    {100.01, 100.011, false},
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

test:group("vecEquals()", function ()
  test:run("should determine if two vectors are equal", function (ax, ay, bx, by, equal)
    test:assertEqual(utils.vecEquals(ax, ay, bx, by), equal)
  end, {
    {1, 2, 1, 2, true},
    {100.01, 0, 100.011, 0, false},
    {100000000000000.01, 0, 100000000000000.011, 0, true},
  })
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

test:group("nextDistinctVertexPosition()", function ()
  test:run("should return the next distinct vertex position", function (vertex, x, y)
    local mesh = love.graphics.newMesh(4, "fan")
    mesh:setVertexAttribute(1, 1, 0, 0)
    mesh:setVertexAttribute(2, 1, 0, 0)
    mesh:setVertexAttribute(3, 1, 10, 0)
    mesh:setVertexAttribute(4, 1, 5, 10)
    test:assertEqual({x, y}, {utils.nextDistinctVertexPosition(mesh, vertex)})
  end, {
    {1, 10, 0},
    {2, 10, 0},
    {3, 5, 10},
    {4, 0, 0},
  })
  test:run("should return the shared postion if no vertex is distinct", function ()
    local mesh = love.graphics.newMesh(4, "fan")
    test:assertEqual({0, 0}, {utils.nextDistinctVertexPosition(mesh, 1)})
  end)
end)

test:group("previousDistinctVertexPosition()", function ()
  test:run("should return the previous distinct vertex position", function (vertex, x, y)
    local mesh = love.graphics.newMesh(4, "fan")
    mesh:setVertexAttribute(1, 1, 0, 0)
    mesh:setVertexAttribute(2, 1, 0, 0)
    mesh:setVertexAttribute(3, 1, 10, 0)
    mesh:setVertexAttribute(4, 1, 5, 10)
    test:assertEqual({x, y}, {utils.previousDistinctVertexPosition(mesh, vertex)})
  end, {
    {1, 5, 10},
    {2, 5, 10},
    {3, 0, 0},
    {4, 10, 0},
  })
  test:run("should return the shared postion if no vertex is distinct", function ()
    local mesh = love.graphics.newMesh(4, "fan")
    test:assertEqual({0, 0}, {utils.previousDistinctVertexPosition(mesh, 1)})
  end)
end)