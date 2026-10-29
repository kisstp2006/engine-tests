// input_lab.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);
const accent = color(0.45, 0.72, 1.0);
const warm = color(1.0, 0.7, 0.35);
const map_path = "user://input.json";

/// Everything the player does, as the game hears it. Each event comes to
/// `input` and is written down as it describes itself; the actions are
/// shown as bars of how far down they are, with what to press for them;
/// a ball rolls by `left` and `right` and the left stick, and hops on
/// `jump`. R and then any key, mouse button or controller button binds
/// `jump` to it, kept in the player's files for the next run; N and then a
/// key makes an action of the game's own, `wave`, which sends a ring out.
/// T has the mouse stand in for a finger, whose touches are drawn; C goes
/// through the pointer's shapes. Controllers plugged in are drawn with
/// their sticks and triggers.
struct InputLab {
    var heard: [string] = [];
    var waiting: string = "";
    var ball: vec2 = vec2(-300, 240);
    var rise: float = 0.0;
    var lift: float = 0.0;
    var rings: [float] = [];
    var shape: int = 0;
    var map_said: string = "";

    fn ready(self) {
        const read = app.loadInputMap(map_path) catch false;
        self.map_said = if (read) "jump as you left it, from user://input.json" else "jump as the project has it";
    }

    fn input(self, event: InputEvent) {
        self.note(event);
        if (self.waiting.len > 0 and pressed(event)) {
            self.take(event);
            app.setInputAsHandled();
            return;
        }
        if (event.isActionPressed("wave")) self.rings.append(0.0);
    }

    /// The press a rebinding waited for: `jump` given it in place of what
    /// it had, or the new action `wave` made with it.
    fn take(self, event: InputEvent) {
        if (self.waiting == "jump") {
            _ = app.clearAction("jump");
            app.bindAction("jump", event);
            app.saveInputMap(map_path) catch |e| {
                self.map_said = f"not kept: {e.name}";
            };
            self.map_said = f"jump is {app.describeAction("jump")} now, kept in user://input.json";
        } else {
            if (app.hasAction("wave")) _ = app.removeAction("wave");
            app.addAction("wave") catch return;
            app.bindAction("wave", event);
            self.map_said = f"a new action, wave, on {app.describeAction("wave")}";
        }
        self.waiting = "";
    }

    fn note(self, event: InputEvent) {
        const kind = if (event is KeyEvent) "key" else if (event is MouseButtonEvent) "mouse button" else if (event is MouseMotionEvent) "" else if (event is WheelEvent) "wheel" else if (event is TouchEvent) "touch" else if (event is TapEvent) "tap" else if (event is SwipeEvent) "swipe" else if (event is PinchEvent) "pinch" else "other";
        // The pointer moving is too much to write down.
        if (kind.len == 0) return;
        self.heard.append(f"{kind}: {event.describe()}");
        if (self.heard.len > 14) _ = self.heard.remove(0);
    }

    fn update(self, dt: float) {
        if (self.waiting.len == 0) {
            if (app.keyJustPressed(.r)) self.waiting = "jump";
            if (app.keyJustPressed(.n)) self.waiting = "wave";
            if (app.keyJustPressed(.t)) app.setTouchFromMouse(!app.touchFromMouse());
            if (app.keyJustPressed(.c)) {
                const shapes = CursorShape.members();
                self.shape = (self.shape + 1) % shapes.len;
                app.setDefaultCursorShape(shapes[self.shape]);
            }
        }
        // The ball: actions and the left stick, a hop on jump.
        const way = app.actionAxis("left", "right") + app.padStick(.left).x;
        self.ball.x = clamp(self.ball.x + way * 300.0 * dt, -560.0, -60.0);
        if (app.actionJustPressed("jump") and self.lift <= 0.0) self.rise = 420.0;
        self.lift = max(0.0, self.lift + self.rise * dt);
        self.rise -= 1400.0 * dt;
        if (self.lift <= 0.0) self.rise = 0.0;
        for (self.rings) |r, i| self.rings[i] = r + dt;
        self.rings = self.rings.filter(|r| r < 1.2);
        self.entity.queueRedraw();
    }

    fn draw(self) {
        const e = self.entity;
        self.heardCard(e);
        self.actionsCard(e);
        self.ballCard(e);
        self.padsCard(e);
        self.touchCard(e);
        const asking = if (self.waiting.len > 0) f"Press what {self.waiting} should be..." else "R rebinds jump, N makes an action, T touches with the mouse, C changes the pointer";
        e.drawText(asking, vec2(-600, 320), if (self.waiting.len > 0) warm else faint, 15.0, font);
    }

    fn heardCard(self, e: Entity) {
        card(e, vec2(-620, -200), vec2(330, 330), "What the game heard");
        for (self.heard) |line, i| {
            const fade = 0.35 + 0.65 * float(i + 1) / float(self.heard.len);
            e.drawText(line, vec2(-604, -168 + float(i) * 21.0), ink.with_alpha(fade), 13.0, font);
        }
    }

    fn actionsCard(self, e: Entity) {
        card(e, vec2(-270, -200), vec2(400, 330), "The actions, how far down, and on what");
        var row = 0;
        for (app.actionNames()) |name| {
            if (row >= 13) break;
            const y = -168.0 + float(row) * 22.0;
            const strength = app.actionStrength(name);
            e.drawText(name, vec2(-254, y), if (strength > 0.0) ink else faint, 13.0, font);
            e.drawRect(vec2(-130, y + 3), vec2(110, 12), color(1, 1, 1, 0.08), true, 1.0);
            e.drawRect(vec2(-130, y + 3), vec2(110.0 * strength, 12), accent, true, 1.0);
            e.drawText(app.describeAction(name), vec2(-10, y), faint, 12.0, font);
            row += 1;
        }
        e.drawText(self.map_said, vec2(-254, 108), warm, 12.0, font);
    }

    fn ballCard(self, e: Entity) {
        card(e, vec2(-620, 150), vec2(750, 150), "left, right, jump - and the left stick");
        e.drawLine(vec2(-580, 260), vec2(-40, 260), color(1, 1, 1, 0.2), 2.0);
        const at = self.ball - vec2(0, self.lift + 2.0);
        e.drawCircle(at, 18.0, accent, true, 1.0);
        for (self.rings) |r| e.drawArc(at, 20.0 + r * 70.0, 0.0, math.tau, warm.with_alpha(1.0 - r / 1.2), 3.0);
    }

    fn padsCard(self, e: Entity) {
        card(e, vec2(150, -200), vec2(470, 230), "Controllers");
        const pads = app.connectedPads();
        if (pads.len == 0) {
            e.drawText("none plugged in", vec2(166, -160), faint, 14.0, font);
            return;
        }
        for (pads) |pad, i| {
            if (i >= 2) break;
            const top = vec2(170 + float(i) * 230.0, -160);
            e.drawText(f"pad {pad}", top, ink, 14.0, font);
            for ([vec2(40, 80), vec2(140, 80)]) |middle, side| {
                const stick = app.padStick(if (side == 0) .left else .right, pad);
                e.drawCircle(top + middle, 34.0, color(1, 1, 1, 0.12), true, 1.0);
                e.drawCircle(top + middle + stick * 26.0, 10.0, accent, true, 1.0);
            }
            const left = app.padAxis(.left_trigger, pad);
            const right = app.padAxis(.right_trigger, pad);
            e.drawRect(top + vec2(0, 130), vec2(80.0 * left, 10), warm, true, 1.0);
            e.drawRect(top + vec2(100, 130), vec2(80.0 * right, 10), warm, true, 1.0);
            var down: [string] = [];
            for (GamepadButton.members()) |button| if (app.padButtonDown(button, pad)) down.append(button.name());
            e.drawText(down.join(" "), top + vec2(0, 150), ink, 12.0, font);
        }
    }

    fn touchCard(self, e: Entity) {
        card(e, vec2(150, 50), vec2(470, 250), f"Touches{if (app.touchFromMouse()) ", the mouse standing in" else ""}");
        const count = app.touchCount();
        e.drawText(f"{count} fingers down", vec2(166, 82), faint, 13.0, font);
        for (range(count)) |i| {
            const finger = app.touchAt(i) orelse continue;
            const at = app.screenToWorld(finger.position.x, finger.position.y);
            e.drawCircle(at, 26.0, warm.with_alpha(0.5), true, 1.0);
            e.drawText(f"{finger.finger}", at - vec2(5, 10), ink, 14.0, font);
        }
    }
}

/// A key, a mouse button or a controller's button going down: what an
/// action can be bound to.
fn pressed(event: InputEvent) bool {
    if (event is KeyEvent) return event.pressed and !event.echo;
    if (event is MouseButtonEvent) return event.pressed;
    if (event is PadButtonEvent) return event.pressed;
    return false;
}

fn card(e: Entity, at: vec2, size: vec2, title: string) {
    e.drawRect(at, size, color(0.13, 0.15, 0.19, 0.92), true, 1.0);
    e.drawRect(at, size, color(0.36, 0.42, 0.55, 0.6), false, 1.0);
    e.drawText(title, at + vec2(14, 8), faint, 14.0, font);
}
