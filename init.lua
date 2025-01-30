local BASE = (...):gsub("init$", ""):gsub("([^%.])$", "%1%.")

--- Provides drawable geometric primitives for the LÖVE framework.
--- @class loveshape
local loveshape = {
  _NAME = "loveshape",
  _DESCRIPTION = "Drawable geometric primitives for the LÖVE framework.",
  _VERSION = "1.2.2",
  _URL = "https://github.com/binaryfs/loveshape",
  _LICENSE = [[
    MIT License

    Copyright (c) 2023 Fabian Staacke

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]],
}

--- @type loveshape.Ellipse
loveshape.Ellipse = require(BASE .. "Ellipse")

--- @type loveshape.Circle
loveshape.Circle = require(BASE .. "Circle")

--- @type loveshape.ConvexPolygon
loveshape.ConvexPolygon = require(BASE .. "ConvexPolygon")

--- @type loveshape.Rectangle
loveshape.Rectangle = require(BASE .. "Rectangle")

--- @type loveshape.RoundedRectangle
loveshape.RoundedRectangle = require(BASE .. "RoundedRectangle")

--- @type loveshape.Shape
loveshape.Shape = require(BASE .. "Shape")

return loveshape