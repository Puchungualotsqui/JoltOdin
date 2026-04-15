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
// BodyCreationSettings
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyCreationSettings_default :: proc(settings: ^Body_Creation_Settings) ---
	JPC_BodyCreationSettings_new :: proc() -> ^Body_Creation_Settings ---
}

// ----------------------------------------------------------------------------
// Body
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_Body_GetID :: proc(self: ^Body) -> BodyID ---
	JPC_Body_GetBodyType :: proc(self: ^Body) -> Body_Type ---
	JPC_Body_IsRigidBody :: proc(self: ^Body) -> bool ---
	JPC_Body_IsSoftBody :: proc(self: ^Body) -> bool ---
	JPC_Body_IsActive :: proc(self: ^Body) -> bool ---
	JPC_Body_IsStatic :: proc(self: ^Body) -> bool ---
	JPC_Body_IsKinematic :: proc(self: ^Body) -> bool ---
	JPC_Body_IsDynamic :: proc(self: ^Body) -> bool ---
	JPC_Body_CanBeKinematicOrDynamic :: proc(self: ^Body) -> bool ---

	JPC_Body_SetIsSensor :: proc(self: ^Body, inIsSensor: bool) ---
	JPC_Body_IsSensor :: proc(self: ^Body) -> bool ---

	JPC_Body_SetCollideKinematicVsNonDynamic :: proc(self: ^Body, inCollide: bool) ---
	JPC_Body_GetCollideKinematicVsNonDynamic :: proc(self: ^Body) -> bool ---

	JPC_Body_SetUseManifoldReduction :: proc(self: ^Body, inUseReduction: bool) ---
	JPC_Body_GetUseManifoldReduction :: proc(self: ^Body) -> bool ---
	JPC_Body_GetUseManifoldReductionWithBody :: proc(self: ^Body, inBody2: ^Body) -> bool ---

	JPC_Body_SetApplyGyroscopicForce :: proc(self: ^Body, inApply: bool) ---
	JPC_Body_GetApplyGyroscopicForce :: proc(self: ^Body) -> bool ---

	JPC_Body_SetEnhancedInternalEdgeRemoval :: proc(self: ^Body, inApply: bool) ---
	JPC_Body_GetEnhancedInternalEdgeRemoval :: proc(self: ^Body) -> bool ---
	JPC_Body_GetEnhancedInternalEdgeRemovalWithBody :: proc(self: ^Body, inBody2: ^Body) -> bool ---

	JPC_Body_GetMotionType :: proc(self: ^Body) -> Motion_Type ---
	JPC_Body_SetMotionType :: proc(self: ^Body, inMotionType: Motion_Type) ---

	JPC_Body_GetBroadPhaseLayer :: proc(self: ^Body) -> BroadPhaseLayer ---
	JPC_Body_GetObjectLayer :: proc(self: ^Body) -> ObjectLayer ---

	JPC_Body_GetAllowSleeping :: proc(self: ^Body) -> bool ---
	JPC_Body_SetAllowSleeping :: proc(self: ^Body, inAllow: bool) ---
	JPC_Body_ResetSleepTimer :: proc(self: ^Body) ---

	JPC_Body_GetFriction :: proc(self: ^Body) -> f32 ---
	JPC_Body_SetFriction :: proc(self: ^Body, inFriction: f32) ---
	JPC_Body_GetRestitution :: proc(self: ^Body) -> f32 ---
	JPC_Body_SetRestitution :: proc(self: ^Body, inRestitution: f32) ---

	JPC_Body_GetLinearVelocity :: proc(self: ^Body) -> Vec3 ---
	JPC_Body_SetLinearVelocity :: proc(self: ^Body, inLinearVelocity: Vec3) ---
	JPC_Body_SetLinearVelocityClamped :: proc(self: ^Body, inLinearVelocity: Vec3) ---

	JPC_Body_GetAngularVelocity :: proc(self: ^Body) -> Vec3 ---
	JPC_Body_SetAngularVelocity :: proc(self: ^Body, inAngularVelocity: Vec3) ---
	JPC_Body_SetAngularVelocityClamped :: proc(self: ^Body, inAngularVelocity: Vec3) ---

	JPC_Body_GetPointVelocityCOM :: proc(self: ^Body, inPointRelativeToCOM: Vec3) -> Vec3 ---
	JPC_Body_GetPointVelocity :: proc(self: ^Body, inPoint: RVec3) -> Vec3 ---

	JPC_Body_AddForce :: proc(self: ^Body, inForce: Vec3) ---
	JPC_Body_AddForceAtPoint :: proc(self: ^Body, inForce: Vec3, inPosition: RVec3) ---
	JPC_Body_AddTorque :: proc(self: ^Body, inTorque: Vec3) ---

	JPC_Body_GetAccumulatedForce :: proc(self: ^Body) -> Vec3 ---
	JPC_Body_GetAccumulatedTorque :: proc(self: ^Body) -> Vec3 ---
	JPC_Body_ResetForce :: proc(self: ^Body) ---
	JPC_Body_ResetTorque :: proc(self: ^Body) ---
	JPC_Body_ResetMotion :: proc(self: ^Body) ---

	JPC_Body_GetInverseInertia :: proc(self: ^Body, outMatrix: ^Mat44) ---

	JPC_Body_AddImpulse :: proc(self: ^Body, inImpulse: Vec3) ---
	JPC_Body_AddImpulse2 :: proc(self: ^Body, inImpulse: Vec3, inPosition: RVec3) ---
	JPC_Body_AddAngularImpulse :: proc(self: ^Body, inAngularImpulse: Vec3) ---

	JPC_Body_MoveKinematic :: proc(self: ^Body, inTargetPosition: RVec3, inTargetRotation: Quat, inDeltaTime: f32) ---

	JPC_Body_ApplyBuoyancyImpulse :: proc(self: ^Body, inSurfacePosition: RVec3, inSurfaceNormal: Vec3, inBuoyancy: f32, inLinearDrag: f32, inAngularDrag: f32, inFluidVelocity: Vec3, inGravity: Vec3, inDeltaTime: f32) -> bool ---

	JPC_Body_IsInBroadPhase :: proc(self: ^Body) -> bool ---
	JPC_Body_IsCollisionCacheInvalid :: proc(self: ^Body) -> bool ---

	JPC_Body_GetShape :: proc(self: ^Body) -> ^Shape ---
	JPC_Body_GetPosition :: proc(self: ^Body) -> RVec3 ---
	JPC_Body_GetRotation :: proc(self: ^Body) -> Quat ---
	JPC_Body_GetWorldTransform :: proc(self: ^Body) -> RMat44 ---
	JPC_Body_GetCenterOfMassPosition :: proc(self: ^Body) -> RVec3 ---
	JPC_Body_GetCenterOfMassTransform :: proc(self: ^Body) -> RMat44 ---
	JPC_Body_GetInverseCenterOfMassTransform :: proc(self: ^Body) -> RMat44 ---

	JPC_Body_GetUserData :: proc(self: ^Body) -> u64 ---
	JPC_Body_SetUserData :: proc(self: ^Body, inUserData: u64) ---

	JPC_Body_GetWorldSpaceSurfaceNormal :: proc(self: ^Body, inSubShapeID: SubShapeID, inPosition: RVec3) -> Vec3 ---
}

// ----------------------------------------------------------------------------
// BodyLockRead
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyLockRead_new :: proc(interface: ^BodyLockInterface, bodyID: BodyID) -> ^BodyLockRead ---
	JPC_BodyLockRead_delete :: proc(self: ^BodyLockRead) ---
	JPC_BodyLockRead_Succeeded :: proc(self: ^BodyLockRead) -> bool ---
	JPC_BodyLockRead_GetBody :: proc(self: ^BodyLockRead) -> ^Body ---
}

// ----------------------------------------------------------------------------
// BodyLockWrite
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyLockWrite_new :: proc(interface: ^BodyLockInterface, bodyID: BodyID) -> ^BodyLockWrite ---
	JPC_BodyLockWrite_delete :: proc(self: ^BodyLockWrite) ---
	JPC_BodyLockWrite_Succeeded :: proc(self: ^BodyLockWrite) -> bool ---
	JPC_BodyLockWrite_GetBody :: proc(self: ^BodyLockWrite) -> ^Body ---
}

// ----------------------------------------------------------------------------
// BodyLockMultiRead
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyLockMultiRead_new :: proc(interface: ^BodyLockInterface, inBodyIDs: ^BodyID, inNumber: c.int) -> ^BodyLockMultiRead ---

	JPC_BodyLockMultiRead_delete :: proc(self: ^BodyLockMultiRead) ---

	JPC_BodyLockMultiRead_GetBody :: proc(self: ^BodyLockMultiRead, inBodyIndex: c.int) -> ^Body ---
}

// ----------------------------------------------------------------------------
// BodyLockMultiWrite
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyLockMultiWrite_new :: proc(interface: ^BodyLockInterface, inBodyIDs: ^BodyID, inNumber: c.int) -> ^BodyLockMultiWrite ---

	JPC_BodyLockMultiWrite_delete :: proc(self: ^BodyLockMultiWrite) ---

	JPC_BodyLockMultiWrite_GetBody :: proc(self: ^BodyLockMultiWrite, inBodyIndex: c.int) -> ^Body ---
}

// ----------------------------------------------------------------------------
// BodyInterface
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_BodyInterface_CreateBody :: proc(self: ^BodyInterface, inSettings: ^Body_Creation_Settings) -> ^Body ---

	JPC_BodyInterface_CreateBodyWithID :: proc(self: ^BodyInterface, inBodyID: BodyID, inSettings: ^Body_Creation_Settings) -> ^Body ---

	JPC_BodyInterface_CreateBodyWithoutID :: proc(self: ^BodyInterface, inSettings: ^Body_Creation_Settings) -> ^Body ---

	JPC_BodyInterface_DestroyBodyWithoutID :: proc(self: ^BodyInterface, inBody: ^Body) ---

	JPC_BodyInterface_AssignBodyID :: proc(self: ^BodyInterface, ioBody: ^Body) -> bool ---

	JPC_BodyInterface_UnassignBodyID :: proc(self: ^BodyInterface, inBodyID: BodyID) -> ^Body ---

	JPC_BodyInterface_UnassignBodyIDs :: proc(self: ^BodyInterface, inBodyIDs: ^BodyID, inNumber: c.int, outBodies: ^^Body) ---

	JPC_BodyInterface_DestroyBody :: proc(self: ^BodyInterface, inBodyID: BodyID) ---

	JPC_BodyInterface_DestroyBodies :: proc(self: ^BodyInterface, inBodyIDs: ^BodyID, inNumber: c.int) ---

	JPC_BodyInterface_AddBody :: proc(self: ^BodyInterface, inBodyID: BodyID, inActivationMode: Activation) ---

	JPC_BodyInterface_RemoveBody :: proc(self: ^BodyInterface, inBodyID: BodyID) ---

	JPC_BodyInterface_IsAdded :: proc(self: ^BodyInterface, inBodyID: BodyID) -> bool ---

	JPC_BodyInterface_CreateAndAddBody :: proc(self: ^BodyInterface, inSettings: ^Body_Creation_Settings, inActivationMode: Activation) -> BodyID ---

	JPC_BodyInterface_AddBodiesPrepare :: proc(self: ^BodyInterface, ioBodies: ^BodyID, inNumber: c.int) -> rawptr ---

	JPC_BodyInterface_AddBodiesFinalize :: proc(self: ^BodyInterface, ioBodies: ^BodyID, inNumber: c.int, inAddState: rawptr, inActivationMode: Activation) ---

	JPC_BodyInterface_AddBodiesAbort :: proc(self: ^BodyInterface, ioBodies: ^BodyID, inNumber: c.int, inAddState: rawptr) ---

	JPC_BodyInterface_RemoveBodies :: proc(self: ^BodyInterface, ioBodies: ^BodyID, inNumber: c.int) ---

	JPC_BodyInterface_ActivateBody :: proc(self: ^BodyInterface, inBodyID: BodyID) ---

	JPC_BodyInterface_ActivateBodies :: proc(self: ^BodyInterface, inBodyIDs: ^BodyID, inNumber: c.int) ---

	JPC_BodyInterface_DeactivateBody :: proc(self: ^BodyInterface, inBodyID: BodyID) ---

	JPC_BodyInterface_DeactivateBodies :: proc(self: ^BodyInterface, inBodyIDs: ^BodyID, inNumber: c.int) ---

	JPC_BodyInterface_IsActive :: proc(self: ^BodyInterface, inBodyID: BodyID) -> bool ---

	JPC_BodyInterface_GetShape :: proc(self: ^BodyInterface, inBodyID: BodyID) -> ^Shape ---

	JPC_BodyInterface_SetShape :: proc(self: ^BodyInterface, inBodyID: BodyID, inShape: ^Shape, inUpdateMassProperties: bool, inActivationMode: Activation) ---

	JPC_BodyInterface_NotifyShapeChanged :: proc(self: ^BodyInterface, inBodyID: BodyID, inPreviousCenterOfMass: Vec3, inUpdateMassProperties: bool, inActivationMode: Activation) ---

	JPC_BodyInterface_SetObjectLayer :: proc(self: ^BodyInterface, inBodyID: BodyID, inLayer: ObjectLayer) ---

	JPC_BodyInterface_GetObjectLayer :: proc(self: ^BodyInterface, inBodyID: BodyID) -> ObjectLayer ---

	JPC_BodyInterface_SetPositionAndRotation :: proc(self: ^BodyInterface, inBodyID: BodyID, inPosition: RVec3, inRotation: Quat, inActivationMode: Activation) ---

	JPC_BodyInterface_SetPositionAndRotationWhenChanged :: proc(self: ^BodyInterface, inBodyID: BodyID, inPosition: RVec3, inRotation: Quat, inActivationMode: Activation) ---

	JPC_BodyInterface_GetPositionAndRotation :: proc(self: ^BodyInterface, inBodyID: BodyID, outPosition: ^RVec3, outRotation: ^Quat) ---

	JPC_BodyInterface_SetPosition :: proc(self: ^BodyInterface, inBodyID: BodyID, inPosition: RVec3, inActivationMode: Activation) ---

	JPC_BodyInterface_GetPosition :: proc(self: ^BodyInterface, inBodyID: BodyID) -> RVec3 ---

	JPC_BodyInterface_GetCenterOfMassPosition :: proc(self: ^BodyInterface, inBodyID: BodyID) -> RVec3 ---

	JPC_BodyInterface_SetRotation :: proc(self: ^BodyInterface, inBodyID: BodyID, inRotation: Quat, inActivationMode: Activation) ---

	JPC_BodyInterface_GetRotation :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Quat ---

	JPC_BodyInterface_GetWorldTransform :: proc(self: ^BodyInterface, inBodyID: BodyID) -> RMat44 ---

	JPC_BodyInterface_GetCenterOfMassTransform :: proc(self: ^BodyInterface, inBodyID: BodyID) -> RMat44 ---

	JPC_BodyInterface_MoveKinematic :: proc(self: ^BodyInterface, inBodyID: BodyID, inTargetPosition: RVec3, inTargetRotation: Quat, inDeltaTime: f32) ---

	JPC_BodyInterface_SetLinearAndAngularVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inLinearVelocity: Vec3, inAngularVelocity: Vec3) ---

	JPC_BodyInterface_GetLinearAndAngularVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, outLinearVelocity: ^Vec3, outAngularVelocity: ^Vec3) ---

	JPC_BodyInterface_SetLinearVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inLinearVelocity: Vec3) ---

	JPC_BodyInterface_GetLinearVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Vec3 ---

	JPC_BodyInterface_AddLinearVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inLinearVelocity: Vec3) ---

	JPC_BodyInterface_AddLinearAndAngularVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inLinearVelocity: Vec3, inAngularVelocity: Vec3) ---

	JPC_BodyInterface_SetAngularVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inAngularVelocity: Vec3) ---

	JPC_BodyInterface_GetAngularVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Vec3 ---

	JPC_BodyInterface_GetPointVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inPoint: RVec3) -> Vec3 ---

	JPC_BodyInterface_SetPositionRotationAndVelocity :: proc(self: ^BodyInterface, inBodyID: BodyID, inPosition: RVec3, inRotation: Quat, inLinearVelocity: Vec3, inAngularVelocity: Vec3) ---

	JPC_BodyInterface_AddForce :: proc(self: ^BodyInterface, inBodyID: BodyID, inForce: Vec3) ---

	JPC_BodyInterface_AddForceAtPoint :: proc(self: ^BodyInterface, inBodyID: BodyID, inForce: Vec3, inPoint: RVec3) ---

	JPC_BodyInterface_AddTorque :: proc(self: ^BodyInterface, inBodyID: BodyID, inTorque: Vec3) ---

	JPC_BodyInterface_AddForceAndTorque :: proc(self: ^BodyInterface, inBodyID: BodyID, inForce: Vec3, inTorque: Vec3) ---

	JPC_BodyInterface_AddImpulse :: proc(self: ^BodyInterface, inBodyID: BodyID, inImpulse: Vec3) ---

	JPC_BodyInterface_AddImpulse3 :: proc(self: ^BodyInterface, inBodyID: BodyID, inImpulse: Vec3, inPoint: RVec3) ---

	JPC_BodyInterface_AddAngularImpulse :: proc(self: ^BodyInterface, inBodyID: BodyID, inAngularImpulse: Vec3) ---

	JPC_BodyInterface_GetBodyType :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Body_Type ---

	JPC_BodyInterface_SetMotionType :: proc(self: ^BodyInterface, inBodyID: BodyID, inMotionType: Motion_Type, inActivationMode: Activation) ---

	JPC_BodyInterface_GetMotionType :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Motion_Type ---

	JPC_BodyInterface_SetMotionQuality :: proc(self: ^BodyInterface, inBodyID: BodyID, inMotionQuality: Motion_Quality) ---

	JPC_BodyInterface_GetMotionQuality :: proc(self: ^BodyInterface, inBodyID: BodyID) -> Motion_Quality ---

	JPC_BodyInterface_GetInverseInertia :: proc(self: ^BodyInterface, inBodyID: BodyID, outMatrix: ^Mat44) ---

	JPC_BodyInterface_SetRestitution :: proc(self: ^BodyInterface, inBodyID: BodyID, inRestitution: f32) ---

	JPC_BodyInterface_GetRestitution :: proc(self: ^BodyInterface, inBodyID: BodyID) -> f32 ---

	JPC_BodyInterface_SetFriction :: proc(self: ^BodyInterface, inBodyID: BodyID, inFriction: f32) ---

	JPC_BodyInterface_GetFriction :: proc(self: ^BodyInterface, inBodyID: BodyID) -> f32 ---

	JPC_BodyInterface_SetGravityFactor :: proc(self: ^BodyInterface, inBodyID: BodyID, inGravityFactor: f32) ---

	JPC_BodyInterface_GetGravityFactor :: proc(self: ^BodyInterface, inBodyID: BodyID) -> f32 ---

	JPC_BodyInterface_SetUseManifoldReduction :: proc(self: ^BodyInterface, inBodyID: BodyID, inUseReduction: bool) ---

	JPC_BodyInterface_GetUseManifoldReduction :: proc(self: ^BodyInterface, inBodyID: BodyID) -> bool ---

	JPC_BodyInterface_GetUserData :: proc(self: ^BodyInterface, inBodyID: BodyID) -> u64 ---

	JPC_BodyInterface_SetUserData :: proc(self: ^BodyInterface, inBodyID: BodyID, inUserData: u64) ---

	JPC_BodyInterface_InvalidateContactCache :: proc(self: ^BodyInterface, inBodyID: BodyID) ---
}
