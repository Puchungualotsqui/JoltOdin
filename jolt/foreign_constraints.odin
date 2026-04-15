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
// Constraint base
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_Constraint_GetRefCount :: proc(self: ^Constraint) -> u32 ---
	JPC_Constraint_AddRef :: proc(self: ^Constraint) ---
	JPC_Constraint_Release :: proc(self: ^Constraint) ---

	JPC_Constraint_delete :: proc(self: ^Constraint) ---

	JPC_Constraint_GetConstraintPriority :: proc(self: ^Constraint) -> u32 ---
	JPC_Constraint_SetConstraintPriority :: proc(self: ^Constraint, inPriority: u32) ---

	JPC_Constraint_GetNumVelocityStepsOverride :: proc(self: ^Constraint) -> c.uint ---
	JPC_Constraint_SetNumVelocityStepsOverride :: proc(self: ^Constraint, inN: c.uint) ---

	JPC_Constraint_GetNumPositionStepsOverride :: proc(self: ^Constraint) -> c.uint ---
	JPC_Constraint_SetNumPositionStepsOverride :: proc(self: ^Constraint, inN: c.uint) ---

	JPC_Constraint_GetEnabled :: proc(self: ^Constraint) -> bool ---
	JPC_Constraint_SetEnabled :: proc(self: ^Constraint, inEnabled: bool) ---

	JPC_Constraint_GetUserData :: proc(self: ^Constraint) -> u64 ---
	JPC_Constraint_SetUserData :: proc(self: ^Constraint, inUserData: u64) ---

	JPC_Constraint_NotifyShapeChanged :: proc(self: ^Constraint, inBodyID: BodyID, inDeltaCOM: Vec3) ---
}

// ----------------------------------------------------------------------------
// TwoBodyConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_TwoBodyConstraint_GetBody1 :: proc(self: ^TwoBodyConstraint) -> ^Body ---
	JPC_TwoBodyConstraint_GetBody2 :: proc(self: ^TwoBodyConstraint) -> ^Body ---

	JPC_TwoBodyConstraint_GetConstraintToBody1Matrix :: proc(self: ^TwoBodyConstraint) -> Mat44 ---
	JPC_TwoBodyConstraint_GetConstraintToBody2Matrix :: proc(self: ^TwoBodyConstraint) -> Mat44 ---
}

// ----------------------------------------------------------------------------
// FixedConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_FixedConstraint_GetTotalLambdaPosition :: proc(self: ^FixedConstraint) -> Vec3 ---
	JPC_FixedConstraint_GetTotalLambdaRotation :: proc(self: ^FixedConstraint) -> Vec3 ---
}

// ----------------------------------------------------------------------------
// DistanceConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_DistanceConstraint_GetTotalLambdaPosition :: proc(self: ^DistanceConstraint) -> f32 ---
}

// ----------------------------------------------------------------------------
// SixDOFConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_SixDOFConstraint_GetTranslationLimitsMin :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_GetTranslationLimitsMax :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_SetTranslationLimits :: proc(self: ^SixDOFConstraint, inLimitMin: Vec3, inLimitMax: Vec3) ---

	JPC_SixDOFConstraint_GetRotationLimitsMin :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_GetRotationLimitsMax :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_SetRotationLimits :: proc(self: ^SixDOFConstraint, inLimitMin: Vec3, inLimitMax: Vec3) ---

	JPC_SixDOFConstraint_GetLimitsMin :: proc(self: ^SixDOFConstraint, inAxis: SixDOFConstraint_Axis) -> f32 ---

	JPC_SixDOFConstraint_GetLimitsMax :: proc(self: ^SixDOFConstraint, inAxis: SixDOFConstraint_Axis) -> f32 ---

	JPC_SixDOFConstraint_IsFreeAxis :: proc(self: ^SixDOFConstraint, inAxis: SixDOFConstraint_Axis) -> bool ---

	JPC_SixDOFConstraint_SetMaxFriction :: proc(self: ^SixDOFConstraint, inAxis: SixDOFConstraint_Axis, inFriction: f32) ---

	JPC_SixDOFConstraint_GetMaxFriction :: proc(self: ^SixDOFConstraint, inAxis: SixDOFConstraint_Axis) -> f32 ---

	JPC_SixDOFConstraint_GetRotationInConstraintSpace :: proc(self: ^SixDOFConstraint) -> Quat ---

	JPC_SixDOFConstraint_GetTargetVelocityCS :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_SetTargetVelocityCS :: proc(self: ^SixDOFConstraint, inVelocity: Vec3) ---

	JPC_SixDOFConstraint_GetTargetAngularVelocityCS :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_SetTargetAngularVelocityCS :: proc(self: ^SixDOFConstraint, inAngularVelocity: Vec3) ---

	JPC_SixDOFConstraint_GetTargetPositionCS :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_SetTargetPositionCS :: proc(self: ^SixDOFConstraint, inPosition: Vec3) ---

	JPC_SixDOFConstraint_GetTargetOrientationCS :: proc(self: ^SixDOFConstraint) -> Quat ---
	JPC_SixDOFConstraint_SetTargetOrientationCS :: proc(self: ^SixDOFConstraint, inOrientation: Quat) ---

	JPC_SixDOFConstraint_SetTargetOrientationBS :: proc(self: ^SixDOFConstraint, inOrientation: Quat) ---

	JPC_SixDOFConstraint_GetTotalLambdaPosition :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_GetTotalLambdaRotation :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_GetTotalLambdaMotorTranslation :: proc(self: ^SixDOFConstraint) -> Vec3 ---
	JPC_SixDOFConstraint_GetTotalLambdaMotorRotation :: proc(self: ^SixDOFConstraint) -> Vec3 ---
}

// ----------------------------------------------------------------------------
// HingeConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_HingeConstraint_SetMotorState :: proc(self: ^HingeConstraint, inState: Motor_State) ---
	JPC_HingeConstraint_GetMotorState :: proc(self: ^HingeConstraint) -> Motor_State ---
	JPC_HingeConstraint_SetTargetAngularVelocity :: proc(self: ^HingeConstraint, inAngularVelocity: f32) ---
	JPC_HingeConstraint_GetTargetAngularVelocity :: proc(self: ^HingeConstraint) -> f32 ---
	JPC_HingeConstraint_SetTargetAngle :: proc(self: ^HingeConstraint, inAngle: f32) ---
	JPC_HingeConstraint_GetTargetAngle :: proc(self: ^HingeConstraint) -> f32 ---

	JPC_HingeConstraint_GetTotalLambdaPosition :: proc(self: ^HingeConstraint) -> Vec3 ---
	JPC_HingeConstraint_GetTotalLambdaRotation :: proc(self: ^HingeConstraint) -> Vec2 ---
	JPC_HingeConstraint_GetTotalLambdaRotationLimits :: proc(self: ^HingeConstraint) -> f32 ---
	JPC_HingeConstraint_GetTotalLambdaMotor :: proc(self: ^HingeConstraint) -> f32 ---
}

// ----------------------------------------------------------------------------
// SliderConstraint
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_SliderConstraint_SetMotorState :: proc(self: ^SliderConstraint, inState: Motor_State) ---
	JPC_SliderConstraint_GetMotorState :: proc(self: ^SliderConstraint) -> Motor_State ---
	JPC_SliderConstraint_SetTargetVelocity :: proc(self: ^SliderConstraint, inVelocity: f32) ---
	JPC_SliderConstraint_GetTargetVelocity :: proc(self: ^SliderConstraint) -> f32 ---
	JPC_SliderConstraint_SetTargetPosition :: proc(self: ^SliderConstraint, inPosition: f32) ---
	JPC_SliderConstraint_GetTargetPosition :: proc(self: ^SliderConstraint) -> f32 ---

	JPC_SliderConstraint_GetTotalLambdaPosition :: proc(self: ^SliderConstraint) -> Vec2 ---
	JPC_SliderConstraint_GetTotalLambdaPositionLimits :: proc(self: ^SliderConstraint) -> f32 ---
	JPC_SliderConstraint_GetTotalLambdaRotation :: proc(self: ^SliderConstraint) -> Vec3 ---
	JPC_SliderConstraint_GetTotalLambdaMotor :: proc(self: ^SliderConstraint) -> f32 ---
}

// ----------------------------------------------------------------------------
// Constraint settings default
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_ConstraintSettings_default :: proc(settings: ^Constraint_Settings) ---
	JPC_SpringSettings_default :: proc(settings: ^Spring_Settings) ---
	JPC_MotorSettings_default :: proc(settings: ^Motor_Settings) ---
}

// ----------------------------------------------------------------------------
// Constraint settings create/default
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_FixedConstraintSettings_default :: proc(settings: ^Fixed_Constraint_Settings) ---
	JPC_FixedConstraintSettings_Create :: proc(self: ^Fixed_Constraint_Settings, inBody1: ^Body, inBody2: ^Body) -> ^Constraint ---

	JPC_SixDOFConstraintSettings_default :: proc(settings: ^SixDOF_Constraint_Settings) ---
	JPC_SixDOFConstraintSettings_Create :: proc(self: ^SixDOF_Constraint_Settings, inBody1: ^Body, inBody2: ^Body) -> ^Constraint ---

	JPC_HingeConstraintSettings_default :: proc(settings: ^Hinge_Constraint_Settings) ---
	JPC_HingeConstraintSettings_Create :: proc(self: ^Hinge_Constraint_Settings, inBody1: ^Body, inBody2: ^Body) -> ^HingeConstraint ---

	JPC_DistanceConstraintSettings_default :: proc(settings: ^Distance_Constraint_Settings) ---
	JPC_DistanceConstraintSettings_Create :: proc(self: ^Distance_Constraint_Settings, inBody1: ^Body, inBody2: ^Body) -> ^DistanceConstraint ---

	JPC_SliderConstraintSettings_default :: proc(settings: ^Slider_Constraint_Settings) ---
	JPC_SliderConstraintSettings_Create :: proc(self: ^Slider_Constraint_Settings, inBody1: ^Body, inBody2: ^Body) -> ^SliderConstraint ---
}
