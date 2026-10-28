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


MADE = [flux_language, notes_app]

if __name__ == "__main__":
    for make in MADE:
        scene = make()
        scene.save(FOLDER)
        print("wrote", scene.name)
