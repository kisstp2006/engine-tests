// pause_menu.flux
const math = @import("math");

/// The pause menu: its entity runs only while the game is paused
/// (`Processing` `when_paused`), so it breathes while all else waits, and
/// P on it un-pauses.
struct PauseMenu {
    var age: float = 0.0;

    fn update(self, dt: float) {
        self.age += dt;
        const look = self.entity.get(Text2D);
        // Shown on the first paused frame, and deaf to P on it: the press
        // that paused the game is still this frame's.
        if (!look.visible) {
            look.visible = true;
            return;
        }
        look.color = color(1, 1, 1, 0.8 + 0.2 * math.sin(self.age * 4.0));
        if (app.keyJustPressed(.p)) {
            look.visible = false;
            app.setPaused(false);
        }
    }
}
