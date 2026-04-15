package joltc

// ----------------------------------------------------------------------------
// Constraint settings
// ----------------------------------------------------------------------------

Fixed_Constraint_Settings :: struct {
	ConstraintSettings: Constraint_Settings,
	Space:              Constraint_Space,
	AutoDetectPoint:    bool,
	Point1:             RVec3,
	AxisX1:             Vec3,
	AxisY1:             Vec3,
	Point2:             RVec3,
	AxisX2:             Vec3,
	AxisY2:             Vec3,
}

SixDOF_Constraint_Settings :: struct {
	ConstraintSettings: Constraint_Settings,
	Space:              Constraint_Space,
	Position1:          RVec3,
	AxisX1:             Vec3,
	AxisY1:             Vec3,
	Position2:          RVec3,
	AxisX2:             Vec3,
	AxisY2:             Vec3,
	MaxFriction:        [6]f32,
	LimitMin:           [6]f32,
	LimitMax:           [6]f32,
}

Hinge_Constraint_Settings :: struct {
	ConstraintSettings:   Constraint_Settings,
	Space:                Constraint_Space,
	Point1:               RVec3,
	HingeAxis1:           Vec3,
	NormalAxis1:          Vec3,
	Point2:               RVec3,
	HingeAxis2:           Vec3,
	NormalAxis2:          Vec3,
	LimitsMin:            f32,
	LimitsMax:            f32,
	LimitsSpringSettings: Spring_Settings,
	MaxFrictionTorque:    f32,
	MotorSettings:        Motor_Settings,
}

Distance_Constraint_Settings :: struct {
	ConstraintSettings:   Constraint_Settings,
	Space:                Constraint_Space,
	Point1:               RVec3,
	Point2:               RVec3,
	MinDistance:          f32,
	MaxDistance:          f32,
	LimitsSpringSettings: Spring_Settings,
}

Slider_Constraint_Settings :: struct {
	ConstraintSettings:   Constraint_Settings,
	Space:                Constraint_Space,
	AutoDetectPoint:      bool,
	Point1:               RVec3,
	SliderAxis1:          Vec3,
	NormalAxis1:          Vec3,
	Point2:               RVec3,
	SliderAxis2:          Vec3,
	NormalAxis2:          Vec3,
	LimitsMin:            f32,
	LimitsMax:            f32,
	LimitsSpringSettings: Spring_Settings,
	MaxFrictionForce:     f32,
	MotorSettings:        Motor_Settings,
}
