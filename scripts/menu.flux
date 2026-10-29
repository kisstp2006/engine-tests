// menu.flux
const math = @import("math");

/// A category of the menu: its name, its mark - 0 a triangle, 1 a circle,
/// 2 a cross, 3 a square, 4 a diamond - the mark's colour, and the sky's
/// under it.
struct Category {
    var name: string = "";
    var kind: float = 0.0;
    var tint: color = color(1.0, 1.0, 1.0);
    var top: color = color(0.42, 0.05, 0.05);
    var bottom: color = color(0.13, 0.01, 0.01);
}

/// One test: the category it is under, the scene it opens, what it is
/// called and what it tries.
struct Test {
    var category: int = 0;
    var scene: string = "";
    var title: string = "";
    var about: string = "";
}

const categories = [
    Category{ .name = "2D", .kind = 0.0, .tint = color(0.45, 0.95, 0.75), .top = color(0.03, 0.24, 0.26), .bottom = color(0.01, 0.06, 0.08) },
    Category{ .name = "Light and shadow", .kind = 1.0, .tint = color(1.0, 0.55, 0.55), .top = color(0.05, 0.14, 0.44), .bottom = color(0.01, 0.03, 0.14) },
    Category{ .name = "Worlds and models", .kind = 2.0, .tint = color(0.55, 0.75, 1.0), .top = color(0.2, 0.08, 0.4), .bottom = color(0.04, 0.02, 0.12) },
    Category{ .name = "Systems", .kind = 3.0, .tint = color(1.0, 0.65, 0.95), .top = color(0.36, 0.13, 0.06), .bottom = color(0.09, 0.03, 0.02) },
    Category{ .name = "Apps and framework", .kind = 4.0, .tint = color(1.0, 0.86, 0.45), .top = color(0.3, 0.23, 0.05), .bottom = color(0.07, 0.05, 0.01) },
];

const tests = [
    Test{ .category = 0, .scene = "2d_sprites", .title = "Sprites, text and drawing", .about = "Sprites turned, mirrored and tinted, layers, a glow, text with an outline" },
    Test{ .category = 0, .scene = "2d_physics", .title = "Physics: bodies, a character, an area", .about = "Crates and balls, a one-way platform, a character that walks and jumps" },
    Test{ .category = 0, .scene = "2d_interface", .title = "Interface: controls and signals", .about = "Buttons, sliders, a line edit and rich text, every signal heard" },
    Test{ .category = 0, .scene = "2d_lights_particles", .title = "Lights, shadows and particles", .about = "Point lights casting shadows from occluders, a fountain and smoke" },
    Test{ .category = 0, .scene = "2d_tweens_timers_sound", .title = "Tweens, timers and sound", .about = "A timer making stars that tweens drop, turn and shrink, with a beep" },
    Test{ .category = 1, .scene = "3d_lights", .title = "Lights, materials, environment", .about = "Smooth to rough, plastic and metal, under a sun, lamps and a spot" },
    Test{ .category = 1, .scene = "3d_shadows", .title = "Shadows", .about = "Cascades of a low sun, soft spot shadows, a point light, a window cookie" },
    Test{ .category = 1, .scene = "3d_lightmap", .title = "Baked light", .about = "A room lit by a lamp and the sun, its light bounced off coloured walls" },
    Test{ .category = 1, .scene = "3d_shader", .title = "A 3D shader of its own", .about = "Bands of light running up a surface the engine lights" },
    Test{ .category = 1, .scene = "3d_extras", .title = "Rain, fog, words, worlds", .about = "Weather, fog volumes, words in the world and worlds of their own" },
    Test{ .category = 1, .scene = "3d_render_view", .title = "A render view of the 3D world", .about = "A camera drawing into a picture that a sprite shows" },
    Test{ .category = 2, .scene = "3d_shapes", .title = "Shapes and materials", .about = "The five primitive shapes, lit, unshaded, see-through and textured" },
    Test{ .category = 2, .scene = "3d_mesh_files", .title = "Meshes from .mesh files", .about = "A torus and a pyramid read from the engine's own mesh files" },
    Test{ .category = 2, .scene = "3d_models", .title = "Models: glTF, FBX, Blender", .about = "A lantern as it is, and models Blender turned into glTF" },
    Test{ .category = 2, .scene = "3d_skinning", .title = "Skinning and bone animation", .about = "A column bent by three bones, its animations fading into each other" },
    Test{ .category = 2, .scene = "3d_hierarchy", .title = "Trees, turns and tweens", .about = "A moon round a planet round a pivot, slerps and a tween in 3D" },
    Test{ .category = 2, .scene = "3d_csg", .title = "A room of solids", .about = "Walls joined, an arched door, windows cut out, a character walking in" },
    Test{ .category = 3, .scene = "3d_cameras", .title = "Cameras, rays and picking", .about = "Click a shape: rays from the camera, names over what is picked" },
    Test{ .category = 3, .scene = "3d_physics", .title = "3D physics", .about = "Bodies falling, a character pushing them, areas, rays and a button" },
    Test{ .category = 3, .scene = "3d_navigation", .title = "3D navigation", .about = "Agents finding their way over baked navigation meshes" },
    Test{ .category = 3, .scene = "3d_stress", .title = "Stress: what a frame costs", .about = "Four hundred dense balls, six hundred boxes, shadows and lamps" },
    Test{ .category = 4, .scene = "app_notes", .title = "A notes program", .about = "Notes kept in the player's files, a config, the clipboard, the window's title" },
    Test{ .category = 4, .scene = "app_dashboard", .title = "A dashboard", .about = "Live charts drawn by a script, the web asked without waiting, a picture kept" },
    Test{ .category = 4, .scene = "fw_systems", .title = "The frame's machinery", .about = "Timers, a clock of the game's own, groups, tasks, pausing and the speed of time" },
    Test{ .category = 4, .scene = "fw_flux_language", .title = "The Flux language", .about = "Every part of the language tried and checked, tasks awaited and signals heard" },
];

/// Where the chosen category's mark is, how far apart the marks are, and
/// how high the row of them is.
const column_x: float = -330.0;
const column_gap: float = 200.0;
const marks_y: float = -150.0;

/// The intro, in seconds from the start: the orchestra starts in the dark,
/// the sky comes in from black, the title fades in on the right and out
/// again, and the menu comes in over the same sky.
const sound_at: float = 0.2;
const sky_in: float = 0.9;
const title_in: float = 2.6;
const title_out: float = 5.6;
const intro_ends: float = 6.5;
/// The sky the intro is under, as a console's is blue unless told.
const intro_top: color = color(0.114, 0.44, 0.05);
const intro_bottom: color = color(0.01, 0.14, 0.077);

/// The menu of the tests, laid out the way a console's is: the categories
/// across, each with its mark, the chosen one's tests down from it - those
/// before the chosen test above the marks, those after it below - and a sky
/// of light rolling behind. Left and right change category, up and down the
/// test, and Enter, Space or a pad's A opens it; a click picks or opens one.
/// Everything glides to where it should be rather than jumping.
///
/// When the game starts it opens with an intro, as a console does: an
/// orchestra warming up in the dark, the blue sky and its ribbons coming in
/// from black, the title fading in on the right and out again, and then the
/// menu over the same sky - the marks sliding in from the right, one after
/// another. Any of the keys that open a test skips it.
/// Opening a test darkens everything to black before its scene comes; coming
/// back, the menu comes in again without the intro.
struct Menu {
    var category: int = 0;
    /// The chosen test of each category, by its place in it.
    var rows: [int];
    /// Each test's place in its category.
    var places: [int];
    var marks: [Entity];
    var names: [Entity];
    var bullets: [Entity];
    var titles: [Entity];
    var abouts: [Entity];
    var glow: ?Entity = null;
    var sky: ?Entity = null;
    var leaving: bool = false;
    var flash: float = 0.0;
    /// Seconds since the menu came, when it starts coming in, and when a
    /// test was opened.
    var clock: float = 0.0;
    var entering: float = 0.1;
    var left_at: float = 0.0;
    var intro: bool = false;
    var booted: bool = false;
    var welcomed: bool = false;
    var changed: bool = false;
    /// The black over everything, and the intro's title.
    var veil: ?Entity = null;
    var title: ?Entity = null;
    var subtitle: ?Entity = null;
    /// The clock and the words in the corner, and the keys along the bottom.
    var clock_words: ?Entity = null;
    var corner: ?Entity = null;
    var hint: ?Entity = null;
    var ticked: float = 1.0;

    fn ready(self) {
        self.sky = app.find("Sky");
        // The game has just started: the intro first.
        self.intro = app.elapsed() < 1.5;
        if (self.intro) self.entering = intro_ends;
        for (categories) |c| {
            self.rows.append(0);
            self.marks.append(self.mark(c.kind, c.tint, 104.0, 10));
            const name = self.words(c.name, 20.0, 10);
            name.get(Text2D).alignment = .center;
            self.names.append(name);
        }
        var counts = categories.map(|c| 0);
        for (tests) |t| {
            self.places.append(counts[t.category]);
            counts[t.category] += 1;
            const c = categories[t.category];
            self.bullets.append(self.mark(c.kind, c.tint, 44.0, 9));
            self.titles.append(self.words(t.title, 26.0, 10));
            self.abouts.append(self.words(t.about, 15.0, 10));
        }
        const glow = self.entity.spawnChild();
        glow.add(Transform2D);
        glow.add(Appearance);
        const shape = glow.add(Sprite);
        shape.width = 980.0;
        shape.height = 130.0;
        shape.layer = 5;
        glow.add(Material).shader = "res://shaders/xmb_glow.shader";
        self.glow = glow;

        const backend = app.backendInUse();
        const api = switch (backend) {
            .gl => "OpenGL",
            .gles => "OpenGL ES",
            .d3d11 => "Direct3D 11",
            .d3d12 => "Direct3D 12",
            .vulkan => "Vulkan",
            .webgl => "WebGL 2",
            else => backend.name(),
        };
        // The date and the time, as a console shows them, and under them
        // what this is and what it draws with.
        const clock_words = self.words("", 22.0, 10);
        clock_words.get(Text2D).alignment = .right;
        clock_words.get(Transform2D).x = 600.0;
        clock_words.get(Transform2D).y = -336.0;
        self.clock_words = clock_words;
        const corner = self.words(f"Fluxion engine tests  |  {api}", 14.0, 10);
        corner.get(Text2D).alignment = .right;
        const at = corner.get(Transform2D);
        at.x = 600.0;
        at.y = -304.0;
        self.corner = corner;
        const hint = self.words("Left, Right: category    Up, Down: test    Enter: open    Esc: back here", 14.0, 10);
        hint.get(Text2D).alignment = .center;
        hint.get(Transform2D).y = 330.0;
        self.hint = hint;

        const veil = self.entity.spawnChild();
        veil.add(Transform2D);
        const cover = veil.add(Sprite);
        cover.width = 1600.0;
        cover.height = 900.0;
        cover.layer = 100;
        const black = veil.add(Material);
        black.shader = "res://shaders/xmb_veil.shader";
        black.fade = 1.0;
        self.veil = veil;
        self.title = self.words("Fluxion", 52.0, 11);
        self.subtitle = self.words("Federated Monitoring Layer", 17.0, 11);

        self.paint(1.0);
        // The marks start off to the right, to slide in.
        for (self.marks) |mark, i| {
            mark.get(Transform2D).x = column_x + float(i - self.category) * column_gap + 420.0;
        }
    }

    /// A category's mark: a square sprite the icon shader draws, `size`
    /// across.
    fn mark(self, kind: float, tint: color, size: float, layer: int) Entity {
        const e = self.entity.spawnChild();
        e.add(Transform2D);
        e.add(Appearance).modulate = color(1, 1, 1, 0);
        const s = e.add(Sprite);
        s.width = size;
        s.height = size;
        s.layer = layer;
        const m = e.add(Material);
        m.shader = "res://shaders/xmb_icon.shader";
        m.kind = kind;
        m.tint = tint;
        m.lit = 0.0;
        return e;
    }

    /// Words in the menu's font, white with a faint shadow round them,
    /// unseen until `place` fades them in; from the left of where they are,
    /// unless the caller lines them up otherwise.
    fn words(self, text: string, size: float, layer: int) Entity {
        const e = self.entity.spawnChild();
        e.add(Transform2D);
        e.add(Appearance).modulate = color(1, 1, 1, 0);
        const w = e.add(Text2D);
        w.text = text;
        w.font = "res://fonts/NotoSans-Regular.ttf";
        w.size = size;
        w.outline_size = 2.0;
        w.outline_color = color(0, 0, 0, 0.35);
        w.layer = layer;
        return e;
    }

    fn update(self, dt: float) {
        self.clock += dt;
        self.ticked += dt;
        if (self.ticked >= 1.0) {
            self.ticked = 0.0;
            self.clock_words.?.get(Text2D).text = time.now().format("d/M  H:mm");
        }
        if (self.clock < self.entering) {
            self.skip();
        } else if (!self.leaving and self.clock > self.entering + 0.4) {
            self.steer();
        }
        self.sounds();
        const k = 1.0 - math.exp(-dt * 10.0);
        self.paint(1.0 - math.exp(-dt * 2.5));
        self.place(k);
        self.cover(k);
        self.flash = max(0.0, self.flash - dt * 2.2);
        self.sky.?.get(Material).flash = self.flash;
        if (self.leaving and !self.changed and self.clock > self.left_at + 0.95) {
            self.changed = true;
            app.changeScene(f"res://scenes/{tests[self.chosen()].scene}.json");
        }
    }

    /// The intro skipped: on to where its title fades, the sky in already.
    fn skip(self) {
        if (!self.intro or self.clock >= title_out) return;
        if (app.keyJustPressed(.enter) or app.keyJustPressed(.kp_enter) or app.keyJustPressed(.space) or app.keyJustPressed(.escape) or app.padButtonJustPressed(.a, null) or app.mouseButtonJustPressed(.left)) {
            self.clock = title_out;
        }
    }

    /// The intro's sound as it starts, and the menu's own as it comes in.
    fn sounds(self) {
        if (self.intro and !self.booted and self.clock > sound_at) {
            self.booted = true;
            app.find("Boot").?.get(AudioPlayer).play(0.0);
        }
        if (!self.welcomed and self.clock > self.entering) {
            self.welcomed = true;
            if (!self.intro) app.find("Open").?.get(AudioPlayer).play(0.0);
            app.find("Ambient").?.get(AudioPlayer).play(0.0);
        }
    }

    /// The black going as the sky comes in - at the intro's pace, or at
    /// once coming back from a test - or coming back over everything as a
    /// test opens; and the intro's title on the right of the sky.
    fn cover(self, k: float) {
        const from = if (self.intro) sky_in else self.entering;
        var fade = 1.0 - math.smoothstep(from, from + 1.5, self.clock);
        if (self.leaving) fade = math.smoothstep(self.left_at + 0.25, self.left_at + 0.85, self.clock);
        self.veil.?.get(Material).fade = fade;
        const shown = if (self.intro) math.smoothstep(title_in, title_in + 0.9, self.clock) * (1.0 - math.smoothstep(title_out, title_out + 0.7, self.clock)) else 0.0;
        glide(self.title.?, 150.0, -44.0, 1.0, shown, 1.0);
        glide(self.subtitle.?, 154.0, 20.0, 1.0, shown * 0.85, 1.0);
    }

    /// What the keys, the pad and the pointer ask for.
    fn steer(self) {
        var across = 0;
        var down = 0;
        if (app.keyJustPressed(.right) or app.padButtonJustPressed(.dpad_right, null)) across = 1;
        if (app.keyJustPressed(.left) or app.padButtonJustPressed(.dpad_left, null)) across = -1;
        if (app.keyJustPressed(.down) or app.padButtonJustPressed(.dpad_down, null)) down = 1;
        if (app.keyJustPressed(.up) or app.padButtonJustPressed(.dpad_up, null)) down = -1;
        if (across != 0) self.pickCategory(self.category + across);
        if (down != 0) self.pickRow(self.rows[self.category] + down);
        if (app.keyJustPressed(.enter) or app.keyJustPressed(.kp_enter) or app.keyJustPressed(.space) or app.padButtonJustPressed(.a, null)) {
            self.open();
            return;
        }
        if (app.mouseButtonJustPressed(.left)) self.click(app.pointerInWorld());
    }

    fn pickCategory(self, next: int) {
        if (next < 0 or next >= categories.len or next == self.category) return;
        self.category = next;
        app.find("Category").?.get(AudioPlayer).play(0.0);
    }

    fn pickRow(self, next: int) {
        if (next < 0 or next >= self.countIn(self.category) or next == self.rows[self.category]) return;
        self.rows[self.category] = next;
        app.find("Move").?.get(AudioPlayer).play(0.0);
    }

    /// A click on a mark picks its category; on a test, picks it, or opens
    /// it if it is picked already.
    fn click(self, at: vec2) {
        for (self.marks) |mark, i| {
            const t = mark.get(Transform2D);
            if (abs(at.x - t.x) < 60.0 and abs(at.y - t.y) < 60.0) {
                self.pickCategory(i);
                return;
            }
        }
        for (tests) |entry, j| {
            if (entry.category != self.category) continue;
            const t = self.titles[j].get(Transform2D);
            if (at.x > t.x - 60.0 and at.x < t.x + 520.0 and abs(at.y - t.y) < 24.0) {
                if (self.places[j] == self.rows[self.category]) {
                    self.open();
                } else {
                    self.pickRow(self.places[j]);
                }
                return;
            }
        }
    }

    fn countIn(self, category: int) int {
        var n = 0;
        for (tests) |entry| {
            if (entry.category == category) n += 1;
        }
        return n;
    }

    /// The chosen test of the chosen category, by its place in `tests`.
    fn chosen(self) int {
        for (tests) |entry, j| {
            if (entry.category == self.category and self.places[j] == self.rows[self.category]) return j;
        }
        return 0;
    }

    /// Open the chosen test: a chime and a flash, everything else fading,
    /// the black coming over it all, and its scene once it is dark.
    fn open(self) {
        if (self.leaving) return;
        self.leaving = true;
        self.left_at = self.clock;
        self.flash = 1.0;
        app.find("Confirm").?.get(AudioPlayer).play(0.0);
        const ambient = app.find("Ambient").?;
        const quiet = ambient.tween();
        quiet.tweenProperty(ambient, "AudioPlayer.volume_db", -60.0, 0.9);
    }

    /// The sky's colours toward the chosen category's, `k` of the way - or
    /// the intro's blue until the menu comes in.
    fn paint(self, k: float) {
        const m = self.sky.?.get(Material);
        const c = categories[self.category];
        const before = self.intro and self.clock < self.entering;
        m.top = m.top.lerp(if (before) intro_top else c.top, k);
        m.bottom = m.bottom.lerp(if (before) intro_bottom else c.bottom, k);
    }

    /// Everything `k` of the way to where it should be now: nothing yet
    /// while the menu has not come in, then the marks sliding in from the
    /// right one after another, and the tests after them.
    fn place(self, k: float) {
        const since = self.clock - self.entering;
        const fade = if (self.leaving) 0.0 else if (since > 0.45) 1.0 else 0.0;
        for (self.marks) |mark, i| {
            const chosen = i == self.category;
            const come = since > 0.2 + float(i) * 0.09;
            const x = column_x + float(i - self.category) * column_gap + (if (come) 0.0 else 420.0);
            const seen = if (self.leaving) 0.0 else if (come) 1.0 else 0.0;
            glide(mark, x, marks_y, if (chosen) 1.0 else 0.62, (if (chosen) 1.0 else 0.75) * seen, k);
            const m = mark.get(Material);
            m.lit += ((if (chosen) 1.0 else 0.0) - m.lit) * k;
            glide(self.names[i], x, marks_y + 74.0, 1.0, (if (chosen) 1.0 else 0.0) * fade, k);
        }
        const picked = self.chosen();
        for (tests) |entry, j| {
            const here = entry.category == self.category;
            const row = self.places[j];
            const from = self.rows[entry.category];
            const x = column_x + float(entry.category - self.category) * column_gap;
            var y = marks_y + 130.0;
            var alpha = if (here) 0.6 else 0.0;
            var size = 0.82;
            if (row < from) {
                y = marks_y - 110.0 - float(from - 1 - row) * 46.0;
                alpha = if (here) 0.4 else 0.0;
            } else if (row == from) {
                size = 1.0;
                alpha = if (here) 1.0 else 0.0;
            } else {
                y = marks_y + 130.0 + 84.0 + float(row - from - 1) * 52.0;
            }
            if (self.leaving and j == picked) {
                alpha = 1.0;
                size = 1.15;
            } else {
                alpha *= fade;
            }
            glide(self.bullets[j], x, y, size, alpha, k);
            glide(self.titles[j], x + 46.0, y - 17.0, size, alpha, k);
            glide(self.abouts[j], x + 48.0, y + 16.0, 1.0, if (row == from and here) 0.75 * fade else 0.0, k);
        }
        const at = self.corner.?.get(Transform2D);
        glide(self.corner.?, at.x, at.y, 1.0, 0.65 * fade, k);
        const clock_at = self.clock_words.?.get(Transform2D);
        glide(self.clock_words.?, clock_at.x, clock_at.y, 1.0, 0.9 * fade, k);
        const keys = self.hint.?.get(Transform2D);
        glide(self.hint.?, keys.x, keys.y, 1.0, 0.55 * fade, k);
        const t = self.titles[picked].get(Transform2D);
        glide(self.glow.?, t.x + 380.0, t.y + 22.0, 1.0, if (self.leaving) 0.0 else 1.0, k);
    }
}

/// `e` `k` of the way to `x`, `y`, `scale` and `alpha`.
fn glide(e: Entity, x: float, y: float, scale: float, alpha: float, k: float) {
    const t = e.get(Transform2D);
    t.x += (x - t.x) * k;
    t.y += (y - t.y) * k;
    t.scale_x += (scale - t.scale_x) * k;
    t.scale_y = t.scale_x;
    const look = e.get(Appearance);
    const a = look.modulate.a;
    look.modulate = color(1, 1, 1, a + (alpha - a) * k);
}
