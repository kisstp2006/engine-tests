// nav_agent.flux

/// A character that walks to its NavigationAgent3D's target: where to head
/// next from `nextPathPosition`, the velocity it wants given to
/// `setAgentVelocity`, and moved by the one that keeps it out of the other
/// agents' way when it comes back in `velocity_computed`.
struct NavAgent {
    @export var speed: float = 3.5;
    @export var gravity: float = 18.0;
    var step: float = 0.0;

    fn ready(self) {
        self.entity.get(NavigationAgent3D).velocity_computed.connect(self.moved);
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
