// SM64 N64-Style Software Renderer for TempleOS
// CPU-based triangle rasterization with authentic N64 look

#include "../kernel/math.HC"

#define SCREEN_WIDTH  640
#define SCREEN_HEIGHT 480
#define SCREEN_DEPTH  32

class Framebuffer {
  U32 *pixels;
  F64 *depthBuffer;
  I32 width;
  I32 height;
};

class Renderer {
  Framebuffer fb;
  Matrix44 viewMatrix;
  Matrix44 projMatrix;
  Matrix44 modelMatrix;
};

Renderer *gRenderer;

Renderer *RendererCreate() {
  Renderer *r = MAlloc(sizeof(Renderer));
  r->fb.width = SCREEN_WIDTH;
  r->fb.height = SCREEN_HEIGHT;
  r->fb.pixels = MAlloc(SCREEN_WIDTH * SCREEN_HEIGHT * sizeof(U32));
  r->fb.depthBuffer = MAlloc(SCREEN_WIDTH * SCREEN_HEIGHT * sizeof(F64));
  
  return r;
}

void RendererClear(Renderer *r) {
  I32 i, j;
  
  // Clear to sky blue (N64 style)
  for (i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
    r->fb.pixels[i] = 0x87CEEB;
    r->fb.depthBuffer[i] = 1e10;
  }
}

// Vertex structure for rendering
class Vertex {
  F64 x, y, z, w;
  U32 color;
  F64 screenX, screenY;
};

// Project vertex to screen space
void ProjectVertex(Vertex *v, Matrix44 proj) {
  F64 clipW = 1.0 / v->w;
  
  v->screenX = (v->x * proj[0][0] + v->y * proj[1][0] + v->z * proj[2][0] + v->w * proj[3][0]) * clipW;
  v->screenY = (v->x * proj[0][1] + v->y * proj[1][1] + v->z * proj[2][1] + v->w * proj[3][1]) * clipW;
  
  // Convert from clip space to screen space
  v->screenX = (v->screenX + 1.0) * SCREEN_WIDTH / 2.0;
  v->screenY = (1.0 - v->screenY) * SCREEN_HEIGHT / 2.0;
}

// Bresenham line drawing
void DrawLine(Renderer *r, I32 x0, I32 y0, I32 x1, I32 y1, U32 color) {
  I32 dx = abs(x1 - x0);
  I32 dy = abs(y1 - y0);
  I32 sx = (x0 < x1) ? 1 : -1;
  I32 sy = (y0 < y1) ? 1 : -1;
  I32 err = dx - dy;
  
  while (1) {
    if (x0 >= 0 && x0 < SCREEN_WIDTH && y0 >= 0 && y0 < SCREEN_HEIGHT) {
      r->fb.pixels[y0 * SCREEN_WIDTH + x0] = color;
    }
    
    if (x0 == x1 && y0 == y1)
      break;
    
    I32 e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x0 += sx;
    }
    if (e2 < dx) {
      err += dx;
      y0 += sy;
    }
  }
}

// Fill triangle using scanline algorithm (N64 style flat shading)
void FillTriangle(Renderer *r, Vertex *v0, Vertex *v1, Vertex *v2) {
  // Sort vertices by Y coordinate
  if (v0->screenY > v1->screenY) {
    Vertex *temp = v0;
    v0 = v1;
    v1 = temp;
  }
  if (v1->screenY > v2->screenY) {
    Vertex *temp = v1;
    v1 = v2;
    v2 = temp;
  }
  if (v0->screenY > v1->screenY) {
    Vertex *temp = v0;
    v0 = v1;
    v1 = temp;
  }
  
  I32 y0 = (I32)v0->screenY;
  I32 y1 = (I32)v1->screenY;
  I32 y2 = (I32)v2->screenY;
  
  // Use flat shading for N64 look
  U32 color = v0->color;
  
  I32 y;
  for (y = y0; y <= y2; y++) {
    F64 t;
    I32 xLeft, xRight;
    
    if (y < y1) {
      // Top half
      t = (y - y0) / (y1 - y0);
      xLeft = (I32)(v0->screenX + t * (v1->screenX - v0->screenX));
      
      t = (y - y0) / (y2 - y0);
      xRight = (I32)(v0->screenX + t * (v2->screenX - v0->screenX));
    } else {
      // Bottom half
      t = (y - y1) / (y2 - y1);
      xLeft = (I32)(v1->screenX + t * (v2->screenX - v1->screenX));
      
      t = (y - y0) / (y2 - y0);
      xRight = (I32)(v0->screenX + t * (v2->screenX - v0->screenX));
    }
    
    if (xLeft > xRight) {
      I32 temp = xLeft;
      xLeft = xRight;
      xRight = temp;
    }
    
    I32 x;
    for (x = xLeft; x <= xRight; x++) {
      if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
        r->fb.pixels[y * SCREEN_WIDTH + x] = color;
      }
    }
  }
}

// Draw triangle with wireframe for N64 look
void DrawTriangleWireframe(Renderer *r, Vertex *v0, Vertex *v1, Vertex *v2) {
  // Draw filled triangle
  FillTriangle(r, v0, v1, v2);
  
  // Draw black edges for authentic N64 look
  DrawLine(r, (I32)v0->screenX, (I32)v0->screenY, (I32)v1->screenX, (I32)v1->screenY, 0x000000);
  DrawLine(r, (I32)v1->screenX, (I32)v1->screenY, (I32)v2->screenX, (I32)v2->screenY, 0x000000);
  DrawLine(r, (I32)v2->screenX, (I32)v2->screenY, (I32)v0->screenX, (I32)v0->screenY, 0x000000);
}

// Present framebuffer to TempleOS screen
void RendererPresent(Renderer *r) {
  I32 x, y;
  
  for (y = 0; y < SCREEN_HEIGHT; y++) {
    for (x = 0; x < SCREEN_WIDTH; x++) {
      U32 color = r->fb.pixels[y * SCREEN_WIDTH + x];
      GrPlot(x, y, color);
    }
  }
}

// N64-style vertex color list
class Triangle {
  Vertex v[3];
};

void RendererDrawTriangle(Renderer *r, Triangle *tri) {
  // Project vertices
  ProjectVertex(&tri->v[0], r->projMatrix);
  ProjectVertex(&tri->v[1], r->projMatrix);
  ProjectVertex(&tri->v[2], r->projMatrix);
  
  // Draw with wireframe outline
  DrawTriangleWireframe(r, &tri->v[0], &tri->v[1], &tri->v[2]);
}
