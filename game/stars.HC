// SM64 Star/Objective System
// Stars and level objectives

#include "../kernel/math.HC"

#define MAX_STARS 120
#define MAX_LEVELS 15

class Star {
  Vec3F pos;
  U32 starID;
  U32 levelID;
  U8 collected;
  F64 rotationAngle;
  F64 bounceHeight;
};

class Level {
  U32 levelID;
  char name[64];
  Vec3F spawnPos;
  F64 waterLevel;
  U32 starCount;
  U32 starsCollected;
  Star stars[7]; // 7 stars per level
};

Star gStars[MAX_STARS];
Level gLevels[MAX_LEVELS];
I32 gTotalStarsCollected = 0;
I32 gCurrentLevelID = 0;

void InitializeLevels() {
  // Level 1: Bob-omb Battlefield
  gLevels[1].levelID = 1;
  gLevels[1].name = "Bob-omb Battlefield";
  gLevels[1].spawnPos = Vec3Create(0, 10, 0);
  gLevels[1].waterLevel = -100;
  gLevels[1].starCount = 7;
  gLevels[1].starsCollected = 0;
  
  // Level 2: Whomp's Fortress
  gLevels[2].levelID = 2;
  gLevels[2].name = "Whomp's Fortress";
  gLevels[2].spawnPos = Vec3Create(0, 20, 0);
  gLevels[2].waterLevel = -100;
  gLevels[2].starCount = 7;
  gLevels[2].starsCollected = 0;
  
  // Level 3: Jolly Roger Bay
  gLevels[3].levelID = 3;
  gLevels[3].name = "Jolly Roger Bay";
  gLevels[3].spawnPos = Vec3Create(0, 5, 0);
  gLevels[3].waterLevel = 0;
  gLevels[3].starCount = 7;
  gLevels[3].starsCollected = 0;
  
  // Level 4: Cool, Cool Mountain
  gLevels[4].levelID = 4;
  gLevels[4].name = "Cool, Cool Mountain";
  gLevels[4].spawnPos = Vec3Create(0, 30, 0);
  gLevels[4].waterLevel = -200;
  gLevels[4].starCount = 7;
  gLevels[4].starsCollected = 0;
  
  // Level 5: Big Boo's Haunt
  gLevels[5].levelID = 5;
  gLevels[5].name = "Big Boo's Haunt";
  gLevels[5].spawnPos = Vec3Create(0, 5, 0);
  gLevels[5].waterLevel = -100;
  gLevels[5].starCount = 7;
  gLevels[5].starsCollected = 0;
}

void AddStarToLevel(U32 levelID, Vec3F pos) {
  if (gLevels[levelID].starCount >= 7)
    return;
  
  Star *s = &gLevels[levelID].stars[gLevels[levelID].starCount];
  s->pos = pos;
  s->starID = gLevels[levelID].starCount;
  s->levelID = levelID;
  s->collected = 0;
  s->rotationAngle = 0;
  s->bounceHeight = 0;
  
  gLevels[levelID].starCount++;
}

void UpdateStars(F64 dt) {
  I32 i, j;
  
  for (i = 1; i < MAX_LEVELS; i++) {
    for (j = 0; j < gLevels[i].starCount; j++) {
      Star *s = &gLevels[i].stars[j];
      
      if (!s->collected) {
        // Rotate star
        s->rotationAngle += 2.0 * dt;
        
        // Bounce
        s->bounceHeight = sin(s->rotationAngle * PI / 180.0) * 2.0;
      }
    }
  }
}

void CheckStarCollection(Vec3F marioPos, U32 currentLevel) {
  I32 i;
  
  for (i = 0; i < gLevels[currentLevel].starCount; i++) {
    Star *s = &gLevels[currentLevel].stars[i];
    
    if (!s->collected) {
      Vec3F diff = Vec3Sub(s->pos, marioPos);
      F64 dist = Vec3Length(diff);
      
      if (dist < 50) {
        s->collected = 1;
        gLevels[currentLevel].starsCollected++;
        gTotalStarsCollected++;
      }
    }
  }
}
