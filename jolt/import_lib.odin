package joltc

when ODIN_OS == .Windows {
	foreign import joltc "system:joltc"
} else when ODIN_OS == .Darwin {
	foreign import joltc "system:joltc"
} else {
	foreign import joltc "system:joltc"
}

// ----------------------------------------------------------------------------
// Temporary ABI sanity checks
// Remove or relax these after the first successful Linux smoke test.
// ----------------------------------------------------------------------------

#assert(size_of(Vec3) == 16)
#assert(align_of(Vec3) == 16)

#assert(size_of(Vec4) == 16)
#assert(align_of(Vec4) == 16)

when JPC_DOUBLE_PRECISION {
	#assert(size_of(RVec3) == 32)
	#assert(align_of(RVec3) == 32)

	#assert(size_of(RMat44) == 80)
	#assert(align_of(RMat44) == 32)

	#assert(size_of(RShape_Cast) == 128)
	#assert(align_of(RShape_Cast) == 32)

	#assert(offset_of(RShape_Cast, Shape) == 0)
	#assert(offset_of(RShape_Cast, Scale) == 16)
	#assert(offset_of(RShape_Cast, CenterOfMassStart) == 32)
	#assert(offset_of(RShape_Cast, Direction) == 112)
} else {
	#assert(size_of(RVec3) == 16)
	#assert(align_of(RVec3) == 16)

	#assert(size_of(RMat44) == 64)
	#assert(align_of(RMat44) == 16)

	#assert(size_of(RShape_Cast) == 112)
	#assert(align_of(RShape_Cast) == 16)

	#assert(offset_of(RShape_Cast, Shape) == 0)
	#assert(offset_of(RShape_Cast, Scale) == 16)
	#assert(offset_of(RShape_Cast, CenterOfMassStart) == 32)
	#assert(offset_of(RShape_Cast, Direction) == 96)
}

#assert(size_of(Shape_Cast_Settings) == 48)
#assert(align_of(Shape_Cast_Settings) == 16)

#assert(offset_of(Shape_Cast_Settings, ActiveEdgeMode) == 0)
#assert(offset_of(Shape_Cast_Settings, CollectFacesMode) == 1)
#assert(offset_of(Shape_Cast_Settings, CollisionTolerance) == 4)
#assert(offset_of(Shape_Cast_Settings, PenetrationTolerance) == 8)
#assert(offset_of(Shape_Cast_Settings, ActiveEdgeMovementDirection) == 16)
#assert(offset_of(Shape_Cast_Settings, BackFaceModeTriangles) == 32)
#assert(offset_of(Shape_Cast_Settings, BackFaceModeConvex) == 33)
#assert(offset_of(Shape_Cast_Settings, UseShrunkenShapeAndConvexRadius) == 34)
#assert(offset_of(Shape_Cast_Settings, ReturnDeepestPoint) == 35)

#assert(size_of(Shape_Cast_Result) == 80)
#assert(align_of(Shape_Cast_Result) == 16)

#assert(offset_of(Shape_Cast_Result, ContactPointOn1) == 0)
#assert(offset_of(Shape_Cast_Result, ContactPointOn2) == 16)
#assert(offset_of(Shape_Cast_Result, PenetrationAxis) == 32)
#assert(offset_of(Shape_Cast_Result, PenetrationDepth) == 48)
#assert(offset_of(Shape_Cast_Result, SubShapeID1) == 52)
#assert(offset_of(Shape_Cast_Result, SubShapeID2) == 56)
#assert(offset_of(Shape_Cast_Result, BodyID2) == 60)
#assert(offset_of(Shape_Cast_Result, Fraction) == 64)
#assert(offset_of(Shape_Cast_Result, IsBackFaceHit) == 68)

when JPC_DOUBLE_PRECISION {
	#assert(size_of(Narrow_Phase_Query_Cast_Shape_Args) == 288)
	#assert(align_of(Narrow_Phase_Query_Cast_Shape_Args) == 32)
} else {
	#assert(size_of(Narrow_Phase_Query_Cast_Shape_Args) == 224)
	#assert(align_of(Narrow_Phase_Query_Cast_Shape_Args) == 16)
}
