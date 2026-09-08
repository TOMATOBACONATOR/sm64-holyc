// SM64 Mario State - Ported from n64decomp/sm64 to HolyC
// Core Mario state tracking and physics

#include "../kernel/math.HC"
#include "../kernel/collision.HC"

// Mario action constants (from SM64 original)
#define ACT_IDLE                       0x00000000
#define ACT_WALKING                    0x01000000
#define ACT_RUNNING                    0x02000000
#define ACT_JUMPING                    0x03000000
#define ACT_FALLING                    0x04000000
#define ACT_LANDING                    0x05000000
#define ACT_DOUBLE_JUMP                0x06000000
#define ACT_WALL_KICK                  0x07000000
#define ACT_FREEFALL                   0x08000000
#define ACT_LONG_JUMP                  0x09000000

// Mario flags
#define MARIO_ACTION_SOUND_PLAYED      0x00000001
#define MARIO_METAL_CAP                0x00000002
#define MARIO_WING_CAP                 0x00000004
#define MARIO_VANISH_CAP               0x00000008
#define MARIO_FALLING                  0x00000010
#define MARIO_JUMPING                  0x00000020
#define MARIO_AIRBORNE                 0x00000040
#define MARIO_ON_GROUND                0x00000080

// Surface types
#define SURFACE_DEFAULT                0
#define SURFACE_WATER                  1
#define SURFACE_ICE                    2
#define SURFACE_LAVA                   3
#define SURFACE_QUICKSAND              4

class MarioState {
  U32 action;
  U32 prevAction;
  Vec3F pos;
  Vec3F vel;
  F64 forwardVel;
  F64 slideVelX;
  F64 slideVelZ;
  Vec3F faceAngle;
  F64 intendedMag;
  S16 intendedYaw;
  U32 flags;
  U32 particleFlags;
  U16 actionTimer;
  U32 actionArg;
  U8 framesSinceA;
  U8 framesSinceB;
  F64 floorHeight;
  F64 ceilHeight;
  S16 floorAngle;
  S16 waterLevel;
  I32 numCoins;
  I32 numStars;
  S16 health;
  U8 capTimer;
  U32 capFlags;
  F64 peakHeight;
};

MarioState *gMarioState;

MarioState *MarioStateCreate() {
  MarioState *m = MAlloc(sizeof(MarioState));
  
  m->action = ACT_IDLE;
  m->prevAction = ACT_IDLE;
  m->pos = Vec3Create(0, 5, 0);
  m->vel = Vec3Create(0, 0, 0);
  m->forwardVel = 0;
  m->slideVelX = 0;
  m->slideVelZ = 0;
  m->faceAngle = Vec3Create(0, 0, 0);
  m->intendedMag = 0;
  m->intendedYaw = 0;
  m->flags = MARIO_ON_GROUND;
  m->particleFlags = 0;
  m->actionTimer = 0;
  m->actionArg = 0;
  m->framesSinceA = 0;
  m->framesSinceB = 0;
  m->floorHeight = 0;
  m->ceilHeight = 1000;
  m->floorAngle = 0;
  m->waterLevel = 0;
  m->numCoins = 0;
  m->numStars = 0;
  m->health = 8;
  m->capTimer = 0;
  m->capFlags = 0;
  m->peakHeight = 0;
  
  return m;
}

// Set Mario's action
U32 SetMarioAction(MarioState *m, U32 action, U32 actionArg) {
  if (action != m->action) {
    m->prevAction = m->action;
    m->action = action;
    m->actionArg = actionArg;
    m->actionTimer = 0;
    m->framesSinceA = 0xFF;
    m->framesSinceB = 0xFF;
  }
  
  return action;
}

// Update Mario's position and velocity with gravity
void UpdateMarioPhysics(MarioState *m, F64 dt) {
  // Apply gravity
  if (!(m->flags & MARIO_ON_GROUND)) {
    m->vel.y -= 9.81 * dt;
    m->flags |= MARIO_AIRBORNE;
  }
  
  // Update position
  m->pos.x += m->vel.x * dt;
  m->pos.y += m->vel.y * dt;
  m->pos.z += m->vel.z * dt;
  
  // Ground collision
  if (m->pos.y <= m->floorHeight) {
    m->pos.y = m->floorHeight;
    m->vel.y = 0;
    m->flags |= MARIO_ON_GROUND;
    m->flags &= ~MARIO_AIRBORNE;
    m->actionTimer++;
  }
  
  // Ceiling collision
  if (m->pos.y >= m->ceilHeight) {
    m->pos.y = m->ceilHeight;
    m->vel.y = -m->vel.y * 0.5; // Bounce off ceiling
  }
  
  m->actionTimer++;
}

// Handle Mario jumping
void MarioJump(MarioState *m, F64 jumpForce) {
  if (m->flags & MARIO_ON_GROUND) {
    m->vel.y = jumpForce;
    m->flags &= ~MARIO_ON_GROUND;
    m->flags |= MARIO_JUMPING;
    m->peakHeight = m->pos.y;
    SetMarioAction(m, ACT_JUMPING, 0);
  }
}

// Handle Mario movement
void UpdateMarioMovement(MarioState *m, F64 forwardVel, F64 dt) {
  m->forwardVel = forwardVel;
  
  if (m->forwardVel != 0) {
    // Convert yaw to movement direction
    F64 moveX = sin(m->intendedYaw * PI / 32768.0) * m->forwardVel;
    F64 moveZ = cos(m->intendedYaw * PI / 32768.0) * m->forwardVel;
    
    m->pos.x += moveX * dt;
    m->pos.z += moveZ * dt;
    
    if (m->forwardVel > 0) {
      SetMarioAction(m, ACT_RUNNING, 0);
    } else {
      SetMarioAction(m, ACT_WALKING, 0);
    }
  } else {
    if (m->flags & MARIO_ON_GROUND) {
      SetMarioAction(m, ACT_IDLE, 0);
    }
  }
}
