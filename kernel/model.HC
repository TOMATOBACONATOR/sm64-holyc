// Model loading and mesh management

#include "math.HC"

#define MAX_VERTICES 5000
#define MAX_MESHES 50

class Mesh {
  Vertex vertices[MAX_VERTICES];
  I32 vertexCount;
  Triangle triangles[MAX_VERTICES];
  I32 triangleCount;
};

class Model {
  Mesh meshes[MAX_MESHES];
  I32 meshCount;
  Vec3F position;
  Vec3F rotation;
  Vec3F scale;
};

Model *ModelCreate() {
  Model *m = MAlloc(sizeof(Model));
  m->meshCount = 0;
  m->position = Vec3Create(0, 0, 0);
  m->rotation = Vec3Create(0, 0, 0);
  m->scale = Vec3Create(1, 1, 1);
  return m;
}

Mesh *ModelAddMesh(Model *m) {
  if (m->meshCount < MAX_MESHES) {
    Mesh *mesh = &m->meshes[m->meshCount];
    mesh->vertexCount = 0;
    mesh->triangleCount = 0;
    m->meshCount++;
    return mesh;
  }
  return 0;
}

void MeshAddVertex(Mesh *m, Vec3F pos, Vec3F normal, U32 color) {
  if (m->vertexCount < MAX_VERTICES) {
    m->vertices[m->vertexCount].pos = pos;
    m->vertices[m->vertexCount].normal = normal;
    m->vertices[m->vertexCount].color = color;
    m->vertexCount++;
  }
}

void MeshAddTriangle(Mesh *m, I32 v0, I32 v1, I32 v2) {
  if (m->triangleCount < MAX_VERTICES && v0 < m->vertexCount && v1 < m->vertexCount && v2 < m->vertexCount) {
    m->triangles[m->triangleCount].v[0] = m->vertices[v0];
    m->triangles[m->triangleCount].v[1] = m->vertices[v1];
    m->triangles[m->triangleCount].v[2] = m->vertices[v2];
    m->triangleCount++;
  }
}

// Create a simple cube mesh
Mesh *CreateCubeMesh() {
  Mesh *mesh = MAlloc(sizeof(Mesh));
  mesh->vertexCount = 0;
  mesh->triangleCount = 0;
  
  // Define cube vertices
  Vec3F vertices[8] = {
    Vec3Create(-1, -1, -1), // 0
    Vec3Create(1, -1, -1),  // 1
    Vec3Create(1, 1, -1),   // 2
    Vec3Create(-1, 1, -1),  // 3
    Vec3Create(-1, -1, 1),  // 4
    Vec3Create(1, -1, 1),   // 5
    Vec3Create(1, 1, 1),    // 6
    Vec3Create(-1, 1, 1),   // 7
  };
  
  I32 i;
  U32 color = 0xFF0000; // Red
  
  for (i = 0; i < 8; i++) {
    MeshAddVertex(mesh, vertices[i], Vec3Create(0, 0, 1), color);
  }
  
  // Front face
  MeshAddTriangle(mesh, 0, 1, 2);
  MeshAddTriangle(mesh, 0, 2, 3);
  
  // Back face
  MeshAddTriangle(mesh, 5, 4, 7);
  MeshAddTriangle(mesh, 5, 7, 6);
  
  // Left face
  MeshAddTriangle(mesh, 4, 0, 3);
  MeshAddTriangle(mesh, 4, 3, 7);
  
  // Right face
  MeshAddTriangle(mesh, 1, 5, 6);
  MeshAddTriangle(mesh, 1, 6, 2);
  
  // Top face
  MeshAddTriangle(mesh, 3, 2, 6);
  MeshAddTriangle(mesh, 3, 6, 7);
  
  // Bottom face
  MeshAddTriangle(mesh, 4, 5, 1);
  MeshAddTriangle(mesh, 4, 1, 0);
  
  return mesh;
}
