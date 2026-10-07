// drop_button.flux

/// An Area3D the pointer picks: lit while the pointer is over it, and a
/// click drops a crate from the sky - a body made from a script, under
/// `Drops` so the scene takes it along.
struct DropButton {
    var made: int = 0;

    fn ready(self) {
        const area = self.entity.get(Area3D);
        area.mouse_entered.connect(fn () { self.light(true); });
        area.mouse_exited.connect(fn () { self.light(false); });
        area.clicked.connect(self.drop);
    }

    fn light(self, on: bool) {
        self.entity.get(Material3D).material = if (on) "res://materials/3d_physics/button_lit.mat3d" else "res://materials/3d_physics/button.mat3d";
    }

    fn drop(self, button: MouseButton) {
        if (button != .left) return;
        const under = app.find("Drops") orelse return;
        const crate = under.spawnChild();
        crate.add(Transform3D).position = vec3(app.randomRange(-2.0, 2.0), 8.0, app.randomRange(-3.0, -1.0));
        crate.add(MeshInstance3D);
        crate.add(PrimitiveMesh3D).size = vec3(0.6, 0.6, 0.6);
        crate.add(Material3D).material = "res://materials/3d_physics/crate.mat3d";
        crate.add(RigidBody3D);
        crate.add(Collider3D).extents = vec3(0.3, 0.3, 0.3);
        self.made += 1;
        app.setName(crate, f"Dropped crate {self.made}");
    }
}
