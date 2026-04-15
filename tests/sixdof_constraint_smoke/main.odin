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

absf :: proc(x: f32) -> f32 {
	if x < 0 {
		return -x
	}
	return x
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
	fmt.println("joltc sixdof constraint smoke test")

	joltc.init()

	bp_interface_fns := joltc.Broad_Phase_Layer_Interface_Fns {
		GetNumBroadPhaseLayers = get_num_broad_phase_layers,
		GetBroadPhaseLayer     = get_broad_phase_layer,
	}
	bp_interface := joltc.JPC_BroadPhaseLayerInterface_new(nil, bp_interface_fns)
	if bp_interface == nil {
		panic("JPC_BroadPhaseLayerInterface_new failed")
	}

	obj_vs_bp_fns := joltc.Object_Vs_Broad_Phase_Layer_Filter_Fns {
		ShouldCollide = should_collide_object_vs_bp,
	}
	obj_vs_bp := joltc.JPC_ObjectVsBroadPhaseLayerFilter_new(nil, obj_vs_bp_fns)
	if obj_vs_bp == nil {
		panic("JPC_ObjectVsBroadPhaseLayerFilter_new failed")
	}

	obj_pair_fns := joltc.Object_Layer_Pair_Filter_Fns {
		ShouldCollide = should_collide_object_pair,
	}
	obj_pair := joltc.JPC_ObjectLayerPairFilter_new(nil, obj_pair_fns)
	if obj_pair == nil {
		panic("JPC_ObjectLayerPairFilter_new failed")
	}

	physics := joltc.JPC_PhysicsSystem_new()
	if physics == nil {
		panic("JPC_PhysicsSystem_new failed")
	}

	joltc.JPC_PhysicsSystem_Init(physics, 1024, 0, 1024, 1024, bp_interface, obj_vs_bp, obj_pair)

	body_interface := joltc.JPC_PhysicsSystem_GetBodyInterface(physics)
	if body_interface == nil {
		panic("JPC_PhysicsSystem_GetBodyInterface failed")
	}

	temp_allocator := joltc.JPC_TempAllocatorImpl_new(10 * 1024 * 1024)
	if temp_allocator == nil {
		panic("JPC_TempAllocatorImpl_new failed")
	}

	job_system_tp := joltc.JPC_JobSystemThreadPool_new3(
		joltc.JPC_MAX_PHYSICS_JOBS,
		joltc.JPC_MAX_PHYSICS_BARRIERS,
		-1,
	)
	if job_system_tp == nil {
		panic("JPC_JobSystemThreadPool_new3 failed")
	}

	shape_a := create_box_shape(vec3(0.5, 0.5, 0.5))
	shape_b := create_box_shape(vec3(0.5, 0.5, 0.5))

	settings_a: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&settings_a)
	settings_a.Shape = shape_a
	settings_a.MotionType = .DYNAMIC
	settings_a.ObjectLayer = MOVING_LAYER
	settings_a.Position = rvec3(0, 0, 0)
	settings_a.Rotation = identity_quat()

	settings_b: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&settings_b)
	settings_b.Shape = shape_b
	settings_b.MotionType = .DYNAMIC
	settings_b.ObjectLayer = MOVING_LAYER
	settings_b.Position = rvec3(2, 0, 0)
	settings_b.Rotation = identity_quat()

	body_a := joltc.JPC_BodyInterface_CreateBody(body_interface, &settings_a)
	body_b := joltc.JPC_BodyInterface_CreateBody(body_interface, &settings_b)
	if body_a == nil || body_b == nil {
		fmt.eprintln("failed to create sixdof bodies")
		os.exit(1)
	}

	id_a := joltc.JPC_Body_GetID(body_a)
	id_b := joltc.JPC_Body_GetID(body_b)

	sixdof_settings: joltc.SixDOF_Constraint_Settings
	joltc.JPC_SixDOFConstraintSettings_default(&sixdof_settings)
	sixdof_settings.Space = .WORLD_SPACE

	sixdof_settings.Position1 = rvec3(0, 0, 0)
	sixdof_settings.AxisX1 = vec3(1, 0, 0)
	sixdof_settings.AxisY1 = vec3(0, 1, 0)

	sixdof_settings.Position2 = rvec3(2, 0, 0)
	sixdof_settings.AxisX2 = vec3(1, 0, 0)
	sixdof_settings.AxisY2 = vec3(0, 1, 0)

	// Lock everything, with translation X fixed at 2 units.
	sixdof_settings.LimitMin[0] = 2.0
	sixdof_settings.LimitMax[0] = 2.0

	sixdof_settings.LimitMin[1] = 0.0
	sixdof_settings.LimitMax[1] = 0.0
	sixdof_settings.LimitMin[2] = 0.0
	sixdof_settings.LimitMax[2] = 0.0

	sixdof_settings.LimitMin[3] = 0.0
	sixdof_settings.LimitMax[3] = 0.0
	sixdof_settings.LimitMin[4] = 0.0
	sixdof_settings.LimitMax[4] = 0.0
	sixdof_settings.LimitMin[5] = 0.0
	sixdof_settings.LimitMax[5] = 0.0

	constraint_base := joltc.JPC_SixDOFConstraintSettings_Create(&sixdof_settings, body_a, body_b)
	if constraint_base == nil {
		fmt.eprintln("JPC_SixDOFConstraintSettings_Create failed")
		os.exit(1)
	}

	constraint := cast(^joltc.SixDOFConstraint)constraint_base

	joltc.JPC_BodyInterface_AddBody(body_interface, id_a, .ACTIVATE)
	joltc.JPC_BodyInterface_AddBody(body_interface, id_b, .ACTIVATE)
	joltc.JPC_PhysicsSystem_AddConstraint(physics, constraint_base)

	start_a := joltc.JPC_BodyInterface_GetPosition(body_interface, id_a)
	start_b := joltc.JPC_BodyInterface_GetPosition(body_interface, id_b)
	start_dist := absf(f32(start_b.x - start_a.x))

	joltc.JPC_BodyInterface_SetLinearVelocity(body_interface, id_b, vec3(8, 0, 0))

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

	end_a := joltc.JPC_BodyInterface_GetPosition(body_interface, id_a)
	end_b := joltc.JPC_BodyInterface_GetPosition(body_interface, id_b)
	end_dist := absf(f32(end_b.x - end_a.x))

	translation_min := joltc.JPC_SixDOFConstraint_GetTranslationLimitsMin(constraint)
	translation_max := joltc.JPC_SixDOFConstraint_GetTranslationLimitsMax(constraint)

	free_x := joltc.JPC_SixDOFConstraint_IsFreeAxis(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_X,
	)
	free_y := joltc.JPC_SixDOFConstraint_IsFreeAxis(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_Y,
	)
	free_z := joltc.JPC_SixDOFConstraint_IsFreeAxis(
		constraint,
		joltc.SIX_DOF_CONSTRAINT_AXIS_TRANSLATION_Z,
	)

	lambda_pos := joltc.JPC_SixDOFConstraint_GetTotalLambdaPosition(constraint)
	lambda_rot := joltc.JPC_SixDOFConstraint_GetTotalLambdaRotation(constraint)

	fmt.printf("start dist       = %v\n", start_dist)
	fmt.printf("end dist         = %v\n", end_dist)
	fmt.printf(
		"translation min  = (%v, %v, %v)\n",
		translation_min.x,
		translation_min.y,
		translation_min.z,
	)
	fmt.printf(
		"translation max  = (%v, %v, %v)\n",
		translation_max.x,
		translation_max.y,
		translation_max.z,
	)
	fmt.printf("free x/y/z       = %v %v %v\n", free_x, free_y, free_z)
	fmt.printf("lambda pos       = (%v, %v, %v)\n", lambda_pos.x, lambda_pos.y, lambda_pos.z)
	fmt.printf("lambda rot       = (%v, %v, %v)\n", lambda_rot.x, lambda_rot.y, lambda_rot.z)

	if free_x {
		fmt.eprintln("translation X should not be free")
		os.exit(1)
	}

	if free_y || free_z {
		fmt.eprintln("translation Y/Z should not be free")
		os.exit(1)
	}

	if translation_min.x != 2.0 || translation_max.x != 2.0 {
		fmt.eprintf(
			"unexpected translation X limits: min=%v max=%v\n",
			translation_min.x,
			translation_max.x,
		)
		os.exit(1)
	}

	if translation_min.y != 0.0 ||
	   translation_max.y != 0.0 ||
	   translation_min.z != 0.0 ||
	   translation_max.z != 0.0 {
		fmt.eprintln("unexpected translation Y/Z limits")
		os.exit(1)
	}

	if absf(end_dist - start_dist) > 0.1 {
		fmt.eprintf(
			"sixdof constraint failed to preserve X separation: start=%v end=%v\n",
			start_dist,
			end_dist,
		)
		os.exit(1)
	}

	fmt.println("sixdof constraint smoke test passed")

	joltc.JPC_PhysicsSystem_RemoveConstraint(physics, constraint_base)

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
