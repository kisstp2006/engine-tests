# Engine tests

The engine's 2D and 3D parts and their APIs, each tried out in a scene of its
own. `scenes/menu.json` is the main scene: each button opens a test, and
Escape comes back to it from any of them (`scripts/back_to_menu.flux`, an
autoload).

Run it with the engine's runtime, or open it in the editor:

```bash
fluxion-runtime --root path/to/engine-tests
fluxion-runtime --root path/to/engine-tests --backend vulkan --frames 60 --capture shot.png
fluxion-editor --root path/to/engine-tests --scene res://scenes/3d_shadows.json
```

`--backend` is `gl`, `vulkan`, and on Windows `d3d11` or `d3d12`. To capture one
scene, make a copy whose `project.fluxion` names it as `application.main_scene`,
with a `user_folder` of its own. `.fluxion/imported/` holds `props.fbx` and
`suzanne.blend` as the editor's Blender turned them into glTF, so the runtime
reads them on a machine with no Blender.

| Scene | What it tries | Try |
| --- | --- | --- |
| `2d_sprites` | Sprites whole and in part, turned, mirrored and tinted; layers; an additive glow; an `Appearance` tinting its children; `Text2D` with an outline, wrapping and markup; a `Drawing2D` drawn by a script | Move the pointer: the star follows it |
| `2d_physics` | Static colliders, a ramp, a one-way platform, rigid crates and balls, a `CharacterBody2D` moved with `moveAndSlide`, an `Area2D` counting what is in it | A/D or the arrows walk, Space jumps; left click drops a crate, right click a ball |
| `2d_interface` | Button, check box, slider, progress bar, line edit and rich text in containers, every signal heard by a method of `ui_demo.flux` | Click, drag, type |
| `2d_lights_particles` | An ambient light, two point lights with shadows from occluders, a fountain, smoke, an unshaded sign | Move the pointer: the lamp follows it; left click lets off a burst |
| `2d_tweens_timers_sound` | A `Timer` making stars that a tween drops, turns and shrinks, a beep from an `AudioPlayer`, tweens there and back for ever | Watch and listen |
| `3d_shapes` | The five `PrimitiveMesh3D` shapes, each drawn with a `.mat3d` its `Material3D` names: lit, unshaded, see-through with both sides drawn, textured; the sun; a camera going round | Left and right arrows turn the camera |
| `3d_mesh_files` | `MeshInstance3D` drawing a torus and a pyramid read from `.mesh` files | - |
| `3d_cameras` | `projectRayOrigin`/`projectRayNormal` picking, `unprojectPosition` putting a name over what is picked, `makeCurrent3D`, a camera's projection | Click a shape; C changes the camera, O its projection |
| `3d_hierarchy` | A planet hanging from a turning pivot and a moon from the planet, `lookAt3D`, `quat` slerp, a tween of a 3D position | - |
| `3d_render_view` | A `Camera3D` with a `RenderView` drawing into a picture a `Sprite` with a `ViewTexture` shows | - |
| `3d_lights` | Spheres from smooth to rough, plastic and metal; a sun, two `PointLight3D`s - one bobbing - and a `SpotLight3D`; a box with a normal map and one that glows; an `Environment` with ACES tone, glow and fog | Left and right arrows turn the camera |
| `3d_shadows` | Shadows: a low sun through four cascades; a spot light with a `size`, its shadows softening away from what casts them; a point light casting every way as it bobs between pillars; a spot light through a window `cookie`; a fence's thin shadows, floating spheres, a spinning box | Left and right arrows turn the camera |
| `3d_lightmap` | Baked light: a room lit by a ceiling lamp baked whole and a sun through its window, its light bounced - the red and green walls colour the boxes and the floor near them; a gold ball that moves, lit by the probes. Baked with `--bake-lightmaps res://scenes/3d_lightmap.json` | None |
| `3d_shader` | `waves.shader3d`, a surface of its own the engine lights, in `waves.mat3d`, which gives it its numbers; a sphere drawn with the material as it is, and a capsule whose entity gives numbers of its own over the material's | - |
| `3d_models` | Models as scenes: `lantern.glb` read as it is; `props.fbx` and `suzanne.blend` turned into glTF by the editor's Blender into `.fluxion/imported`; an instance of each, its meshes, materials and pictures named after it | - |
| `3d_skinning` | `skinned.glb`: a column bent on the GPU by a `Skeleton3D` of three bones, a cube hanging from the top bone by a `BoneAttachment3D`, and the model's two animations played by its root's `AnimationPlayer`, each change fading over its `default_blend`; its `.import` loops them | B and W play Bend and Wave, S shows the bones; the buttons do the same |
| `3d_physics` | 3D physics: crates, balls, a capsule, a cylinder and a pyramid made convex from its `.mesh` falling on a floor; a ramp whose `Collider3D` is its own triangles; a fence that is a collider with nothing drawn; a `CharacterBody3D` walked with `moveAndSlide`, leaning on what it walks into with `applyImpulse3D`; an `Area3D` lit while a body is in it; a `RayCast3D` going round; a click pushing a body (`castRay3D`), the touches between bodies counted (`contactsBegun3D`), and a picked `Area3D` button dropping crates made by a script | Arrows or WASD walk, Space jumps; click a body to push it, the red button to drop a crate |
| `3d_navigation` | Navigation: two `NavigationRegion3D`s, West and East, cut where they meet at x = 0 (`bake_bounds_*`, `scope = .scene`) and baked by the editor's `--bake-navigation` from the floor, the walls, the crates, a pillar and a ramp up to a platform; one map across both. Four `CharacterBody3D`s with a `NavigationAgent3D` walk to the corners across from them round what is in the way (`nextPathPosition`) and out of each other's way (`setAgentVelocity`, `velocity_computed`); a one-way `NavigationLink3D` drops them off the platform (`link_reached`); a kinematic cart with a `NavigationObstacle3D` that affects ways goes through the narrow east doorway and closes it while it is there; the mesh, the links, the obstacle and the ways drawn by `setDebugView("navigation", true)` | Click the floor to send them all there; N shows or hides the mesh |
| `3d_extras` | The rest of 3D: rain - a `Particles3D` of streaks (`align_to_velocity`, `stretch`) over the yard, already falling (`preprocess`) - and glowing sparks from a lamp; two `FogVolume`s, a box of drifting mist with noise and a ball of haze, fogging what is seen through them; `Label3D`s - an EXIT sign on the wall with an outline, one over the mist facing the camera; `Sprite3D`s - a star turning only about its up (`y_only`, `alpha_cut`) and an added glow over the lamp; an arcade cabinet whose screen is a `Sprite3D` with a `ViewTexture` showing a `World3D` of its own - its floor, spinning box, sun and pink sky seen by no other camera; a beeping `AudioPlayer` with an `AudioSpatial3D` going round the yard, heard from the camera, its script drawing where it is with `debugLine3D`, `debugSphere3D`, `debugArrow3D` and `debugText3D` | Arrows turn the camera |

The pictures, the sound, the two meshes, the four models, the shader and the
materials in `art/`, `sfx/`, `models/`, `shaders/` and `materials/` were made
for these tests. `fonts/NotoSans-Regular.ttf` is Noto Sans, under
the SIL Open Font License.
