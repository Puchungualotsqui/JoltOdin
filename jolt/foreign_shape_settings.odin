package joltc

when ODIN_OS == .Windows {
	foreign import joltc "system:joltc"
} else when ODIN_OS == .Darwin {
	foreign import joltc "system:joltc"
} else {
	foreign import joltc "system:joltc"
}


// ----------------------------------------------------------------------------
// Settings defaults
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_TriangleShapeSettings_default :: proc(object: ^Triangle_Shape_Settings) ---
	JPC_MeshShapeSettings_default :: proc(object: ^Mesh_Shape_Settings) ---
	JPC_BoxShapeSettings_default :: proc(object: ^Box_Shape_Settings) ---
	JPC_SphereShapeSettings_default :: proc(object: ^Sphere_Shape_Settings) ---
	JPC_CapsuleShapeSettings_default :: proc(object: ^Capsule_Shape_Settings) ---
	JPC_CylinderShapeSettings_default :: proc(object: ^Cylinder_Shape_Settings) ---
	JPC_ConvexHullShapeSettings_default :: proc(object: ^ConvexHull_Shape_Settings) ---

	JPC_SubShapeSettings_default :: proc(object: ^SubShape_Settings) ---

	JPC_StaticCompoundShapeSettings_default :: proc(object: ^Static_Compound_Shape_Settings) ---
	JPC_MutableCompoundShapeSettings_default :: proc(object: ^Mutable_Compound_Shape_Settings) ---
}

// ----------------------------------------------------------------------------
// Settings create
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_TriangleShapeSettings_Create :: proc(self: ^Triangle_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_MeshShapeSettings_Create :: proc(self: ^Mesh_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_BoxShapeSettings_Create :: proc(self: ^Box_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_SphereShapeSettings_Create :: proc(self: ^Sphere_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_CapsuleShapeSettings_Create :: proc(self: ^Capsule_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_CylinderShapeSettings_Create :: proc(self: ^Cylinder_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_ConvexHullShapeSettings_Create :: proc(self: ^ConvexHull_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_StaticCompoundShapeSettings_Create :: proc(self: ^Static_Compound_Shape_Settings, outShape: ^^Shape, outError: ^^String) -> bool ---

	JPC_MutableCompoundShapeSettings_Create :: proc(self: ^Mutable_Compound_Shape_Settings, outShape: ^^Mutable_Compound_Shape, outError: ^^String) -> bool ---
}
