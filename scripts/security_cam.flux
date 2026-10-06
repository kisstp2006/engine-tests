// security_cam.flux
const math = @import("math");

/// A camera on a wall, looking from side to side.
struct SecurityCam {
    @export var sweep: float = 50.0;
    var time: float = 0.0;

    fn update(self, dt: float) {
        self.time += dt;
        self.entity.get(Transform3D).rotation_degrees = vec3(-25, 180.0 + self.sweep * math.sin(self.time * 0.6), 0);
    }
}
