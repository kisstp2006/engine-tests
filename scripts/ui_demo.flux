// ui_demo.flux

/// The controls' signals, each heard by a method: a button counts, a check
/// box turns it on and off, a slider fills a bar, a field greets.
struct UiDemo {
    var clicks: int = 0;

    fn ready(self) {
        app.find("ClickButton").?.get(Button).pressed.connect(self.clicked);
        app.find("Enabled").?.get(CheckBox).toggled.connect(self.toggled);
        app.find("Volume").?.get(Slider).value_changed.connect(self.slid);
        app.find("NameField").?.get(LineEdit).text_changed.connect(self.typed);
    }

    fn clicked(self) {
        self.clicks += 1;
        app.find("ClickLabel").?.get(Label).text = f"Clicked {self.clicks} times";
    }

    fn toggled(self, checked: bool) {
        app.find("ClickButton").?.get(Button).disabled = !checked;
    }

    fn slid(self, value: float) {
        app.find("Meter").?.get(ProgressBar).value = value;
        app.find("VolumeLabel").?.get(Label).text = f"Volume: {value:.0}";
    }

    fn typed(self) {
        const name = app.find("NameField").?.get(LineEdit).text;
        app.find("Greeting").?.get(Label).text = if (name.len == 0) "Type your name above" else f"Hello, {name}!";
    }
}
