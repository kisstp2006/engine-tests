// patrol.flux

/// There and back for ever, by `offset`: a tween of a Transform3D's
/// position - a cart going through a doorway and out again.
struct Patrol {
    @export var offset: vec3 = vec3(0, 0, 4);
    @export var seconds: float = 3.0;
    /// How long it waits at each end.
    @export var rest: float = 1.5;

    fn ready(self) {
        const start = self.entity.get(Transform3D).position;
        const tw = self.entity.tween();
        tw.get(Tween).loops = 0;
        tw.tweenEase(.quad_in_out);
        tw.tweenProperty(self.entity, "Transform3D.position", start + self.offset, self.seconds);
        tw.tweenInterval(self.rest);
        tw.tweenProperty(self.entity, "Transform3D.position", start, self.seconds);
        tw.tweenInterval(self.rest);
    }
}
