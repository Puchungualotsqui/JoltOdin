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

Collide_State :: struct {
	hit_count:  i32,
	last_body:  joltc.BodyID,
	last_depth: f32,
}

collide_reset :: proc "c" (self: rawptr) {
	s := cast(^Collide_State)self
	s.hit_count = 0
	s.last_body = joltc.BodyID(0)
	s.last_depth = 0
}

collide_add_hit :: proc "c" (
	self: rawptr,
	base: ^joltc.CollideShapeCollector,
	result: ^joltc.Collide_Shape_Result,
) {
	s := cast(^Collide_State)self
	s.hit_count += 1
	s.last_body = result.BodyID2
	s.last_depth = result.PenetrationDepth
	joltc.JPC_CollideShapeCollector_UpdateEarlyOutFraction(base, 0)
}

rmat44_identity_at :: proc(pos: joltc.RVec3) -> joltc.RMat44 {
	when joltc.JPC_DOUBLE_PRECISION {
		p := cast(joltc.DVec3)pos
		p._w = 1

		return joltc.DMat44 {
			col = [3]joltc.Vec4 {
				joltc.Vec4{x = 1, y = 0, z = 0, w = 0},
				joltc.Vec4{x = 0, y = 1, z = 0, w = 0},
				joltc.Vec4{x = 0, y = 0, z = 1, w = 0},
			},
			col3 = p,
		}
	} else {
		p := cast(joltc.Vec3)pos
		p._w = 1

		return joltc.Mat44 {
			col = [3]joltc.Vec4 {
				joltc.Vec4{x = 1, y = 0, z = 0, w = 0},
				joltc.Vec4{x = 0, y = 1, z = 0, w = 0},
				joltc.Vec4{x = 0, y = 0, z = 1, w = 0},
			},
			col3 = p,
		}
	}
}

main :: proc() {
	fmt.println("joltc collide shape smoke test")

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
	query := joltc.JPC_PhysicsSystem_GetNarrowPhaseQuery(physics)

	temp_allocator := joltc.JPC_TempAllocatorImpl_new(10 * 1024 * 1024)
	job_system_tp := joltc.JPC_JobSystemThreadPool_new3(
		joltc.JPC_MAX_PHYSICS_JOBS,
		joltc.JPC_MAX_PHYSICS_BARRIERS,
		-1,
	)

	target_shape := create_box_shape(vec3(1, 1, 1))
	query_shape := create_box_shape(vec3(0.75, 0.75, 0.75))

	target_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&target_settings)
	target_settings.Shape = target_shape
	target_settings.MotionType = .STATIC
	target_settings.ObjectLayer = MOVING_LAYER
	target_settings.Position = rvec3(0, 0, 0)
	target_settings.Rotation = identity_quat()

	target_id := joltc.JPC_BodyInterface_CreateAndAddBody(
		body_interface,
		&target_settings,
		.DONT_ACTIVATE,
	)

	err := joltc.JPC_PhysicsSystem_Update(
		physics,
		1.0 / 60.0,
		1,
		temp_allocator,
		cast(^joltc.JobSystem)job_system_tp,
	)
	if err != joltc.PHYSICS_UPDATE_ERROR_NONE {
		fmt.eprintln("initial update failed")
		os.exit(1)
	}

	state := Collide_State{}
	collector_fns := joltc.Collide_Shape_Collector_Fns {
		Reset  = collide_reset,
		AddHit = collide_add_hit,
	}
	collector := joltc.JPC_CollideShapeCollector_new(&state, collector_fns)

	args: joltc.Narrow_Phase_Query_Collide_Shape_Args
	args.Shape = query_shape
	args.ShapeScale = vec3(1, 1, 1)
	args.CenterOfMassTransform = rmat44_identity_at(rvec3(0, 0.5, 0))
	joltc.JPC_CollideShapeSettings_default(&args.Settings)
	args.BaseOffset = rvec3(0, 0, 0)
	args.Collector = collector

	joltc.JPC_NarrowPhaseQuery_CollideShape(query, &args)

	fmt.printf("hit count    = %v\n", state.hit_count)
	fmt.printf("body id      = %v\n", state.last_body)
	fmt.printf("penetration  = %v\n", state.last_depth)

	if state.hit_count < 1 {
		fmt.eprintln("expected at least one collide-shape hit")
		os.exit(1)
	}

	if state.last_body != target_id {
		fmt.eprintf(
			"collide-shape hit wrong body: got %v expected %v\n",
			state.last_body,
			target_id,
		)
		os.exit(1)
	}

	if !(state.last_depth >= 0) {
		fmt.eprintf("penetration depth invalid: %v\n", state.last_depth)
		os.exit(1)
	}

	fmt.println("collide shape smoke test passed")

	joltc.JPC_CollideShapeCollector_delete(collector)
	joltc.JPC_BodyInterface_RemoveBody(body_interface, target_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, target_id)
	joltc.JPC_Shape_Release(query_shape)
	joltc.JPC_Shape_Release(target_shape)
	joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
	joltc.JPC_TempAllocatorImpl_delete(temp_allocator)
	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.shutdown()
}
