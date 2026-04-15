package joltc

import "core:c"

// ----------------------------------------------------------------------------
// Shape settings
// ----------------------------------------------------------------------------

Triangle_Shape_Settings :: struct {
	UserData:     u64,
	Density:      f32,
	V1:           Vec3,
	V2:           Vec3,
	V3:           Vec3,
	ConvexRadius: f32,
}

Mesh_Shape_Settings :: struct {
	UserData:            u64,
	TriangleVertices:    ^Float3,
	TriangleVerticesLen: c.size_t,
	IndexedTriangles:    ^Indexed_Triangle,
	IndexedTrianglesLen: c.size_t,
}

Box_Shape_Settings :: struct {
	UserData:     u64,
	Density:      f32,
	HalfExtent:   Vec3,
	ConvexRadius: f32,
}

Sphere_Shape_Settings :: struct {
	UserData: u64,
	Density:  f32,
	Radius:   f32,
}

Capsule_Shape_Settings :: struct {
	UserData:             u64,
	Density:              f32,
	Radius:               f32,
	HalfHeightOfCylinder: f32,
}

Cylinder_Shape_Settings :: struct {
	UserData:     u64,
	Density:      f32,
	HalfHeight:   f32,
	Radius:       f32,
	ConvexRadius: f32,
}

ConvexHull_Shape_Settings :: struct {
	UserData:             u64,
	Density:              f32,
	Points:               ^Vec3,
	PointsLen:            c.size_t,
	MaxConvexRadius:      f32,
	MaxErrorConvexRadius: f32,
	HullTolerance:        f32,
}

Static_Compound_Shape_Settings :: struct {
	UserData:     u64,
	SubShapes:    ^SubShape_Settings,
	SubShapesLen: c.size_t,
}

Mutable_Compound_Shape_Settings :: struct {
	UserData:     u64,
	SubShapes:    ^SubShape_Settings,
	SubShapesLen: c.size_t,
}
