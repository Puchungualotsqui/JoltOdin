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
	fmt.println("joltc body lock smoke test")

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
	lock_interface := joltc.JPC_PhysicsSystem_GetBodyLockInterface(physics)

	shape := create_box_shape(vec3(0.5, 0.5, 0.5))

	settings_a: joltc.Body_Creation_Settings
	joltc.JPC_BodyCreationSettings_default(&settings_a)
	settings_a.Shape = shape
	settings_a.MotionType = .DYNAMIC
	settings_a.ObjectLayer = MOVING_LAYER
	settings_a.Position = rvec3(1, 2, 3)
	settings_a.Rotation = identity_quat()

	settings_b := settings_a
	settings_b.Position = rvec3(4, 5, 6)

	id_a := joltc.JPC_BodyInterface_CreateAndAddBody(body_interface, &settings_a, .ACTIVATE)
	id_b := joltc.JPC_BodyInterface_CreateAndAddBody(body_interface, &settings_b, .ACTIVATE)

	// Read lock
	read_lock := joltc.JPC_BodyLockRead_new(lock_interface, id_a)
	if read_lock == nil || !joltc.JPC_BodyLockRead_Succeeded(read_lock) {
		fmt.eprintln("BodyLockRead failed")
		os.exit(1)
	}
	read_body := joltc.JPC_BodyLockRead_GetBody(read_lock)
	if read_body == nil {
		fmt.eprintln("BodyLockRead_GetBody returned nil")
		os.exit(1)
	}
	read_pos := joltc.JPC_Body_GetPosition(read_body)
	fmt.printf("read lock position = (%v, %v, %v)\n", read_pos.x, read_pos.y, read_pos.z)
	joltc.JPC_BodyLockRead_delete(read_lock)

	// Write lock
	write_lock := joltc.JPC_BodyLockWrite_new(lock_interface, id_a)
	if write_lock == nil || !joltc.JPC_BodyLockWrite_Succeeded(write_lock) {
		fmt.eprintln("BodyLockWrite failed")
		os.exit(1)
	}
	write_body := joltc.JPC_BodyLockWrite_GetBody(write_lock)
	if write_body == nil {
		fmt.eprintln("BodyLockWrite_GetBody returned nil")
		os.exit(1)
	}
	joltc.JPC_Body_SetLinearVelocity(write_body, vec3(7, 8, 9))
	write_vel := joltc.JPC_Body_GetLinearVelocity(write_body)
	fmt.printf("write lock velocity = (%v, %v, %v)\n", write_vel.x, write_vel.y, write_vel.z)
	joltc.JPC_BodyLockWrite_delete(write_lock)

	// Multi read
	ids := [2]joltc.BodyID{id_a, id_b}
	multi_read := joltc.JPC_BodyLockMultiRead_new(lock_interface, &ids[0], 2)
	if multi_read == nil {
		fmt.eprintln("BodyLockMultiRead failed")
		os.exit(1)
	}
	body0_r := joltc.JPC_BodyLockMultiRead_GetBody(multi_read, 0)
	body1_r := joltc.JPC_BodyLockMultiRead_GetBody(multi_read, 1)
	if body0_r == nil || body1_r == nil {
		fmt.eprintln("BodyLockMultiRead_GetBody returned nil")
		os.exit(1)
	}
	pos0 := joltc.JPC_Body_GetPosition(body0_r)
	pos1 := joltc.JPC_Body_GetPosition(body1_r)
	fmt.printf("multi read y = %v, %v\n", pos0.y, pos1.y)
	joltc.JPC_BodyLockMultiRead_delete(multi_read)

	// Multi write
	multi_write := joltc.JPC_BodyLockMultiWrite_new(lock_interface, &ids[0], 2)
	if multi_write == nil {
		fmt.eprintln("BodyLockMultiWrite failed")
		os.exit(1)
	}
	body0_w := joltc.JPC_BodyLockMultiWrite_GetBody(multi_write, 0)
	body1_w := joltc.JPC_BodyLockMultiWrite_GetBody(multi_write, 1)
	if body0_w == nil || body1_w == nil {
		fmt.eprintln("BodyLockMultiWrite_GetBody returned nil")
		os.exit(1)
	}
	joltc.JPC_Body_SetAngularVelocity(body0_w, vec3(1, 2, 3))
	joltc.JPC_Body_SetAngularVelocity(body1_w, vec3(4, 5, 6))
	ang0 := joltc.JPC_Body_GetAngularVelocity(body0_w)
	ang1 := joltc.JPC_Body_GetAngularVelocity(body1_w)
	fmt.printf("multi write ang z = %v, %v\n", ang0.z, ang1.z)
	joltc.JPC_BodyLockMultiWrite_delete(multi_write)

	// Validate through body interface after locks released
	vel_after := joltc.JPC_BodyInterface_GetLinearVelocity(body_interface, id_a)
	ang0_after := joltc.JPC_BodyInterface_GetAngularVelocity(body_interface, id_a)
	ang1_after := joltc.JPC_BodyInterface_GetAngularVelocity(body_interface, id_b)

	if vel_after.x != 7 || vel_after.y != 8 || vel_after.z != 9 {
		fmt.eprintf(
			"linear velocity mismatch after write lock: (%v, %v, %v)\n",
			vel_after.x,
			vel_after.y,
			vel_after.z,
		)
		os.exit(1)
	}

	if ang0_after.x != 1 || ang0_after.y != 2 || ang0_after.z != 3 {
		fmt.eprintf(
			"angular velocity mismatch for body A: (%v, %v, %v)\n",
			ang0_after.x,
			ang0_after.y,
			ang0_after.z,
		)
		os.exit(1)
	}

	if ang1_after.x != 4 || ang1_after.y != 5 || ang1_after.z != 6 {
		fmt.eprintf(
			"angular velocity mismatch for body B: (%v, %v, %v)\n",
			ang1_after.x,
			ang1_after.y,
			ang1_after.z,
		)
		os.exit(1)
	}

	fmt.println("body lock smoke test passed")

	joltc.JPC_BodyInterface_RemoveBody(body_interface, id_b)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, id_b)
	joltc.JPC_BodyInterface_RemoveBody(body_interface, id_a)
	joltc.JPC_BodyInterface_DestroyBody(body_interface, id_a)
	joltc.JPC_Shape_Release(shape)
	joltc.JPC_PhysicsSystem_delete(physics)
	joltc.JPC_ObjectLayerPairFilter_delete(obj_pair)
	joltc.JPC_ObjectVsBroadPhaseLayerFilter_delete(obj_vs_bp)
	joltc.JPC_BroadPhaseLayerInterface_delete(bp_interface)
	joltc.shutdown()
}
