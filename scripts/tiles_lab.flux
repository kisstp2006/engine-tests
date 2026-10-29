// tiles_lab.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const sheet = "res://art/tiles.png";
const ink = color(0.95, 0.96, 0.98);
const faint = color(0.75, 0.78, 0.84);
const names = ["grass", "path", "stone wall", "water", "brick", "flowers", "sand", "planks"];
const columns = 40;
const rows = 22;
const grass = 0;
const path = 1;
const stone = 2;
const water = 3;
const brick = 4;
const flowers = 5;
const sand = 6;
const planks = 7;

/// A garden of tiles laid out by a script and painted by hand. The map is
/// built cell by cell with `app.paintTile`: a stone wall round it, a pond
/// ringed with sand, a brick hut floored with planks and a path from its
/// door, grass with flowers in it. The left button paints the brush, the
/// right one grass; 1 to 8 choose the brush, M mirrors what it paints, F
/// fills the patch under the pointer - a flood fill of the script's own,
/// read with `app.tileAt` - and R lays a new garden out. The walls stop the
/// walker, as the tile set says, and the water slows it.
struct TilesLab {
    var brush: int = stone;
    var mirror: bool = false;
    var hover_x: int = -1;
    var hover_y: int = -1;
    var said: string = "";

    fn ready(self) {
        self.build();
    }

    /// The tile `tile` of the sheet, four to a row, at `x`, `y`.
    fn paint(self, x: int, y: int, tile: int) {
        app.paintTile(self.entity, x, y, tile % 4, tile / 4);
    }

    fn build(self) {
        for (range(rows)) |y| {
            for (range(columns)) |x| {
                const edge = x == 0 or y == 0 or x == columns - 1 or y == rows - 1;
                self.paint(x, y, if (edge) stone else if (math.random_range(0.0, 1.0) < 0.08) flowers else grass);
            }
        }
        // The pond, and the sand round it.
        const middle = vec2(math.random_range(25.0, 31.0), math.random_range(9.0, 13.0));
        for (range(1, rows - 1)) |y| {
            for (range(1, columns - 1)) |x| {
                const d = (vec2(float(x), float(y)) - middle) / vec2(6.0, 4.0);
                const far = d.length();
                if (far < 1.0) self.paint(x, y, water) else if (far < 1.35) self.paint(x, y, sand);
            }
        }
        // The hut: brick walls, a plank floor, a door at the bottom.
        for (range(10, 17)) |y| {
            for (range(5, 13)) |x| {
                const wall = x == 5 or x == 12 or y == 10 or y == 16;
                self.paint(x, y, if (wall) brick else planks);
            }
        }
        self.paint(8, 16, planks);
        // The path from the door, down and along to the pond.
        for (range(17, 19)) |y| self.paint(8, y, path);
        for (range(8, 24)) |x| self.paint(x, 19, path);
        // The flowers by the door, the one on the right mirrored.
        self.paint(7, 17, flowers);
        self.paint(9, 17, flowers);
        app.setTile(self.entity, 9, 17, app.tileAt(self.entity, 7, 17).mirrored(true, false));
        self.said = "A new garden";
    }

    fn update(self, dt: float) {
        const map = self.entity;
        if (app.cellAt(map, app.pointerInWorld())) |cell| {
            self.hover_x = cell.x;
            self.hover_y = cell.y;
        }
        const inside = self.hover_x >= 0 and self.hover_y >= 0 and self.hover_x < columns and self.hover_y < rows;
        if (inside and app.mouseButtonDown(.left)) self.brushAt(self.hover_x, self.hover_y, self.brush);
        if (inside and app.mouseButtonDown(.right)) self.brushAt(self.hover_x, self.hover_y, grass);
        const keys: [Key] = [.@"1", .@"2", .@"3", .@"4", .@"5", .@"6", .@"7", .@"8"];
        for (keys) |key, i| {
            if (app.keyJustPressed(key)) self.brush = i;
        }
        if (app.keyJustPressed(.m)) self.mirror = !self.mirror;
        if (app.keyJustPressed(.r)) self.build();
        if (app.keyJustPressed(.f) and inside) self.fill(self.hover_x, self.hover_y);
        map.queueRedraw();
    }

    fn brushAt(self, x: int, y: int, tile: int) {
        self.paint(x, y, tile);
        if (self.mirror) app.setTile(self.entity, x, y, app.tileAt(self.entity, x, y).mirrored(true, false));
    }

    /// The patch of one tile the pointer is over, painted with the brush:
    /// cells taken from a list kept as a queue, each one's neighbours of the
    /// same tile added.
    fn fill(self, x: int, y: int) {
        const map = self.entity;
        const from = app.tileAt(map, x, y);
        if (from.x + from.y * 4 == self.brush) return;
        var queue: [vec2] = [vec2(float(x), float(y))];
        var seen: [string: bool] = {};
        var count = 0;
        while (queue.len > 0 and count < columns * rows) {
            const at = queue.remove(0);
            const cx = int(at.x);
            const cy = int(at.y);
            const key = f"{cx},{cy}";
            if (seen.has(key) or cx < 0 or cy < 0 or cx >= columns or cy >= rows) continue;
            seen[key] = true;
            const here = app.tileAt(map, cx, cy);
            if (here.x != from.x or here.y != from.y) continue;
            self.brushAt(cx, cy, self.brush);
            count += 1;
            for ([vec2(1, 0), vec2(-1, 0), vec2(0, 1), vec2(0, -1)]) |step| queue.append(at + step);
        }
        self.said = f"Filled {count} tiles of {names[from.x + from.y * 4]}";
    }

    fn draw(self) {
        const e = self.entity;
        const size = app.tileSizeOf(e);
        // The cell under the pointer.
        if (self.hover_x >= 0 and self.hover_y >= 0 and self.hover_x < columns and self.hover_y < rows) {
            e.drawRect(vec2(float(self.hover_x) * size[0], float(self.hover_y) * size[1]), vec2(size[0], size[1]), color(1, 1, 1, 0.9), false, 2.0);
        }
        // The sheet, the brush marked on it.
        const at = vec2(1100, 40);
        e.drawRect(at - vec2(8, 30), vec2(144, 110), color(0, 0, 0, 0.55), true, 1.0);
        e.drawText("the sheet: 1 to 8", at - vec2(0, 26), faint, 13.0, font);
        e.drawTexture(sheet, at, vec2(128, 64));
        e.drawRect(at + vec2(float(self.brush % 4) * 32.0, float(self.brush / 4) * 32.0), vec2(32, 32), color(1, 0.9, 0.3), false, 2.0);
        e.drawText(f"{names[self.brush]}{if (self.mirror) ", mirrored" else ""}", at + vec2(0, 66), ink, 13.0, font);
        // What is going on, along the bottom.
        const used = app.usedCells(e);
        const across = if (used) |u| u.size.x else 0;
        const down = if (used) |u| u.size.y else 0;
        e.drawRect(vec2(0, 704), vec2(1280, 16), color(0, 0, 0, 0.7), true, 1.0);
        e.drawText(f"{self.said}  |  {across} x {down} tiles of {int(size[0])} px  |  left paints, right grass, M mirror, F fill, R new garden  |  arrows or WASD walk", vec2(8, 704), faint, 12.0, font);
    }
}
