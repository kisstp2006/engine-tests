#!/usr/bin/env python3
"""make_scenes.py: the test scenes made by script, written into scenes/ -
`python3 tools/make_scenes.py` from the project's folder. Each is made the
same each time: see `scenes.py`."""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from scenes import Scene, camera2d, control, label, panel, screen, script  # noqa: E402

FOLDER = os.path.join(os.path.dirname(__file__), "..", "scenes")


def flux_language():
    s = Scene("fw_flux_language")
    script(s, "Tour", "flux_tour.flux")
    panel(s, "The Flux language",
          "Each part of the language tried as the scene starts and checked: values, lists and maps, text, "
          "structs and extends, enums and switch, optionals, errors, closures, signals, vectors, JSON, and "
          "tasks awaited. Green passed, red failed. The code is scripts/flux_tour.flux.", width=430)
    page = screen(s, "Page")
    margin = s.add("Margin", page, Control=control("grow", "grow"),
                   MarginContainer={"margin": {"left": 470, "right": 24, "top": 18, "bottom": 18}})
    column = s.add("Column", margin, Control=control("grow", "grow"), BoxContainer={"separation": 10})
    s.add("Summary", column, Control=control("grow", 28), ThemeOverride={"override_font_size": True, "font_size": 16},
          RichText={"text": "Checking..."})
    columns = s.add("Columns", column, Control=control("grow", "grow"),
                    BoxContainer={"direction": "horizontal", "separation": 24})
    for side in ("Left", "Right"):
        s.add(side, columns, Control=control("grow", "grow"), ThemeOverride={"override_font_size": True, "font_size": 14},
              RichText={"text": ""})
    return s


def notes_app():
    s = Scene("app_notes")
    script(s, "Notes", "notes_app.flux")
    panel(s, "A notes program",
          "A program made of the engine's interface, not a game: notes kept as JSON in the player's files, "
          "the text size in a config file, the clipboard, the window's title, and how long ago each changed "
          "in the player's words. Ctrl+S saves, Ctrl+N makes a new one. The code is scripts/notes_app.flux.", width=430)
    page = screen(s, "Page")
    margin = s.add("Margin", page, Control=control("grow", "grow"),
                   MarginContainer={"margin": {"left": 24, "right": 24, "top": 150, "bottom": 24}})
    window = s.add("Window", margin, Control=control("grow", "grow"), PanelContainer={},
                   BoxContainer={"direction": "horizontal", "separation": 14})
    side = s.add("Side", window, Control=control(300, "grow"), BoxContainer={"separation": 8})
    s.add("Search", side, Control=control("grow", 36), LineEdit={"placeholder_text": "Search"})
    s.add("New", side, Control=control("grow", 36), Button={"text": "New note"})
    scroll = s.add("Scroll", side, Control=control("grow", "grow"), ScrollContainer={})
    s.add("List", scroll, Control=control("grow"), BoxContainer={"separation": 4})
    editor = s.add("Editor", window, Control=control("grow", "grow"), BoxContainer={"separation": 8})
    s.add("TitleField", editor, Control=control("grow", 40), ThemeOverride={"override_font_size": True, "font_size": 20},
          LineEdit={"placeholder_text": "Title"})
    s.add("Body", editor, Control=control("grow", "grow"), ThemeOverride={"override_font_size": True, "font_size": 16},
          LineEdit={"multiline": True, "placeholder_text": "Write here"})
    row = s.add("Buttons", editor, Control=control("grow", 36), BoxContainer={"direction": "horizontal", "separation": 8})
    for name, text in (("Save", "Save"), ("Copy", "Copy"), ("Paste", "Paste"), ("Delete", "Delete")):
        s.add(name, row, Control=control(110, 36), Button={"text": text})
    s.add("TextSizeLabel", row, Control=control(120, 36), Label={"text": "Text size", "vertical_alignment": "center"})
    s.add("TextSize", row, Control=control(180, 36), Slider={"value": 16.0, "min": 10.0, "max": 32.0})
    label(s, "Status", editor, "", font_size=13)
    return s


def dashboard():
    s = Scene("app_dashboard")
    camera2d(s)
    s.add("Board", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/dashboard.flux"})
    panel(s, "A dashboard",
          "Live numbers drawn by a script with a Drawing2D: frame times, frames a second, a gauge, the date and "
          "the time in the player's words, a repository's numbers asked of the web without the frame waiting, "
          "and a picture of the frame saved and shown again. R asks the web again, P keeps a picture.", width=410)
    return s


def systems_lab():
    s = Scene("fw_systems")
    camera2d(s)
    s.add("Lab", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/systems_lab.flux"})
    for name, seconds in (("Beat half", 0.5), ("Beat one", 1.0), ("Beat two", 2.0)):
        s.add(name, Timer={"wait_time": seconds, "autostart": True})
    for i in range(5):
        s.add(f"Lamp {i}", Transform2D={"x": -540.0 + i * 70.0, "y": 50.0}, Sprite={"texture": "res://art/glow.png", "width": 90.0, "height": 90.0, "blend": "additive"},
              Script={"source": "res://scripts/lamp.flux"})
    s.add("Paused", Transform2D={"x": 0.0, "y": -10.0}, Processing={"mode": "when_paused"},
          Text2D={"text": "PAUSED  -  P goes on", "font": "res://fonts/NotoSans-Regular.ttf", "size": 44.0, "alignment": "center",
                  "outline_size": 3.0, "visible": False, "layer": 20},
          Script={"source": "res://scripts/pause_menu.flux"})
    panel(s, "The frame's machinery",
          "Timers at three beats, a clock of the game's own running a day a minute, lamps in a group switched by "
          "one call, a task stepping with await, a signal heard, frames awaited and a call deferred. P pauses: "
          "all of it waits while the pause menu, which runs only when paused, breathes. 1, 2 and 3 set the speed.", width=520)
    return s


def flower():
    s = Scene("parts/flower")
    s.add("Flower", Transform2D={}, Sprite={"texture": "res://art/star.png", "width": 44.0, "height": 44.0, "layer": 1},
          Script={"source": "res://scripts/flower.flux"})
    return s


def scene_io():
    s = Scene("fw_scene_io")
    camera2d(s)
    s.add("Io", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/scene_io.flux"})
    s.add("Garden", Transform2D={})
    panel(s, "Scenes in and out",
          "A click plants a flower, an instance of scenes/parts/flower.json. S saves the garden, its own branch "
          "of the world, as a JSON scene and a CBOR one and keeps numbers in a data file; L reads it back, C clears "
          "it, B reads another scene in the background with its progress, and Enter opens it.", width=520)
    return s


def tiles():
    s = Scene("2d_tiles")
    camera2d(s)
    s.add("Garden", Transform2D={"x": -640.0, "y": -360.0},
          TileMap={"tile_set": "res://tiles/garden.tileset", "layer": -1}, Drawing2D={},
          Script={"source": "res://scripts/tiles_lab.flux"})
    s.add("Walker", Transform2D={"x": -112.0, "y": 104.0, "scale_x": 1.5, "scale_y": 1.5}, Sprite={"layer": 1},
          AnimatedSprite2D={}, CharacterBody2D={},
          Collider2D={"shape": "circle", "radius": 11.0}, Script={"source": "res://scripts/tile_walker.flux"})
    panel(s, "Tiles and an animated sprite",
          "A tile map painted by a script, cell by cell, and by hand: 1 to 8 choose the brush, the buttons paint, "
          "M mirrors, F fills a patch. The walls stop the walker, an AnimatedSprite2D whose frames the script cuts "
          "from a sheet, and the water slows it, as its tile set says.", width=430)
    return s


def v3(x, y, z):
    return {"x": float(x), "y": float(y), "z": float(z)}


def rgba(r, g, b, a=1.0):
    return {"r": float(r), "g": float(g), "b": float(b), "a": float(a)}


def render_live():
    s = Scene("3d_render_live")
    m = "res://materials/3d_render_live"
    s.add("Camera", Transform3D={"position": v3(0, 3.5, 10)}, Camera3D={"fov": 1.0471976, "current": True},
          Script={"source": "res://scripts/orbit_camera.flux"}, exports={"radius": 10.5, "height": 3.2, "speed": 0.1})
    s.add("Sun", Transform3D={}, DirectionalLight3D={"energy": 2.2, "shadow": True})
    s.add("Environment", Environment={"background": "color", "tonemap": "aces", "exposure": 1.0, "glow": True,
                                      "glow_threshold": 1.2, "ssao": True, "ssr": True, "ambient_energy": 0.3},
          Sky3D={"cloud_coverage": 0.35})
    s.add("Floor", Transform3D={"position": v3(0, -0.25, 0)}, MeshInstance3D={},
          PrimitiveMesh3D={"size": v3(22, 0.5, 22)}, Material3D={"material": f"{m}/floor.mat3d"})
    for i, (name, mat) in enumerate([("Chrome", "chrome"), ("Gold", "gold"), ("Red", "red"), ("Chalk", "chalk")]):
        s.add(f"{name} ball", Transform3D={"position": v3(-3 + i * 2, 0.8, 0)}, MeshInstance3D={},
              PrimitiveMesh3D={"shape": "sphere", "radius": 0.8}, Material3D={"material": f"{m}/{mat}.mat3d"})
    # Blocks close together, for the occlusion in their corners.
    for i, (x, z, h) in enumerate([(-4.5, -3, 2.5), (-3.3, -3.4, 1.4), (-4.2, -4.4, 1.0), (3.5, -3.5, 3.0)]):
        s.add(f"Block {i + 1}", Transform3D={"position": v3(x, h / 2, z)}, MeshInstance3D={},
              PrimitiveMesh3D={"size": v3(1.1, h, 1.1)}, Material3D={"material": f"{m}/stone.mat3d"})
    s.add("Glowing bar", Transform3D={"position": v3(0, 0.25, -3.5)}, MeshInstance3D={},
          PrimitiveMesh3D={"size": v3(4, 0.25, 0.25)}, Material3D={"material": f"{m}/glow.mat3d"})
    s.add("Probe", Transform3D={"position": v3(0, 1.5, 0)}, ReflectionProbe3D={"extents": v3(11, 4, 11), "update": "realtime"})
    # Turned to look down: a decal is cast along its own -z.
    s.add("Mark", Transform3D={"position": v3(0, 0.1, 3), "rotation": {"x": -0.70710678, "y": 0.0, "z": 0.0, "w": 0.70710678}}, Decal={"texture": "res://art/star.png", "size": v3(2.6, 2.6, 1.0),
          "color": rgba(1.0, 0.85, 0.3)})
    # A lamp in a patch of fog, sparks rising from it.
    s.add("Lamp", Transform3D={"position": v3(4, 1.6, 2.5)}, MeshInstance3D={},
          PrimitiveMesh3D={"shape": "sphere", "radius": 0.18}, Material3D={"material": f"{m}/lamp.mat3d"},
          PointLight3D={"color": rgba(1.0, 0.75, 0.45), "energy": 6.0, "range": 7.0, "shadow": True})
    s.add("Mist", Transform3D={"position": v3(4, 1.2, 2.5)}, FogVolume={"size": v3(3.5, 2.2, 3), "shape": "ellipsoid", "density": 0.07,
          "edge_fade": 0.6, "noise_strength": 0.7, "wind": v3(0.3, 0.05, 0.1)})
    s.add("Sparks", Transform3D={"position": v3(4, 1.6, 2.5)}, Particles3D={"amount": 160, "lifetime": 1.6,
          "emission_shape": "sphere", "emission_radius": 0.15, "direction": v3(0, 1, 0), "spread": 0.6,
          "speed_min": 0.6, "speed_max": 1.6, "gravity": v3(0, 0.4, 0), "size": 0.03, "color": rgba(1.0, 0.7, 0.3)})
    s.add("Lab", Script={"source": "res://scripts/render_lab.flux"})
    _, box = panel(s, "The renderer, live",
                   "The renderer changed as it runs: what is drawn, antialiasing, the 3D world's scale, shadows, "
                   "the Environment's effects, the tone curve and the time of day under a Sky3D, with a reflection "
                   "probe, a decal, a lamp in fog and sparks to see them on.", width=380)
    s.add("Settings", box, Control=control(380), ThemeOverride={"override_font_size": True, "font_size": 13},
          Label={"text": ""})
    return s


def input_lab():
    s = Scene("fw_input")
    camera2d(s)
    s.add("Lab", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/input_lab.flux"})
    panel(s, "Input, actions and rebinding",
          "Every event as the game hears it, the actions as bars, a ball on left, right and jump. R rebinds jump "
          "to the next press, kept for the next run; N makes an action of the game's own; T has the mouse stand "
          "in for a finger; C changes the pointer.", width=560)
    return s


def sound_lab():
    s = Scene("fw_sound")
    camera2d(s)
    s.add("Lab", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/sound_lab.flux"})
    s.add("Listener", Transform2D={"y": 120.0}, AudioListener2D={})
    s.add("Music", AudioPlayer={"clip": "res://sfx/lab_music.wav", "autoplay": True, "loop": True, "bus": "Music"})
    s.add("Wind", AudioPlayer={"clip": "res://sfx/lab_wind.wav", "autoplay": True, "loop": True, "bus": "Ambience",
                               "volume_db": -6.0})
    s.add("Bee", Transform2D={"x": 520.0, "y": 120.0}, AudioPlayer={"clip": "res://sfx/lab_hum.wav", "autoplay": True,
          "loop": True, "bus": "Effects", "volume_db": -4.0}, AudioSpatial2D={"max_distance": 900.0})
    panel(s, "Sound, mixed",
          "Buses with faders and mutes, music to pause, seek and pitch, wind under it, a bee heard where it flies, "
          "and a string plucked by a player made for each note.", width=520)
    return s


def joints():
    s = Scene("3d_joints")
    m = "res://materials/3d_joints"
    down = {"x": -0.70710678, "y": 0.0, "z": 0.0, "w": 0.70710678}
    s.add("Camera", Transform3D={"position": v3(0, 4, 11)}, Camera3D={"fov": 1.0471976, "current": True},
          Script={"source": "res://scripts/orbit_camera.flux"}, exports={"radius": 11.0, "height": 4.0, "speed": 0.06})
    s.add("Sun", Transform3D={"rotation": {"x": -0.4368643, "y": 0.2379317, "z": 0.1210044, "w": 0.8590088}},
          DirectionalLight3D={"energy": 1.6, "shadow": True})
    s.add("Environment", Environment={"background": "color", "tonemap": "aces", "ssao": True, "ambient_energy": 0.35},
          Sky3D={})
    s.add("Floor", Transform3D={"position": v3(0, -0.25, 0)}, MeshInstance3D={}, PrimitiveMesh3D={"size": v3(24, 0.5, 24)},
          Material3D={"material": f"{m}/floor.mat3d"}, RigidBody3D={"type": "static"}, Collider3D={"extents": v3(12, 0.25, 12)})

    # A chain of ball joints from a beam, a lamp at its end.
    anchor = v3(-4.5, 5.0, 0.0)
    s.add("Beam", Transform3D={"position": v3(-4.5, 5.1, 0)}, MeshInstance3D={}, PrimitiveMesh3D={"size": v3(1.2, 0.2, 0.2)},
          Material3D={"material": f"{m}/post.mat3d"})
    above = None
    link = 0.36
    for i in range(8):
        joint = {"position": v3(0, link / 2, 0), "limit_swing": False}
        if above is None:
            joint["connected_position"] = anchor
        else:
            joint["connected"] = above
            joint["connected_position"] = v3(0, -link / 2, 0)
        # Each a little to the side, so the chain starts swinging.
        above = s.add(f"Link {i + 1}", Transform3D={"position": v3(-4.5 + (i + 1) * 0.12, 5.0 - link * (i + 0.5), 0)},
                      MeshInstance3D={}, PrimitiveMesh3D={"shape": "capsule", "radius": 0.06, "height": link},
                      Material3D={"material": f"{m}/chain.mat3d"}, RigidBody3D={}, Collider3D={"shape": "capsule",
                      "radius": 0.06, "height": link}, Joint3D=joint)
    s.add("Lamp", Transform3D={"position": v3(-4.5 + 9 * 0.12, 5.0 - link * 8 - 0.2, 0)}, MeshInstance3D={},
          PrimitiveMesh3D={"shape": "sphere", "radius": 0.22}, Material3D={"material": f"{m}/lamp.mat3d"},
          RigidBody3D={}, Collider3D={"shape": "sphere", "radius": 0.22},
          Joint3D={"connected": above, "position": v3(0, 0.22, 0), "connected_position": v3(0, -link / 2, 0)},
          PointLight3D={"color": rgba(1.0, 0.8, 0.5), "energy": 4.0, "range": 6.0, "shadow": True})

    # A bridge of planks on hinges between two posts.
    left, right, planks, width = -1.8, 1.8, 10, 0.36
    for x in (left - 0.15, right + 0.15):
        s.add(f"Post {'left' if x < 0 else 'right'}", Transform3D={"position": v3(x, 1.0, -3.5)}, MeshInstance3D={},
              PrimitiveMesh3D={"size": v3(0.3, 2.0, 1.2)}, Material3D={"material": f"{m}/post.mat3d"},
              RigidBody3D={"type": "static"}, Collider3D={"extents": v3(0.15, 1.0, 0.6)})
    above = None
    for i in range(planks):
        x = left + width * (i + 0.5)
        joint = {"kind": "hinge", "position": v3(-width / 2, 0, 0)}
        if above is None:
            joint["connected_position"] = v3(left, 1.9, -3.5)
        else:
            joint["connected"] = above
            joint["connected_position"] = v3(width / 2, 0, 0)
        above = s.add(f"Plank {i + 1}", Transform3D={"position": v3(x, 1.9, -3.5)}, MeshInstance3D={},
                      PrimitiveMesh3D={"size": v3(width - 0.03, 0.06, 1.0)}, Material3D={"material": f"{m}/wood.mat3d"},
                      RigidBody3D={}, Collider3D={"extents": v3(width / 2 - 0.015, 0.03, 0.5)}, Joint3D=joint)
    # The last plank's other end, held by a joint on a collider of its own.
    s.add("Far end", above, Transform3D={"position": v3(width / 2, 0, 0)}, Collider3D={"shape": "sphere", "radius": 0.02},
          Joint3D={"kind": "hinge", "connected_position": v3(right, 1.9, -3.5)})

    # A door on a hinge up its left edge: the hinge's z turned to stand up.
    s.add("Door frame", Transform3D={"position": v3(4.0, 1.1, 1.0)}, MeshInstance3D={},
          PrimitiveMesh3D={"size": v3(0.12, 2.2, 0.12)}, Material3D={"material": f"{m}/post.mat3d"})
    s.add("Door", Transform3D={"position": v3(4.6, 1.1, 1.0)}, MeshInstance3D={}, PrimitiveMesh3D={"size": v3(1.0, 2.0, 0.08)},
          Material3D={"material": f"{m}/door.mat3d"}, RigidBody3D={"gravity_scale": 0.0, "angular_damp": 0.6},
          Collider3D={"extents": v3(0.5, 1.0, 0.04)},
          Joint3D={"kind": "hinge", "position": v3(-0.55, 0, 0), "rotation": down, "connected_position": v3(4.05, 1.1, 1.0),
                   "connected_rotation": down, "limit_twist": True, "twist_lower": -1.7, "twist_upper": 1.7})

    s.add("Skinned", instance="res://models/skinned.glb", Transform3D={"position": v3(1.5, 0, 2.5)},
          AnimationPlayer={"autoplay": "Wave", "default_blend": 0.4})
    s.add("Lab", Script={"source": "res://scripts/joints_lab.flux"})
    _, box = panel(s, "Joints and a ragdoll",
                   "A chain of ball joints with a lamp, a bridge of planks on hinges, a door on a hinge with limits, "
                   "and the skinned column given a body for each bone: R lets it fall as a ragdoll.", width=420)
    s.add("Status", box, Control=control(420), ThemeOverride={"override_font_size": True, "font_size": 13}, Label={"text": ""})
    return s


def net_board():
    s = Scene("fw_net")
    camera2d(s)
    s.add("Board", Transform2D={}, Drawing2D={}, Script={"source": "res://scripts/net_board.flux"})
    panel(s, "A board shared over the network",
          "One game hosts, others join it - on this machine or found on the LAN - and every pointer, stamp and "
          "line is sent to everyone: the pointers each frame on the sequenced channel, the rest on the reliable one.",
          width=560)
    return s


MADE = [flux_language, notes_app, dashboard, systems_lab, flower, scene_io, tiles, render_live, input_lab, sound_lab, joints,
        net_board]

if __name__ == "__main__":
    for make in MADE:
        scene = make()
        scene.save(FOLDER)
        print("wrote", scene.name)
