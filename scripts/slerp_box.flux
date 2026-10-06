// slerp_box.flux
const math = @import("math");

/// A box turned between two turns along the shortest arc: `quat`'s
/// `slerp`, there and back.
struct SlerpBox {
    var time: float = 0.0;

    fn update(self, dt: float) {
        self.time += dt;
        const to = quat(vec3(1, 1, 0).normalized(), math.pi * 0.75);
        const k = 0.5 + 0.5 * math.sin(self.time * 1.5);
        self.entity.get(Transform3D).rotation = quat().slerp(to, k);
    }
}
