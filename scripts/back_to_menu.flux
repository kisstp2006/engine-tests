// back_to_menu.flux

/// Escape goes back to the menu from any of the tests. An autoload: one for
/// the whole game, kept as the scenes change.
struct BackToMenu {
    fn update(self, dt: float) {
        if (app.keyJustPressed(.escape)) app.changeScene("res://scenes/menu.json");
    }
}
