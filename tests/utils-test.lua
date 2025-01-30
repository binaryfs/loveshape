local lovecase = require("libs.lovecase")
local utils = require("utils")

local expect = lovecase.expect
local suite = lovecase.newSuite("utils")

suite:describe("clamp()", function ()
  suite:test("should clamp a value between a lower an an upper bound", function (value, min, max, result)
    expect.equal(result, utils.clamp(value, min, max))
  end, {
    {5, 10, 20, 10},
    {30, 10, 20, 20},
    {10, 10, 20, 10},
    {20, 10, 20, 20},
    {15, 10, 20, 15},
  })
end)

suite:describe("almostEqual()", function ()
  suite:test("should determine if two numbers are almost equal", function (a, b, equal)
    expect.equal(utils.almostEqual(a, b), equal)
  end, {
    {1, 1, true},
    {1, 2, false},
    {100000000000000.01, 100000000000000.011, true},
    {100.01, 100.011, false},
  })
end)

suite:describe("vecLength()", function ()
  suite:test("should return the length of a vector", function (x, y, length)
    expect.almostEqual(length, utils.vecLength(x, y))
  end, {
    {10, 0, 10},
    {0, 10, 10},
    {0, 0, 0},
    {-10, 0, 10},
    {10, 10, math.sqrt(2) * 10},
  })
end)

suite:describe("vecNormalize()", function ()
  suite:test("should normalize a vector to unit length", function (x, y, nx, ny)
    expect.almostEqual({nx, ny}, {utils.vecNormalize(x, y)})
  end, {
    {10, 0, 1, 0},
    {0, 10, 0, 1},
  })
  suite:test("should normalize a vector to the specified length", function ()
    expect.almostEqual(4, utils.vecLength(utils.vecNormalize(10, 20, 4)))
  end)
end)

suite:describe("vecEquals()", function ()
  suite:test("should determine if two vectors are equal", function (ax, ay, bx, by, equal)
    expect.equal(utils.vecEquals(ax, ay, bx, by), equal)
  end, {
    {1, 2, 1, 2, true},
    {100.01, 0, 100.011, 0, false},
    {100000000000000.01, 0, 100000000000000.011, 0, true},
  })
end)

suite:describe("computeVertexNormal()", function ()
  -- ax, ay -> Start vertex of first edge
  -- bx, by -> Shared vertex of first and second edge
  -- cx, cy -> End vertex of second edge
  -- length -> Desired length of the normal
  -- nx, ny -> Expected normal
  suite:test("should compute the vertex normal", function (ax, ay, bx, by, cx, cy, length, nx, ny)
    local normalX, normalY = utils.computeVertexNormal(ax, ay, bx, by, cx, cy)
    expect.almostEqual({nx, ny}, {normalX * length, normalY * length})
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

suite:describe("nextDistinctVertexPosition()", function ()
  suite:test("should return the next distinct vertex position", function (vertex, x, y)
    local mesh = love.graphics.newMesh(4, "fan")
    mesh:setVertexAttribute(1, 1, 0, 0)
    mesh:setVertexAttribute(2, 1, 0, 0)
    mesh:setVertexAttribute(3, 1, 10, 0)
    mesh:setVertexAttribute(4, 1, 5, 10)
    expect.equal({x, y}, {utils.nextDistinctVertexPosition(mesh, vertex)})
  end, {
    {1, 10, 0},
    {2, 10, 0},
    {3, 5, 10},
    {4, 0, 0},
  })
  suite:test("should return the shared postion if no vertex is distinct", function ()
    local mesh = love.graphics.newMesh(4, "fan")
    expect.equal({0, 0}, {utils.nextDistinctVertexPosition(mesh, 1)})
  end)
end)

suite:describe("previousDistinctVertexPosition()", function ()
  suite:test("should return the previous distinct vertex position", function (vertex, x, y)
    local mesh = love.graphics.newMesh(4, "fan")
    mesh:setVertexAttribute(1, 1, 0, 0)
    mesh:setVertexAttribute(2, 1, 0, 0)
    mesh:setVertexAttribute(3, 1, 10, 0)
    mesh:setVertexAttribute(4, 1, 5, 10)
    expect.equal({x, y}, {utils.previousDistinctVertexPosition(mesh, vertex)})
  end, {
    {1, 5, 10},
    {2, 5, 10},
    {3, 0, 0},
    {4, 10, 0},
  })
  suite:test("should return the shared postion if no vertex is distinct", function ()
    local mesh = love.graphics.newMesh(4, "fan")
    expect.equal({0, 0}, {utils.previousDistinctVertexPosition(mesh, 1)})
  end)
end)

return suite