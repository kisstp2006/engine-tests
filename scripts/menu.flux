// menu.flux

/// The menu of the tests: every button in the group `scene_buttons` opens
/// the scene its entity is named after.
struct Menu {
    fn ready(self) {
        for (app.groupMembers("scene_buttons")) |button| {
            const path = f"res://scenes/{button.name()}.json";
            button.get(Button).pressed.connect(fn () {
                app.changeScene(path);
            });
        }
    }
}
