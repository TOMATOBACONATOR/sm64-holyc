// SM64 Level Geometry System
// Platform and level design data

#include "../kernel/surface.HC"
#include "../kernel/math.HC"

#define MAX_PLATFORMS 256
#define MAX_LEVEL_GEOMETRY 512

class Platform {
  Vec3F pos;
  Vec3F scale;
  S16 rotationY;
  U8 platformType;
  U8 dynamic;
  F64 moveSpeed;
  Vec3F moveDirection;
};

class LevelGeometry {
  Surface surfaces[MAX_LEVEL_GEOMETRY];
  Platform platforms[MAX_PLATFORMS];
  I32 surfaceCount;
  I32 platformCount;
};

LevelGeometry gLevelGeometry;

void InitializeLevelGeometry() {
  gLevelGeometry.surfaceCount = 0;
  gLevelGeometry.platformCount = 0;
  InitializeSurfaceArray();
}

void AddLevelSurface(Vec3F v1, Vec3F v2, Vec3F v3, S16 type) {
  Surface *s = SurfaceCreate(v1, v2, v3, type);
  if (s) {
    gLevelGeometry.surfaces[gLevelGeometry.surfaceCount] = *s;
    gLevelGeometry.surfaceCount++;
  }
}

void AddPlatform(Vec3F pos, Vec3F scale, U8 type, U8 dynamic) {
  if (gLevelGeometry.platformCount >= MAX_PLATFORMS)
    return;
  
  Platform *p = &gLevelGeometry.platforms[gLevelGeometry.platformCount];
  gLevelGeometry.platformCount++;
  
  p->pos = pos;
  p->scale = scale;
  p->rotationY = 0;
  p->platformType = type;
  p->dynamic = dynamic;
  p->moveSpeed = 0;
  p->moveDirection = Vec3Create(0, 0, 0);
}

void CreateBobOmbBattlefieldLevel() {
  // Main arena floor
  AddLevelSurface(
    Vec3Create(-200, 0, -200),
    Vec3Create(200, 0, -200),
    Vec3Create(-200, 0, 200),
    SURFACE_DEFAULT
  );
  
  AddLevelSurface(
    Vec3Create(200, 0, -200),
    Vec3Create(200, 0, 200),
    Vec3Create(-200, 0, 200),
    SURFACE_DEFAULT
  );
  
  // Bomb-omb mountain
  AddLevelSurface(
    Vec3Create(-100, 0, 100),
    Vec3Create(-50, 50, 100),
    Vec3Create(-100, 50, 150),
    SURFACE_DEFAULT
  );
  
  AddPlatform(Vec3Create(0, 20, 0), Vec3Create(30, 5, 30), 0, 0);
  AddPlatform(Vec3Create(80, 30, 0), Vec3Create(20, 5, 20), 0, 0);
  AddPlatform(Vec3Create(-80, 40, 0), Vec3Create(20, 5, 20), 0, 0);
}

void CreateWhompsFortressLevel() {
  // Main fortress floor
  AddLevelSurface(
    Vec3Create(-150, 0, -150),
    Vec3Create(150, 0, -150),
    Vec3Create(-150, 0, 150),
    SURFACE_DEFAULT
  );
  
  AddLevelSurface(
    Vec3Create(150, 0, -150),
    Vec3Create(150, 0, 150),
    Vec3Create(-150, 0, 150),
    SURFACE_DEFAULT
  );
  
  // Whomp statue platforms
  AddPlatform(Vec3Create(0, 30, 0), Vec3Create(50, 10, 50), 0, 0);
  AddPlatform(Vec3Create(0, 60, 0), Vec3Create(30, 10, 30), 0, 0);
}

void CreateJollyRogerBayLevel() {
  // Water arena
  AddLevelSurface(
    Vec3Create(-200, 0, -200),
    Vec3Create(200, 0, -200),
    Vec3Create(-200, 0, 200),
    SURFACE_DEFAULT
  );
  
  // Sunken ship exterior
  AddPlatform(Vec3Create(-100, -50, 0), Vec3Create(80, 30, 100), 0, 0);
  AddPlatform(Vec3Create(100, -30, 0), Vec3Create(40, 20, 60), 0, 0);
}

void CreateCoolCoolMountainLevel() {
  // Mountain peaks and slopes
  AddLevelSurface(
    Vec3Create(-150, 0, -150),
    Vec3Create(150, 0, -150),
    Vec3Create(-150, 100, 150),
    SURFACE_DEFAULT
  );
  
  AddLevelSurface(
    Vec3Create(150, 0, -150),
    Vec3Create(150, 100, 150),
    Vec3Create(-150, 100, 150),
    SURFACE_DEFAULT
  );
  
  // Slope for sliding
  AddPlatform(Vec3Create(0, 50, 0), Vec3Create(40, 5, 100), 0, 0);
  
  // Peak platform
  AddPlatform(Vec3Create(0, 120, 0), Vec3Create(30, 5, 30), 0, 0);
}

void CreateBigBoosHauntLevel() {
  // Haunted mansion floor
  AddLevelSurface(
    Vec3Create(-200, 0, -200),
    Vec3Create(200, 0, -200),
    Vec3Create(-200, 0, 200),
    SURFACE_DEFAULT
  );
  
  AddLevelSurface(
    Vec3Create(200, 0, -200),
    Vec3Create(200, 0, 200),
    Vec3Create(-200, 0, 200),
    SURFACE_DEFAULT
  );
  
  // Mansion interior platforms
  AddPlatform(Vec3Create(0, 30, 0), Vec3Create(40, 5, 40), 0, 0);
  AddPlatform(Vec3Create(80, 20, 0), Vec3Create(30, 5, 30), 0, 0);
  AddPlatform(Vec3Create(-80, 25, 0), Vec3Create(35, 5, 35), 0, 0);
}

void UpdateLevelPlatforms(F64 dt) {
  I32 i;
  
  for (i = 0; i < gLevelGeometry.platformCount; i++) {
    Platform *p = &gLevelGeometry.platforms[i];
    
    if (p->dynamic) {
      p->pos.x += p->moveDirection.x * p->moveSpeed * dt;
      p->pos.y += p->moveDirection.y * p->moveSpeed * dt;
      p->pos.z += p->moveDirection.z * p->moveSpeed * dt;
    }
  }
}
