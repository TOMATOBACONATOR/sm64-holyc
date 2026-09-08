// SM64 Power-Up System
// Power-ups and special items

#include "../kernel/math.HC"

#define MAX_POWERUPS 32

#define POWERUP_NONE          0
#define POWERUP_METAL_CAP     1
#define POWERUP_WING_CAP      2
#define POWERUP_VANISH_CAP    3
#define POWERUP_MUSHROOM      4
#define POWERUP_FIRE_FLOWER   5
#define POWERUP_STAR          6
#define POWERUP_RED_COIN      7

class PowerUp {
  U32 type;
  Vec3F pos;
  F64 rotationAngle;
  U8 active;
};

class PowerUpManager {
  PowerUp powerups[MAX_POWERUPS];
  I32 count;
};

PowerUpManager gPowerUpManager;

void InitializePowerUpManager() {
  gPowerUpManager.count = 0;
}

PowerUp *AddPowerUp(U32 type, Vec3F pos) {
  if (gPowerUpManager.count >= MAX_POWERUPS)
    return 0;
  
  PowerUp *p = &gPowerUpManager.powerups[gPowerUpManager.count];
  gPowerUpManager.count++;
  
  p->type = type;
  p->pos = pos;
  p->rotationAngle = 0;
  p->active = 1;
  
  return p;
}

void UpdatePowerUps(F64 dt) {
  I32 i;
  
  for (i = 0; i < gPowerUpManager.count; i++) {
    PowerUp *p = &gPowerUpManager.powerups[i];
    
    if (p->active) {
      p->rotationAngle += 3.0 * dt;
      p->pos.y += sin(p->rotationAngle * PI / 180.0) * 0.5 * dt;
    }
  }
}

void CheckPowerUpCollection(Vec3F marioPos, U32 *marioFlags, U16 *capTimer) {
  I32 i;
  
  for (i = 0; i < gPowerUpManager.count; i++) {
    PowerUp *p = &gPowerUpManager.powerups[i];
    
    if (p->active) {
      Vec3F diff = Vec3Sub(p->pos, marioPos);
      F64 dist = Vec3Length(diff);
      
      if (dist < 30) {
        p->active = 0;
        
        switch (p->type) {
          case POWERUP_METAL_CAP:
            *marioFlags |= 0x00000002; // MARIO_METAL_CAP
            *capTimer = 600;
            break;
          case POWERUP_WING_CAP:
            *marioFlags |= 0x00000004; // MARIO_WING_CAP
            *capTimer = 600;
            break;
          case POWERUP_VANISH_CAP:
            *marioFlags |= 0x00000008; // MARIO_VANISH_CAP
            *capTimer = 600;
            break;
          case POWERUP_STAR:
            // Temporary invincibility
            *marioFlags |= 0x00001000; // Invincible flag
            break;
        }
      }
    }
  }
}
