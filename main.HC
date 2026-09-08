// SM64 HolyC - Main Game Loop

#include "kernel/renderer.HC"
#include "kernel/math.HC"
#include "game/mario.HC"
#include "game/level.HC"

#define TARGET_FPS 60
#define FRAME_TIME (1.0 / TARGET_FPS)

void GameInit() {
  // Initialize renderer
  gRenderer = RendererCreate();
  
  // Initialize level
  gLevel = LevelCreate();
  LevelCreatePeachsCastle(gLevel);
  
  // Initialize Mario
  gMario = MarioCreate();
  gMario->pos = Vec3Create(0, 2, 15);
}

void GameUpdate(F64 dt) {
  MarioUpdate(gMario, dt);
}

void GameRender() {
  RendererClear(gRenderer);
  
  // Draw level
  LevelDraw(gLevel, gRenderer);
  
  // Draw Mario
  MarioDraw(gMario, gRenderer);
  
  // Present to screen
  RendererPresent(gRenderer);
}

void GameLoop() {
  I64 lastTime = GetTicks();
  F64 accumulator = 0;
  
  while (1) {
    I64 currentTime = GetTicks();
    F64 deltaTime = (F64)(currentTime - lastTime) / 1000.0; // Convert to seconds
    lastTime = currentTime;
    
    if (deltaTime > 0.1) // Cap deltaTime to prevent large jumps
      deltaTime = 0.1;
    
    accumulator += deltaTime;
    
    while (accumulator >= FRAME_TIME) {
      GameUpdate(FRAME_TIME);
      accumulator -= FRAME_TIME;
    }
    
    GameRender();
    
    // Check for exit
    if (GetKey(CH_ESCAPE))
      break;
  }
}

void Main() {
  "\n==================================";
  "  SM64 HolyC Renderer";
  "  Super Mario 64 Remake";
  "==================================\n";
  
  GameInit();
  
  "Game initialized. Starting game loop...\n";
  
  GameLoop();
  
  "Game ended. Thanks for playing!\n";
}

Main();
