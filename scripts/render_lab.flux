// render_lab.flux
const math = @import("math");

const names = ["What is drawn", "Screen-space AA", "MSAA", "3D scale", "Shadow filter", "Shadows", "Occlusion (SSAO)",
    "Reflections (SSR)", "Glow", "Fog volumes", "Tone curve", "Exposure", "Time of day", "Clouds"];
const scales = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
const exposures = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// The renderer changed while it runs, each setting a row: W and S choose
/// one, A and D change it. What is drawn - the picture, or one of its parts
/// such as the normals, the shadow atlas or the motion vectors -, the
/// antialiasing, how many pixels the 3D world is worked out in, how soft
/// the shadows are, the effects of the Environment, the tone curve, and the
/// time of day under the Sky3D, which Space runs and stops. The frame's
/// cost is shown under the rows, so each change is seen in it.
struct RenderLab {
    var chosen: int = 0;
    var view: int = 0;
    var scale: int = 2;
    var exposure: int = 2;
    var hour: float = 15.5;
    var running: bool = false;
    var frame_ms: float = 16.0;

    fn update(self, dt: float) {
        if (app.keyJustPressed(.w)) self.chosen = (self.chosen + names.len - 1) % names.len;
        if (app.keyJustPressed(.s)) self.chosen = (self.chosen + 1) % names.len;
        if (app.keyJustPressed(.a)) self.change(-1);
        if (app.keyJustPressed(.d)) self.change(1);
        if (app.keyJustPressed(.space)) self.running = !self.running;
        if (self.running) self.hour = (self.hour + dt * 1.5) % 24.0;
        self.placeSun();
        self.frame_ms += (dt * 1000.0 - self.frame_ms) * min(1.0, dt * 4.0);
        app.find("Settings").?.get(Label).text = self.shown();
    }

    fn environment(self) Environment {
        return app.find("Environment").?.get(Environment);
    }

    /// The setting chosen, a step one way or the other.
    fn change(self, by: int) {
        const env = self.environment();
        switch (self.chosen) {
            0 => {
                const all = View.members();
                self.view = (self.view + all.len + by) % all.len;
                app.setDebugView3D(all[self.view]);
            },
            1 => app.setScreenSpaceAa(next(ScreenSpaceAa.members(), app.screenSpaceAa(), by)),
            2 => app.setMsaa3d(next(Msaa.members(), app.msaa3d(), by)),
            3 => {
                self.scale = clamp(self.scale + by, 0, scales.len - 1);
                app.setScale3d(scales[self.scale]);
            },
            4 => app.setShadowFilter(next(ShadowFilter.members(), app.shadowFilter(), by)),
            5 => app.setEffect3D(.shadows, !app.effect3D(.shadows)),
            6 => env.ssao = !env.ssao,
            7 => env.ssr = !env.ssr,
            8 => env.glow = !env.glow,
            9 => app.setEffect3D(.fog, !app.effect3D(.fog)),
            10 => env.tonemap = next(Tonemap.members(), env.tonemap, by),
            11 => {
                self.exposure = clamp(self.exposure + by, 0, exposures.len - 1);
                env.exposure = exposures[self.exposure];
            },
            12 => self.hour = (self.hour + 24.0 + float(by)) % 24.0,
            13 => {
                const sky = app.find("Environment").?.get(Sky3D);
                sky.clouds = !sky.clouds;
            },
            else => {},
        }
    }

    /// The sun where the hour puts it: up in the east at six, overhead at
    /// noon, down in the west at six in the evening, under the world at night.
    fn placeSun(self) {
        const turn = (self.hour - 6.0) / 12.0 * math.pi;
        const toward = vec3(math.cos(turn), math.sin(turn), 0.35).normalized();
        const t = app.find("Sun").?.get(Transform3D);
        t.position = vec3(0, 0, 0);
        t.lookAt(-toward, vec3(0, 0, 1));
    }

    fn shown(self) string {
        const env = self.environment();
        const values = [
            View.members()[self.view].name(),
            app.screenSpaceAa().name(),
            app.msaa3d().name(),
            f"{scales[self.scale]:.2}x",
            app.shadowFilter().name(),
            onOff(app.effect3D(.shadows)),
            onOff(env.ssao),
            onOff(env.ssr),
            onOff(env.glow),
            onOff(app.effect3D(.fog)),
            env.tonemap.name(),
            f"{exposures[self.exposure]:.2}",
            f"{int(self.hour)}:{int((self.hour % 1.0) * 60.0):02}{if (self.running) ", running" else ""}",
            onOff(app.find("Environment").?.get(Sky3D).clouds),
        ];
        var lines: [string] = [];
        for (names) |name, i| lines.append(f"{if (i == self.chosen) "> " else "   "}{name}: {values[i]}");
        lines.append("");
        lines.append(f"{self.frame_ms:.1} ms a frame, {app.fps():.0} a second, on {app.backendInUse().name()}");
        lines.append("W S choose, A D change, Space runs the day");
        return lines.join("\n");
    }
}

/// The member `by` steps from `now` among `all`, round at the ends.
fn next(all: [any], now: any, by: int) any {
    const at = all.index_of(now) orelse 0;
    return all[(at + all.len + by) % all.len];
}

fn onOff(on: bool) string {
    return if (on) "on" else "off";
}
