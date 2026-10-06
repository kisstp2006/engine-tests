// coin_zone.flux

/// An Area2D that counts the bodies in it: its signals heard by methods.
struct CoinZone {
    var inside: int = 0;

    fn ready(self) {
        const area = self.entity.get(Area2D);
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
        if (app.childNamed(self.entity, "Count")) |label| label.get(Text2D).text = f"{self.inside} in the zone";
    }
}
