package joltc

when ODIN_OS == .Windows {
	foreign import joltc "system:joltc"
} else when ODIN_OS == .Darwin {
	foreign import joltc "system:joltc"
} else {
	foreign import joltc "system:joltc"
}


// ----------------------------------------------------------------------------
// NarrowPhaseQuery
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_NarrowPhaseQuery_CastRay :: proc(self: ^NarrowPhaseQuery, args: ^Narrow_Phase_Query_Cast_Ray_Args) -> bool ---

	JPC_ShapeCastSettings_default :: proc(object: ^Shape_Cast_Settings) ---

	JPC_NarrowPhaseQuery_CastShape :: proc(self: ^NarrowPhaseQuery, args: ^Narrow_Phase_Query_Cast_Shape_Args) ---

	JPC_CollideShapeSettings_default :: proc(object: ^Collide_Shape_Settings) ---

	JPC_NarrowPhaseQuery_CollideShape :: proc(self: ^NarrowPhaseQuery, args: ^Narrow_Phase_Query_Collide_Shape_Args) ---
}
