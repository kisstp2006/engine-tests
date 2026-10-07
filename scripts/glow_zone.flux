// glow_zone.flux

/// An Area3D that counts the bodies in it, its lamp lit while any is: its
/// signals heard by methods.
struct GlowZone {
    @export var bright: float = 6.0;
    var inside: int = 0;

    fn ready(self) {
        const area = self.entity.get(Area3D);
        area.body_entered.connect(self.entered);
        area.body_exited.connect(self.left);
        self.show();
    }

    fn entered(self, body: Entity) {
        self.inside += 1;
        self.show();
    }

    fn left(self, body: Entity) {
        self.inside -= 1;
        self.show();
    }

    fn show(self) {
        if (app.childNamed(self.entity, "Lamp")) |lamp| lamp.get(PointLight3D).energy = if (self.inside > 0) self.bright else 0.0;
        if (app.find("ZoneCount")) |words| words.get(Label).text = f"{self.inside} in the zone";
    }
}
