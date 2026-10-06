// ping_pong.flux

/// A tween that goes there and back for ever: `loops` nought, each way
/// eased in and out.
struct PingPong {
    /// How far each way it goes, in pixels.
    @export var reach: float = 300.0;
    @export var seconds: float = 1.2;

    fn ready(self) {
        const x = self.entity.get(Transform2D).position.x;
        const tw = self.entity.tween();
        tw.get(Tween).loops = 0;
        tw.tweenEase(.quad_in_out);
        tw.tweenProperty(self.entity, "Transform2D.x", x + self.reach, self.seconds);
        tw.tweenProperty(self.entity, "Transform2D.x", x - self.reach, self.seconds * 2.0);
        tw.tweenProperty(self.entity, "Transform2D.x", x, self.seconds);
    }
}
