// back_to_menu.flux
const math = @import("math");

/// Escape goes back to the menu from any of the tests, and a test comes in
/// from black and goes back out to it, the way a console's games do. An
/// autoload: one for the whole game, kept as the scenes change, with a sheet
/// of black over everything - the interface's top layer, so over the 3D world
/// as well as the 2D - that is its own. The menu brings itself in and takes
/// itself out, so over the menu the sheet stays clear.
struct BackToMenu {
    var sheet: ?Entity = null;
    /// The scene playing, by its root, to know when another has come.
    var root: ?Entity = null;
    /// How black the sheet is now, and where it is going.
    var dark: float = 0.0;
    var aim: float = 0.0;
    var leaving: bool = false;
    var left_for: float = 0.0;

    fn ready(self) {
        const sheet = self.entity.spawnChild();
        sheet.add(CanvasLayer).layer = 1000;
        const box = sheet.add(Control);
        box.width.mode = .grow;
        box.height.mode = .grow;
        sheet.add(ColorRect).color = color(0, 0, 0, 0);
        self.sheet = sheet;
    }

    fn update(self, dt: float) {
        const root = app.currentSceneRoot();
        if (self.root == null or self.root.? != root) {
            self.root = root;
            self.leaving = false;
            // A test comes in from black; the menu brings itself in.
            self.dark = if (app.find("Menu") == null) 1.0 else 0.0;
            self.aim = 0.0;
        }
        if (!self.leaving and app.keyJustPressed(.escape) and app.find("Menu") == null) {
            self.leaving = true;
            self.left_for = 0.0;
            self.aim = 1.0;
        }
        // Black in a little under half a second, either way.
        self.dark = math.move_toward(self.dark, self.aim, dt * 2.4);
        self.sheet.?.get(ColorRect).color = color(0, 0, 0, self.dark);
        if (self.leaving) {
            self.left_for += dt;
            if (self.dark >= 1.0 and self.left_for > 0.45) {
                self.leaving = false;
                app.changeScene("res://scenes/menu.json");
            }
        }
    }
}
