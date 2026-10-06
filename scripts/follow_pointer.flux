// follow_pointer.flux

/// Goes where the pointer is in the world, catching up smoothly.
struct FollowPointer {
    /// How fast it catches up: higher is snappier.
    @export var smoothing: float = 10.0;

    fn update(self, dt: float) {
        const t = self.entity.get(Transform2D);
        var k = self.smoothing * dt;
        if (k > 1.0) k = 1.0;
        t.position = t.position.lerp(app.pointerInWorld(), k);
    }
}
