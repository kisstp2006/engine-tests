// sound_lab.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);
const accent = color(0.45, 0.72, 1.0);
const warm = color(1.0, 0.7, 0.35);
const buses = ["Master", "Music", "Effects", "Ambience"];
/// A major scale from C, as how much faster than the pluck's own C.
const scale = [0.5, 0.5612, 0.63, 0.6674, 0.7491, 0.8409, 0.9439, 1.0, 1.1225, 1.26, 1.3348, 1.4983];
const names = ["C", "D", "E", "F", "G", "A", "B", "C", "D", "E", "F", "G"];

/// Sound as a program mixes it. Four buses - the project's Music, Effects
/// and Ambience, all into Master - each with a fader: Tab chooses one, Up
/// and Down turn it, M mutes it. The music loops on Music: P pauses it,
/// Left and Right seek through it, K and L change its pitch, and where it is
/// is drawn. The wind loops on Ambience. A bee hums round the middle with
/// an AudioSpatial2D, heard from the left as it flies left and fainter as
/// it goes away; B stops it. A click on a key of the keyboard, or Space,
/// plucks a string on Effects - each pluck a player of its own, made as it
/// is played and taken away when it has rung out, so they ring together.
struct SoundLab {
    var chosen: int = 1;
    var flying: bool = true;
    var angle: float = 0.0;
    var plucked: [float] = [];
    var notes: int = 0;

    fn update(self, dt: float) {
        if (app.keyJustPressed(.tab)) self.chosen = (self.chosen + 1) % buses.len;
        const bus = buses[self.chosen];
        if (app.keyJustPressed(.up)) _ = app.setBusVolumeDb(bus, min(6.0, app.busVolumeDb(bus) + 3.0));
        if (app.keyJustPressed(.down)) _ = app.setBusVolumeDb(bus, max(-60.0, app.busVolumeDb(bus) - 3.0));
        if (app.keyJustPressed(.m)) _ = app.setBusMute(bus, !app.isBusMuted(bus));

        const music = app.find("Music").?.get(AudioPlayer);
        if (app.keyJustPressed(.p)) music.paused = !music.paused;
        const length = app.audioLength(music.clip);
        if (app.keyJustPressed(.left)) music.seek(max(0.0, music.position - 2.0));
        if (app.keyJustPressed(.right)) music.seek(min(length - 0.1, music.position + 2.0));
        if (app.keyJustPressed(.k)) music.pitch = max(0.5, music.pitch - 0.1);
        if (app.keyJustPressed(.l)) music.pitch = min(2.0, music.pitch + 0.1);

        if (app.keyJustPressed(.b)) self.flying = !self.flying;
        if (self.flying) self.angle += dt * 0.9;
        const bee = app.find("Bee").?;
        const t = bee.get(Transform2D);
        t.x = math.cos(self.angle) * 520.0;
        t.y = 120.0 + math.sin(self.angle) * 150.0;
        bee.get(AudioPlayer).paused = !self.flying;

        if (app.keyJustPressed(.space)) self.pluck(int(math.random_range(0.0, float(scale.len))));
        if (app.mouseButtonJustPressed(.left)) {
            const at = app.pointerInWorld();
            if (at.y > 230.0 and at.y < 310.0 and at.x > -600.0 and at.x < -600.0 + 12.0 * 50.0) self.pluck(int((at.x + 600.0) / 50.0));
        }
        for (self.plucked) |p, i| self.plucked[i] = max(0.0, p - dt * 2.0);
        self.entity.queueRedraw();
    }

    /// A player of its own for one note: made, sent to Effects, played at
    /// the note's pitch, and taken away once it has rung out.
    fn pluck(self, key: int) {
        const string = self.entity.spawnChild();
        const player = string.add(AudioPlayer);
        player.clip = "res://sfx/lab_pluck.wav";
        player.pitch = scale[key];
        player.setBus("Effects");
        player.play(0.0);
        while (self.plucked.len < scale.len) self.plucked.append(0.0);
        self.plucked[key] = 1.0;
        self.notes += 1;
        await wait(1.3);
        string.despawn();
    }

    fn draw(self) {
        const e = self.entity;
        self.mixer(e);
        self.track(e);
        self.keys(e);
        // The bee, and the listener in the middle.
        const bee = app.find("Bee").?.get(Transform2D);
        e.drawCircle(vec2(0, 120), 10.0, ink, false, 2.0);
        e.drawText("listener", vec2(-26, 134), faint, 12.0, font);
        const at = vec2(bee.x, bee.y);
        e.drawCircle(at, 16.0, color(1.0, 0.85, 0.2), true, 1.0);
        e.drawLine(at - vec2(10, 0), at + vec2(10, 0), color(0.2, 0.15, 0.1), 4.0);
        const side = if (bee.x < -40.0) "left" else if (bee.x > 40.0) "right" else "ahead";
        e.drawText(f"the bee, heard on the {side}, {int((at - vec2(0, 120)).length())} px away  |  B {if (self.flying) "stops" else "starts"} it", vec2(-600, 210), faint, 13.0, font);
    }

    fn mixer(self, e: Entity) {
        e.drawText("The buses: Tab chooses, Up and Down turn, M mutes", vec2(60, -200), faint, 14.0, font);
        for (buses) |bus, i| {
            const x = 80.0 + float(i) * 130.0;
            const db = app.busVolumeDb(bus);
            const muted = app.isBusMuted(bus);
            // From -60 dB at the bottom to +6 at the top.
            const level = clamp((db + 60.0) / 66.0, 0.0, 1.0);
            e.drawRect(vec2(x, -160), vec2(16, 200), color(1, 1, 1, 0.08), true, 1.0);
            e.drawRect(vec2(x, -160 + 200.0 * (1.0 - level)), vec2(16, 200.0 * level), if (muted) color(0.5, 0.5, 0.5) else accent, true, 1.0);
            e.drawRect(vec2(x - 10, -160 + 200.0 * (1.0 - level) - 4.0), vec2(36, 8), if (i == self.chosen) warm else ink, true, 1.0);
            e.drawText(bus, vec2(x - 10, 50), if (i == self.chosen) warm else ink, 14.0, font);
            e.drawText(if (muted) "muted" else f"{db:.0} dB", vec2(x - 10, 70), faint, 12.0, font);
        }
    }

    fn track(self, e: Entity) {
        const music = app.find("Music").?.get(AudioPlayer);
        const length = app.audioLength(music.clip);
        e.drawText("The music: P pauses, Left and Right seek, K and L change the pitch", vec2(-600, -200), faint, 14.0, font);
        e.drawRect(vec2(-600, -170), vec2(560, 10), color(1, 1, 1, 0.1), true, 1.0);
        const done = if (length > 0.0) music.position / length else 0.0;
        e.drawRect(vec2(-600, -170), vec2(560.0 * done, 10), accent, true, 1.0);
        e.drawText(f"{music.position:.1} of {length:.1} s  |  pitch {music.pitch:.1}  |  {if (music.paused) "paused" else if (music.playing) "playing" else "stopped"}  |  on {music.busName()}", vec2(-600, -150), ink, 13.0, font);
        const wind = app.find("Wind").?.get(AudioPlayer);
        e.drawText(f"The wind: {wind.position:.1} s in, looping on {wind.busName()}", vec2(-600, -120), faint, 13.0, font);
    }

    fn keys(self, e: Entity) {
        for (scale) |_, i| {
            const x = -600.0 + float(i) * 50.0;
            const lit = if (i < self.plucked.len) self.plucked[i] else 0.0;
            e.drawRect(vec2(x, 230), vec2(46, 80), color(0.92, 0.92, 0.95).lerp(warm, lit), true, 1.0);
            e.drawText(names[i], vec2(x + 16, 284), color(0.2, 0.2, 0.25), 14.0, font);
        }
        e.drawText(f"{self.notes} plucked, {app.childCount(self.entity)} ringing now  |  click a key, or Space", vec2(0, 260), ink, 13.0, font);
    }
}
