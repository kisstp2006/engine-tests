// joints_lab.flux
const math = @import("math");

/// Bodies held by joints, and a skeleton that falls as bodies do. A chain
/// of ball joints with a lamp at its end swings from the world; a bridge
/// of planks hangs on hinges between two posts - its last plank held by a
/// second joint, on a collider of its own; a door swings on a hinge as far
/// as its limits. The skinned column is given a body for each of its bones,
/// made here as it starts, each held to the one below: R lets them fall as
/// a ragdoll and R again gives the bones back to the animation. Space
/// throws a ball from the camera at whatever it looks at; D gives the door
/// a push.
struct JointsLab {
    var parts: [Entity] = [];
    var thrown: int = 0;
    var falling: bool = false;

    fn ready(self) {
        self.makeRagdoll();
    }

    /// A body for each bone of the column: a capsule from the bone's root
    /// to the next one's, held to the body below by a ball joint that leans
    /// only so far. While they do not simulate they follow the animation.
    fn makeRagdoll(self) {
        const skinned = app.find("Skinned") orelse return;
        var below: ?Entity = null;
        for (["Root", "Middle", "Tip"]) |name| {
            const part = skinned.spawnChild();
            part.setName(f"{name} body");
            _ = part.add(Transform3D);
            _ = part.add(RigidBody3D);
            const shape = part.add(Collider3D);
            shape.shape = .capsule;
            shape.radius = 0.32;
            shape.height = 1.0;
            shape.offset = vec3(0, 0.5, 0);
            part.add(PhysicalBone3D).bone = name;
            if (below) |held| {
                const joint = part.add(Joint3D);
                joint.connected = held;
                joint.connected_position = vec3(0, 1, 0);
                joint.limit_swing = true;
                joint.swing = 0.7;
            }
            below = part;
            self.parts.append(part);
        }
    }

    fn update(self, dt: float) {
        if (app.keyJustPressed(.r)) {
            self.falling = !self.falling;
            for (self.parts) |part| part.get(PhysicalBone3D).simulate = self.falling;
        }
        if (app.keyJustPressed(.space)) self.throw();
        if (app.keyJustPressed(.d)) {
            const door = app.find("Door").?.get(RigidBody3D);
            door.angular_velocity = vec3(0, if (door.angular_velocity.y > 0.0) -3.0 else 3.0, 0);
        }
        app.find("Status").?.get(Label).text = f"{self.thrown} balls thrown  |  the column {if (self.falling) "falls as bodies, R gives it back" else "is animated, R lets it fall"}  |  Space throws, D pushes the door";
    }

    /// A ball from the camera, along where it looks, gone after six seconds.
    fn throw(self) {
        const camera = app.currentCamera3D();
        const from = app.globalPosition3D(camera) orelse return;
        const ahead = app.globalForward3D(camera) orelse return;
        const ball = app.newEntity(null);
        ball.setName(f"Ball {self.thrown}");
        ball.add(Transform3D).position = from + ahead * 1.0;
        ball.add(RigidBody3D).linear_velocity = ahead * 16.0 + vec3(0, 2, 0);
        const shape = ball.add(Collider3D);
        shape.shape = .sphere;
        shape.radius = 0.2;
        shape.density = 4.0;
        _ = ball.add(MeshInstance3D);
        const mesh = ball.add(PrimitiveMesh3D);
        mesh.shape = .sphere;
        mesh.radius = 0.2;
        ball.add(Material3D).material = "res://materials/3d_joints/ball.mat3d";
        self.thrown += 1;
        await wait(6.0);
        ball.despawn();
    }
}
