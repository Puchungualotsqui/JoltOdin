# joltc Odin bindings

This package provides Odin bindings for the `JoltC` C wrapper around Jolt Physics.

The bindings are currently focused on the rigid-body core needed for real engine integration on Linux / Unix-like systems, with runtime validation across multiple JoltC build configurations.

## Status

The currently tested subset is working.

Validated areas:

- Jolt init / shutdown
- broad phase layer interface
- object-vs-broadphase filter
- object layer pair filter
- primitive shape creation
- body creation / add / remove / destroy
- physics stepping
- ray casting
- contact listener callbacks
- one constraint path
- tested configurations:
  - default
  - double precision
  - 32-bit object layer

Test suite:

- `tests/physics_smoke`
- `tests/raycast_smoke`
- `tests/contact_listener_smoke`
- `tests/constraint_smoke`

Runner:

- `jolt/test-odin-all-flags.sh`

## Layout

- `constants.odin` – build-time configuration mirrored on Odin side
- `enums.odin` – enum and constant mirrors
- `types_*.odin` – POD struct mirrors and callback/settings types
- `opaque_handles.odin` – opaque foreign handle declarations
- `foreign_*.odin` – raw foreign imported procedures
- `import_lib.odin` – foreign import setup

## Initialization and shutdown

All usage must be bracketed by:

- `joltc.init()`
- `joltc.shutdown()`

`shutdown()` must only happen after all live physics objects are gone.

## Ownership rules

These are the important current ownership conventions for the validated subset.

### Shapes

Shapes created through shape settings create functions, e.g.

- `JPC_BoxShapeSettings_Create`
- `JPC_SphereShapeSettings_Create`

return shape pointers that must later be released with:

- `JPC_Shape_Release(shape)`

Do not raw-delete shapes.

### Bodies

Bodies created and added to the world should be cleaned up in this order:

1. `JPC_BodyInterface_RemoveBody(...)`
2. `JPC_BodyInterface_DestroyBody(...)`

That is the cleanup path used by the passing tests.

### Constraints

For the currently validated path:

1. create the constraint
2. add it to the physics system
3. remove it from the physics system
4. do **not** manually destroy it afterward in the tested flow

The bindings currently expose both delete-style and refcount-style constraint functions, which makes ownership less obvious than it should be. The tested behavior is to remove the constraint from the physics system and not manually delete it in the smoke test path.

This should be cleaned up later if the constraint API is expanded further.

### Callback objects

Objects created for callback bridges, such as:

- contact listener
- filters
- collectors

should be deleted explicitly with their matching delete procedures after they are no longer registered or used.

For example:

- unregister listener from physics system first
- then delete listener object

## Supported build configurations

The Odin side mirrors the same config as JoltC through `constants.odin`.

Currently tested:

- `JPC_DOUBLE_PRECISION :: false`, `JPC_OBJECT_LAYER_BITS :: 16`
- `JPC_DOUBLE_PRECISION :: true`, `JPC_OBJECT_LAYER_BITS :: 16`
- `JPC_DOUBLE_PRECISION :: false`, `JPC_OBJECT_LAYER_BITS :: 32`

If the C library and Odin constants disagree, ABI mismatches are possible.

## Running tests

From the repository root:

```bash
./jolt/test-odin-all-flags.sh
```

This script rebuilds JoltC, updates the Odin-side config constants, builds the Odin tests, and runs them across all supported configurations.

## Debug rendering

Debug-renderer-related APIs are conditional in upstream Jolt and may be gated by `JPH_DEBUG_RENDERER`.

These bindings treat those paths as optional and they are not part of the currently validated core subset.

## Intended usage

This package exposes the raw binding layer.

A higher-level public Odin API can sit on top of it and should be preferred by engine/game code, so that gameplay code does not have to manage low-level JoltC details directly.

## Notes

These bindings are currently validated against the JoltC setup in this repository and the pinned JoltPhysics submodule version used there.
