// lamp.flux

/// A lamp in the group `lamps`: `toggle`, called on every lamp by
/// `app.callGroup`, turns it on or off - its glow fading rather than
/// snapping.
struct Lamp {
    @export var on: bool = true;
    var shown: float = 1.0;

    fn ready(self) {
        app.addToGroup(self.entity, "lamps");
    }

    fn toggle(self) {
        self.on = !self.on;
    }

    fn update(self, dt: float) {
        const aim = if (self.on) 1.0 else 0.08;
        self.shown += (aim - self.shown) * min(1.0, dt * 8.0);
        self.entity.get(Sprite).tint = color(1.0, 0.85, 0.5, self.shown);
    }
}
