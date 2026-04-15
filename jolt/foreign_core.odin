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
// Core bootstrap / utility bindings
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_RegisterDefaultAllocator :: proc() ---
	JPC_FactoryInit :: proc() ---
	JPC_FactoryDelete :: proc() ---
	JPC_RegisterTypes :: proc() ---
	JPC_UnregisterTypes :: proc() ---
}

// ----------------------------------------------------------------------------
// TempAllocatorImpl
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_TempAllocatorImpl_new :: proc(size: c.uint) -> ^TempAllocatorImpl ---
	JPC_TempAllocatorImpl_delete :: proc(object: ^TempAllocatorImpl) ---
}

// ----------------------------------------------------------------------------
// JobSystem
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_JobSystemThreadPool_new2 :: proc(inMaxJobs: c.uint, inMaxBarriers: c.uint) -> ^JobSystemThreadPool ---
	JPC_JobSystemThreadPool_new3 :: proc(inMaxJobs: c.uint, inMaxBarriers: c.uint, inNumThreads: c.int) -> ^JobSystemThreadPool ---
	JPC_JobSystemThreadPool_delete :: proc(object: ^JobSystemThreadPool) ---

	JPC_JobSystemSingleThreaded_new :: proc(inMaxJobs: c.uint) -> ^JobSystemSingleThreaded ---
	JPC_JobSystemSingleThreaded_delete :: proc(object: ^JobSystemSingleThreaded) ---
}

// ----------------------------------------------------------------------------
// String
// ----------------------------------------------------------------------------

foreign joltc {
	JPC_String_delete :: proc(self: ^String) ---
	JPC_String_c_str :: proc(self: ^String) -> cstring ---
}

// ----------------------------------------------------------------------------
// Small lifecycle helpers
// ----------------------------------------------------------------------------

init :: proc() {
	JPC_RegisterDefaultAllocator()
	JPC_FactoryInit()
	JPC_RegisterTypes()
}

shutdown :: proc() {
	JPC_UnregisterTypes()
	JPC_FactoryDelete()
}
