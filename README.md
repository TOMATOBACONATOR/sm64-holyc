# SM64 HolyC - Super Mario 64 in HolyC with 3D Renderer

A complete Super Mario 64 remake featuring a custom 3D renderer written entirely in HolyC.

## Project Structure

- `kernel/` - Core 3D rendering engine
  - `math.HC` - Vector and matrix mathematics
  - `renderer.HC` - Polygon rasterization and projection
- `game/` - Mario game logic and mechanics
  - `mario.HC` - Mario character controller
  - `level.HC` - Level geometry and management
- `main.HC` - Main game loop and initialization

## Building and Running

Compile in TempleOS:
```holyc
TempleOS> #include "main.HC"
```

## Controls

- **Arrow Keys** - Move Mario
- **Spacebar** - Jump
- **ESC** - Exit Game

## Features

✅ Custom 3D vector math library (Vec3, Vec4)
✅ Matrix transformations (rotation, translation, scale)
✅ Polygon rasterization renderer with depth testing
✅ Perspective projection
✅ Mario character controller with physics
✅ Gravity and jump mechanics
✅ Peach's Castle level geometry
✅ 60 FPS game loop with fixed timestep
✅ Keyboard input handling

## Implementation Details

### 3D Math Engine
- Vec3/Vec4 operations (add, subtract, scale, normalize, dot, cross)
- Matrix operations with proper multiplication
- Rotation matrices (X, Y, Z axes)
- Translation and scale transforms

### Renderer
- Screen-space rasterization
- Depth buffering for hidden surface removal
- Perspective-correct projection
- Per-triangle rendering with color

### Game Logic
- Mario physics with gravity
- Jump implementation with velocity
- Ground collision detection
- Camera following Mario
- Level rendering system

## Future Enhancements

- [ ] Load 3D models from files
- [ ] Texture mapping
- [ ] Lighting and shading
- [ ] More complex level geometry
- [ ] Enemy AI
- [ ] Collectible stars
- [ ] Animation system
- [ ] Sound effects (if TempleOS supports)

## Author

Created in HolyC for TempleOS

## License

Public Domain
