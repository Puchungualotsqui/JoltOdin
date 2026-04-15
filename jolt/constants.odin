package joltc

// ----------------------------------------------------------------------------
// JoltC compile-time configuration mirrored for Odin.
//
// Change these only if your JoltC build uses different flags.
// ----------------------------------------------------------------------------

JPC_OBJECT_LAYER_BITS :: 16
JPC_DOUBLE_PRECISION :: false

// ----------------------------------------------------------------------------
// Numeric constants from JoltC/Enums.h and JoltC/Functions.h
// ----------------------------------------------------------------------------

JPC_MAX_PHYSICS_JOBS :: 2048
JPC_MAX_PHYSICS_BARRIERS :: 8

JPC_DEFAULT_COLLISION_TOLERANCE :: 1.0e-4
JPC_DEFAULT_PENETRATION_TOLERANCE :: 1.0e-4
JPC_DEFAULT_CONVEX_RADIUS :: 0.05
JPC_CAPSULE_PROJECTION_SLOP :: 0.02

JPC_PI :: 3.14159265358979323846

JPC_CONTACT_POINTS_CAPACITY :: 64
