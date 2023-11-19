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
- Bounding rectangles
- Alignments (align shapes to specified points)

The shapes are based on meshes, so you can do anything with them that you can do with meshes.

## Requirements

loveshape requires LÖVE 11.4 and has no other external dependencies.

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

### Borders

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
rect:setBorderSmoothing(4)
```

### Textures

Create a textured hexagon:

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

### Shapes

Create a convex polygon:

```lua
local poly = loveshape.ConvexPolygon.new(4)

-- Set points in clockwise order:
poly:setPoint(1, 0, 0)
poly:setPoint(2, 30, 30)
poly:setPoint(3, 0, 90)
poly:setPoint(4, -30, 30)

assert(poly:isConvex(), "Polygon is not convex!")
```

### Demo

Have a look at the LÖVE demo (`main.lua`) to find many more examples.

## Credits

loveshape was inspired from the drawable shape objects in [SFML.](https://www.sfml-dev.org/)

The wall texture was created by [Kutejnikov.](https://opengameart.org/content/wall-texture-wallpng)

## License

MIT License (see LICENSE file in project root)