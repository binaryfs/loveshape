# loveshape
This library provides drawable geometric shapes for the [LÖVE framework.](https://love2d.org/)

In contrast to the LÖVE graphics API, the primitives are drawn in retained mode instead of immediate mode. This means that each shape is represented by an actual object that stores the size, colors and other properties for drawing.

The following screenshot shows the LÖVE demo that is included in the loveshape repository:

![loveshape demo screenshot](assets/screenshot.png?raw=true)

## Features

- Available shapes:
  - rectangles
  - rounded rectangles
  - circles
  - convex polygons
- Borders with adjustable width and smoothing
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

### Demo

Have a look at the LÖVE demo (`main.lua`) to find many more examples.

## Credits

loveshape was inspired from the drawable shape objects in [SFML.](https://www.sfml-dev.org/)

The wall texture was created by [Kutejnikov.](https://opengameart.org/content/wall-texture-wallpng)

## License

MIT License (see LICENSE file in project root)