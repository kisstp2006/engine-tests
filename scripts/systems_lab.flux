// systems_lab.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);

/// A bell: a struct of the script's own with a signal, rung by a task.
struct Bell {
    var rung: int = 0;
    signal rang(times: int);

    fn ring(self) {
        self.rung += 1;
        self.rang.emit(self.rung);
    }
}

/// The frame's own machinery at work, each part drawn as it ticks: three
/// timers pulsing at their own beats, a clock of the game's own running a
/// day a minute with the sky it is under, lamps in a group all switched by
/// one call, a task stepping with `await`, a bell's signal heard, and the
/// frames counted by `await app.nextFrame()`. P pauses the game - the timers,
/// the tasks and the clock stop where they are while the pause menu, which
/// runs only when paused, breathes; 1, 2 and 3 run time at a quarter, as it
/// is and twice as fast; L calls `toggle` on every lamp.
struct SystemsLab {
    var beats: [int] = [0, 0, 0];
    var flashes: [float] = [0.0, 0.0, 0.0];
    var day: ?Clock = null;
    var hours: int = 0;
    var steps: int = 0;
    var walker: vec2 = vec2(-560, 250);
    var bell: Bell = Bell{};
    var heard: int = 0;
    var frames: int = 0;
    var deferred: string = "";

    fn ready(self) {
        for (["Beat half", "Beat one", "Beat two"]) |name, i| {
            app.find(name).?.get(Timer).timeout.connect(fn () {
                self.beats[i] += 1;
                self.flashes[i] = 1.0;
            });
        }
        // A day a minute: an hour of the clock a second.
        self.day = time.clock(time.date(2026, 6, 21, 4, 0, 0), 3600.0);
        if (self.day) |clock| clock.hour_passed.connect(fn (hours: int) {
            self.hours += hours;
        });
        self.bell.rang.connect(fn (times: int) {
            self.heard = times;
        });
        app.callDeferred(fn () {
            self.deferred = f"at the end of frame {app.frameCount()}";
        });
        self.walk();
        self.count();
    }

    fn update(self, dt: float) {
        if (app.keyJustPressed(.p)) app.setPaused(true);
        if (app.keyJustPressed(.@"1")) app.setTimeScale(0.25);
        if (app.keyJustPressed(.@"2")) app.setTimeScale(1.0);
        if (app.keyJustPressed(.@"3")) app.setTimeScale(2.0);
        if (app.keyJustPressed(.l)) app.callGroup("lamps", "toggle");
        for (self.flashes) |f, i| self.flashes[i] = max(0.0, f - dt * 3.0);
        self.entity.queueRedraw();
    }

    /// A task that steps a dot across, a step a third of a second, ringing
    /// the bell at the end of each way.
    fn walk(self) {
        while (true) {
            for (range(12)) |_| {
                await wait(0.33);
                self.walker.x += 40.0;
                self.steps += 1;
            }
            self.bell.ring();
            for (range(12)) |_| {
                await wait(0.33);
                self.walker.x -= 40.0;
                self.steps += 1;
            }
            self.bell.ring();
        }
    }

    /// Frames, counted by awaiting each.
    fn count(self) {
        while (true) {
            await app.nextFrame();
            self.frames += 1;
        }
    }

    fn draw(self) {
        const e = self.entity;
        self.timers(e);
        self.sky(e);
        self.tasks(e);
        e.drawText(f"time runs at {app.timeScale():.2}x  |  {if (app.isPaused()) "paused" else "running"}  |  P pause, 1 2 3 speed, L lamps", vec2(-600, 320), faint, 15.0, font);
    }

    fn timers(self, e: Entity) {
        e.drawText("Timers: every half second, every second, every two", vec2(-600, -190), faint, 15.0, font);
        const hues = [color(0.45, 0.8, 1.0), color(0.55, 0.95, 0.6), color(1.0, 0.7, 0.35)];
        for (self.beats) |count, i| {
            const at = vec2(-520 + float(i) * 150.0, -100);
            const r = 34.0 + self.flashes[i] * 16.0;
            e.drawCircle(at, r + 10.0, hues[i].with_alpha(0.15 * self.flashes[i]), true, 1.0);
            e.drawCircle(at, r, hues[i].with_alpha(0.25 + 0.75 * self.flashes[i]), true, 1.0);
            e.drawText(f"{count}", at - vec2(10, 12), ink, 20.0, font);
        }
        e.drawText("Lamps in the group `lamps`: L calls toggle on each", vec2(-600, 0), faint, 15.0, font);
    }

    fn sky(self, e: Entity) {
        e.drawText("A clock of the game's own: a day a minute", vec2(40, -190), faint, 15.0, font);
        const clock = self.day orelse return;
        const now = clock.time();
        const hour = float(now.hour) + float(now.minute) / 60.0;
        // Night, dawn, day and dusk, by the hour.
        const light = clamp(math.sin((hour - 6.0) / 24.0 * math.tau) * 1.4 + 0.3, 0.0, 1.0);
        const top = color(0.03, 0.04, 0.12).lerp(color(0.25, 0.55, 0.95), light);
        const low = color(0.08, 0.05, 0.1).lerp(color(0.95, 0.75, 0.5), light * (1.0 - light) * 3.0 + light * 0.4);
        const box = vec2(40, -160);
        for (range(12)) |i| {
            e.drawRect(box + vec2(0, float(i) * 20.0), vec2(560, 20), top.lerp(low, float(i) / 11.0), true, 1.0);
        }
        // The sun on its arc, and the moon opposite.
        const turn = (hour - 6.0) / 24.0 * math.tau;
        const middle = box + vec2(280, 230);
        const sun = middle + vec2(-math.cos(turn) * 240.0, -math.sin(turn) * 190.0);
        const moon = middle + vec2(math.cos(turn) * 240.0, math.sin(turn) * 190.0);
        if (sun.y < middle.y) e.drawCircle(sun, 20.0, color(1.0, 0.85, 0.4), true, 1.0);
        if (moon.y < middle.y) e.drawCircle(moon, 14.0, color(0.85, 0.88, 1.0), true, 1.0);
        e.drawRect(box, vec2(560, 240), color(0.36, 0.42, 0.55, 0.6), false, 1.0);
        e.drawText(now.format("H:mm"), box + vec2(16, 12), ink, 28.0, font);
        e.drawText(f"{self.hours} hours have passed", box + vec2(16, 200), ink, 14.0, font);
    }

    fn tasks(self, e: Entity) {
        e.drawText("A task stepping with await, a bell's signal, frames awaited", vec2(-600, 150), faint, 15.0, font);
        e.drawLine(vec2(-560, 250), vec2(-80, 250), color(1, 1, 1, 0.15), 2.0);
        e.drawCircle(self.walker, 12.0, color(0.9, 0.6, 1.0), true, 1.0);
        e.drawText(f"{self.steps} steps  |  the bell rang {self.heard} times  |  {self.frames} frames awaited, {app.frameCount()} drawn", vec2(-600, 275), ink, 14.0, font);
        e.drawText(f"called later: {self.deferred}", vec2(-600, 296), faint, 13.0, font);
    }
}
