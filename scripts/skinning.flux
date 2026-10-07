// skinning.flux

/// The skinned column's buttons: Bend and Wave each play their animation,
/// fading from the one before over its player's default blend; Bones shows
/// and hides its skeleton.
struct Skinning {
    fn ready(self) {
        app.find("BendButton").?.get(Button).pressed.connect(self.bend);
        app.find("WaveButton").?.get(Button).pressed.connect(self.wave);
        app.find("BonesButton").?.get(Button).pressed.connect(self.bones);
    }

    fn update(self, dt: float) {
        if (app.keyJustPressed(.b)) self.bend();
        if (app.keyJustPressed(.w)) self.wave();
        if (app.keyJustPressed(.s)) self.bones();
    }

    fn bend(self) {
        app.find("Skinned").?.get(AnimationPlayer).play("Bend");
    }

    fn wave(self) {
        app.find("Skinned").?.get(AnimationPlayer).play("Wave");
    }

    fn bones(self) {
        const skeleton = app.find("Armature").?.get(Skeleton3D);
        skeleton.show_bones = !skeleton.show_bones;
    }
}
