// picker.flux

/// What the 3D camera API can do from a script:
/// - a click picks the nearest shape of the group `pickable` the ray from
///   the camera through the pointer meets (`projectRayOrigin`,
///   `projectRayNormal`), and draws it with another material;
/// - the words named `Tag` follow the picked shape on the screen
///   (`unprojectPosition`);
/// - C goes to the next camera of the group `cameras` (`makeCurrent3D`),
///   O switches its projection.
struct Picker {
    var picked: ?Entity = null;
    /// The material the picked shape was drawn with.
    var was: string = "";

    fn update(self, dt: float) {
        if (app.keyJustPressed(.c)) self.nextCamera();
        if (app.keyJustPressed(.o)) {
            if (app.currentCamera3D()) |camera| {
                const lens = camera.get(Camera3D);
                lens.projection = if (lens.projection == .perspective) .orthogonal else .perspective;
            }
        }
        if (app.mouseButtonJustPressed(.left)) self.pick();
        self.tag();
    }

    fn nextCamera(self) {
        const cameras = app.groupMembers("cameras");
        if (cameras.len == 0) return;
        var next = 0;
        if (app.currentCamera3D()) |now| {
            for (cameras) |camera, i| {
                if (camera == now) next = (i + 1) % cameras.len;
            }
        }
        app.makeCurrent3D(cameras[next]) catch |e| print("no camera:", e.name);
    }

    fn pick(self) {
        const camera = app.currentCamera3D() orelse return;
        const pointer = app.pointerOnScreen();
        const from = app.projectRayOrigin(camera, pointer) orelse return;
        const way = app.projectRayNormal(camera, pointer) orelse return;
        var best = 1000000.0;
        var hit: ?Entity = null;
        for (app.groupMembers("pickable")) |shape| {
            if (shape.globalPosition3D()) |middle| {
                const along = (middle - from).dot(way);
                const nearest = from + way * along;
                if (along > 0.0 and nearest.distance_to(middle) < 0.8 and along < best) {
                    best = along;
                    hit = shape;
                }
            }
        }
        if (self.picked) |old| old.get(Material3D).material = self.was;
        self.picked = hit;
        if (hit) |shape| {
            const look = shape.get(Material3D);
            self.was = if (look.material) |held| held.resource_path else "";
            look.material = "res://materials/3d_cameras/picked.mat3d";
        }
    }

    fn tag(self) {
        const words = app.find("Tag") orelse return;
        const text = words.get(Text2D);
        text.text = "";
        const camera = app.currentCamera3D() orelse return;
        const shape = self.picked orelse return;
        const middle = shape.globalPosition3D() orelse return;
        if (app.unprojectPosition(camera, middle + vec3(0, 1, 0))) |seen| {
            words.get(Transform2D).position = seen;
            text.text = shape.name();
        }
    }
}
