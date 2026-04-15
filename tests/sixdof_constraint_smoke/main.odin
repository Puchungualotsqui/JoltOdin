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

absf :: proc(x: f32) -> f32 {
	if x < 0 {
		return -x
	}
	return x
}

main :: proc() {
	fmt.println("joltc sixdof constraint smoke test")

	joltc.init()
	defer joltc.shutdown()

	bp_interface_fns := joltc.Broad_Phase_Layer_Interface_Fns {
		GetNumBroadPhaseLayers = get_num_broad_phase_layers,
		GetBroadPhaseLayer     = get_broad_phase_layer,
	}
	bp_interface := joltc.JPC_BroadPhaseLayerInterface_new(nil, bp_interface_fns)
	if bp_interface == nil {
		fmt.eprintln("JPC_BroadPhaseLayerInterface_new failed")
		os.exit(1)
	}
	defer joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)

	obj_vs_bp_fns := joltc.Object_Vs_Broad_Phase_Layer_Filter_Fns {
		ShouldCollide = should_collide_object_vs_bp,
	}
	obj_vs_bp := joltc.JPC_ObjectVsBroadPhaseLayerFilter_new(nil, obj_vs_bp_fns)
	if obj_vs_bp == nil {
		fmt.eprintln("JPC_ObjectVsBroadPhaseLayerFilter_new failed")
		os.exit(1)
	}
	defer joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)

	obj_pair_fns := joltc.Object_Layer_Pair_Filter_Fns {
		ShouldCollide = should_collide_object_pair,
	}
	obj_pair := joltc.JPC_ObjectLayerPairFilter_new(nil, obj_pair_fns)
	if obj_pair == nil {
		fmt.eprintln("JPC_ObjectLayerPairFilter_new failed")
		os.exit(1)
	}
	defer joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)

	physics := joltc.JPC_PhysicsSystem_new()
	if physics == nil {
		fmt.eprintln("JPC_PhysicsSystem_new failed")
		os.exit(1)
	}
	defer joltc.JPC_PhysicsSystem_delete(physics)

	joltc.JPC_PhysicsSystem_Init(physics, 1024, 0, 1024, 1024, bp_interface, obj_vs_bp, obj_pair)

	body_interface := joltc.JPC_PhysicsSystem_GetBodyInterface(physics)
	if body_interface == nil {
		fmt.eprintln("JPC_PhysicsSystem_GetBodyInterface failed")
		os.exit(1)
	}

	temp_allocator := joltc.JPC_TempAllocatorImpl_new(10 * 1024 * 1024)
	if temp_allocator == nil {
		fmt.eprintln("JPC_TempAllocatorImpl_new failed")
		os.exit(1)
	}
	defer joltc.JPC_TempAllocatorImpl_delete(temp_allocator)

	job_system_tp := joltc.JPC_JobSystemThreadPool_new3(
		joltc.JPC_MAX_PHYSICS_JOBS,
		joltc.JPC_MAX_PHYSICS_BARRIERS,
		-1,
	)
	if job_system_tp == nil {
		fmt.eprintln("JPC_JobSystemThreadPool_new3 failed")
		os.exit(1)
	}
	defer joltc.JPC_JobSystemThreadPool_delete(job_system_tp)

	box_shape := create_box_shape(vec3(0.5, 0.5, 0.5))
	defer joltc.JPC_Shape_Release(box_shape)

	body_a_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&body_a_settings)
	body_a_settings.Shape = box_shape
	body_a_settings.MotionType = .DYNAMIC
	body_a_settings.ObjectLayer = MOVING_LAYER
	body_a_settings.Position = rvec3(0, 0, 0)
	body_a_settings.Rotation = identity_quat()

	body_b_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&body_b_settings)
	body_b_settings.Shape = box_shape
	body_b_settings.MotionType = .DYNAMIC
	body_b_settings.ObjectLayer = MOVING_LAYER
	body_b_settings.Position = rvec3(2, 0, 0)
	body_b_settings.Rotation = identity_quat()

	body_a_id := joltc.JPC_BodyInterface_CreateAndAddBody(
		body_interface,
		&body_a_settings,
		.ACTIVATE,
	)
	body_b_id := joltc.JPC_BodyInterface_CreateAndAddBody(
		body_interface,
		&body_b_settings,
		.ACTIVATE,
	)

	start_a := joltc.JPC_BodyInterface_GetPosition(body_interface, body_a_id)
	start_b := joltc.JPC_BodyInterface_GetPosition(body_interface, body_b_id)
	start_dist := absf(f32(start_b.x - start_a.x))

	body_lock := joltc.JPC_PhysicsSystem_GetBodyLockInterface(physics)
	if body_lock == nil {
		fmt.eprintln("JPC_PhysicsSystem_GetBodyLockInterface failed")
		os.exit(1)
	}

	lock_a := joltc.JPC_BodyLockRead_new(body_lock, body_a_id)
	if lock_a == nil || !joltc.JPC_BodyLockRead_Succeeded(lock_a) {
		fmt.eprintln("failed to read-lock body A")
		os.exit(1)
	}
	body_a_ptr := cast(^joltc.Body)joltc.JPC_BodyLockRead_GetBody(lock_a)
	joltc.JPC_BodyLockRead_delete(lock_a)

	lock_b := joltc.JPC_BodyLockRead_new(body_lock, body_b_id)
	if lock_b == nil || !joltc.JPC_BodyLockRead_Succeeded(lock_b) {
		fmt.eprintln("failed to read-lock body B")
		os.exit(1)
	}
	body_b_ptr := cast(^joltc.Body)joltc.JPC_BodyLockRead_GetBody(lock_b)
	joltc.JPC_BodyLockRead_delete(lock_b)

	if body_a_ptr == nil || body_b_ptr == nil {
		fmt.eprintln("body lock returned nil body")
		os.exit(1)
	}

	settings: joltc.SixDOF_Constraint_Settings
	joltc.JPC_SixDOFConstraintSettings_default(&settings)
	settings.Space = .WORLD_SPACE
	settings.Position1 = rvec3(0, 0, 0)
	settings.AxisX1 = vec3(1, 0, 0)
	settings.AxisY1 = vec3(0, 1, 0)
	settings.Position2 = rvec3(2, 0, 0)
	settings.AxisX2 = vec3(1, 0, 0)
	settings.AxisY2 = vec3(0, 1, 0)

	settings.LimitMin[0] = 2
	settings.LimitMax[0] = 2
	settings.LimitMin[1] = 0
	settings.LimitMax[1] = 0
	settings.LimitMin[2] = 0
	settings.LimitMax[2] = 0
	settings.LimitMin[3] = 0
	settings.LimitMax[3] = 0
	settings.LimitMin[4] = 0
	settings.LimitMax[4] = 0
	settings.LimitMin[5] = 0
	settings.LimitMax[5] = 0

	settings.MaxFriction[0] = 0
	settings.MaxFriction[1] = 0
	settings.MaxFriction[2] = 0
	settings.MaxFriction[3] = 0
	settings.MaxFriction[4] = 0
	settings.MaxFriction[5] = 0

	constraint_base := joltc.JPC_SixDOFConstraintSettings_Create(&settings, body_a_ptr, body_b_ptr)
	if constraint_base == nil {
		fmt.eprintln("JPC_SixDOFConstraintSettings_Create failed")
		os.exit(1)
	}
	constraint := cast(^joltc.SixDOFConstraint)constraint_base

	joltc.JPC_PhysicsSystem_AddConstraint(physics, constraint_base)

	joltc.JPC_BodyInterface_SetLinearVelocity(body_interface, body_b_id, vec3(8, 0, 0))

	for step in 0 ..< 120 {
		update_err := joltc.JPC_PhysicsSystem_Update(
			physics,
			1.0 / 60.0,
			1,
			temp_allocator,
			cast(^joltc.JobSystem)job_system_tp,
		)
		if update_err != joltc.PHYSICS_UPDATE_ERROR_NONE {
			fmt.eprintf("Physics update error at step %v: %v\n", step, update_err)
			os.exit(1)
		}
	}

	end_a := joltc.JPC_BodyInterface_GetPosition(body_interface, body_a_id)
	end_b := joltc.JPC_BodyInterface_GetPosition(body_interface, body_b_id)
	end_dist := absf(f32(end_b.x - end_a.x))

	limit_min_x := joltc.JPC_SixDOFConstraint_GetLimitsMin(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_X,
	)
	limit_max_x := joltc.JPC_SixDOFConstraint_GetLimitsMax(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_X,
	)
	free_x := joltc.JPC_SixDOFConstraint_IsFreeAxis(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_X,
	)
	lambda_pos := joltc.JPC_SixDOFConstraint_GetTotalLambdaPosition(constraint)
	lambda_rot := joltc.JPC_SixDOFConstraint_GetTotalLambdaRotation(constraint)

	fmt.printf("start dist  = %v\n", start_dist)
	fmt.printf("end dist    = %v\n", end_dist)
	fmt.printf("limit min x = %v\n", limit_min_x)
	fmt.printf("limit max x = %v\n", limit_max_x)
	fmt.printf("free x      = %v\n", free_x)
	fmt.printf("lambda pos  = (%v, %v, %v)\n", lambda_pos.x, lambda_pos.y, lambda_pos.z)
	fmt.printf("lambda rot  = (%v, %v, %v)\n", lambda_rot.x, lambda_rot.y, lambda_rot.z)

	if free_x {
		fmt.eprintln("translation X should not be free")
		os.exit(1)
	}

	if limit_min_x != 2 || limit_max_x != 2 {
		fmt.eprintln("unexpected sixdof X limits")
		os.exit(1)
	}

	if absf(end_dist - start_dist) > 0.1 {
		fmt.eprintf(
			"constraint failed to preserve relative X distance: start=%v end=%v\n",
			start_dist,
			end_dist,
		)
		os.exit(1)
	}

	fmt.println("sixdof constraint smoke test passed")

	// Explicit destruction order:
	// 1) remove constraint from system
	// 2) release constraint reference
	// 3) remove/destroy bodies
	joltc.JPC_PhysicsSystem_RemoveConstraint(physics, constraint_base)
	joltc.JPC_Constraint_Release(constraint_base)

	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_b_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_b_id)
	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_a_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_a_id)
}
