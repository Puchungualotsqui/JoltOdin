package joltc

// ----------------------------------------------------------------------------
// Callback vtables / function tables
// ----------------------------------------------------------------------------

Group_Filter_Can_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inGroup1: ^Collision_Group,
	inGroup2: ^Collision_Group,
) -> bool

Group_Filter_Fns :: struct {
	CanCollide: Group_Filter_Can_Collide_Proc,
}

Broad_Phase_Layer_Interface_Get_Num_Broad_Phase_Layers_Proc :: #type proc "c" (self: rawptr) -> u32

Broad_Phase_Layer_Interface_Get_Broad_Phase_Layer_Proc :: #type proc "c" (
	self: rawptr,
	inLayer: ObjectLayer,
) -> BroadPhaseLayer

Broad_Phase_Layer_Interface_Fns :: struct {
	GetNumBroadPhaseLayers: Broad_Phase_Layer_Interface_Get_Num_Broad_Phase_Layers_Proc,
	GetBroadPhaseLayer:     Broad_Phase_Layer_Interface_Get_Broad_Phase_Layer_Proc,
}

Broad_Phase_Layer_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inLayer: BroadPhaseLayer,
) -> bool

Broad_Phase_Layer_Filter_Fns :: struct {
	ShouldCollide: Broad_Phase_Layer_Filter_Should_Collide_Proc,
}

Object_Layer_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inLayer: ObjectLayer,
) -> bool

Object_Layer_Filter_Fns :: struct {
	ShouldCollide: Object_Layer_Filter_Should_Collide_Proc,
}

Body_Filter_Should_Collide_Proc :: #type proc "c" (self: rawptr, inBodyID: BodyID) -> bool

Body_Filter_Should_Collide_Locked_Proc :: #type proc "c" (self: rawptr, inBody: ^Body) -> bool

Body_Filter_Fns :: struct {
	ShouldCollide:       Body_Filter_Should_Collide_Proc,
	ShouldCollideLocked: Body_Filter_Should_Collide_Locked_Proc,
}

Shape_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inShape2: ^Shape,
	inSubShapeIDOfShape2: SubShapeID,
) -> bool

Shape_Filter_Should_Collide_Two_Shapes_Proc :: #type proc "c" (
	self: rawptr,
	inShape1: ^Shape,
	inSubShapeIDOfShape1: SubShapeID,
	inShape2: ^Shape,
	inSubShapeIDOfShape2: SubShapeID,
) -> bool

Shape_Filter_Fns :: struct {
	ShouldCollide:          Shape_Filter_Should_Collide_Proc,
	ShouldCollideTwoShapes: Shape_Filter_Should_Collide_Two_Shapes_Proc,
}

Sim_Shape_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inBody1: ^Body,
	inShape1: ^Shape,
	inSubShapeIDOfShape1: SubShapeID,
	inBody2: ^Body,
	inShape2: ^Shape,
	inSubShapeIDOfShape2: SubShapeID,
) -> bool

Sim_Shape_Filter_Fns :: struct {
	ShouldCollide: Sim_Shape_Filter_Should_Collide_Proc,
}

Object_Vs_Broad_Phase_Layer_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inLayer1: ObjectLayer,
	inLayer2: BroadPhaseLayer,
) -> bool

Object_Vs_Broad_Phase_Layer_Filter_Fns :: struct {
	ShouldCollide: Object_Vs_Broad_Phase_Layer_Filter_Should_Collide_Proc,
}

Object_Layer_Pair_Filter_Should_Collide_Proc :: #type proc "c" (
	self: rawptr,
	inLayer1: ObjectLayer,
	inLayer2: ObjectLayer,
) -> bool

Object_Layer_Pair_Filter_Fns :: struct {
	ShouldCollide: Object_Layer_Pair_Filter_Should_Collide_Proc,
}

Contact_Listener_On_Contact_Validate_Proc :: #type proc "c" (
	self: rawptr,
	inBody1: ^Body,
	inBody2: ^Body,
	inBaseOffset: RVec3,
	inCollisionResult: ^Collide_Shape_Result,
) -> Validate_Result

Contact_Listener_On_Contact_Added_Proc :: #type proc "c" (
	self: rawptr,
	inBody1: ^Body,
	inBody2: ^Body,
	inManifold: ^Contact_Manifold,
	ioSettings: ^Contact_Settings,
)

Contact_Listener_On_Contact_Persisted_Proc :: #type proc "c" (
	self: rawptr,
	inBody1: ^Body,
	inBody2: ^Body,
	inManifold: ^Contact_Manifold,
	ioSettings: ^Contact_Settings,
)

Contact_Listener_On_Contact_Removed_Proc :: #type proc "c" (
	self: rawptr,
	inSubShapePair: ^SubShapeID_Pair,
)

Contact_Listener_Fns :: struct {
	OnContactValidate:  Contact_Listener_On_Contact_Validate_Proc,
	OnContactAdded:     Contact_Listener_On_Contact_Added_Proc,
	OnContactPersisted: Contact_Listener_On_Contact_Persisted_Proc,
	OnContactRemoved:   Contact_Listener_On_Contact_Removed_Proc,
}

Cast_Shape_Collector_Reset_Proc :: #type proc "c" (self: rawptr)

Cast_Shape_Collector_Add_Hit_Proc :: #type proc "c" (
	self: rawptr,
	base: ^CastShapeCollector,
	result: ^Shape_Cast_Result,
)

Cast_Shape_Collector_Fns :: struct {
	Reset:  Cast_Shape_Collector_Reset_Proc,
	AddHit: Cast_Shape_Collector_Add_Hit_Proc,
}

Collide_Shape_Collector_Reset_Proc :: #type proc "c" (self: rawptr)

Collide_Shape_Collector_Add_Hit_Proc :: #type proc "c" (
	self: rawptr,
	base: ^CollideShapeCollector,
	result: ^Collide_Shape_Result,
)

Collide_Shape_Collector_Fns :: struct {
	Reset:  Collide_Shape_Collector_Reset_Proc,
	AddHit: Collide_Shape_Collector_Add_Hit_Proc,
}

Debug_Renderer_Simple_Draw_Line_Proc :: #type proc "c" (
	self: rawptr,
	inFrom: RVec3,
	inTo: RVec3,
	inColor: Color,
)

Debug_Renderer_Simple_Fns :: struct {
	DrawLine: Debug_Renderer_Simple_Draw_Line_Proc,
}
