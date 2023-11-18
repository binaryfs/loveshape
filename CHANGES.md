# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2023-11-x

### Added

- Unit tests
- `Rectangle:getWidth` and `Rectangle:getHeight`
- `RoundedRectangle:getCornerRadius` and `RoundedRectangle:getPointsPerCorner`
- `Bounds:unpack` to get the dimensions of a bounds object

### Changed

- Clamp components of `Color` class automatically
- `utils.computeVertexNormal` does not return inverted normals anymore

### Fixed

- Wrong height assertion in `Rectangle` initializer
- Wrong vertex normals for perpendicular edges
- Rendering issues of shapes that included non-distinct vertices (e.g. pills)

## [1.0.0] - 2023-11-12

Initial release
