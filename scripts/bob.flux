// bob.flux

/// Up and down for ever: a tween of a Transform3D's position.
struct Bob {
    @export var height: float = 1.0;
    @export var seconds: float = 1.2;

    fn ready(self) {
        const start = self.entity.get(Transform3D).position;
        const tw = self.entity.tween();
        tw.get(Tween).loops = 0;
        tw.tweenEase(.quad_in_out);
        tw.tweenProperty(self.entity, "Transform3D.position", start + vec3(0, self.height, 0), self.seconds);
        tw.tweenProperty(self.entity, "Transform3D.position", start, self.seconds);
    }
}
