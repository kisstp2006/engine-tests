// star_rain.flux

/// Each time the Timer named `Clock` runs out, a star falls: made from the
/// script, moved by a tween that turns and shrinks it on the way, and gone
/// at the end of it - with a beep from the AudioPlayer named `Beep`.
struct StarRain {
    var fallen: int = 0;

    fn ready(self) {
        app.find("Clock").?.get(Timer).timeout.connect(self.drop);
    }

    fn drop(self) {
        self.fallen += 1;
        const star = self.entity.spawnChild();
        const t = star.add(Transform2D);
        t.position = vec2(app.randomRange(-520.0, 520.0), -380.0);
        star.add(Sprite).texture = "res://art/star.png";
        const tw = star.tween();
        tw.tweenEase(.quad_in);
        tw.tweenProperty(star, "Transform2D.y", 330.0, 1.8);
        tw.tweenParallel(true);
        tw.tweenProperty(star, "Transform2D.rotation", 6.28, 1.8);
        tw.tweenProperty(star, "Transform2D.scale_x,scale_y", vec2(0.3, 0.3), 1.8);
        tw.tweenParallel(false);
        tw.tweenCallback(fn () {
            star.despawn();
        });
        app.find("Beep").?.get(AudioPlayer).play(0.0);
        app.find("Fallen").?.get(Text2D).text = f"{self.fallen} stars";
    }
}
