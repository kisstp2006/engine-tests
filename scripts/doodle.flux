// doodle.flux
const math = @import("math");

/// What a Drawing2D draws from a script: a frame, a ball going round, a line,
/// a triangle and words, drawn again every frame.
struct Doodle {
    var time: float = 0.0;

    fn update(self, dt: float) {
        self.time += dt;
        self.entity.queueRedraw();
    }

    fn draw(self) {
        const e = self.entity;
        e.drawRect(vec2(-110, -70), vec2(220, 140), color("#2b3442"), true, 1.0);
        e.drawRect(vec2(-110, -70), vec2(220, 140), color("#8da5f3"), false, 2.0);
        e.drawLine(vec2(-100, 60), vec2(100, -60), color(1, 1, 1, 0.4), 2.0);
        e.drawPolygon([vec2(0, -50), vec2(30, 10), vec2(-30, 10)], color(0.5, 0.9, 0.6, 0.8));
        const ball = vec2(math.cos(self.time * 2.0) * 70.0, math.sin(self.time * 2.0) * 40.0);
        e.drawCircle(ball, 12.0, color("tomato"), true, 1.0);
        e.drawArc(vec2(0, 0), 60.0, 0.0, self.time % 6.0, color("gold"), 3.0);
        e.drawText("Drawing2D", vec2(-100, -66), color("white"), 18.0, "res://fonts/NotoSans-Regular.ttf");
    }
}
