// nav_agent.flux

/// A character that walks to its NavigationAgent3D's target: where to head
/// next from `nextPathPosition`, the velocity it wants given to
/// `setAgentVelocity`, and moved by the one that keeps it out of the other
/// agents' way when it comes back in `velocity_computed`. At a link's start
/// - `link_reached` - it jumps, or walks off where the link goes down.
struct NavAgent {
    @export var speed: float = 3.5;
    @export var gravity: float = 18.0;
    var step: float = 0.0;

    fn ready(self) {
        const agent = self.entity.get(NavigationAgent3D);
        agent.velocity_computed.connect(self.moved);
        agent.link_reached.connect(self.jump);
    }

    /// At a link's start: up or across, a jump; down, it walks off.
    fn jump(self, start: vec3, end: vec3) {
        const body = self.entity.get(CharacterBody3D);
        if (end.y > start.y - 0.3 and body.on_floor) body.velocity = vec3(body.velocity.x, 7.0, body.velocity.z);
    }

    fn fixed(self, dt: float) {
        self.step = dt;
        var want = vec3(0, 0, 0);
        if (!app.isNavigationFinished(self.entity)) {
            // The way is on the floor, the agent's middle above it.
            var to = app.nextPathPosition(self.entity) - self.entity.globalPosition3D().?;
            to.y = 0.0;
            if (to.length() > 0.01) want = to.normalized() * self.speed;
        }
        app.setAgentVelocity(self.entity, want);
    }

    fn moved(self, safe_velocity: vec3) {
        const body = self.entity.get(CharacterBody3D);
        body.velocity = vec3(safe_velocity.x, body.velocity.y - self.gravity * self.step, safe_velocity.z);
        app.moveAndSlide(self.entity);
    }
}
