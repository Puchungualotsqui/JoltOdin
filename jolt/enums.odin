package joltc

// ----------------------------------------------------------------------------
// Enums and bitflag-like types mirrored from JoltC/Enums.h
// ----------------------------------------------------------------------------

Shape_Type :: enum u8 {
	CONVEX,
	COMPOUND,
	DECORATED,
	MESH,
	HEIGHT_FIELD,
	SOFTBODY,
	USER1,
	USER2,
	USER3,
	USER4,
}

Shape_SubType :: enum u8 {
	SPHERE,
	BOX,
	TRIANGLE,
	CAPSULE,
	TAPEREDCAPSULE,
	CYLINDER,
	CONVEX_HULL,
	STATIC_COMPOUND,
	MUTABLE_COMPOUND,
	ROTATED_TRANSLATED,
	SCALED,
	OFFSET_CENTER_OF_MASS,
	MESH,
	HEIGHT_FIELD,
	SOFT_BODY,
	USER1,
	USER2,
	USER3,
	USER4,
	USER5,
	USER6,
	USER7,
	USER8,
	USER_CONVEX1,
	USER_CONVEX2,
	USER_CONVEX3,
	USER_CONVEX4,
	USER_CONVEX5,
	USER_CONVEX6,
	USER_CONVEX7,
	USER_CONVEX8,
}

Physics_Update_Error :: distinct u32

PHYSICS_UPDATE_ERROR_NONE :: Physics_Update_Error(0)
PHYSICS_UPDATE_ERROR_MANIFOLD_CACHE_FULL :: Physics_Update_Error(1 << 0)
PHYSICS_UPDATE_ERROR_BODY_PAIR_CACHE_FULL :: Physics_Update_Error(1 << 1)
PHYSICS_UPDATE_ERROR_CONTACT_CONSTRAINTS_FULL :: Physics_Update_Error(1 << 2)

Constraint_Type :: enum u32 {
	CONSTRAINT,
	TWO_BODY_CONSTRAINT,
}

Constraint_SubType :: enum u32 {
	FIXED,
	POINT,
	HINGE,
	SLIDER,
	DISTANCE,
	CONE,
	SWING_TWIST,
	SIX_DOF,
	PATH,
	VEHICLE,
	RACK_AND_PINION,
	GEAR,
	PULLEY,
	USER1,
	USER2,
	USER3,
	USER4,
}

Constraint_Space :: enum u32 {
	LOCAL_TO_BODY_COM,
	WORLD_SPACE,
}

Motion_Type :: enum u8 {
	STATIC,
	KINEMATIC,
	DYNAMIC,
}

Motion_Quality :: enum u8 {
	DISCRETE,
	LINEAR_CAST,
}

Override_Mass_Properties :: enum u8 {
	CALC_MASS_INERTIA,
	CALC_INERTIA,
	MASS_INERTIA_PROVIDED,
}

Ground_State :: enum u32 {
	ON_GROUND,
	ON_STEEP_GROUND,
	NOT_SUPPORTED,
	IN_AIR,
}

Activation :: enum u32 {
	ACTIVATE      = 0,
	DONT_ACTIVATE = 1,
}

Validate_Result :: enum u32 {
	ACCEPT_ALL_CONTACTS,
	ACCEPT_CONTACT,
	REJECT_CONTACT,
	REJECT_ALL_CONTACTS,
}

Back_Face_Mode :: distinct u8

BACK_FACE_MODE_IGNORE :: Back_Face_Mode(0)
BACK_FACE_MODE_COLLIDE :: Back_Face_Mode(1)

Body_Type :: enum u8 {
	RIGID_BODY = 0,
	SOFT_BODY  = 1,
}

Allowed_DOFs :: distinct u8

ALLOWED_DOFS_NONE :: Allowed_DOFs(0b000000)
ALLOWED_DOFS_ALL :: Allowed_DOFs(0b111111)
ALLOWED_DOFS_TRANSLATIONX :: Allowed_DOFs(0b000001)
ALLOWED_DOFS_TRANSLATIONY :: Allowed_DOFs(0b000010)
ALLOWED_DOFS_TRANSLATIONZ :: Allowed_DOFs(0b000100)
ALLOWED_DOFS_ROTATIONX :: Allowed_DOFs(0b001000)
ALLOWED_DOFS_ROTATIONY :: Allowed_DOFs(0b010000)
ALLOWED_DOFS_ROTATIONZ :: Allowed_DOFs(0b100000)
ALLOWED_DOFS_PLANE2D :: Allowed_DOFs(0b000001 | 0b000010 | 0b100000)

Features :: distinct u32

FEATURE_DOUBLE_PRECISION :: Features(1 << 0)
FEATURE_NEON :: Features(1 << 1)
FEATURE_SSE :: Features(1 << 2)
FEATURE_SSE4_1 :: Features(1 << 3)
FEATURE_SSE4_2 :: Features(1 << 4)
FEATURE_AVX :: Features(1 << 5)
FEATURE_AVX2 :: Features(1 << 6)
FEATURE_AVX512 :: Features(1 << 7)
FEATURE_F16C :: Features(1 << 8)
FEATURE_LZCNT :: Features(1 << 9)
FEATURE_TZCNT :: Features(1 << 10)
FEATURE_FMADD :: Features(1 << 11)
FEATURE_PLATFORM_DETERMINISTIC :: Features(1 << 12)
FEATURE_FLOATING_POINT_EXCEPTIONS :: Features(1 << 13)
FEATURE_DEBUG :: Features(1 << 14)

Shape_Color :: distinct int

SHAPE_COLOR_INSTANCE_COLOR :: Shape_Color(0)
SHAPE_COLOR_SHAPE_TYPE_COLOR :: Shape_Color(1)
SHAPE_COLOR_MOTION_TYPE_COLOR :: Shape_Color(2)
SHAPE_COLOR_SLEEP_COLOR :: Shape_Color(3)
SHAPE_COLOR_ISLAND_COLOR :: Shape_Color(4)
SHAPE_COLOR_MATERIAL_COLOR :: Shape_Color(5)

Soft_Body_Constraint_Color :: distinct int

SOFT_BODY_CONSTRAINT_COLOR_CONSTRAINT_TYPE :: Soft_Body_Constraint_Color(0)
SOFT_BODY_CONSTRAINT_COLOR_CONSTRAINT_GROUP :: Soft_Body_Constraint_Color(1)
SOFT_BODY_CONSTRAINT_COLOR_CONSTRAINT_ORDER :: Soft_Body_Constraint_Color(2)

Active_Edge_Mode :: distinct u8

ACTIVE_EDGE_MODE_COLLIDE_ONLY_WITH_ACTIVE :: Active_Edge_Mode(0)
ACTIVE_EDGE_MODE_COLLIDE_WITH_ALL :: Active_Edge_Mode(1)

Collect_Faces_Mode :: distinct u8

COLLECT_FACES_MODE_COLLECT_FACES :: Collect_Faces_Mode(0)
COLLECT_FACES_MODE_NO_FACES :: Collect_Faces_Mode(1)

Swing_Type :: distinct u8

SWING_TYPE_CONE :: Swing_Type(0)
SWING_TYPE_PYRAMID :: Swing_Type(1)

SixDOFConstraint_Axis :: distinct u32

SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_X :: SixDOFConstraint_Axis(0)
SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_Y :: SixDOFConstraint_Axis(1)
SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_Z :: SixDOFConstraint_Axis(2)
SIX_DOF_CONSTRAINT_AXIS_ROTATION_X :: SixDOFConstraint_Axis(3)
SIX_DOF_CONSTRAINT_AXIS_ROTATION_Y :: SixDOFConstraint_Axis(4)
SIX_DOF_CONSTRAINT_AXIS_ROTATION_Z :: SixDOFConstraint_Axis(5)
SIX_DOF_CONSTRAINT_AXIS_NUM :: SixDOFConstraint_Axis(6)
SIX_DOF_CONSTRAINT_AXIS_NUM_TRANSLATION :: SixDOFConstraint_Axis(3)

Spring_Mode :: enum u8 {
	FREQUENCY_AND_DAMPING = 0,
	STIFFNESS_AND_DAMPING = 1,
}

Motor_State :: enum u32 {
	OFF      = 0,
	VELOCITY = 1,
	POSITION = 2,
}
