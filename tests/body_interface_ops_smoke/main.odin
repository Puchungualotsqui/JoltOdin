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

create_sphere_shape :: proc(radius: f32) -> ^joltc.Shape {
	settings: joltc.Sphere_Shape_Settings
	joltc.JPC_SphereShapeSettings_default(&settings)
	settings.Radius = radius

	shape: ^joltc.Shape
	err: ^joltc.String
	ok := joltc.JPC_SphereShapeSettings_Create(&settings, &shape, &err)
	if !ok || shape == nil {
		panic_with_jpc_error("JPC_SphereShapeSettings_Create failed", err)
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
	fmt.println("joltc body interface ops smoke test")

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

	box_shape := create_box_shape(vec3(0.5, 0.5, 0.5))
	sphere_shape := create_sphere_shape(0.75)

	settings: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&settings)
	settings.Shape = box_shape
	settings.MotionType = .DYNAMIC
	settings.ObjectLayer = MOVING_LAYER
	settings.Position = rvec3(1, 2, 3)
	settings.Rotation = identity_quat()

	body_id := joltc.JPC_BodyInterface_CreateAndAddBody(body_interface, &settings, .ACTIVATE)

	// Position / rotation
	joltc.JPC_BodyInterface_SetPosition(body_interface, body_id, rvec3(4, 5, 6), .ACTIVATE)
	got_pos := joltc.JPC_BodyInterface_GetPosition(body_interface, body_id)

	rot := joltc.Quat {
		x = 0,
		y = 0,
		z = 0.70710677,
		w = 0.70710677,
	}
	joltc.JPC_BodyInterface_SetRotation(body_interface, body_id, rot, .ACTIVATE)
	got_rot := joltc.JPC_BodyInterface_GetRotation(body_interface, body_id)

	// Velocities
	joltc.JPC_BodyInterface_SetLinearVelocity(body_interface, body_id, vec3(1, 2, 3))
	joltc.JPC_BodyInterface_SetAngularVelocity(body_interface, body_id, vec3(4, 5, 6))
	got_lin_vel := joltc.JPC_BodyInterface_GetLinearVelocity(body_interface, body_id)
	got_ang_vel := joltc.JPC_BodyInterface_GetAngularVelocity(body_interface, body_id)

	// Friction / restitution / gravity / user data / motion quality
	joltc.JPC_BodyInterface_SetFriction(body_interface, body_id, 0.25)
	joltc.JPC_BodyInterface_SetRestitution(body_interface, body_id, 0.75)
	joltc.JPC_BodyInterface_SetGravityFactor(body_interface, body_id, 0.5)
	joltc.JPC_BodyInterface_SetUserData(body_interface, body_id, 123456789)
	joltc.JPC_BodyInterface_SetMotionQuality(body_interface, body_id, .LINEAR_CAST)

	got_friction := joltc.JPC_BodyInterface_GetFriction(body_interface, body_id)
	got_restitution := joltc.JPC_BodyInterface_GetRestitution(body_interface, body_id)
	got_gravity := joltc.JPC_BodyInterface_GetGravityFactor(body_interface, body_id)
	got_user_data := joltc.JPC_BodyInterface_GetUserData(body_interface, body_id)
	got_motion_quality := joltc.JPC_BodyInterface_GetMotionQuality(body_interface, body_id)

	// Shape swap
	joltc.JPC_BodyInterface_SetShape(body_interface, body_id, sphere_shape, true, .ACTIVATE)
	got_shape := joltc.JPC_BodyInterface_GetShape(body_interface, body_id)
	got_shape_type := joltc.JPC_Shape_GetSubType(got_shape)

	// Other body interface operations
	joltc.JPC_BodyInterface_SetMotionType(body_interface, body_id, .KINEMATIC, .ACTIVATE)
	got_motion_type := joltc.JPC_BodyInterface_GetMotionType(body_interface, body_id)

	joltc.JPC_BodyInterface_SetUseManifoldReduction(body_interface, body_id, true)
	got_use_mr := joltc.JPC_BodyInterface_GetUseManifoldReduction(body_interface, body_id)

	joltc.JPC_BodyInterface_InvalidateContactCache(body_interface, body_id)

	fmt.printf("position      = (%v, %v, %v)\n", got_pos.x, got_pos.y, got_pos.z)
	fmt.printf("rotation      = (%v, %v, %v, %v)\n", got_rot.x, got_rot.y, got_rot.z, got_rot.w)
	fmt.printf("linear vel    = (%v, %v, %v)\n", got_lin_vel.x, got_lin_vel.y, got_lin_vel.z)
	fmt.printf("angular vel   = (%v, %v, %v)\n", got_ang_vel.x, got_ang_vel.y, got_ang_vel.z)
	fmt.printf("friction      = %v\n", got_friction)
	fmt.printf("restitution   = %v\n", got_restitution)
	fmt.printf("gravity       = %v\n", got_gravity)
	fmt.printf("user data     = %v\n", got_user_data)
	fmt.printf("motion quality= %v\n", got_motion_quality)
	fmt.printf("shape subtype = %v\n", got_shape_type)
	fmt.printf("motion type   = %v\n", got_motion_type)
	fmt.printf("use MR        = %v\n", got_use_mr)

	if got_pos.x != 4 || got_pos.y != 5 || got_pos.z != 6 {
		fmt.eprintln("position roundtrip failed")
		os.exit(1)
	}

	if got_lin_vel.x != 1 || got_lin_vel.y != 2 || got_lin_vel.z != 3 {
		fmt.eprintln("linear velocity roundtrip failed")
		os.exit(1)
	}

	if got_ang_vel.x != 4 || got_ang_vel.y != 5 || got_ang_vel.z != 6 {
		fmt.eprintln("angular velocity roundtrip failed")
		os.exit(1)
	}

	if got_friction != 0.25 {
		fmt.eprintln("friction roundtrip failed")
		os.exit(1)
	}

	if got_restitution != 0.75 {
		fmt.eprintln("restitution roundtrip failed")
		os.exit(1)
	}

	if got_gravity != 0.5 {
		fmt.eprintln("gravity factor roundtrip failed")
		os.exit(1)
	}

	if got_user_data != 123456789 {
		fmt.eprintln("user data roundtrip failed")
		os.exit(1)
	}

	if got_motion_quality != joltc.Motion_Quality.LINEAR_CAST {
		fmt.eprintln("motion quality roundtrip failed")
		os.exit(1)
	}

	if got_shape_type != joltc.Shape_SubType.SPHERE {
		fmt.eprintln("shape swap failed")
		os.exit(1)
	}

	if got_motion_type != joltc.Motion_Type.KINEMATIC {
		fmt.eprintln("motion type roundtrip failed")
		os.exit(1)
	}

	if !got_use_mr {
		fmt.eprintln("use manifold reduction roundtrip failed")
		os.exit(1)
	}

	fmt.println("body interface ops smoke test passed")

	joltc.JPC_BodyInterface_RemoveBody(body_interface, body_id)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, body_id)
	joltc.JPC_Shape_Release(sphere_shape)
	joltc.JPC_Shape_Release(box_shape)
	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.shutdown()
}
