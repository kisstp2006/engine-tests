// light_pulse.flux
const math = @import("math");

/// A PointLight2D that breathes and goes round the colours.
struct LightPulse {
    var time: float = 0.0;

    fn update(self, dt: float) {
        self.time += dt;
        const light = self.entity.get(PointLight2D);
        light.energy = 1.4 + 0.5 * math.sin(self.time * 3.0);
        light.color = hsv(self.time * 40.0 % 360.0, 0.6, 1.0);
    }
}
