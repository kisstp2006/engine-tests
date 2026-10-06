// spawner.flux

/// A crate where the left button is pressed, a ball where the right one is:
/// rigid bodies made from a script, under this entity so the scene takes
/// them with it.
struct Spawner {
    var made: int = 0;

    fn update(self, dt: float) {
        const crate = app.mouseButtonJustPressed(.left);
        const ball = app.mouseButtonJustPressed(.right);
        if (!crate and !ball) return;
        const body = self.entity.spawnChild();
        body.add(Transform2D).position = app.pointerInWorld();
        const look = body.add(Sprite);
        look.texture = if (crate) "res://art/crate.png" else "res://art/disc.png";
        look.width = 36.0;
        look.height = 36.0;
        if (ball) look.tint = color("#7fc8f8");
        body.add(RigidBody2D);
        const shape = body.add(Collider2D);
        if (ball) shape.shape = .circle;
        shape.bounce = if (ball) 0.6 else 0.1;
        self.made += 1;
        app.find("Made").?.get(Text2D).text = f"{self.made} made";
    }
}
