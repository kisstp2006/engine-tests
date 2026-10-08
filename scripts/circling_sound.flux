// circling_sound.flux
const math = @import("math");

/// Goes round the middle of the yard, playing its sound, and draws where it
/// is and how far it is heard: a debug line down to the ground, its name
/// over it, and a ring at its unit size.
struct CirclingSound {
    @export var radius: float = 5.0;
    /// Radians a second.
    @export var speed: float = 0.6;
    var angle: float = 0.0;

    fn update(self, dt: float) {
        self.angle += self.speed * dt;
        const t = self.entity.get(Transform3D);
        t.position = vec3(math.cos(self.angle) * self.radius, 0.8, math.sin(self.angle) * self.radius);
        const at = t.position;
        const heard = self.entity.get(AudioSpatial3D);
        app.debugLine3D(at, vec3(at.x, 0, at.z), color(0.55, 0.85, 0.65));
        app.debugSphere3D(at, heard.unit_size, color(0.55, 0.85, 0.65, 0.6));
        app.debugText3D(at + vec3(0, 0.4, 0), "beep");
        // Which way it goes.
        app.debugArrow3D(at, at + vec3(-math.sin(self.angle), 0, math.cos(self.angle)) * 0.8, color(1, 0.8, 0.3));
    }
}
