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
	fmt.println("joltc compound shape smoke test")

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

	sub_a := create_box_shape(vec3(0.5, 0.5, 0.5))
	sub_b := create_box_shape(vec3(0.5, 0.5, 0.5))
	defer joltc.JPC_Shape_Release(sub_a)
	defer joltc.JPC_Shape_Release(sub_b)

	subshapes := [2]joltc.SubShape_Settings {
		{Shape = sub_a, Position = vec3(-1, 0, 0), Rotation = identity_quat(), UserData = 111},
		{Shape = sub_b, Position = vec3(1, 0, 0), Rotation = identity_quat(), UserData = 222},
	}

	mutable_settings: joltc.Mutable_Compound_Shape_Settings
	joltc.JPC_MutableCompoundShapeSettings_default(&mutable_settings)
	mutable_settings.SubShapes = &subshapes[0]
	mutable_settings.SubShapesLen = len(subshapes)

	compound: ^joltc.Mutable_Compound_Shape
	err: ^joltc.String
	ok := joltc.JPC_MutableCompoundShapeSettings_Create(&mutable_settings, &compound, &err)
	if !ok || compound == nil {
		panic_with_jpc_error("JPC_MutableCompoundShapeSettings_Create failed", err)
	}
	defer joltc.JPC_Shape_Release(cast(^joltc.Shape)compound)

	idx0_shape := joltc.JPC_CompoundShape_GetSubShape_Shape(cast(^joltc.Compound_Shape)compound, 0)
	idx1_shape := joltc.JPC_CompoundShape_GetSubShape_Shape(cast(^joltc.Compound_Shape)compound, 1)

	if idx0_shape == nil || idx1_shape == nil {
		fmt.eprintln("compound subshape lookup returned nil")
		os.exit(1)
	}

	sub_c := create_box_shape(vec3(0.25, 0.25, 0.25))
	defer joltc.JPC_Shape_Release(sub_c)

	added_idx := joltc.JPC_MutableCompoundShape_AddShape(
		compound,
		vec3(0, 1, 0),
		identity_quat(),
		sub_c,
		333,
	)
	joltc.JPC_MutableCompoundShape_ModifyShape(compound, added_idx, vec3(0, 2, 0), identity_quat())
	joltc.JPC_MutableCompoundShape_RemoveShape(compound, added_idx)
	joltc.JPC_MutableCompoundShape_AdjustCenterOfMass(compound)

	body_settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&body_settings)
	body_settings.Shape = cast(^joltc.Shape)compound
	body_settings.MotionType = .DYNAMIC
	body_settings.ObjectLayer = MOVING_LAYER
	body_settings.Position = rvec3(0, 5, 0)
	body_settings.Rotation = identity_quat()

	body_id := joltc.JPC_BodyInterface_CreateAndAddBody(body_interface, &body_settings, .ACTIVATE)

	for step in 0 ..< 30 {
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

	pos := joltc.JPC_BodyInterface_GetPosition(body_interface, body_id)
	shape := joltc.JPC_BodyInterface_GetShape(body_interface, body_id)
	subtype := joltc.JPC_Shape_GetSubType(shape)

	fmt.printf("final y        = %v\n", pos.y)
	fmt.printf("shape subtype  = %v\n", subtype)
	fmt.printf("added idx      = %v\n", added_idx)

	if shape == nil {
		fmt.eprintln("body shape is nil")
		os.exit(1)
	}

	if subtype != .MUTABLE_COMPOUND {
		fmt.eprintf("unexpected subtype: %v\n", subtype)
		os.exit(1)
	}

	if !(pos.y < 5) {
		fmt.eprintln("compound body did not move")
		os.exit(1)
	}

	fmt.println("compound shape smoke test passed")

	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_id)
	joltc.JPC_JobSystemThreadPool_delete(job_system_tp)
	joltc.JPC_TempAllocatorImpl_delete(temp_allocator)
	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.shutdown()
}
