// notes_app.flux
const json = @import("json");

/// One note: what it is called, what it says, and when it was last changed,
/// in seconds since 1970.
struct Note {
    var title: string = "";
    var body: string = "";
    var modified: float = 0.0;
}

/// Where the notes and the settings are kept: the player's own files.
const notes_path = "user://notes.json";
const settings_path = "user://notes.cfg";

/// A small notes program made of the engine's interface: a list of notes
/// with a search over it, the chosen note's title and words to edit, and
/// buttons to save, copy, paste and delete. The notes are kept as JSON in the
/// player's files and read back the next time; the text size is kept in a
/// config file. The window's title says how many notes there are, each
/// note says how long ago it changed in the player's own words, and Ctrl+S
/// saves, Ctrl+N makes a new one. Its dates are written in English, as its
/// words are, and in the player's own language again once it is left.
struct NotesApp {
    var notes: [Note];
    var current: int = 0;
    var settings: ?any = null;
    var changed: bool = false;
    var said: string = "";
    var shown_for: float = 0.0;

    fn ready(self) {
        // Its words are English, so its dates are too; the player's own
        // again when the scene goes.
        time.setLocale("en-US") catch {};
        self.load();
        self.settings = files.config(settings_path, "") catch null;
        const size = if (self.settings) |cfg| cfg.get("view", "text_size", 16) else 16;
        app.find("TextSize").?.get(Slider).value = float(size);
        self.resize(float(size));

        app.find("New").?.get(Button).pressed.connect(self.add);
        app.find("Save").?.get(Button).pressed.connect(self.save);
        app.find("Copy").?.get(Button).pressed.connect(self.copy);
        app.find("Paste").?.get(Button).pressed.connect(self.paste);
        app.find("Delete").?.get(Button).pressed.connect(self.remove);
        app.find("Search").?.get(LineEdit).text_changed.connect(self.list);
        app.find("TitleField").?.get(LineEdit).text_changed.connect(self.edited);
        app.find("Body").?.get(LineEdit).text_changed.connect(self.edited);
        app.find("TextSize").?.get(Slider).value_changed.connect(self.resize);
        self.open(0);
    }

    fn exit(self) {
        if (self.changed) self.save();
        app.setWindowTitle("Engine Tests") catch {};
        time.setLocale("") catch {};
    }

    fn update(self, dt: float) {
        if (app.keyDown(.left_control) or app.keyDown(.right_control)) {
            if (app.keyJustPressed(.s)) self.save();
            if (app.keyJustPressed(.n)) self.add();
        }
        self.shown_for += dt;
        // How long ago, said again each second.
        if (self.shown_for > 1.0) {
            self.shown_for = 0.0;
            self.status();
        }
    }

    /// The notes kept last time, or two to start with.
    fn load(self) {
        const text = files.readText(notes_path) catch "";
        const kept: ?any = if (text.len > 0) (json.parse(text) catch null) else null;
        if (kept) |list| {
            for (list) |item| {
                self.notes.append(Note{ .title = item["title"], .body = item["body"], .modified = float(item["modified"]) });
            }
        }
        if (self.notes.len == 0) {
            const now = time.unix();
            self.notes.append(Note{ .title = "Welcome", .body = "A notes program made of the engine's interface.\nEdit this, make a new one, close the scene: they are kept.", .modified = now });
            self.notes.append(Note{ .title = "Shopping", .body = "bread\nmilk\ntwo lamps for the warehouse", .modified = now - 3600.0 });
        }
    }

    fn save(self) {
        files.writeText(notes_path, json.stringify(self.notes)) catch |e| {
            self.say(f"Not saved: {e.name}");
            return;
        };
        self.changed = false;
        self.say("Saved");
    }

    fn add(self) {
        self.notes.insert(0, Note{ .title = "New note", .modified = time.unix() });
        self.changed = true;
        self.open(0);
        app.find("TitleField").?.grabFocus();
    }

    fn remove(self) {
        if (self.notes.len == 0) return;
        _ = self.notes.remove(self.current);
        self.changed = true;
        self.open(min(self.current, self.notes.len - 1));
        self.say("Deleted");
    }

    fn copy(self) {
        if (self.notes.len == 0) return;
        const note = self.notes[self.current];
        app.setClipboardText(f"{note.title}\n\n{note.body}") catch |e| {
            self.say(f"Not copied: {e.name}");
            return;
        };
        self.say("Copied to the clipboard");
    }

    fn paste(self) {
        const text = app.clipboardText() catch "";
        if (text.len == 0) {
            self.say("The clipboard is empty");
            return;
        }
        const body = app.find("Body").?.get(LineEdit);
        body.text = body.text + text;
        self.edited();
        self.say("Pasted");
    }

    /// The note's fields changed: kept in it, and the list says so.
    fn edited(self) {
        if (self.notes.len == 0) return;
        const note = self.notes[self.current];
        note.title = app.find("TitleField").?.get(LineEdit).text;
        note.body = app.find("Body").?.get(LineEdit).text;
        note.modified = time.unix();
        self.changed = true;
        self.list();
    }

    /// Note `at` shown to edit.
    fn open(self, at: int) {
        self.current = max(at, 0);
        const title = app.find("TitleField").?.get(LineEdit);
        const body = app.find("Body").?.get(LineEdit);
        if (self.notes.len == 0) {
            title.text = "";
            body.text = "";
        } else {
            const note = self.notes[self.current];
            title.text = note.title;
            body.text = note.body;
        }
        self.list();
        self.status();
    }

    /// The list of notes, those the search finds, the open one pressed in.
    fn list(self) {
        const holder = app.find("List").?;
        for (app.children(holder)) |old| old.despawn();
        const wanted = app.find("Search").?.get(LineEdit).text.lower();
        for (self.notes) |note, i| {
            if (wanted.len > 0 and !note.title.lower().contains(wanted) and !note.body.lower().contains(wanted)) continue;
            const row = holder.spawnChild();
            const box = row.add(Control);
            box.width.mode = .grow;
            box.height.mode = .fixed;
            box.height.value = 36.0;
            const button = row.add(Button);
            button.text = if (note.title.len > 0) note.title else "(untitled)";
            button.alignment = .left;
            button.toggle_mode = true;
            button.button_pressed = i == self.current;
            button.pressed.connect(fn () {
                self.open(i);
            });
        }
        app.setWindowTitle(f"Notes - {self.notes.len} notes") catch {};
    }

    fn resize(self, size: float) {
        app.find("Body").?.get(ThemeOverride).font_size = int(size);
        app.find("TextSizeLabel").?.get(Label).text = f"Text size: {int(size)}";
        if (self.settings) |cfg| {
            cfg.set("view", "text_size", int(size)) catch {};
            cfg.save() catch {};
        }
    }

    fn say(self, what: string) {
        self.said = what;
        self.status();
    }

    /// What was done last, and when the open note changed.
    fn status(self) {
        var line = self.said;
        if (self.notes.len > 0) {
            const when = time.fromUnix(self.notes[self.current].modified).relative();
            line = if (line.len > 0) f"{line}  |  changed {when}" else f"Changed {when}";
        }
        if (self.changed) line += "  |  not saved";
        app.find("Status").?.get(Label).text = line;
    }
}
