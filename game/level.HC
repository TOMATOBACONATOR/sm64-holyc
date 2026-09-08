// Level Management and Geometry

#include "../kernel/renderer.HC"

#define MAX_TRIANGLES 10000

class Level {
  Triangle triangles[MAX_TRIANGLES];
  I32 triangleCount;
};

Level *gLevel;

Level *LevelCreate() {
  Level *l = MAlloc(sizeof(Level));
  l->triangleCount = 0;
  return l;
}

void LevelAddTriangle(Level *l, Triangle *tri) {
  if (l->triangleCount < MAX_TRIANGLES) {
    l->triangles[l->triangleCount] = *tri;
    l->triangleCount++;
  }
}

void LevelCreatePeachsCastle(Level *l) {
  // Create Peach's Castle level
  // This is a simplified version with basic geometry
  
  Triangle floor_tri;
  
  // Floor
  floor_tri.v[0].pos = Vec3Create(-50, 0, -50);
  floor_tri.v[0].color = 0x228B22; // Forest Green
  
  floor_tri.v[1].pos = Vec3Create(50, 0, -50);
  floor_tri.v[1].color = 0x228B22;
  
  floor_tri.v[2].pos = Vec3Create(-50, 0, 50);
  floor_tri.v[2].color = 0x228B22;
  
  LevelAddTriangle(l, &floor_tri);
  
  // Second triangle for floor
  Triangle floor_tri2;
  floor_tri2.v[0].pos = Vec3Create(50, 0, -50);
  floor_tri2.v[0].color = 0x228B22;
  
  floor_tri2.v[1].pos = Vec3Create(50, 0, 50);
  floor_tri2.v[1].color = 0x228B22;
  
  floor_tri2.v[2].pos = Vec3Create(-50, 0, 50);
  floor_tri2.v[2].color = 0x228B22;
  
  LevelAddTriangle(l, &floor_tri2);
  
  // Back wall
  Triangle wall;
  wall.v[0].pos = Vec3Create(-50, 0, -50);
  wall.v[0].color = 0xFF6B6B; // Red
  
  wall.v[1].pos = Vec3Create(50, 0, -50);
  wall.v[1].color = 0xFF6B6B;
  
  wall.v[2].pos = Vec3Create(-50, 20, -50);
  wall.v[2].color = 0xFF6B6B;
  
  LevelAddTriangle(l, &wall);
}

void LevelDraw(Level *l, Renderer *r) {
  I32 i;
  for (i = 0; i < l->triangleCount; i++) {
    RendererDrawTriangle(r, &l->triangles[i]);
  }
}
