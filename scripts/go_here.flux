// go_here.flux
const math = @import("math");

/// A click on the floor sends every agent of the group `agents` there, each
/// to its own spot round the point the click meets on the navigation mesh
/// (`castRay3D`, `closestNavigationPoint`); the words say how many are
/// there. N shows or hides the navigation mesh and the agents' ways.
struct GoHere {
    fn ready(self) {
        app.setDebugView("navigation", true);
    }

    fn update(self, dt: float) {
        if (app.keyJustPressed(.n)) app.setDebugView("navigation", !app.isDebugViewOn("navigation"));
        const agents = app.groupMembers("agents");
        var there = 0;
        for (agents) |agent| {
            if (app.isTargetReached(agent)) there += 1;
        }
        if (app.find("There")) |words| words.get(Label).text = f"{there} of {agents.len} agents there";
        if (!app.mouseButtonJustPressed(.left)) return;
        const camera = app.currentCamera3D() orelse return;
        const pointer = app.pointerOnScreen();
        const from = app.projectRayOrigin(camera, pointer) orelse return;
        const way = app.projectRayNormal(camera, pointer) orelse return;
        const hit = app.castRay3D(from, from + way * 200.0, 0xFFFFFFFF, false) orelse return;
        const goal = app.closestNavigationPoint(hit.point);
        if (app.find("Marker")) |marker| marker.get(Transform3D).position = goal + vec3(0, 0.03, 0);
        // A quarter turn apart round it.
        var turn = 0.0;
        for (agents) |agent| {
            agent.get(NavigationAgent3D).target_position = app.closestNavigationPoint(goal + vec3(math.cos(turn), 0, math.sin(turn)) * 0.9);
            turn += 1.5707963;
        }
        if (app.find("Going")) |words| words.get(Label).text = f"Going to {goal.x}, {goal.z}";
    }
}
