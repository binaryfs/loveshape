local Bounds = require("Bounds")
local lovecase = require("libs.lovecase")

local expect = lovecase.expect
local suite = lovecase.newSuite("Bounds")

suite:describe("type()", function ()
  suite:test("should return the typename", function ()
    expect.equal("loveshape.Bounds", Bounds.new():type())
  end)
end)

suite:describe("new()", function ()
  suite:test("should create bounds with infinite dimensions", function ()
    local bounds = Bounds.new()
    expect.equal({math.huge, math.huge, -math.huge, -math.huge}, {bounds:unpack()})
  end)
end)

suite:describe("set()", function ()
  suite:test("should set the dimensions of the bounds object", function ()
    local bounds = Bounds.new()
    bounds:set(10, 20, 30, 40)
    expect.equal({10, 20, 30, 40}, {bounds:unpack()})
  end)
end)

suite:describe("getRect()", function ()
  suite:test("should return the rectangle of the bounds", function ()
    local bounds = Bounds.new():set(10, 10, 25, 35)
    expect.equal({10, 10, 15, 25}, {bounds:getRect()})
  end)
end)

suite:describe("isEmpty()", function ()
  suite:test("should initially return true", function ()
    expect.isTrue(Bounds.new():isEmpty())
  end)
  suite:test("should return false for non-empty bounds", function ()
    expect.isFalse(Bounds.new():set(0, 0, 1, 1):isEmpty())
  end)
end)

suite:describe("reset()", function ()
  suite:test("should reset the bounds to infinite dimensions", function ()
    local bounds = Bounds.new():set(0, 0, 10, 10)
    bounds:reset()
    expect.equal({math.huge, math.huge, -math.huge, -math.huge}, {bounds:unpack()})
  end)
end)

suite:describe("getWidth()", function ()
  suite:test("should get the width of the bounds", function ()
    local bounds = Bounds.new():set(10, 20, 33, 44)
    expect.equal(23, bounds:getWidth())
  end)
end)

suite:describe("getHeight()", function ()
  suite:test("should get the height of the bounds", function ()
    local bounds = Bounds.new():set(10, 20, 33, 44)
    expect.equal(24, bounds:getHeight())
  end)
end)

suite:describe("copyFrom()", function ()
  suite:test("should copy the values from the specified bounds", function ()
    local bounds1 = Bounds.new()
    local bounds2 = Bounds.new():set(10, 20, 30, 40)
    bounds1:copyFrom(bounds2)
    expect.equal(bounds2, bounds1)
  end)
end)

suite:describe("addPoint()", function ()
  suite:test("should extend the bounds to contain the point", function ()
    local bounds = Bounds.new()
    bounds:addPoint(10, 20)
    expect.equal({10, 20, 10, 20}, {bounds:unpack()})
    bounds:addPoint(5, 20)
    expect.equal({5, 20, 10, 20}, {bounds:unpack()})
    bounds:addPoint(5, 15)
    expect.equal({5, 15, 10, 20}, {bounds:unpack()})
    bounds:addPoint(15, 20)
    expect.equal({5, 15, 15, 20}, {bounds:unpack()})
    bounds:addPoint(15, 25)
    expect.equal({5, 15, 15, 25}, {bounds:unpack()})
    bounds:addPoint(5, 15)
    expect.equal({5, 15, 15, 25}, {bounds:unpack()})
  end)
end)

return suite