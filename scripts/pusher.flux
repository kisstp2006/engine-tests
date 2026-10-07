// pusher.flux

/// A click on a body pushes it away from the camera where the ray through
/// the pointer meets it (`castRay3D`, `applyImpulse3D`); the words say what
/// was pushed, and how many touches have begun between bodies that move
/// (`contactsBegun3D`).
struct Pusher {
    @export var strength: float = 6.0;
    var touches: int = 0;

    fn update(self, dt: float) {
        for (app.contactsBegun3D()) |contact| {
            if (contact.a.?.has(RigidBody3D) and contact.b.?.has(RigidBody3D)) self.touches += 1;
        }
        if (app.find("Contacts")) |words| words.get(Label).text = f"{self.touches} touches begun between bodies";
        if (!app.mouseButtonJustPressed(.left)) return;
        const camera = app.currentCamera3D() orelse return;
        const pointer = app.pointerOnScreen();
        const from = app.projectRayOrigin(camera, pointer) orelse return;
        const way = app.projectRayNormal(camera, pointer) orelse return;
        const hit = app.castRay3D(from, from + way * 100.0, 0xFFFFFFFF, false) orelse return;
        const pushed = hit.collider orelse return;
        if (!pushed.has(RigidBody3D)) return;
        const middle = pushed.globalPosition3D() orelse return;
        app.applyImpulse3D(pushed, way * self.strength, hit.point - middle);
        if (app.find("Pushed")) |words| words.get(Label).text = f"Pushed: {pushed.name()}";
    }
}
