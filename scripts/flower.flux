// flower.flux
const math = @import("math");

/// A flower of the garden: the root of `scenes/parts/flower.json`, made an
/// instance of wherever the garden is clicked. A new one is given a colour
/// of its own and grows in; one read back from a saved garden keeps the
/// colour its Sprite was saved with, and is there at once.
struct Flower {
    @export var sway: float = 1.0;
    var age: float = 0.0;
    var grown: float = 1.0;

    fn ready(self) {
        const sprite = self.entity.get(Sprite);
        if (sprite.tint == color(1, 1, 1)) {
            sprite.tint = color(math.random_range(0.6, 1.0), math.random_range(0.35, 0.9), math.random_range(0.3, 1.0));
            self.sway = math.random_range(0.6, 1.6);
            self.grown = 0.0;
        }
    }

    fn update(self, dt: float) {
        self.age += dt * self.sway;
        self.grown = min(1.0, self.grown + dt * 2.5);
        // Over its size a little, then back: grown in with a bounce.
        const size = 1.0 + math.sin(self.grown * math.pi) * 0.25 * self.grown;
        const t = self.entity.get(Transform2D);
        t.scale_x = size * self.grown;
        t.scale_y = size * self.grown;
        t.rotation = math.sin(self.age * 2.0) * 0.15;
    }
}
