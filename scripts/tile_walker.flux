// tile_walker.flux

/// The walker of the tile garden: an AnimatedSprite2D whose frames the
/// script cuts from a sheet itself - four steps, four breaths - and keeps
/// in the player's files, and a CharacterBody2D the garden's walls stop.
/// It walks with the arrows or WASD, as fast as the tile under it lets it:
/// what the tile set says under `speed`.
struct TileWalker {
    @export var speed: float = 160.0;
    var walking: bool = false;
    var under: string = "";

    fn ready(self) {
        const frames = app.newSpriteFrames();
        frames.addAnimation("walk");
        frames.setAnimationSpeed("walk", 9.0);
        frames.addAnimation("idle");
        frames.setAnimationSpeed("idle", 2.5);
        for (range(4)) |i| {
            frames.addFrameRegion("walk", "res://art/walker.png", i * 32, 0, 32, 32);
            frames.addFrameRegion("idle", "res://art/walker.png", i * 32, 32, 32, 32);
        }
        app.saveSpriteFrames(frames, "user://walker.spriteframes") catch |e| print(f"the frames are not kept: {e.name}");
        const look = self.entity.get(AnimatedSprite2D);
        look.sprite_frames = frames;
        look.play("idle");
    }

    fn fixed(self, dt: float) {
        const map = app.find("Garden") orelse return;
        const here = app.globalPosition(self.entity) orelse return;
        const said = app.tileDataAt(map, here, "speed");
        const pace = if (said) |s| max(float(s), 0.2) else 1.0;
        var way = vec2(app.keyAxis(.left, .right) + app.keyAxis(.a, .d), app.keyAxis(.up, .down) + app.keyAxis(.w, .s));
        if (way.length() > 1.0) way = way.normalized();
        const body = self.entity.get(CharacterBody2D);
        body.velocity = way * self.speed * pace;
        app.moveAndSlide(self.entity);

        const look = self.entity.get(AnimatedSprite2D);
        const moving = way.length() > 0.1;
        if (moving != self.walking) {
            self.walking = moving;
            look.play(if (moving) "walk" else "idle");
        }
        if (way.x != 0.0) look.flip_h = way.x < 0.0;
        look.speed_scale = if (moving) pace else 1.0;
    }
}
