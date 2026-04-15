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
	fmt.println("joltc constraint smoke test")

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

	box_shape_a := create_box_shape(vec3(0.5, 0.5, 0.5))
	box_shape_b := create_box_shape(vec3(0.5, 0.5, 0.5))

	body_a_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&body_a_settings)
	body_a_settings.Shape = box_shape_a
	body_a_settings.MotionType = .DYNAMIC
	body_a_settings.ObjectLayer = MOVING_LAYER
	body_a_settings.Position = rvec3(0, 5, 0)
	body_a_settings.Rotation = identity_quat()

	body_b_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&body_b_settings)
	body_b_settings.Shape = box_shape_b
	body_b_settings.MotionType = .DYNAMIC
	body_b_settings.ObjectLayer = MOVING_LAYER
	body_b_settings.Position = rvec3(0, 8, 0)
	body_b_settings.Rotation = identity_quat()

	body_a := joltc.JPC_BodyInterface_CreateBody(body_interface, &body_a_settings)
	if body_a == nil {
		fmt.eprintln("CreateBody for body A failed")
		os.exit(1)
	}

	body_b := joltc.JPC_BodyInterface_CreateBody(body_interface, &body_b_settings)
	if body_b == nil {
		fmt.eprintln("CreateBody for body B failed")
		os.exit(1)
	}

	body_a_id := joltc.JPC_Body_GetID(body_a)
	body_b_id := joltc.JPC_Body_GetID(body_b)

	joltc.JPC_BodyInterface_AddBody(body_interface, body_a_id, .ACTIVATE)
	joltc.JPC_BodyInterface_AddBody(body_interface, body_b_id, .ACTIVATE)

	dist_settings: joltc.Distance_Constraint_Settings
	joltc.JPC_DistanceConstraintSettings_default(&dist_settings)
	dist_settings.Space = .WORLD_SPACE
	dist_settings.Point1 = rvec3(0, 5, 0)
	dist_settings.Point2 = rvec3(0, 8, 0)
	dist_settings.MinDistance = 3.0
	dist_settings.MaxDistance = 3.0

	constraint := joltc.JPC_DistanceConstraintSettings_Create(&dist_settings, body_a, body_b)
	if constraint == nil {
		fmt.eprintln("JPC_DistanceConstraintSettings_Create failed")
		os.exit(1)
	}

	joltc.JPC_PhysicsSystem_AddConstraint(physics, cast(^joltc.Constraint)constraint)

	start_a := joltc.JPC_BodyInterface_GetPosition(body_interface, body_a_id)
	start_b := joltc.JPC_BodyInterface_GetPosition(body_interface, body_b_id)
	start_dist := start_b.y - start_a.y

	for step in 0 ..< 240 {
		err := joltc.JPC_PhysicsSystem_Update(
			physics,
			1.0 / 60.0,
			1,
			temp_allocator,
			cast(^joltc.JobSystem)job_system_tp,
		)

		if err != joltc.PHYSICS_UPDATE_ERROR_NONE {
			fmt.eprintf("Physics update error at step %v: %v\n", step, err)
			os.exit(1)
		}
	}

	end_a := joltc.JPC_BodyInterface_GetPosition(body_interface, body_a_id)
	end_b := joltc.JPC_BodyInterface_GetPosition(body_interface, body_b_id)
	end_dist := end_b.y - end_a.y

	fmt.printf("start dist = %v\n", start_dist)
	fmt.printf("end dist   = %v\n", end_dist)

	if !(end_dist > 2.5 && end_dist < 3.5) {
		fmt.eprintf("distance constraint did not preserve expected separation: %v\n", end_dist)
		os.exit(1)
	}

	fmt.println("constraint smoke test passed")

	joltc.JPC_PhysicsSystem_RemoveConstraint(physics, cast(^joltc.Constraint)constraint)

	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_b_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_b_id)

	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_a_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_a_id)

	joltc.JPC_Shape_Release(box_shape_b)
	joltc.JPC_Shape_Release(box_shape_a)

	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
	joltc.JPC_TempAllocatorImpl_delete(temp_allocator)

	joltc.shutdown()
}
