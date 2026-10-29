// dashboard.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const card_color = color(0.13, 0.15, 0.19, 0.92);
const edge_color = color(0.36, 0.42, 0.55, 0.6);
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);
const accent = color(0.45, 0.72, 1.0);
const warm = color(1.0, 0.7, 0.35);
const good = color(0.5, 0.88, 0.62);
const bad = color(1.0, 0.48, 0.48);

/// Where each card is: its top left and its size, in the world the camera
/// fits to 1280 by 720 round the middle.
const frame_card = [vec2(-620, -210), vec2(660, 220)];
const clock_card = [vec2(60, -350), vec2(560, 360)];
const fps_card = [vec2(-620, 30), vec2(400, 320)];
const gauge_card = [vec2(-200, 30), vec2(240, 320)];
const web_card = [vec2(60, 30), vec2(270, 320)];
const shot_card = [vec2(350, 30), vec2(270, 320)];

/// A board of live numbers drawn by a script with a Drawing2D: what each
/// frame took, as a line over the last four seconds, frames a second as bars
/// over the last half minute, how much of a sixtieth of a second the last
/// frame used as a gauge, the date and the time in the player's own words, a
/// public repository's numbers asked of the web without the frame waiting,
/// and a picture of the frame saved to the player's files and shown again.
/// R asks the web again, P keeps a picture; a click on a card does the same.
struct Dashboard {
    var frames: [float];
    var each_second: [float];
    var counted: int = 0;
    var second: float = 0.0;
    var since_start: float = 0.0;
    var web_state: string = "asking...";
    var stars: int = -1;
    var forks: int = -1;
    var pushed: string = "";
    var picture: ?any = null;
    var picture_said: string = "P keeps a picture of this frame";
    var shoot_next: bool = false;

    fn ready(self) {
        self.ask();
    }

    fn update(self, dt: float) {
        // Asked for last frame: the picture is of that frame, drawn whole.
        if (self.shoot_next) {
            self.shoot_next = false;
            self.shoot();
        }
        self.since_start += dt;
        self.frames.append(dt * 1000.0);
        if (self.frames.len > 240) _ = self.frames.remove(0);
        self.counted += 1;
        self.second += dt;
        if (self.second >= 1.0) {
            self.each_second.append(float(self.counted) / self.second);
            if (self.each_second.len > 30) _ = self.each_second.remove(0);
            self.counted = 0;
            self.second = 0.0;
        }
        if (app.keyJustPressed(.r)) self.ask();
        if (app.keyJustPressed(.p)) self.shoot_next = true;
        if (app.mouseButtonJustPressed(.left)) {
            const at = app.pointerInWorld();
            if (inside(web_card, at)) self.ask();
            if (inside(shot_card, at)) self.shoot_next = true;
        }
        self.entity.queueRedraw();
    }

    /// The repository's numbers, asked of GitHub's public API; the frame
    /// goes on while the answer comes.
    fn ask(self) {
        self.web_state = "asking...";
        const reply = await web.get("https://api.github.com/repos/kisstp2006/fluxion-smooth", 10.0) catch |e| {
            self.web_state = f"no answer: {e.name}";
            return;
        };
        if (!reply.ok) {
            self.web_state = f"answered {reply.status}";
            return;
        }
        const data = reply.json();
        self.stars = int(data["stargazers_count"]) catch -1;
        self.forks = int(data["forks_count"]) catch -1;
        const when = time.parse(data["pushed_at"]) catch null;
        self.pushed = if (when) |at| at.relative() else "";
        self.web_state = "answered 200";
    }

    /// A picture of the frame, kept in the player's files, made a texture
    /// and drawn small on its card.
    fn shoot(self) {
        const shot = images.capture() catch |e| {
            self.picture_said = f"no picture: {e.name}";
            return;
        };
        shot.resize(shot.width() / 4, shot.height() / 4, true);
        shot.savePng("user://dashboard.png") catch |e| {
            self.picture_said = f"not saved: {e.name}";
            return;
        };
        self.picture = images.toTexture(shot) catch null;
        self.picture_said = f"user://dashboard.png, {shot.width()} x {shot.height()}, at {time.now().format("H:mm:ss")}";
    }

    fn draw(self) {
        const e = self.entity;
        self.frameCard(e);
        self.clockCard(e);
        self.fpsCard(e);
        self.gaugeCard(e);
        self.webCard(e);
        self.shotCard(e);
    }

    fn frameCard(self, e: Entity) {
        card(e, frame_card, "Frame time, the last four seconds");
        const at = frame_card[0] + vec2(20, 50);
        const size = frame_card[1] - vec2(40, 70);
        // The sixtieth and the thirtieth of a second, as lines to read against.
        const top = 40.0;
        for ([16.7, 33.3]) |ms| {
            const y = at.y + size.y - ms / top * size.y;
            e.drawLine(vec2(at.x, y), vec2(at.x + size.x, y), color(1, 1, 1, 0.12), 1.0);
            e.drawText(f"{ms:.1} ms", vec2(at.x + size.x - 60, y - 18), faint, 12.0, font);
        }
        if (self.frames.len < 2) return;
        var points: [vec2];
        for (self.frames) |ms, i| {
            const x = at.x + float(i) / 239.0 * size.x;
            points.append(vec2(x, at.y + size.y - min(ms, top) / top * size.y));
        }
        e.drawPolyline(points, accent, 2.0);
        const last = self.frames[-1];
        e.drawText(f"{last:.2} ms now", frame_card[0] + vec2(frame_card[1].x - 140, 14), ink, 14.0, font);
    }

    fn clockCard(self, e: Entity) {
        card(e, clock_card, "The time, in the player's words");
        const now = time.now();
        e.drawText(now.format("H:mm:ss"), clock_card[0] + vec2(24, 60), ink, 72.0, font);
        e.drawText(now.formatStyle(.full, null), clock_card[0] + vec2(28, 160), faint, 20.0, font);
        e.drawText(f"{time.zoneName()}  |  {time.locale()}", clock_card[0] + vec2(28, 196), faint, 15.0, font);
        // Seconds round a ring, and the scene's own age under it.
        const middle = clock_card[0] + vec2(430, 240);
        e.drawArc(middle, 70.0, 0.0, math.tau, color(1, 1, 1, 0.1), 8.0);
        const turn = float(now.second) / 60.0 * math.tau;
        e.drawArc(middle, 70.0, -math.pi / 2.0, -math.pi / 2.0 + turn, warm, 8.0);
        e.drawText(f"open {int(self.since_start)} s", clock_card[0] + vec2(28, 300), faint, 15.0, font);
    }

    fn fpsCard(self, e: Entity) {
        card(e, fps_card, "Frames a second, the last half minute");
        const at = fps_card[0] + vec2(20, 50);
        const size = fps_card[1] - vec2(40, 80);
        const highest = if (self.each_second.len > 0) max(self.each_second) else 60.0;
        const top = max(highest, 60.0) * 1.1;
        const wide = size.x / 30.0;
        for (self.each_second) |fps, i| {
            const tall = fps / top * size.y;
            const shade = if (fps >= 55.0) good else if (fps >= 30.0) warm else bad;
            e.drawRect(vec2(at.x + float(i) * wide + 1.0, at.y + size.y - tall), vec2(wide - 2.0, tall), shade, true, 1.0);
        }
        const now = if (self.each_second.len > 0) self.each_second[-1] else 0.0;
        e.drawText(f"{now:.0} now  |  {app.fps():.0} by the engine", fps_card[0] + vec2(20, fps_card[1].y - 26), ink, 14.0, font);
    }

    fn gaugeCard(self, e: Entity) {
        card(e, gauge_card, "Of a sixtieth, waits too");
        const last = if (self.frames.len > 0) self.frames[-1] else 0.0;
        const used = clamp(last / 16.667, 0.0, 1.5);
        const middle = gauge_card[0] + vec2(120, 180);
        const from = math.pi * 0.75;
        const all = math.pi * 1.5;
        e.drawArc(middle, 80.0, from, from + all, color(1, 1, 1, 0.1), 14.0);
        const shade = if (used < 0.8) good else if (used < 1.0) warm else bad;
        e.drawArc(middle, 80.0, from, from + all * min(used, 1.0), shade, 14.0);
        e.drawText(f"{used * 100.0:.0}%", middle - vec2(34, 20), ink, 30.0, font);
    }

    fn webCard(self, e: Entity) {
        card(e, web_card, "The web, without waiting");
        const at = web_card[0] + vec2(18, 50);
        e.drawText("kisstp2006/fluxion-smooth", at, accent, 15.0, font);
        e.drawText(self.web_state, at + vec2(0, 30), faint, 14.0, font);
        if (self.stars >= 0) {
            e.drawText(f"{self.stars}", at + vec2(0, 70), ink, 44.0, font);
            e.drawText("stars", at + vec2(0, 124), faint, 14.0, font);
            e.drawText(f"{self.forks}", at + vec2(130, 70), ink, 44.0, font);
            e.drawText("forks", at + vec2(130, 124), faint, 14.0, font);
            e.drawText(f"pushed {self.pushed}", at + vec2(0, 160), faint, 14.0, font);
        }
        e.drawText("R or a click asks again", at + vec2(0, web_card[1].y - 80), faint, 12.0, font);
    }

    fn shotCard(self, e: Entity) {
        card(e, shot_card, "A picture of the frame");
        const at = shot_card[0] + vec2(15, 50);
        if (self.picture) |texture| {
            e.drawTexture(texture, at, vec2(240, 135), color(1, 1, 1));
            e.drawRect(at, vec2(240, 135), edge_color, false, 1.0);
        }
        e.drawText(self.picture_said, at + vec2(0, 150), faint, 12.0, font);
    }
}

/// A card: a panel with an edge and a title.
fn card(e: Entity, place: [vec2], title: string) {
    e.drawRect(place[0], place[1], card_color, true, 1.0);
    e.drawRect(place[0], place[1], edge_color, false, 1.0);
    e.drawText(title, place[0] + vec2(18, 14), faint, 15.0, font);
}

fn inside(place: [vec2], at: vec2) bool {
    return at.x >= place[0].x and at.y >= place[0].y and at.x <= place[0].x + place[1].x and at.y <= place[0].y + place[1].y;
}
