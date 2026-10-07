// scanner.flux

/// A RayCast3D turned round by the pivot it hangs from, saying what it
/// sees first.
struct Scanner {
    fn fixed(self, dt: float) {
        const ray = self.entity.get(RayCast3D);
        const words = app.find("Scanned") orelse return;
        words.get(Label).text = "The scanner sees nothing";
        if (ray.collider) |seen| words.get(Label).text = f"The scanner sees: {seen.name()}";
    }
}
