// spinner.flux
const math = @import("math");

/// Turns its entity round: a 2D one about itself, a 3D one about `axis`, in
/// its own space.
struct Spinner {
    /// Degrees a second.
    @export var speed: float = 90.0;
    /// Which way round, for a 3D entity.
    @export var axis: vec3 = vec3(0, 1, 0);

    fn update(self, dt: float) {
        const turn = self.speed * math.pi / 180.0 * dt;
        if (self.entity.has(Transform3D)) {
            const t = self.entity.get(Transform3D);
            t.rotation = t.rotation * quat(self.axis.normalized(), turn);
        } else if (self.entity.has(Transform2D)) {
            self.entity.get(Transform2D).rotation += turn;
        }
    }
}
