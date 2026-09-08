// Camera System for SM64
// Manages view matrix and camera positioning

#include "math.HC"

class Camera {
  Vec3F position;
  Vec3F target;
  Vec3F up;
  F64 fov;
  F64 aspect;
  F64 near;
  F64 far;
  Matrix44 viewMatrix;
  Matrix44 projMatrix;
};

Camera gCamera;

void CameraInit(F64 aspect) {
  gCamera.position = Vec3Create(0, 10, 25);
  gCamera.target = Vec3Create(0, 5, 0);
  gCamera.up = Vec3Create(0, 1, 0);
  gCamera.fov = PI / 4.0; // 45 degrees
  gCamera.aspect = aspect;
  gCamera.near = 0.1;
  gCamera.far = 1000.0;
}

Matrix44 CameraLookAt(Vec3F pos, Vec3F target, Vec3F up) {
  // Build view matrix using look-at technique
  Vec3F forward = Vec3Normalize(Vec3Sub(target, pos));
  Vec3F right = Vec3Normalize(Vec3Cross(forward, up));
  Vec3F newUp = Vec3Cross(right, forward);
  
  Matrix44 view = Matrix44Identity();
  
  view.m[0][0] = right.x;
  view.m[1][0] = right.y;
  view.m[2][0] = right.z;
  
  view.m[0][1] = newUp.x;
  view.m[1][1] = newUp.y;
  view.m[2][1] = newUp.z;
  
  view.m[0][2] = -forward.x;
  view.m[1][2] = -forward.y;
  view.m[2][2] = -forward.z;
  
  view.m[3][0] = -Vec3Dot(right, pos);
  view.m[3][1] = -Vec3Dot(newUp, pos);
  view.m[3][2] = Vec3Dot(forward, pos);
  
  return view;
}

Matrix44 CameraPerspective(F64 fov, F64 aspect, F64 near, F64 far) {
  // Build perspective projection matrix
  F64 f = 1.0 / tan(fov / 2.0);
  
  Matrix44 proj = Matrix44Identity();
  proj.m[0][0] = f / aspect;
  proj.m[1][1] = f;
  proj.m[2][2] = (far + near) / (near - far);
  proj.m[2][3] = -1.0;
  proj.m[3][2] = (2.0 * far * near) / (near - far);
  proj.m[3][3] = 0.0;
  
  return proj;
}

void CameraUpdate() {
  gCamera.viewMatrix = CameraLookAt(gCamera.position, gCamera.target, gCamera.up);
  gCamera.projMatrix = CameraPerspective(gCamera.fov, gCamera.aspect, gCamera.near, gCamera.far);
}

void CameraFollowMario(Vec3F marioPos) {
  // Position camera behind and above Mario
  gCamera.position.x = marioPos.x;
  gCamera.position.y = marioPos.y + 8;
  gCamera.position.z = marioPos.z + 20;
  
  gCamera.target = Vec3Add(marioPos, Vec3Create(0, 3, 0));
  
  CameraUpdate();
}
