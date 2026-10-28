"""scenes.py: what the test scenes made by `make_scenes.py` are built from -
entities with the same UUIDs each time they are made, the panel every test
has in its top left, controls laid out by size, and the scene file written
as the engine reads it."""
import json
import uuid

FLOAT_MAX = 3.4028235e38


class Scene:
    """A scene being written: its entities in order, each with a UUID made
    from the scene's name and its own, so that making it again changes
    nothing that did not change."""

    def __init__(self, name):
        self.name = name
        self.entities = []

    def add(self, name, parent=None, **components):
        e = {"uuid": str(uuid.uuid5(uuid.NAMESPACE_URL, f"engine-tests/{self.name}/{parent or ''}/{name}")), "name": name}
        if parent is not None:
            e["parent"] = parent
        for key, value in components.items():
            e[key] = value
        self.entities.append(e)
        return e["uuid"]

    def save(self, folder):
        with open(f"{folder}/{self.name}.json", "w") as f:
            json.dump({"fluxion_scene": 3, "entities": self.entities}, f, indent=2)
            f.write("\n")


def size(mode="grow", value=0.0):
    return {"mode": mode, "value": float(value), "min": 0.0, "max": FLOAT_MAX, "weight": 1.0}


def control(width=None, height=None, **more):
    c = dict(more)
    if width is not None:
        c["width"] = size("grow") if width == "grow" else size("fixed", width)
    if height is not None:
        c["height"] = size("grow") if height == "grow" else size("fixed", height)
    return c


def screen(scene, name="Hud", layer=None):
    """A layer of the interface over the whole window."""
    layer_part = {"layer": layer} if layer is not None else {}
    return scene.add(name, Control=control("grow", "grow"), CanvasLayer=layer_part)


def panel(scene, title, about, width=420):
    """The panel in the top left every test has: its title, and what it
    tries and how."""
    hud = screen(scene)
    box = scene.add("Panel", hud, Control={"position": "anchored", "offset_left": 12.0, "offset_top": 12.0},
                    BoxContainer={"separation": 4}, PanelContainer={})
    scene.add("Title", box, Control=control(width), ThemeOverride={"override_font_size": True, "font_size": 18},
              Label={"text": title})
    scene.add("About", box, Control=control(width), ThemeOverride={"override_font_size": True, "font_size": 13},
              Label={"text": about})
    return hud, box


def label(scene, name, parent, text, font_size=None, width="grow", **more):
    parts = {"Control": control(width), "Label": dict({"text": text}, **more)}
    if font_size:
        parts["ThemeOverride"] = {"override_font_size": True, "font_size": font_size}
    return scene.add(name, parent, **parts)


def camera2d(scene, width=1280, height=720):
    return scene.add("Camera", Transform2D={}, Camera2D={"fit_width": float(width), "fit_height": float(height)})


def script(scene, name, source, exports=None, parent=None):
    parts = {"Script": {"source": f"res://scripts/{source}"}}
    if exports:
        parts["exports"] = exports
    return scene.add(name, parent, **parts)
