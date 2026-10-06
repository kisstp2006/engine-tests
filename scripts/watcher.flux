// watcher.flux

/// Always looks at the entity it is told to - its `-z` towards it -
/// through `lookAt3D`, wherever the two are in their trees.
struct Watcher {
    @export var target: string = "Moon";

    fn update(self, dt: float) {
        const other = app.find(self.target) orelse return;
        if (other.globalPosition3D()) |there| self.entity.lookAt3D(there);
    }
}
