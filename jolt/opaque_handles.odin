package joltc

// ----------------------------------------------------------------------------
// Opaque C/C++ handle types.
//
// These mirror forward declarations like:
//   typedef struct JPC_Shape JPC_Shape;
// and must only be used through pointers.
// ----------------------------------------------------------------------------

Vertex_List :: struct {}
Indexed_Triangle_List :: struct {}

Shape :: struct {}
Compound_Shape :: struct {}
Mutable_Compound_Shape :: struct {}

TempAllocatorImpl :: struct {}
JobSystem :: struct {}
JobSystemThreadPool :: struct {}
JobSystemSingleThreaded :: struct {}

GroupFilter :: struct {}
BroadPhaseLayerInterface :: struct {}
BroadPhaseLayerFilter :: struct {}
ObjectLayerFilter :: struct {}
BodyFilter :: struct {}
ShapeFilter :: struct {}
SimShapeFilter :: struct {}
ObjectVsBroadPhaseLayerFilter :: struct {}
ObjectLayerPairFilter :: struct {}

ContactListener :: struct {}
CastShapeCollector :: struct {}
CollideShapeCollector :: struct {}
DebugRendererSimple :: struct {}

String :: struct {}

Constraint :: struct {}
TwoBodyConstraint :: struct {}
FixedConstraint :: struct {}
DistanceConstraint :: struct {}
SixDOFConstraint :: struct {}
HingeConstraint :: struct {}
SliderConstraint :: struct {}

Body :: struct {}
BodyLockInterface :: struct {}
BodyLockRead :: struct {}
BodyLockWrite :: struct {}
BodyLockMultiRead :: struct {}
BodyLockMultiWrite :: struct {}
BodyInterface :: struct {}

NarrowPhaseQuery :: struct {}
PhysicsSystem :: struct {}
