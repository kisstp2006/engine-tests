# Engine tests

The engine's 2D and 3D parts and their APIs, each tried out in a scene of its
own. `scenes/menu.json` is the main scene, and Escape comes back to it from
any of them (`scripts/back_to_menu.flux`, an autoload).

**The game starts with an intro**, as a console does: an orchestra warming up
in the dark, the blue sky and its ribbons coming in from black, *Fluxion* fading
in on the right and out again, and the menu coming in over the same sky. Any of
the keys that open a test skips it. Opening a test darkens everything to black
before its scene comes; a test comes in from black, and Escape takes it back
out to black and to the menu (`scripts/back_to_menu.flux`).

**The menu** is laid out the way a console's is: five categories across, each
with its mark - a triangle, a circle, a cross, a square and a diamond - and the chosen
one's tests down from it, those before the chosen test above the marks and
those after it below. Left and right change category, up and down the test,
Enter, Space or a pad's A opens it, and a click picks or opens one; everything
glides to its place. Behind it, `shaders/xmb_waves.shader` rolls three
ribbons of light over a sky whose colours change with the category; the marks
are `xmb_icon.shader`, the light behind the chosen test `xmb_glow.shader`
and the black it comes in from and goes out to `xmb_veil.shader`.
Its sounds - the intro's orchestra, a tick to move, another to change
category, a chime to open, a swell as it comes up and a quiet drone under it -
are made from nothing by
`tools/make_sounds.py`: `python3 tools/make_sounds.py sfx` writes them again.
The whole menu is `scripts/menu.flux`.

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
| `2d_tiles` | A `TileMap` painted by a script cell by cell (`paintTile`, `setTile`, `tileAt`, `Cell.mirrored`) from `tiles/garden.tileset` - a stone wall, a pond ringed with sand, a brick hut floored with planks, a path - and by hand, with a flood fill the script does itself; the walls are solid, as the set says, and its `speed` data layer slows the walker on the water and the sand (`tileDataAt`). The walker is an `AnimatedSprite2D` whose frames the script cuts from a sheet (`newSpriteFrames`, `addFrameRegion`) and keeps in the player's files (`saveSpriteFrames`), on a `CharacterBody2D` | Arrows or WASD walk; 1 to 8 choose the brush, the left button paints, the right grass, M mirrors, F fills, R lays a new garden |
| `2d_tweens_timers_sound` | A `Timer` making stars that a tween drops, turns and shrinks, a beep from an `AudioPlayer`, tweens there and back for ever | Watch and listen |
| `3d_shapes` | The five `PrimitiveMesh3D` shapes, each drawn with a `.mat3d` its `Material3D` names: lit, unshaded, see-through with both sides drawn, textured; the sun; a camera going round | Left and right arrows turn the camera |
| `3d_mesh_files` | `MeshInstance3D` drawing a torus and a pyramid read from `.mesh` files | - |
| `3d_cameras` | `projectRayOrigin`/`projectRayNormal` picking, `unprojectPosition` putting a name over what is picked, `makeCurrent3D`, a camera's projection | Click a shape; C changes the camera, O its projection |
| `3d_hierarchy` | A planet hanging from a turning pivot and a moon from the planet, `lookAt3D`, `quat` slerp, a tween of a 3D position | - |
| `3d_render_live` | The renderer changed as it runs, a setting a row: the debug views (`setDebugView3D`), `setScreenSpaceAa`, `setMsaa3d`, `setScale3d`, `setShadowFilter`, the shadows and fog effects (`setEffect3D`), the `Environment`'s SSAO, SSR, glow, tone curve and exposure, and the time of day under a `Sky3D` with clouds; a `ReflectionProbe3D`, a `Decal`, a lamp in a `FogVolume` and sparks to see them on; the frame's cost under the rows | W and S choose a row, A and D change it, Space runs the day; arrows turn the camera |
| `3d_render_view` | A `Camera3D` with a `RenderView` drawing into a picture a `Sprite` with a `ViewTexture` shows | - |
| `3d_lights` | Spheres from smooth to rough, plastic and metal; a sun, two `PointLight3D`s - one bobbing - and a `SpotLight3D`; a box with a normal map and one that glows; an `Environment` with ACES tone, glow and fog | Left and right arrows turn the camera |
| `3d_shadows` | Shadows: a low sun through four cascades; a spot light with a `size`, its shadows softening away from what casts them; a point light casting every way as it bobs between pillars; a spot light through a window `cookie`; a fence's thin shadows, floating spheres, a spinning box | Left and right arrows turn the camera |
| `3d_lightmap` | Baked light: a room lit by a ceiling lamp baked whole and a sun through its window, its light bounced - the red and green walls colour the boxes and the floor near them; a gold ball that moves, lit by the probes. Baked with `--bake-lightmaps res://scenes/3d_lightmap.json` | None |
| `3d_shader` | `waves.shader3d`, a surface of its own the engine lights, in `waves.mat3d`, which gives it its numbers; a sphere drawn with the material as it is, and a capsule whose entity gives numbers of its own over the material's | - |
| `3d_models` | Models as scenes: `lantern.glb` read as it is; `props.fbx` and `suzanne.blend` turned into glTF by the editor's Blender into `.fluxion/imported`; an instance of each, its meshes, materials and pictures named after it | - |
| `3d_skinning` | `skinned.glb`: a column bent on the GPU by a `Skeleton3D` of three bones, a cube hanging from the top bone by a `BoneAttachment3D`, and the model's two animations played by its root's `AnimationPlayer`, each change fading over its `default_blend`; its `.import` loops them | B and W play Bend and Wave, S shows the bones; the buttons do the same |
| `3d_physics` | 3D physics: crates, balls, a capsule, a cylinder and a pyramid made convex from its `.mesh` falling on a floor; a ramp whose `Collider3D` is its own triangles; a fence that is a collider with nothing drawn; a `CharacterBody3D` walked with `moveAndSlide`, leaning on what it walks into with `applyImpulse3D`; an `Area3D` lit while a body is in it; a `RayCast3D` going round; a click pushing a body (`castRay3D`), the touches between bodies counted (`contactsBegun3D`), and a picked `Area3D` button dropping crates made by a script | Arrows or WASD walk, Space jumps; click a body to push it, the red button to drop a crate |
| `3d_joints` | `Joint3D`s: a chain of ball joints from a beam with a lamp at its end, a bridge of planks on hinges between two posts - its last plank held a second time by a joint on a collider of its own - and a door on a hinge with limits; the skinned column given a `RigidBody3D`, a `Collider3D` and a `PhysicalBone3D` for each bone by the script as it starts, each held to the one below: a ragdoll | Space throws a ball, D pushes the door, R lets the column fall and gives it back to its animation |
| `3d_navigation` | Navigation: two `NavigationRegion3D`s, West and East, cut where they meet at x = 0 (`bake_bounds_*`, `scope = .scene`) and baked by the editor's `--bake-navigation` from the floor, the walls, the crates, a pillar and a ramp up to a platform; one map across both. Four `CharacterBody3D`s with a `NavigationAgent3D` walk to the corners across from them round what is in the way (`nextPathPosition`) and out of each other's way (`setAgentVelocity`, `velocity_computed`); a one-way `NavigationLink3D` drops them off the platform (`link_reached`); a kinematic cart with a `NavigationObstacle3D` that affects ways goes through the narrow east doorway and closes it while it is there; the mesh, the links, the obstacle and the ways drawn by `setDebugView("navigation", true)` | Click the floor to send them all there; N shows or hides the mesh |
| `3d_extras` | The rest of 3D: rain - a `Particles3D` of streaks (`align_to_velocity`, `stretch`) over the yard, already falling (`preprocess`) - and glowing sparks from a lamp; two `FogVolume`s, a box of drifting mist with noise and a ball of haze, fogging what is seen through them; `Label3D`s - an EXIT sign on the wall with an outline, one over the mist facing the camera; `Sprite3D`s - a star turning only about its up (`y_only`, `alpha_cut`) and an added glow over the lamp; an arcade cabinet whose screen is a `Sprite3D` with a `ViewTexture` showing a `World3D` of its own - its floor, spinning box, sun and pink sky seen by no other camera; a beeping `AudioPlayer` with an `AudioSpatial3D` going round the yard, heard from the camera, its script drawing where it is with `debugLine3D`, `debugSphere3D`, `debugArrow3D` and `debugText3D` | Arrows turn the camera |
| `3d_csg` | Solids joined, cut and met: a room that is one `CSGShape3D` group - four walls joined, an arched door (a box and a cylinder cut out), two pointed windows (a `polygon` - an outline drawn out - stood upright), a window, a round window, a low arch and three slits cut from them, their sides in the cutters' wood - drawn and collided with as one mesh (`Collider3D` `mesh`); an L-shaped platform, a `polygon` too; a die that is a box met with a ball (`intersect`), turning, its mesh made once; a stone block a moving ball scoops into, its mesh made again each frame; a hollow cut in the ground. A capsule walks in through the door | Arrows or WASD walk, Space jumps |
| `3d_stress` | A heavy scene to measure by: four hundred balls of 30 720 triangles each (`models/dense_ball.glb`) drawn at coarser levels of detail as they get further off, six hundred boxes drawn together, a sun casting shadows and twenty-four lamps, the camera going round. Run with `--stats report.json --vsync disabled` for what a frame costs | Arrows turn the camera |

**Apps and framework**, the fifth category, tries the engine as a framework
for programs as much as for games:

| Scene | What it tries | Try |
| --- | --- | --- |
| `app_notes` | A notes program made of the interface: a searched list, a title and words to edit, buttons; the notes kept as JSON in the player's files, the text size in a config file, the clipboard, the window's title, how long ago each note changed in the player's own words | Type, click; Ctrl+S saves, Ctrl+N makes a new note |
| `app_dashboard` | Live numbers drawn by a script with a `Drawing2D`: frame times as a line, frames a second as bars, a gauge, the date and time in the player's words, a public repository's numbers asked of GitHub without the frame waiting (`web.get`), and a picture of the frame kept in the player's files and shown again (`images.capture`) | R asks the web again, P keeps a picture |
| `fw_systems` | The frame's machinery: three `Timer`s, a clock of the game's own (`time.clock`) running a day a minute, lamps in a group switched by one call (`callGroup`), a task stepping with `await` and a signal it rings, frames awaited, a deferred call; pausing with a pause menu that runs only when paused (`Processing`), and the speed of time | P pauses, 1, 2 and 3 set the speed, L switches the lamps |
| `fw_scene_io` | Scenes in and out: a click makes an instance of `scenes/parts/flower.json`; S saves the garden - its own branch of the world - as a JSON scene and a CBOR one (`saveScene` with `.{ .root = garden, .format = .cbor }`), shows the JSON and both sizes, and keeps a struct of the script's own in a data file (`writeData`); L reads the garden back (`readScene`); B reads another scene in the background with its progress (`loadInBackground`, `loadProgress`, `loadStatus`) | Click, S, L, C, B, then Enter |
| `fw_input` | Every input event as the game hears it (`input`), the actions as bars with what to press for them (`actionNames`, `describeAction`); R rebinds `jump` to the next press and keeps it in the player's files (`bindAction`, `saveInputMap`, `loadInputMap`), N makes an action of the game's own (`addAction`); controllers' sticks, triggers and buttons; touches, with the mouse standing in; the pointer's shapes | R, N, T, C; a controller |
| `fw_sound` | The project's buses - Music, Effects and Ambience into Master - with faders and mutes (`setBusVolumeDb`, `setBusMute`); music paused, sought and pitched with where it is drawn; wind under it; a bee heard where it flies (`AudioSpatial2D`, an `AudioListener2D`); a string plucked by an `AudioPlayer` made for each note and taken away when it has rung | Tab, Up, Down, M; P, Left, Right, K, L; B; click a key or Space |
| `fw_net` | A board shared over the network: host a game, join the one on this machine, or find one on the LAN and join it (`net.host`, `net.join`, `net.search`, `net.servers`); every pointer sent each frame on the sequenced channel, stamps and lines on the reliable one; who joined and left and each peer's ping | H in one window, J in another; click, T |
| `fw_flux_language` | The Flux language part by part, each checked on screen: values and types, structs with `extends`, enums and quoted names (`.@"1"`), optionals and errors, lists, maps and strings, vectors, closures, tasks awaited and signals heard | - |

Most of the newer scenes are written by `tools/make_scenes.py` (with
`tools/scenes.py`), so they come out the same each time; their pictures by
`tools/make_tiles.py` and their sounds by `tools/make_lab_sounds.py`.

The pictures, the sound, the two meshes, the four models, the shader and the
materials in `art/`, `sfx/`, `models/`, `shaders/` and `materials/` were made
for these tests. `fonts/NotoSans-Regular.ttf` is Noto Sans, under
the SIL Open Font License.
