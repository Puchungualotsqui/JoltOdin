package joltc

import "core:c"

when ODIN_OS == .Windows {
	foreign import joltc "system:joltc"
} else when ODIN_OS == .Darwin {
	foreign import joltc "system:joltc"
} else {
	foreign import joltc "system:joltc"
}


// ----------------------------------------------------------------------------
// Filters / interfaces
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_GroupFilter_new :: proc(self: rawptr, fns: Group_Filter_Fns) -> ^GroupFilter ---
	JPC_GroupFilter_delete :: proc(object: ^GroupFilter) ---

	JPC_BroadPhaseLayerInterface_new :: proc(self: rawptr, fns: Broad_Phase_Layer_Interface_Fns) -> ^BroadPhaseLayerInterface ---

	JPC_BroadPhaseLayerInterface_delete :: proc(object: ^BroadPhaseLayerInterface) ---

	JPC_BroadPhaseLayerFilter_new :: proc(self: rawptr, fns: Broad_Phase_Layer_Filter_Fns) -> ^BroadPhaseLayerFilter ---

	JPC_BroadPhaseLayerFilter_delete :: proc(object: ^BroadPhaseLayerFilter) ---

	JPC_ObjectLayerFilter_new :: proc(self: rawptr, fns: Object_Layer_Filter_Fns) -> ^ObjectLayerFilter ---

	JPC_ObjectLayerFilter_delete :: proc(object: ^ObjectLayerFilter) ---

	JPC_BodyFilter_new :: proc(self: rawptr, fns: Body_Filter_Fns) -> ^BodyFilter ---

	JPC_BodyFilter_delete :: proc(object: ^BodyFilter) ---

	JPC_ShapeFilter_new :: proc(self: rawptr, fns: Shape_Filter_Fns) -> ^ShapeFilter ---

	JPC_ShapeFilter_delete :: proc(object: ^ShapeFilter) ---

	JPC_SimShapeFilter_new :: proc(self: rawptr, fns: Sim_Shape_Filter_Fns) -> ^SimShapeFilter ---

	JPC_SimShapeFilter_delete :: proc(object: ^SimShapeFilter) ---

	JPC_ObjectVsBroadPhaseLayerFilter_new :: proc(self: rawptr, fns: Object_Vs_Broad_Phase_Layer_Filter_Fns) -> ^ObjectVsBroadPhaseLayerFilter ---

	JPC_ObjectVsBroadPhaseLayerFilter_delete :: proc(object: ^ObjectVsBroadPhaseLayerFilter) ---

	JPC_ObjectLayerPairFilter_new :: proc(self: rawptr, fns: Object_Layer_Pair_Filter_Fns) -> ^ObjectLayerPairFilter ---

	JPC_ObjectLayerPairFilter_delete :: proc(object: ^ObjectLayerPairFilter) ---
}

// ----------------------------------------------------------------------------
// Contact listener
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_ContactListener_new :: proc(self: rawptr, fns: Contact_Listener_Fns) -> ^ContactListener ---

	JPC_ContactListener_delete :: proc(object: ^ContactListener) ---
}

// ----------------------------------------------------------------------------
// Collision estimation
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_EstimateCollisionResponse :: proc(inBody1: ^Body, inBody2: ^Body, inManifold: ^Contact_Manifold, outResult: ^Collision_Estimation_Result, inCombinedFriction: f32, inCombinedRestitution: f32, inMinVelocityForRestitution: f32, inNumIterations: c.uint) ---
}

// ----------------------------------------------------------------------------
// Collectors
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_CastShapeCollector_new :: proc(self: rawptr, fns: Cast_Shape_Collector_Fns) -> ^CastShapeCollector ---

	JPC_CastShapeCollector_delete :: proc(object: ^CastShapeCollector) ---

	JPC_CastShapeCollector_UpdateEarlyOutFraction :: proc(self: ^CastShapeCollector, inFraction: f32) ---

	JPC_CollideShapeCollector_new :: proc(self: rawptr, fns: Collide_Shape_Collector_Fns) -> ^CollideShapeCollector ---

	JPC_CollideShapeCollector_delete :: proc(object: ^CollideShapeCollector) ---

	JPC_CollideShapeCollector_UpdateEarlyOutFraction :: proc(self: ^CollideShapeCollector, inFraction: f32) ---
}

// ----------------------------------------------------------------------------
// Debug rendering
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyManager_DrawSettings_default :: proc(object: ^BodyManager_Draw_Settings) ---

	JPC_DebugRendererSimple_new :: proc(self: rawptr, fns: Debug_Renderer_Simple_Fns) -> ^DebugRendererSimple ---

	JPC_DebugRendererSimple_delete :: proc(object: ^DebugRendererSimple) ---
}
