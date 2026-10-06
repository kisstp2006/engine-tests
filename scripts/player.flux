// player.flux

/// A body that walks with the arrows or A and D and jumps with Space, W or
/// Up: a CharacterBody2D moved with moveAndSlide.
struct Player {
    @export var speed: float = 280.0;
    @export var jump: float = 560.0;
    @export var gravity: float = 1500.0;

    fn fixed(self, dt: float) {
        const body = self.entity.get(CharacterBody2D);
        var v = body.velocity;
        v.x = app.actionAxis("left", "right") * self.speed;
        v.y += self.gravity * dt;
        if (body.on_floor and app.actionJustPressed("jump")) v.y = -self.jump;
        body.velocity = v;
        app.moveAndSlide(self.entity);
    }
}
