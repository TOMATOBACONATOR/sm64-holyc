// SM64 Complete Game Engine
// Main game loop and integration

#include "kernel/renderer.HC"
#include "kernel/math.HC"
#include "kernel/camera.HC"
#include "kernel/collision.HC"
#include "kernel/surface.HC"
#include "kernel/model.HC"
#include "game/mario_state.HC"
#include "game/enemy.HC"
#include "game/stars.HC"
#include "game/powerups.HC"
#include "game/hud.HC"
#include "game/levels.HC"

#define TARGET_FPS 60
#define FRAME_TIME (1.0 / TARGET_FPS)

// Game state
U32 gGameState = 0; // 0=menu, 1=playing, 2=paused, 3=level_select
U32 gCurrentLevel = 1;
F64 gGameTime = 0;

void GameInitialize() {
  "==================================\n";
  "  SM64 HolyC - Complete Edition\n";
  "  Super Mario 64 Remake\n";
  "==================================\n\n";
  
  // Initialize systems
  RendererClear(gRenderer);
  InitializeEnemyManager();
  InitializeLevels();
  InitializeLevelGeometry();
  InitializePowerUpManager();
  InitializeHUD();
  
  // Create Mario
  gMarioState = MarioStateCreate();
  
  // Create level based on current level ID
  switch (gCurrentLevel) {
    case 1:
      CreateBobOmbBattlefieldLevel();
      break;
    case 2:
      CreateWhompsFortressLevel();
      break;
    case 3:
      CreateJollyRogerBayLevel();
      break;
    case 4:
      CreateCoolCoolMountainLevel();
      break;
    case 5:
      CreateBigBoosHauntLevel();
      break;
  }
  
  // Add enemies based on level
  if (gCurrentLevel == 1) {
    AddEnemy(ENEMY_GOOMBA, Vec3Create(50, 0, 50), 20);
    AddEnemy(ENEMY_GOOMBA, Vec3Create(-50, 0, -50), 20);
    AddEnemy(ENEMY_BOB_OMB, Vec3Create(0, 0, 100), 15);
  }
  
  // Add power-ups
  AddPowerUp(POWERUP_METAL_CAP, Vec3Create(100, 20, 0));
  AddPowerUp(POWERUP_WING_CAP, Vec3Create(-100, 20, 0));
  
  // Initialize HUD
  SetHUDLevel(gCurrentLevel);
  SetHUDHealth(8);
  SetHUDLives(4);
  
  gGameState = 1; // Start playing
}

void GameHandleInput() {
  // Check for pause
  if (GetKey(CH_ESCAPE)) {
    gGameState = 2;
  }
  
  // Arrow keys for movement
  F64 moveInput = 0;
  S16 yawInput = 0;
  
  if (GetKey(CH_CURS_UP)) {
    moveInput = 50;
    yawInput = 0;
  }
  if (GetKey(CH_CURS_DOWN)) {
    moveInput = -30;
    yawInput = 0x8000;
  }
  if (GetKey(CH_CURS_LEFT)) {
    yawInput = 0x4000;
    moveInput = 40;
  }
  if (GetKey(CH_CURS_RIGHT)) {
    yawInput = -0x4000;
    moveInput = 40;
  }
  
  // Space to jump
  if (GetKey(' ')) {
    MarioJump(gMarioState, 30.0);
  }
  
  gMarioState->intendedMag = moveInput;
  gMarioState->intendedYaw = yawInput;
}

void GameUpdate(F64 dt) {
  if (gGameState != 1) return; // Only update if playing
  
  GameHandleInput();
  
  // Update Mario
  UpdateMarioPhysics(gMarioState, dt);
  UpdateMarioMovement(gMarioState, gMarioState->intendedMag, dt);
  
  // Update enemies
  UpdateAllEnemies(gMarioState, dt);
  
  // Check collisions
  I32 i;
  for (i = 0; i < gEnemyManager.enemyCount; i++) {
    CheckEnemyMarioCollision(&gEnemyManager.enemies[i], gMarioState);
  }
  
  // Update stars
  UpdateStars(dt);
  CheckStarCollection(gMarioState->pos, gCurrentLevel);
  
  // Update power-ups
  UpdatePowerUps(dt);
  CheckPowerUpCollection(gMarioState->pos, &gMarioState->flags, &gMarioState->capTimer);
  
  // Update level platforms
  UpdateLevelPlatforms(dt);
  
  // Update camera to follow Mario
  CameraFollowMario(gMarioState->pos);
  CameraUpdate();
  
  // Update HUD
  UpdateHUD(dt);
  SetHUDCoins(gMarioState->numCoins);
  SetHUDStars(gMarioState->numStars);
  SetHUDHealth(gMarioState->health);
  
  gGameTime += dt;
}

void GameRender() {
  RendererClear(gRenderer);
  
  // Render all level surfaces
  for (I32 i = 0; i < gLevelGeometry.surfaceCount; i++) {
    Triangle tri;
    tri.v[0].pos = gLevelGeometry.surfaces[i].vertex1;
    tri.v[1].pos = gLevelGeometry.surfaces[i].vertex2;
    tri.v[2].pos = gLevelGeometry.surfaces[i].vertex3;
    tri.v[0].color = 0x00FF00;
    tri.v[1].color = 0x00FF00;
    tri.v[2].color = 0x00FF00;
    RendererDrawTriangle(gRenderer, &tri);
  }
  
  // Render Mario as cube
  Matrix44 marioTransform = Matrix44Translate(gMarioState->pos.x, gMarioState->pos.y, gMarioState->pos.z);
  Mesh *marioMesh = CreateCubeMesh();
  
  // Render stars
  for (I32 i = 0; i < gLevels[gCurrentLevel].starCount; i++) {
    if (!gLevels[gCurrentLevel].stars[i].collected) {
      // Render star as wireframe cube
      Vec3F starPos = gLevels[gCurrentLevel].stars[i].pos;
      Matrix44 starTransform = Matrix44Translate(starPos.x, starPos.y + gLevels[gCurrentLevel].stars[i].bounceHeight, starPos.z);
    }
  }
  
  // Render enemies
  for (I32 i = 0; i < gEnemyManager.enemyCount; i++) {
    if (gEnemyManager.enemies[i].active) {
      Vec3F enemyPos = gEnemyManager.enemies[i].pos;
      // Would render enemy model here
    }
  }
  
  // Render power-ups
  for (I32 i = 0; i < gPowerUpManager.count; i++) {
    if (gPowerUpManager.powerups[i].active) {
      Vec3F puPos = gPowerUpManager.powerups[i].pos;
      // Would render power-up model here
    }
  }
  
  // Render HUD
  RenderHUD();
  
  // Present to display
  RendererPresent(gRenderer);
}

void GameLoop() {
  I64 lastTime = GetTicks();
  F64 accumulator = 0;
  
  while (1) {
    I64 currentTime = GetTicks();
    F64 deltaTime = (F64)(currentTime - lastTime) / 1000.0;
    lastTime = currentTime;
    
    if (deltaTime > 0.1)
      deltaTime = 0.1;
    
    accumulator += deltaTime;
    
    while (accumulator >= FRAME_TIME) {
      GameUpdate(FRAME_TIME);
      accumulator -= FRAME_TIME;
    }
    
    GameRender();
    
    // Check for exit
    if (GetKey(CH_ESCAPE) && gGameState == 2)
      break;
  }
}

void Main() {
  gRenderer = RendererCreate();
  GameInitialize();
  GameLoop();
  
  "Game ended. Final stats:\n";
  "Stars collected: %d\n", gTotalStarsCollected;
  "Coins collected: %d\n", gMarioState->numCoins;
  "Thanks for playing!\n";
}

Main();
