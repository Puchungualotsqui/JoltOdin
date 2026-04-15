package joltc

import "core:c"

// ----------------------------------------------------------------------------
// Primitive ABI-safe types mirrored from JoltC/Functions.h
// ----------------------------------------------------------------------------

BodyID :: distinct u32
SubShapeID :: distinct u32
BroadPhaseLayer :: distinct u8

when JPC_OBJECT_LAYER_BITS == 16 {
	ObjectLayer :: distinct u16
} else when JPC_OBJECT_LAYER_BITS == 32 {
	ObjectLayer :: distinct u32
} else {
	#panic("JPC_OBJECT_LAYER_BITS must be 16 or 32")
}

GroupID :: distinct u32
SubGroupID :: distinct u32

Float3 :: struct {
	x: f32,
	y: f32,
	z: f32,
}

Vec2 :: struct {
	x: f32,
	y: f32,
}

Vec3 :: struct #align (16) {
	x:  f32,
	y:  f32,
	z:  f32,
	_w: f32,
}

Vec4 :: struct #align (16) {
	x: f32,
	y: f32,
	z: f32,
	w: f32,
}

DVec3 :: struct #align (32) {
	x:  f64,
	y:  f64,
	z:  f64,
	_w: f64,
}

Quat :: struct #align (16) {
	x: f32,
	y: f32,
	z: f32,
	w: f32,
}

Mat44 :: struct #align (16) {
	col:  [3]Vec4,
	col3: Vec3,
}

DMat44 :: struct #align (32) {
	col:  [3]Vec4,
	col3: DVec3,
}

Color :: struct #align (4) {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

when JPC_DOUBLE_PRECISION {
	RVec3 :: DVec3
	RMat44 :: DMat44
	Real :: f64
} else {
	RVec3 :: Vec3
	RMat44 :: Mat44
	Real :: f32
}

Indexed_Triangle_No_Material :: struct {
	idx: [3]u32,
}

Indexed_Triangle :: struct {
	idx:           [3]u32,
	materialIndex: u32,
	userData:      u32,
}

Ray_Cast :: struct {
	Origin:    Vec3,
	Direction: Vec3,
}

RRay_Cast :: struct {
	Origin:    RVec3,
	Direction: Vec3,
}

Ray_Cast_Result :: struct {
	BodyID:      BodyID,
	Fraction:    f32,
	SubShapeID2: SubShapeID,
}

Shape_Cast_Result :: struct {
	ContactPointOn1:  Vec3,
	ContactPointOn2:  Vec3,
	PenetrationAxis:  Vec3,
	PenetrationDepth: f32,
	SubShapeID1:      SubShapeID,
	SubShapeID2:      SubShapeID,
	BodyID2:          BodyID,
	Fraction:         f32,
	IsBackFaceHit:    bool,
}

Collide_Shape_Result :: struct {
	ContactPointOn1:  Vec3,
	ContactPointOn2:  Vec3,
	PenetrationAxis:  Vec3,
	PenetrationDepth: f32,
	SubShapeID1:      SubShapeID,
	SubShapeID2:      SubShapeID,
	BodyID2:          BodyID,
}

// ----------------------------------------------------------------------------
// Base POD structs used widely later by settings, queries, and callbacks
// ----------------------------------------------------------------------------

Collision_Group :: struct {
	GroupFilter: ^GroupFilter,
	GroupID:     GroupID,
	SubGroupID:  SubGroupID,
}

Contact_Points :: struct {
	length: c.uint,
	points: [JPC_CONTACT_POINTS_CAPACITY]Vec3,
}

Contact_Manifold :: struct {
	BaseOffset:               RVec3,
	WorldSpaceNormal:         Vec3,
	PenetrationDepth:         f32,
	SubShapeID1:              SubShapeID,
	SubShapeID2:              SubShapeID,
	RelativeContactPointsOn1: Contact_Points,
	RelativeContactPointsOn2: Contact_Points,
}

Contact_Settings :: struct {
	CombinedFriction:               f32,
	CombinedRestitution:            f32,
	InvMassScale1:                  f32,
	InvInertiaScale1:               f32,
	InvMassScale2:                  f32,
	InvInertiaScale2:               f32,
	IsSensor:                       bool,
	RelativeLinearSurfaceVelocity:  Vec3,
	RelativeAngularSurfaceVelocity: Vec3,
}

SubShapeID_Pair :: struct {
	Body1ID:     BodyID,
	SubShapeID1: SubShapeID,
	Body2ID:     BodyID,
	SubShapeID2: SubShapeID,
}

Shape_Cast_Settings :: struct {
	ActiveEdgeMode:                  Active_Edge_Mode,
	CollectFacesMode:                Collect_Faces_Mode,
	CollisionTolerance:              f32,
	PenetrationTolerance:            f32,
	ActiveEdgeMovementDirection:     Vec3,
	BackFaceModeTriangles:           Back_Face_Mode,
	BackFaceModeConvex:              Back_Face_Mode,
	UseShrunkenShapeAndConvexRadius: bool,
	ReturnDeepestPoint:              bool,
}

Collide_Shape_Settings :: struct {
	ActiveEdgeMode:              Active_Edge_Mode,
	CollectFacesMode:            Collect_Faces_Mode,
	CollisionTolerance:          f32,
	PenetrationTolerance:        f32,
	ActiveEdgeMovementDirection: Vec3,
	MaxSeparationDistance:       f32,
	BackFaceMode:                Back_Face_Mode,
}

Impulse :: struct {
	ContactImpulse:   f32,
	FrictionImpulse1: f32,
	FrictionImpulse2: f32,
}

Collision_Estimation_Result :: struct {
	LinearVelocity1:  Vec3,
	AngularVelocity1: Vec3,
	LinearVelocity2:  Vec3,
	AngularVelocity2: Vec3,
	Tangent1:         Vec3,
	Tangent2:         Vec3,
	NumImpulses:      c.uint,
	Impulses:         [JPC_CONTACT_POINTS_CAPACITY]Impulse,
}

BodyManager_Draw_Settings :: struct {
	mDrawGetSupportFunction:        bool,
	mDrawSupportDirection:          bool,
	mDrawGetSupportingFace:         bool,
	mDrawShape:                     bool,
	mDrawShapeWireframe:            bool,
	mDrawShapeColor:                Shape_Color,
	mDrawBoundingBox:               bool,
	mDrawCenterOfMassTransform:     bool,
	mDrawWorldTransform:            bool,
	mDrawVelocity:                  bool,
	mDrawMassAndInertia:            bool,
	mDrawSleepStats:                bool,
	mDrawSoftBodyVertices:          bool,
	mDrawSoftBodyVertexVelocities:  bool,
	mDrawSoftBodyEdgeConstraints:   bool,
	mDrawSoftBodyBendConstraints:   bool,
	mDrawSoftBodyVolumeConstraints: bool,
	mDrawSoftBodySkinConstraints:   bool,
	mDrawSoftBodyLRAConstraints:    bool,
	mDrawSoftBodyPredictedBounds:   bool,
	DrawSoftBodyConstraintColor:    Soft_Body_Constraint_Color,
}

Constraint_Settings :: struct {
	Enabled:                  bool,
	ConstraintPriority:       u32,
	NumVelocityStepsOverride: c.uint,
	NumPositionStepsOverride: c.uint,
	DrawConstraintSize:       f32,
	UserData:                 u64,
}

Spring_Settings :: struct {
	Mode:                 Spring_Mode,
	FrequencyOrStiffness: f32,
	Damping:              f32,
}

Motor_Settings :: struct {
	SpringSettings: Spring_Settings,
	MinForceLimit:  f32,
	MaxForceLimit:  f32,
	MinTorqueLimit: f32,
	MaxTorqueLimit: f32,
}

SubShape_Settings :: struct {
	Shape:    ^Shape,
	Position: Vec3,
	Rotation: Quat,
	UserData: u32,
}

Body_Creation_Settings :: struct {
	Position:                     RVec3,
	Rotation:                     Quat,
	LinearVelocity:               Vec3,
	AngularVelocity:              Vec3,
	UserData:                     u64,
	ObjectLayer:                  ObjectLayer,
	MotionType:                   Motion_Type,
	AllowedDOFs:                  Allowed_DOFs,
	AllowDynamicOrKinematic:      bool,
	IsSensor:                     bool,
	CollideKinematicVsNonDynamic: bool,
	UseManifoldReduction:         bool,
	ApplyGyroscopicForce:         bool,
	MotionQuality:                Motion_Quality,
	EnhancedInternalEdgeRemoval:  bool,
	AllowSleeping:                bool,
	Friction:                     f32,
	Restitution:                  f32,
	LinearDamping:                f32,
	AngularDamping:               f32,
	MaxLinearVelocity:            f32,
	MaxAngularVelocity:           f32,
	GravityFactor:                f32,
	NumVelocityStepsOverride:     c.uint,
	NumPositionStepsOverride:     c.uint,
	OverrideMassProperties:       Override_Mass_Properties,
	InertiaMultiplier:            f32,
	Shape:                        ^Shape,
}

RShape_Cast :: struct {
	Shape:             ^Shape,
	Scale:             Vec3,
	CenterOfMassStart: RMat44,
	Direction:         Vec3,
}

Narrow_Phase_Query_Cast_Ray_Args :: struct {
	Ray:                   RRay_Cast,
	Result:                Ray_Cast_Result,
	BroadPhaseLayerFilter: ^BroadPhaseLayerFilter,
	ObjectLayerFilter:     ^ObjectLayerFilter,
	BodyFilter:            ^BodyFilter,
	ShapeFilter:           ^ShapeFilter,
}

Narrow_Phase_Query_Cast_Shape_Args :: struct {
	ShapeCast:             RShape_Cast,
	Settings:              Shape_Cast_Settings,
	BaseOffset:            RVec3,
	Collector:             ^CastShapeCollector,
	BroadPhaseLayerFilter: ^BroadPhaseLayerFilter,
	ObjectLayerFilter:     ^ObjectLayerFilter,
	BodyFilter:            ^BodyFilter,
	ShapeFilter:           ^ShapeFilter,
}

Narrow_Phase_Query_Collide_Shape_Args :: struct {
	Shape:                 ^Shape,
	ShapeScale:            Vec3,
	CenterOfMassTransform: RMat44,
	Settings:              Collide_Shape_Settings,
	BaseOffset:            RVec3,
	Collector:             ^CollideShapeCollector,
	BroadPhaseLayerFilter: ^BroadPhaseLayerFilter,
	ObjectLayerFilter:     ^ObjectLayerFilter,
	BodyFilter:            ^BodyFilter,
	ShapeFilter:           ^ShapeFilter,
}
