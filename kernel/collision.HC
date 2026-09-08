// Collision Detection System

#include "math.HC"

class BoundingBox {
  Vec3F min;
  Vec3F max;
};

class Sphere {
  Vec3F center;
  F64 radius;
};

// AABB vs AABB collision
U8 AABBCollide(BoundingBox a, BoundingBox b) {
  return (a.min.x <= b.max.x && a.max.x >= b.min.x) &&
         (a.min.y <= b.max.y && a.max.y >= b.min.y) &&
         (a.min.z <= b.max.z && a.max.z >= b.min.z);
}

// Sphere vs Sphere collision
U8 SphereCollide(Sphere a, Sphere b) {
  Vec3F diff = Vec3Sub(b.center, a.center);
  F64 dist = Vec3Length(diff);
  return dist <= (a.radius + b.radius);
}

// Point vs AABB collision
U8 PointInAABB(Vec3F point, BoundingBox box) {
  return (point.x >= box.min.x && point.x <= box.max.x) &&
         (point.y >= box.min.y && point.y <= box.max.y) &&
         (point.z >= box.min.z && point.z <= box.max.z);
}

// Ray vs Sphere collision
U8 RaySphereCollide(Vec3F rayOrigin, Vec3F rayDir, Sphere sphere, F64 *outT) {
  Vec3F oc = Vec3Sub(rayOrigin, sphere.center);
  
  F64 a = Vec3Dot(rayDir, rayDir);
  F64 b = 2.0 * Vec3Dot(oc, rayDir);
  F64 c = Vec3Dot(oc, oc) - sphere.radius * sphere.radius;
  
  F64 discriminant = b * b - 4.0 * a * c;
  
  if (discriminant < 0.0)
    return 0;
  
  F64 t = (-b - sqrt(discriminant)) / (2.0 * a);
  
  if (t > 0.0) {
    *outT = t;
    return 1;
  }
  
  return 0;
}

// Ground collision - check if point is above ground (y = 0)
U8 IsOnGround(Vec3F pos) {
  return pos.y <= 0.01; // Small epsilon for floating point
}
