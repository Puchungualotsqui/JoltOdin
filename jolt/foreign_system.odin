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
// PhysicsSystem
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_PhysicsSystem_new :: proc() -> ^PhysicsSystem ---
	JPC_PhysicsSystem_delete :: proc(object: ^PhysicsSystem) ---

	JPC_PhysicsSystem_Init :: proc(self: ^PhysicsSystem, inMaxBodies: c.uint, inNumBodyMutexes: c.uint, inMaxBodyPairs: c.uint, inMaxContactConstraints: c.uint, inBroadPhaseLayerInterface: ^BroadPhaseLayerInterface, inObjectVsBroadPhaseLayerFilter: ^ObjectVsBroadPhaseLayerFilter, inObjectLayerPairFilter: ^ObjectLayerPairFilter) ---

	JPC_PhysicsSystem_OptimizeBroadPhase :: proc(self: ^PhysicsSystem) ---

	JPC_PhysicsSystem_Update :: proc(self: ^PhysicsSystem, inDeltaTime: f32, inCollisionSteps: c.int, inTempAllocator: ^TempAllocatorImpl, inJobSystem: ^JobSystem) -> Physics_Update_Error ---

	JPC_PhysicsSystem_AddConstraint :: proc(self: ^PhysicsSystem, constraint: ^Constraint) ---

	JPC_PhysicsSystem_RemoveConstraint :: proc(self: ^PhysicsSystem, constraint: ^Constraint) ---

	JPC_PhysicsSystem_GetBodyInterface :: proc(self: ^PhysicsSystem) -> ^BodyInterface ---

	JPC_PhysicsSystem_GetBodyLockInterface :: proc(self: ^PhysicsSystem) -> ^BodyLockInterface ---

	JPC_PhysicsSystem_GetNarrowPhaseQuery :: proc(self: ^PhysicsSystem) -> ^NarrowPhaseQuery ---

	JPC_PhysicsSystem_DrawBodies :: proc(self: ^PhysicsSystem, inSettings: ^BodyManager_Draw_Settings, inRenderer: ^DebugRendererSimple, inBodyFilter: rawptr) ---

	/*JPC_PhysicsSystem_DrawConstraints :: proc(self: ^PhysicsSystem, inRenderer: ^DebugRendererSimple) ---*/

	JPC_PhysicsSystem_SetSimShapeFilter :: proc(self: ^PhysicsSystem, inShapeFilter: ^SimShapeFilter) ---

	JPC_PhysicsSystem_SetContactListener :: proc(self: ^PhysicsSystem, inContactListener: ^ContactListener) ---
}
