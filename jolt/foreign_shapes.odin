package joltc

import "core:c"

when ODIN_OS == .Windows {
	foreign import joltc "system:joltc"
} else when ODIN_OS == .Darwin {
	foreign import joltc "system:joltc"
} else {
	foreign import joltc "system:joltc"
}


// ----------------------------------------------------------------------------
// VertexList == Array<Float3>
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_VertexList_new :: proc(storage: ^Float3, len: c.size_t) -> ^Vertex_List ---
	JPC_VertexList_delete :: proc(object: ^Vertex_List) ---
}

// ----------------------------------------------------------------------------
// IndexedTriangleList == Array<IndexedTriangle>
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_IndexedTriangleList_new :: proc(storage: ^Indexed_Triangle, len: c.size_t) -> ^Indexed_Triangle_List ---
	JPC_IndexedTriangleList_delete :: proc(object: ^Indexed_Triangle_List) ---
}

// ----------------------------------------------------------------------------
// Shape
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_Shape_GetRefCount :: proc(self: ^Shape) -> u32 ---
	JPC_Shape_AddRef :: proc(self: ^Shape) ---
	JPC_Shape_Release :: proc(self: ^Shape) ---

	JPC_Shape_GetUserData :: proc(self: ^Shape) -> u64 ---
	JPC_Shape_SetUserData :: proc(self: ^Shape, userData: u64) ---

	JPC_Shape_GetType :: proc(self: ^Shape) -> Shape_Type ---
	JPC_Shape_GetSubType :: proc(self: ^Shape) -> Shape_SubType ---

	JPC_Shape_GetSubShapeUserData :: proc(self: ^Shape, inSubShapeID: SubShapeID) -> u64 ---

	JPC_Shape_GetCenterOfMass :: proc(self: ^Shape) -> Vec3 ---
	JPC_Shape_GetVolume :: proc(self: ^Shape) -> f32 ---
}

// ----------------------------------------------------------------------------
// CompoundShape
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_CompoundShape_GetSubShape_Shape :: proc(self: ^Compound_Shape, inIdx: c.uint) -> ^Shape ---

	JPC_CompoundShape_GetSubShapeIndexFromID :: proc(self: ^Compound_Shape, inSubShapeID: SubShapeID, outRemainder: ^SubShapeID) -> u32 ---
}

// ----------------------------------------------------------------------------
// MutableCompoundShape
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_MutableCompoundShape_AddShape :: proc(self: ^Mutable_Compound_Shape, inPosition: Vec3, inRotation: Quat, inShape: ^Shape, inUserData: u32) -> c.uint ---

	JPC_MutableCompoundShape_RemoveShape :: proc(self: ^Mutable_Compound_Shape, inIndex: c.uint) ---

	JPC_MutableCompoundShape_ModifyShape :: proc(self: ^Mutable_Compound_Shape, inIndex: c.uint, inPosition: Vec3, inRotation: Quat) ---

	JPC_MutableCompoundShape_ModifyShape2 :: proc(self: ^Mutable_Compound_Shape, inIndex: c.uint, inPosition: Vec3, inRotation: Quat, inShape: ^Shape) ---

	JPC_MutableCompoundShape_AdjustCenterOfMass :: proc(self: ^Mutable_Compound_Shape) ---
}
