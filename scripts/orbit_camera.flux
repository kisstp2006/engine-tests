// orbit_camera.flux
const math = @import("math");

/// A Camera3D going round the middle of the world, looking at it. The
/// left and right arrows turn it faster or back.
struct OrbitCamera {
    @export var radius: float = 9.0;
    @export var height: float = 4.0;
    /// Radians a second.
    @export var speed: float = 0.25;
    var angle: float = 0.0;

    fn update(self, dt: float) {
        self.angle += (self.speed + app.keyAxis(.left, .right) * 1.5) * dt;
        const t = self.entity.get(Transform3D);
        t.position = vec3(math.sin(self.angle) * self.radius, self.height, math.cos(self.angle) * self.radius);
        t.lookAt(vec3(0, 0, 0), vec3(0, 1, 0));
    }
}
