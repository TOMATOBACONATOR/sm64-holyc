// SM64 Enemy AI System - Ported from n64decomp/sm64
// Basic enemy behavior patterns

#include "../kernel/math.HC"
#include "../game/mario_state.HC"

#define MAX_ENEMIES 64

// Enemy types
#define ENEMY_GOOMBA          1
#define ENEMY_KOOPA           2
#define ENEMY_BOB_OMB         3
#define ENEMY_PIRANHA_PLANT   4
#define ENEMY_THWOMP          5

class Enemy {
  U32 type;
  Vec3F pos;
  Vec3F vel;
  F64 health;
  F64 speed;
  U32 state;
  U32 stateTimer;
  S16 yaw;
  F64 alertRange;
  U8 active;
};

class EnemyManager {
  Enemy enemies[MAX_ENEMIES];
  I32 enemyCount;
};

EnemyManager gEnemyManager;

void InitializeEnemyManager() {
  gEnemyManager.enemyCount = 0;
}

Enemy *AddEnemy(U32 type, Vec3F pos, F64 speed) {
  if (gEnemyManager.enemyCount >= MAX_ENEMIES)
    return 0;
  
  Enemy *e = &gEnemyManager.enemies[gEnemyManager.enemyCount];
  gEnemyManager.enemyCount++;
  
  e->type = type;
  e->pos = pos;
  e->vel = Vec3Create(0, 0, 0);
  e->health = 1.0;
  e->speed = speed;
  e->state = 0;
  e->stateTimer = 0;
  e->yaw = 0;
  e->alertRange = 300;
  e->active = 1;
  
  return e;
}

// Update enemy AI
void UpdateEnemyAI(Enemy *e, MarioState *m, F64 dt) {
  if (!e->active)
    return;
  
  // Calculate distance to Mario
  Vec3F diff = Vec3Sub(m->pos, e->pos);
  F64 distToMario = Vec3Length(diff);
  
  switch (e->type) {
    case ENEMY_GOOMBA:
      // Goomba walks in a patrol pattern
      if (distToMario < e->alertRange) {
        // Alert state - chase Mario
        e->yaw = atan2(diff.z, diff.x) * 32768.0 / PI;
        e->vel.x = cos(e->yaw * PI / 32768.0) * e->speed;
        e->vel.z = sin(e->yaw * PI / 32768.0) * e->speed;
      } else {
        // Patrol state
        e->stateTimer++;
        if (e->stateTimer > 120) {
          e->yaw += 0x4000; // Turn 90 degrees
          e->stateTimer = 0;
        }
        e->vel.x = cos(e->yaw * PI / 32768.0) * (e->speed * 0.5);
        e->vel.z = sin(e->yaw * PI / 32768.0) * (e->speed * 0.5);
      }
      break;
      
    case ENEMY_KOOPA:
      // Koopa Troopa patrols and retreats into shell
      if (distToMario < e->alertRange * 0.5) {
        // Retreat into shell
        e->state = 1;
        e->vel.x = 0;
        e->vel.z = 0;
      } else if (distToMario < e->alertRange) {
        // Chase Mario
        e->yaw = atan2(diff.z, diff.x) * 32768.0 / PI;
        e->vel.x = cos(e->yaw * PI / 32768.0) * e->speed;
        e->vel.z = sin(e->yaw * PI / 32768.0) * e->speed;
      } else {
        // Patrol
        e->vel.x = cos(e->yaw * PI / 32768.0) * (e->speed * 0.3);
        e->vel.z = sin(e->yaw * PI / 32768.0) * (e->speed * 0.3);
      }
      break;
      
    case ENEMY_BOB_OMB:
      // Bob-omb walks around and explodes if touched
      if (distToMario < 150) {
        e->state = 2; // Exploding state
      }
      e->vel.x = cos(e->yaw * PI / 32768.0) * e->speed * 0.3;
      e->vel.z = sin(e->yaw * PI / 32768.0) * e->speed * 0.3;
      break;
      
    case ENEMY_PIRANHA_PLANT:
      // Piranha plant bites at Mario
      if (distToMario < e->alertRange) {
        e->pos.y = e->pos.y + (e->speed * dt);
        if (e->stateTimer++ > 60) {
          e->pos.y -= (e->speed * 0.5) * dt;
        }
      }
      break;
      
    case ENEMY_THWOMP:
      // Thwomp drops from ceiling
      if (distToMario < e->alertRange) {
        e->vel.y = -e->speed * 2;
        e->state = 1;
      } else if (e->state == 1) {
        e->vel.y = e->speed * 1.5; // Rise back up
        if (e->pos.y > 100) {
          e->state = 0;
          e->vel.y = 0;
        }
      }
      break;
  }
  
  // Apply velocity
  e->pos.x += e->vel.x * dt;
  e->pos.y += e->vel.y * dt;
  e->pos.z += e->vel.z * dt;
  
  // Gravity
  if (e->pos.y > 0) {
    e->vel.y -= 9.81 * dt;
  } else {
    e->pos.y = 0;
    e->vel.y = 0;
  }
}

void UpdateAllEnemies(MarioState *m, F64 dt) {
  I32 i;
  for (i = 0; i < gEnemyManager.enemyCount; i++) {
    UpdateEnemyAI(&gEnemyManager.enemies[i], m, dt);
  }
}

// Check collision with Mario
void CheckEnemyMarioCollision(Enemy *e, MarioState *m) {
  Vec3F diff = Vec3Sub(m->pos, e->pos);
  F64 dist = Vec3Length(diff);
  
  if (dist < 30) {
    // Enemy-Mario collision
    switch (e->type) {
      case ENEMY_GOOMBA:
        if (m->vel.y < -10) {
          // Jump on Goomba
          e->health = 0;
          e->active = 0;
          m->numCoins += 1;
        } else {
          // Take damage
          m->health -= 2;
        }
        break;
      case ENEMY_KOOPA:
        m->health -= 1;
        break;
      case ENEMY_BOB_OMB:
        if (e->state == 2) {
          m->health -= 4;
          e->active = 0;
        }
        break;
    }
  }
}
