// walker.flux

/// A capsule walked about with the arrows or WASD, Space to jump: a
/// CharacterBody3D moved with moveAndSlide - up the ramp, along the walls,
/// and stopped by the crates, which it leans on.
struct Walker {
    @export var speed: float = 5.0;
    @export var jump: float = 6.5;
    @export var gravity: float = 18.0;
    /// How hard it leans on a body it walks into, a second.
    @export var push: float = 4.0;

    fn fixed(self, dt: float) {
        const body = self.entity.get(CharacterBody3D);
        // Fallen out of the world: back in from above the middle.
        const place = self.entity.get(Transform3D);
        if (place.position.y < -10.0) {
            place.position = vec3(0, 3, 3);
            body.velocity = vec3(0, 0, 0);
        }
        var way = vec3(app.actionAxis("left", "right"), 0, app.keyAxis(.w, .s) + app.keyAxis(.up, .down));
        if (way.length() > 1.0) way = way.normalized();
        var v = body.velocity;
        v.x = way.x * self.speed;
        v.z = way.z * self.speed;
        v.y -= self.gravity * dt;
        if (body.on_floor and app.keyJustPressed(.space)) v.y = self.jump;
        body.velocity = v;
        app.moveAndSlide(self.entity);
        if (app.find("Footing")) |words| words.get(Label).text = if (body.on_floor) "The player stands on the floor" else if (body.on_wall) "The player is against a wall" else "The player is in the air";
        // What it walked into that moves, leaned on.
        var i = 0;
        while (i < app.slideCollisionCount(self.entity)) : (i += 1) {
            if (app.slideCollision3D(self.entity, i)) |hit| {
                if (hit.collider) |other| {
                    if (other.has(RigidBody3D) and hit.normal.y < 0.5) {
                        app.applyImpulse3D(other, hit.normal * (-self.push * dt), hit.point - other.globalPosition3D().?);
                    }
                }
            }
        }
    }
}
