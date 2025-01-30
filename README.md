# loveshape
This library provides drawable geometric shapes for the [LÖVE framework.](https://love2d.org/)

In contrast to the LÖVE graphics API, the primitives are drawn in retained mode instead of immediate mode. This means that each shape is represented by an actual object that stores the size, colors and other properties for drawing.

The following screenshot shows the LÖVE demo that is included in the loveshape repository:

![loveshape demo screenshot](assets/screenshot.png?raw=true)

## Features

- Available shapes:
  - rectangles
  - rounded rectangles
  - circles / regular polygons
  - ellipses
  - convex polygons
- Outer and inner borders with adjustable width and smoothing
- Fill and border colors
- Textured shapes
- Soft edges
- Bounding rectangles
- Alignments (align shapes to specified points)

The shapes are based on meshes, so you can do anything with them that you can do with meshes.

## Requirements

loveshape requires LÖVE 11.4+ and has no other external dependencies.

## Integration

This section describes how to integrate loveshape into your project.

### Manually

Create a new subdirectory `libs/loveshape` in your project root and paste the content of this repository into it. Afterwards you can include loveshape like this:

```lua
local loveshape = require("libs.loveshape")
```

The naming of `libs/loveshape` is just an example, of course. You can use any name you like.

### Git Submodule

Run the following command in your project root to add loveshape as a submodule:

```
git submodule add https://github.com/binaryfs/loveshape.git libs/loveshape
```

Afterwards you can include loveshape like this:

```lua
local loveshape = require("libs.loveshape")
```

## Usage

### Basic example

This example draws a red rectangle with green border.

```lua
local loveshape = require("libs.loveshape")

local rect

function love.load()
  rect = loveshape.Rectangle.new(200, 100)
  rect:setFillColor(1, 0, 0)
  rect:setBorderWidth(3)
  -- Colors can also be specified as tables
  rect:setBorderColor({0, 1, 0})
end

function love.draw()
  -- This method accepts the same arguments as love.graphics.draw()
  rect:draw(50, 50)
end
```

Create a convex polygon:

```lua
-- 4 is the number of vertices.
local poly = loveshape.ConvexPolygon.new(4)

-- Set points in clockwise order:
poly:setPoint(1, 0, 0)
poly:setPoint(2, 30, 30)
poly:setPoint(3, 0, 90)
poly:setPoint(4, -30, 30)

assert(poly:isConvex(), "Polygon is not convex!")
```

### Borders

![Borders](assets/borders.png?raw=true)

Apply different kind of borders:

```lua
local rect = loveshape.Rectangle.new(200, 100)

-- Positive values create an outer border.
rect:setBorderWidth(10)

-- Use negative values to create an inner border.
rect:setBorderWidth(-6)

-- Set border width to zero to remove the border.
rect:setBorderWidth(0)

-- Blur the border edges to make it smoother.
-- The default smoothing value is 1.
rect:setBorderSmoothing(4)
```

### Soft edges

![Soft edges](assets/soft-edges.png?raw=true)

```lua
local rect = loveshape.Rectangle.new(50, 50)

-- Shapes use a smoothing value of 1 by default (for better anti-aliasing).
-- Increase the smoothing value to render blurred edges.
rect:setEdgeSmoothing(10)

-- Disable soft edges completely.
rect:setEdgeSmoothing(0)

-- When a border is set, soft edges are disabled automatically.
-- Use Shape:setBorderSmoothing instead.
rect:setBorderWidth(5)
rect:setBorderSmoothing(2)
```

### Textures

![Borders](assets/textured-hexagon.png?raw=true)

Create a textured shape:

```lua
local image = love.graphics.newImage("path/to/image.png")
local hexagon = loveshape.Circle.new(50, 6)

-- If second argument is true, the texture coodinates of the shape are set
-- automatically.
hexagon:setTexture(image, true)

-- Alternatively you can set them manually, e.g. to use an atlas image or to
-- repeat the texture.
hexagon:setTextureQuad(16, 16, 128, 128)

-- Remove the texture.
hexagon:setTexture(nil)
```

### Alignment

![Borders](assets/alignment.png?raw=true)

Draw shapes aligned to specified points, which is useful in GUIs and layouts.

```lua
local rect = loveshape.Rectangle.new(50, 50)

-- Center the shape at the specified point.
rect:drawAligned("center", "center", x, y)

-- Align the bottom-right corner of the shape at the specified point.
rect:drawAligned("right", "bottom", x, y)
```

### Custom shapes

To create a custom diamond shape, create a new file named `Diamond.lua` in your project and insert the following code:

```lua
local loveshape = require("libs.loveshape")
local utils = require("libs.loveshape.utils")

local Diamond = utils.class("Diamond", loveshape.Shape)

-- Create a new diamond shape.
function Diamond.new(width, height)
  local self = setmetatable({}, Diamond)
  Shape._init(self, 4)
  self._width = width
  self._height = height
  return self
end

-- Get the positon of the specified vertex.
function Diamond:getPoint(index)
  if index == 1 then
    return 0, -self._height / 2
  elseif index == 2 then
    return self._width / 2, 0
  elseif index == 3 then
    return 0, self._height / 2
  elseif index == 4 then
    return -self._width / 2, 0
  end
  error("Invalid vertex index: " .. tostring(index))
end

return Diamond
```

And you're done. Now you can use your diamond shape like any other shape from loveshape.

### Demo

Have a look at the LÖVE demo (`main.lua`) to find many more examples.

If you would like to run the unit tests, download [lovecase 4](https://github.com/binaryfs/lovecase) and copy the files into the subdirectory `libs/lovecase`. When you start the LÖVE demo, the unit tests are run automatically.

## Credits

loveshape was inspired from the drawable shape objects in [SFML.](https://www.sfml-dev.org/)

The wall texture was created by [Kutejnikov.](https://opengameart.org/content/wall-texture-wallpng)

## License

MIT License (see LICENSE file in project root)