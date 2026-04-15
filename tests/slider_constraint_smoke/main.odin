package main

import "core:fmt"
import "core:os"

import joltc "../../jolt"

NON_MOVING_LAYER :: joltc.ObjectLayer(0)
MOVING_LAYER :: joltc.ObjectLayer(1)

BP_NON_MOVING :: joltc.BroadPhaseLayer(0)
BP_MOVING :: joltc.BroadPhaseLayer(1)

identity_quat :: proc() -> joltc.Quat {
	return joltc.Quat{x = 0, y = 0, z = 0, w = 1}
}

vec3 :: proc(x, y, z: f32) -> joltc.Vec3 {
	return joltc.Vec3{x = x, y = y, z = z, _w = 0}
}

rvec3 :: proc(x, y, z: f32) -> joltc.RVec3 {
	when joltc.JPC_DOUBLE_PRECISION {
		return joltc.DVec3{x = f64(x), y = f64(y), z = f64(z), _w = 0}
	} else {
		return joltc.Vec3{x = x, y = y, z = z, _w = 0}
	}
}

panic_with_jpc_error :: proc(prefix: string, err: ^joltc.String) -> ! {
	if err != nil {
		msg := joltc.JPC_String_c_str(err)
		fmt.eprintf("%s: %s\n", prefix, msg)
		joltc.JPC_String_delete(err)
	} else {
		fmt.eprintf("%s\n", prefix)
	}
	os.exit(1)
}

create_box_shape :: proc(half_extent: joltc.Vec3) -> ^joltc.Shape {
	settings: joltc.Box_Shape_Settings
	joltc.JPC_BoxShapeSettings_default(&settings)
	settings.HalfExtent = half_extent

	shape: ^joltc.Shape
	err: ^joltc.String
	ok := joltc.JPC_BoxShapeSettings_Create(&settings, &shape, &err)
	if !ok || shape == nil {
		panic_with_jpc_error("JPC_BoxShapeSettings_Create failed", err)
	}
	return shape
}

get_num_broad_phase_layers :: proc "c" (self: rawptr) -> u32 {
	return 2
}

get_broad_phase_layer :: proc "c" (
	self: rawptr,
	inLayer: joltc.ObjectLayer,
) -> joltc.BroadPhaseLayer {
	switch inLayer {
	case NON_MOVING_LAYER:
		return BP_NON_MOVING
	case MOVING_LAYER:
		return BP_MOVING
	}
	return BP_MOVING
}

should_collide_object_vs_bp :: proc "c" (
	self: rawptr,
	inLayer1: joltc.ObjectLayer,
	inLayer2: joltc.BroadPhaseLayer,
) -> bool {
	switch inLayer1 {
	case NON_MOVING_LAYER:
		return inLayer2 == BP_MOVING
	case MOVING_LAYER:
		return true
	}
	return false
}

should_collide_object_pair :: proc "c" (
	self: rawptr,
	inLayer1: joltc.ObjectLayer,
	inLayer2: joltc.ObjectLayer,
) -> bool {
	if inLayer1 == NON_MOVING_LAYER && inLayer2 == NON_MOVING_LAYER {
		return false
	}
	return true
}

main :: proc() {
	fmt.println("joltc slider constraint smoke test")

	joltc.init()

	bp_interface_fns := joltc.Broad_Phase_Layer_Interface_Fns {
		GetNumBroadPhaseLayers = get_num_broad_phase_layers,
		GetBroadPhaseLayer     = get_broad_phase_layer,
	}
	bp_interface := joltc.JPC_BroadPhaseLayerInterface_new(nil, bp_interface_fns)

	obj_vs_bp_fns := joltc.Object_Vs_Broad_Phase_Layer_Filter_Fns {
		ShouldCollide = should_collide_object_vs_bp,
	}
	obj_vs_bp := joltc.JPC_ObjectVsBroadPhaseLayerFilter_new(nil, obj_vs_bp_fns)

	obj_pair_fns := joltc.Object_Layer_Pair_Filter_Fns {
		ShouldCollide = should_collide_object_pair,
	}
	obj_pair := joltc.JPC_ObjectLayerPairFilter_new(nil, obj_pair_fns)

	physics := joltc.JPC_PhysicsSystem_new()
	joltc.JPC_PhysicsSystem_Init(physics, 1024, 0, 1024, 1024, bp_interface, obj_vs_bp, obj_pair)
	body_interface := joltc.JPC_PhysicsSystem_GetBodyInterface(physics)

	temp_allocator := joltc.JPC_TempAllocatorImpl_new(10 * 1024 * 1024)
	job_system_tp := joltc.JPC_JobSystemThreadPool_new3(
		joltc.JPC_MAX_PHYSICS_JOBS,
		joltc.JPC_MAX_PHYSICS_BARRIERS,
		-1,
	)

	shape_a := create_box_shape(vec3(0.5, 0.5, 0.5))
	shape_b := create_box_shape(vec3(0.5, 0.5, 0.5))

	settings_a: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&settings_a)
	settings_a.Shape = shape_a
	settings_a.MotionType = .DYNAMIC
	settings_a.ObjectLayer = MOVING_LAYER
	settings_a.Position = rvec3(0, 2, 0)
	settings_a.Rotation = identity_quat()

	settings_b := settings_a
	settings_b.Shape = shape_b
	settings_b.Position = rvec3(0, 2, 2)

	body_a := joltc.JPC_BodyInterface_CreateBody(body_interface, &settings_a)
	body_b := joltc.JPC_BodyInterface_CreateBody(body_interface, &settings_b)
	if body_a == nil || body_b == nil {
		fmt.eprintln("failed to create slider bodies")
		os.exit(1)
	}

	id_a := joltc.JPC_Body_GetID(body_a)
	id_b := joltc.JPC_Body_GetID(body_b)

	joltc.JPC_BodyInterface_AddBody(body_interface, id_a, .ACTIVATE)
	joltc.JPC_BodyInterface_AddBody(body_interface, id_b, .ACTIVATE)

	slider_settings: joltc.Slider_Constraint_Settings
	joltc.JPC_SliderConstraintSettings_default(&slider_settings)
	slider_settings.Space = .WORLD_SPACE
	slider_settings.AutoDetectPoint = false
	slider_settings.Point1 = rvec3(0, 2, 1)
	slider_settings.Point2 = rvec3(0, 2, 1)
	slider_settings.SliderAxis1 = vec3(0, 0, 1)
	slider_settings.SliderAxis2 = vec3(0, 0, 1)
	slider_settings.NormalAxis1 = vec3(1, 0, 0)
	slider_settings.NormalAxis2 = vec3(1, 0, 0)
	slider_settings.LimitsMin = -1.0
	slider_settings.LimitsMax = 1.0

	constraint := joltc.JPC_SliderConstraintSettings_Create(&slider_settings, body_a, body_b)
	if constraint == nil {
		fmt.eprintln("JPC_SliderConstraintSettings_Create failed")
		os.exit(1)
	}

	joltc.JPC_PhysicsSystem_AddConstraint(physics, cast(^joltc.Constraint)constraint)

	joltc.JPC_SliderConstraint_SetMotorState(constraint, .POSITION)
	joltc.JPC_SliderConstraint_SetTargetPosition(constraint, 0.25)

	motor_state := joltc.JPC_SliderConstraint_GetMotorState(constraint)
	target_pos := joltc.JPC_SliderConstraint_GetTargetPosition(constraint)

	for step in 0 ..< 120 {
		err := joltc.JPC_PhysicsSystem_Update(
			physics,
			1.0 / 60.0,
			1,
			temp_allocator,
			cast(^joltc.JobSystem)job_system_tp,
		)
		if err != joltc.PHYSICS_UPDATE_ERROR_NONE {
			fmt.eprintf("physics update failed at step %v: %v\n", step, err)
			os.exit(1)
		}
	}

	lambda_pos := joltc.JPC_SliderConstraint_GetTotalLambdaPosition(constraint)
	lambda_pos_limits := joltc.JPC_SliderConstraint_GetTotalLambdaPositionLimits(constraint)
	lambda_rot := joltc.JPC_SliderConstraint_GetTotalLambdaRotation(constraint)
	lambda_motor := joltc.JPC_SliderConstraint_GetTotalLambdaMotor(constraint)

	fmt.printf("motor state      = %v\n", motor_state)
	fmt.printf("target position  = %v\n", target_pos)
	fmt.printf("lambda pos       = (%v, %v)\n", lambda_pos.x, lambda_pos.y)
	fmt.printf("lambda pos limit = %v\n", lambda_pos_limits)
	fmt.printf("lambda rot       = (%v, %v, %v)\n", lambda_rot.x, lambda_rot.y, lambda_rot.z)
	fmt.printf("lambda motor     = %v\n", lambda_motor)

	if motor_state != joltc.Motor_State.POSITION {
		fmt.eprintln("slider motor state roundtrip failed")
		os.exit(1)
	}

	if target_pos != 0.25 {
		fmt.eprintf("slider target position mismatch: %v\n", target_pos)
		os.exit(1)
	}

	fmt.println("slider constraint smoke test passed")

	joltc.JPC_PhysicsSystem_RemoveConstraint(physics, cast(^joltc.Constraint)constraint)
	joltc.JPC_BodyInterface_RemoveBody(body_interface, id_b)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, id_b)
	joltc.JPC_BodyInterface_RemoveBody(body_interface, id_a)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, id_a)
	joltc.JPC_Shape_Release(shape_b)
	joltc.JPC_Shape_Release(shape_a)
	joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
	joltc.JPC_TempAllocatorImpl_delete(temp_allocator)
	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.shutdown()
}
