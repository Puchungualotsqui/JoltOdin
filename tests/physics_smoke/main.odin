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

// -----------------------------------------------------------------------------
// Broadphase / layer mapping callbacks
// -----------------------------------------------------------------------------

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
	fmt.println("joltc physics smoke test")

	// -------------------------------------------------------------------------
	// Init
	// -------------------------------------------------------------------------
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

	// -------------------------------------------------------------------------
	// Shapes
	// -------------------------------------------------------------------------
	floor_shape := create_box_shape(vec3(100, 1, 100))
	box_shape := create_box_shape(vec3(0.5, 0.5, 0.5))

	// -------------------------------------------------------------------------
	// Bodies
	// -------------------------------------------------------------------------
	floor_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&floor_settings)
	floor_settings.Shape = floor_shape
	floor_settings.MotionType = .STATIC
	floor_settings.ObjectLayer = NON_MOVING_LAYER
	floor_settings.Position = rvec3(0, -1, 0)
	floor_settings.Rotation = identity_quat()

	box_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&box_settings)
	box_settings.Shape = box_shape
	box_settings.MotionType = .DYNAMIC
	box_settings.ObjectLayer = MOVING_LAYER
	box_settings.Position = rvec3(0, 10, 0)
	box_settings.Rotation = identity_quat()

	floor_id := joltc.JPC_BodyInterface_CreateAndAddBody(
		body_interface,
		&floor_settings,
		.DONT_ACTIVATE,
	)

	box_id := joltc.JPC_BodyInterface_CreateAndAddBody(body_interface, &box_settings, .ACTIVATE)

	// -------------------------------------------------------------------------
	// Simulate
	// -------------------------------------------------------------------------
	start_pos := joltc.JPC_BodyInterface_GetPosition(body_interface, box_id)
	fmt.printf("start y = %v\n", start_pos.y)

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

			// Best-effort cleanup before exit
			joltc.JPC_BodyInterface_RemoveBody(body_interface, box_id)
			joltc.JPC_BodyInterface_DestroyBody(body_interface, box_id)
			joltc.JPC_BodyInterface_RemoveBody(body_interface, floor_id)
			joltc.JPC_BodyInterface_DestroyBody(body_interface, floor_id)

			joltc.JPC_Shape_Release(box_shape)
			joltc.JPC_Shape_Release(floor_shape)

			joltc.JPC_PhysicsSystem_delete(physics)
			joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
			joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
			joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
			joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
			joltc.JPC_TempAllocatorImpl_delete(temp_allocator)
			joltc.shutdown()
			os.exit(1)
		}
	}

	end_pos := joltc.JPC_BodyInterface_GetPosition(body_interface, box_id)
	end_vel := joltc.JPC_BodyInterface_GetLinearVelocity(body_interface, box_id)

	fmt.printf("end y   = %v\n", end_pos.y)
	fmt.printf("end vy  = %v\n", end_vel.y)

	if !(end_pos.y < start_pos.y) {
		fmt.eprintln("box did not fall")
	}

	if !(end_pos.y > -5 && end_pos.y < 2.5) {
		fmt.eprintf("box final y is unreasonable: %v\n", end_pos.y)
		os.exit(1)
	}

	fmt.println("physics smoke test passed")

	// -------------------------------------------------------------------------
	// Explicit teardown in safe order
	// -------------------------------------------------------------------------
	joltc.JPC_BodyInterface_RemoveBody(body_interface, box_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, box_id)

	joltc.JPC_BodyInterface_RemoveBody(body_interface, floor_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, floor_id)

	joltc.JPC_Shape_Release(box_shape)
	joltc.JPC_Shape_Release(floor_shape)

	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
	joltc.JPC_TempAllocatorImpl_delete(temp_allocator)

	joltc.shutdown()
}
