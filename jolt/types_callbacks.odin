package joltc

// ----------------------------------------------------------------------------
// Callback vtables / function tables
// ----------------------------------------------------------------------------

Group_Filter_Fns :: struct {
	CanCollide: proc "c" (
		self: rawptr,
		inGroup1: ^Collision_Group,
		inGroup2: ^Collision_Group,
	) -> bool,
}

Broad_Phase_Layer_Interface_Fns :: struct {
	GetNumBroadPhaseLayers: proc "c" (self: rawptr) -> u32,
	GetBroadPhaseLayer:     proc "c" (self: rawptr, inLayer: ObjectLayer) -> BroadPhaseLayer,
}

Broad_Phase_Layer_Filter_Fns :: struct {
	ShouldCollide: proc "c" (self: rawptr, inLayer: BroadPhaseLayer) -> bool,
}

Object_Layer_Filter_Fns :: struct {
	ShouldCollide: proc "c" (self: rawptr, inLayer: ObjectLayer) -> bool,
}

Body_Filter_Fns :: struct {
	ShouldCollide:       proc "c" (self: rawptr, inBodyID: BodyID) -> bool,
	ShouldCollideLocked: proc "c" (self: rawptr, inBody: ^Body) -> bool,
}

Shape_Filter_Fns :: struct {
	ShouldCollide:          proc "c" (
		self: rawptr,
		inShape2: ^Shape,
		inSubShapeIDOfShape2: SubShapeID,
	) -> bool,
	ShouldCollideTwoShapes: proc "c" (
		self: rawptr,
		inShape1: ^Shape,
		inSubShapeIDOfShape1: SubShapeID,
		inShape2: ^Shape,
		inSubShapeIDOfShape2: SubShapeID,
	) -> bool,
}

Sim_Shape_Filter_Fns :: struct {
	ShouldCollide: proc "c" (
		self: rawptr,
		inBody1: ^Body,
		inShape1: ^Shape,
		inSubShapeIDOfShape1: SubShapeID,
		inBody2: ^Body,
		inShape2: ^Shape,
		inSubShapeIDOfShape2: SubShapeID,
	) -> bool,
}

Object_Vs_Broad_Phase_Layer_Filter_Fns :: struct {
	ShouldCollide: proc "c" (
		self: rawptr,
		inLayer1: ObjectLayer,
		inLayer2: BroadPhaseLayer,
	) -> bool,
}

Object_Layer_Pair_Filter_Fns :: struct {
	ShouldCollide: proc "c" (self: rawptr, inLayer1: ObjectLayer, inLayer2: ObjectLayer) -> bool,
}

Contact_Listener_Fns :: struct {
	OnContactValidate:  proc "c" (
		self: rawptr,
		inBody1: ^Body,
		inBody2: ^Body,
		inBaseOffset: RVec3,
		inCollisionResult: ^Collide_Shape_Result,
	) -> Validate_Result,
	OnContactAdded:     proc "c" (
		self: rawptr,
		inBody1: ^Body,
		inBody2: ^Body,
		inManifold: ^Contact_Manifold,
		ioSettings: ^Contact_Settings,
	),
	OnContactPersisted: proc "c" (
		self: rawptr,
		inBody1: ^Body,
		inBody2: ^Body,
		inManifold: ^Contact_Manifold,
		ioSettings: ^Contact_Settings,
	),
	OnContactRemoved:   proc "c" (self: rawptr, inSubShapePair: ^SubShapeID_Pair),
}

Cast_Shape_Collector_Fns :: struct {
	Reset:  proc "c" (self: rawptr),
	AddHit: proc "c" (self: rawptr, base: ^CastShapeCollector, Result: ^Shape_Cast_Result),
}

Collide_Shape_Collector_Fns :: struct {
	Reset:  proc "c" (self: rawptr),
	AddHit: proc "c" (self: rawptr, base: ^CollideShapeCollector, Result: ^Collide_Shape_Result),
}

Debug_Renderer_Simple_Fns :: struct {
	DrawLine: proc "c" (self: rawptr, inFrom: RVec3, inTo: RVec3, inColor: Color),
}
