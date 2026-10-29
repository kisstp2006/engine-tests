// scene_io.flux

const font = "res://fonts/NotoSans-Regular.ttf";
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);
const garden_json = "user://garden.json";
const garden_cbor = "user://garden.cbor";
const stats_path = "user://garden_stats.data";
const far_scene = "res://scenes/3d_models.json";

/// What the garden keeps of itself between runs: a data file of a struct
/// of the script's own, its `@export` fields written and read back as they
/// are.
struct GardenStats {
    @export var saves: int = 0;
    @export var flowers: int = 0;
    @export var when: string = "";
}

/// Scenes in and out: a click in the garden makes an instance of
/// `scenes/parts/flower.json` there; S saves the garden - its own branch of
/// the world, as a scene of its own - as JSON and as CBOR, and keeps a few
/// numbers in a data file; L throws the garden away and reads it back; C
/// clears it. B reads a whole other scene in the background, its progress
/// drawn, and Enter then opens it. What the files hold is shown as it is.
struct SceneIo {
        var said: string = "Click in the garden to plant a flower";
    var saved_text: string = "";
    var sizes: string = "";
    var stats: string = "";
    var loading: bool = false;

    fn ready(self) {
        self.readStats();
    }

    fn update(self, dt: float) {
        const garden = app.find("Garden") orelse return;
        if (app.mouseButtonJustPressed(.left)) {
            const at = app.pointerInWorld();
            if (at.x > -600.0 and at.x < 40.0 and at.y > -160.0 and at.y < 280.0) {
                const made = app.instantiate("res://scenes/parts/flower.json", garden);
                made.get(Transform2D).x = at.x;
                made.get(Transform2D).y = at.y;
                self.said = f"{app.children(garden).len} flowers";
            }
        }
        if (app.keyJustPressed(.s)) self.save(garden);
        if (app.keyJustPressed(.l)) self.load(garden);
        if (app.keyJustPressed(.c)) {
            for (app.children(garden)) |child| child.despawn();
            self.said = "Cleared";
        }
        if (app.keyJustPressed(.b) and !self.loading) {
            app.loadInBackground(far_scene) catch |e| {
                self.said = f"not loading: {e.name}";
                return;
            };
            self.loading = true;
        }
        if (self.loading and app.keyJustPressed(.enter) and app.loadStatus(far_scene) == .done) {
            app.changeScene(far_scene);
        }
        self.entity.queueRedraw();
    }

    /// The garden's branch as a scene of its own, twice: JSON a person can
    /// read and CBOR a program reads faster.
    fn save(self, garden: Entity) {
        app.saveScene(garden_json, .{ .root = garden }) catch |e| {
            self.said = f"not saved: {e.name}";
            return;
        };
        app.saveScene(garden_cbor, .{ .root = garden, .format = .cbor }) catch |e| {
            self.said = f"not saved as CBOR: {e.name}";
            return;
        };
        const json_size = files.size(garden_json) catch 0;
        const cbor_size = files.size(garden_cbor) catch 0;
        self.sizes = f"garden.json {json_size} bytes  |  garden.cbor {cbor_size} bytes";
        const text = files.readText(garden_json) catch "";
        const lines = text.lines();
        self.saved_text = lines[0..min(18, lines.len)].join("\n");
        const count = app.children(garden).len;
        var stats = GardenStats{};
        if (files.exists(stats_path)) stats = files.readData(stats_path) catch GardenStats{};
        stats.saves += 1;
        stats.flowers = count;
        stats.when = time.now().format("yyyy-MM-dd H:mm:ss");
        files.writeData(stats, stats_path) catch |e| {
            self.said = f"the numbers are not kept: {e.name}";
            return;
        };
        self.readStats();
        self.said = f"Saved {count} flowers";
    }

    /// The garden thrown away, and on the next frame - when it is gone -
    /// read back from its JSON: the Garden itself, with its flowers.
    fn load(self, garden: Entity) {
        if (!files.exists(garden_json)) {
            self.said = "Nothing saved yet: S saves";
            return;
        }
        garden.despawn();
        await app.nextFrame();
        app.readScene(garden_json, .{}) catch |e| {
            self.said = f"not read: {e.name}";
            return;
        };
        self.said = f"Read back from garden.json: {app.children(app.find("Garden").?).len} flowers";
    }

    fn readStats(self) {
        if (!files.exists(stats_path)) {
            self.stats = "no data file yet";
            return;
        }
        const s: GardenStats = files.readData(stats_path) catch {
            self.stats = "the data file is not read";
            return;
        };
        self.stats = f"saved {s.saves} times, last with {s.flowers} flowers, {s.when}";
    }

    fn draw(self) {
        const e = self.entity;
        e.drawRect(vec2(-600, -160), vec2(640, 440), color(0.1, 0.2, 0.12), true, 1.0);
        e.drawRect(vec2(-600, -160), vec2(640, 440), color(0.35, 0.55, 0.38, 0.7), false, 1.0);
        e.drawText("The garden: a click plants a flower, an instance of flower.json", vec2(-600, -190), faint, 15.0, font);
        e.drawText(self.said, vec2(-600, 290), ink, 16.0, font);
        e.drawText("S save   L load   C clear   B load a scene in the background", vec2(-600, 316), faint, 14.0, font);

        e.drawText("What garden.json holds", vec2(80, -190), faint, 15.0, font);
        e.drawRect(vec2(80, -160), vec2(520, 300), color(0.08, 0.09, 0.12), true, 1.0);
        e.drawText(if (self.saved_text.len > 0) self.saved_text else "(nothing saved yet)", vec2(92, -150), color(0.7, 0.85, 1.0), 11.0, font);
        e.drawText(self.sizes, vec2(80, 150), ink, 14.0, font);
        e.drawText(f"garden_stats.data: {self.stats}", vec2(80, 174), faint, 12.0, font);

        e.drawText("A scene read in the background", vec2(80, 210), faint, 15.0, font);
        const done = if (self.loading) app.loadProgress(far_scene) else 0.0;
        e.drawRect(vec2(80, 236), vec2(520, 14), color(1, 1, 1, 0.1), true, 1.0);
        e.drawRect(vec2(80, 236), vec2(520.0 * done, 14), color(0.45, 0.72, 1.0), true, 1.0);
        const state = if (!self.loading) "B starts it" else switch (app.loadStatus(far_scene)) {
            .done => "read: Enter opens it",
            .failed => "it failed",
            else => f"{int(done * 100.0)}%",
        };
        e.drawText(f"3d_models.json: {state}", vec2(80, 258), ink, 14.0, font);
    }
}
