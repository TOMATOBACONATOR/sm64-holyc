// SM64 HUD and UI System
// Health, coins, stars display

#include "../kernel/renderer.HC"
#include "../kernel/math.HC"

class HUD {
  I32 coins;
  I32 stars;
  S16 health;
  I32 lives;
  U32 levelID;
  F64 timer;
};

HUD gHUD;

void InitializeHUD() {
  gHUD.coins = 0;
  gHUD.stars = 0;
  gHUD.health = 8;
  gHUD.lives = 4;
  gHUD.levelID = 0;
  gHUD.timer = 0;
}

void RenderHUDNumber(I32 x, I32 y, I32 number) {
  // Simple number rendering (would need actual font)
  char buffer[16];
  
  if (number < 10) {
    buffer[0] = '0' + number;
    buffer[1] = 0;
  } else if (number < 100) {
    buffer[0] = '0' + (number / 10);
    buffer[1] = '0' + (number % 10);
    buffer[2] = 0;
  } else {
    buffer[0] = '0' + (number / 100);
    buffer[1] = '0' + ((number / 10) % 10);
    buffer[2] = '0' + (number % 10);
    buffer[3] = 0;
  }
}

void RenderHUD() {
  // Top left: Coins
  "COINS: %d", gHUD.coins;
  
  // Top center: Stars
  "STARS: %d", gHUD.stars;
  
  // Top right: Lives
  "LIVES: %d", gHUD.lives;
  
  // Bottom left: Health (as pie chart style)
  "HEALTH: ";
  I32 i;
  for (i = 0; i < gHUD.health; i++) {
    "*";
  }
  
  // Bottom right: Level ID
  "LEVEL: %d", gHUD.levelID;
}

void UpdateHUD(F64 dt) {
  gHUD.timer += dt;
}

void SetHUDCoins(I32 coins) {
  gHUD.coins = coins;
}

void SetHUDStars(I32 stars) {
  gHUD.stars = stars;
}

void SetHUDHealth(S16 health) {
  if (health > 8) health = 8;
  if (health < 0) health = 0;
  gHUD.health = health;
}

void SetHUDLives(I32 lives) {
  gHUD.lives = lives;
}

void SetHUDLevel(U32 levelID) {
  gHUD.levelID = levelID;
}
