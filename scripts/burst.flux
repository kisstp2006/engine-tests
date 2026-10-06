// burst.flux

/// A one-shot Particles2D, moved to where the left button is pressed and
/// let off there.
struct Burst {
    fn update(self, dt: float) {
        if (!app.mouseButtonJustPressed(.left)) return;
        self.entity.get(Transform2D).position = app.pointerInWorld();
        app.emitParticles(self.entity, 48);
    }
}
