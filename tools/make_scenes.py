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


MADE = [flux_language, notes_app, dashboard, systems_lab]

if __name__ == "__main__":
    for make in MADE:
        scene = make()
        scene.save(FOLDER)
        print("wrote", scene.name)
