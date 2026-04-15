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

#assert(size_of(DVec3) == 32)
#assert(align_of(DVec3) == 32)

#assert(size_of(Quat) == 16)
#assert(align_of(Quat) == 16)

#assert(size_of(Mat44) == 64)
#assert(align_of(Mat44) == 16)

#assert(size_of(DMat44) == 96)
#assert(align_of(DMat44) == 32)

#assert(size_of(Color) == 4)
#assert(align_of(Color) == 4)

when JPC_DOUBLE_PRECISION {
	#assert(size_of(RVec3) == size_of(DVec3))
	#assert(align_of(RVec3) == align_of(DVec3))
	#assert(size_of(RMat44) == size_of(DMat44))
	#assert(align_of(RMat44) == align_of(DMat44))
} else {
	#assert(size_of(RVec3) == size_of(Vec3))
	#assert(align_of(RVec3) == align_of(Vec3))
	#assert(size_of(RMat44) == size_of(Mat44))
	#assert(align_of(RMat44) == align_of(Mat44))
}
