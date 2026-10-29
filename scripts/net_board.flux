// net_board.flux
const math = @import("math");

const font = "res://fonts/NotoSans-Regular.ttf";
const ink = color(0.9, 0.92, 0.96);
const faint = color(0.62, 0.66, 0.74);
const port = 47500;
const board_at = vec2(-600, -170);
const board_size = vec2(760, 440);

/// A board shared over the network: H hosts a game on this machine's LAN,
/// J joins the one on this machine, F looks for games on the LAN and E
/// joins the first one found, L leaves. Once on, everyone's pointer is sent
/// to everyone each frame on the sequenced channel and drawn in their
/// colour; a click puts a stamp on everyone's board and T says a line,
/// both on the reliable one. Who joined and left, and each peer's ping, are
/// shown as they come.
struct NetBoard {
    var pointers: [int: vec2] = {};
    var stamps: [vec2] = [];
    var stamp_peers: [int] = [];
    var lines: [string] = [];
    var lines_said: int = 0;

    fn ready(self) {
        net.peer_joined.connect(fn (peer: int, hello: string) {
            self.write(f"{peer} joined, saying \"{hello}\"");
        });
        net.peer_left.connect(fn (peer: int, reason: string) {
            self.write(f"{peer} left: {reason}");
            _ = self.pointers.remove(peer);
        });
        net.message.connect(fn (peer: int, value: any) {
            self.heard(peer, value);
        });
        net.joined.connect(fn (me: int) {
            self.write(f"taken in, as peer {me}");
        });
        net.left.connect(fn (reason: string) {
            self.write(f"off the game: {reason}");
            self.pointers = {};
        });
    }

    fn write(self, line: string) {
        self.lines.append(f"{time.now().format("H:mm:ss")}  {line}");
        if (self.lines.len > 12) _ = self.lines.remove(0);
    }

    /// What a peer sent: where its pointer is, a stamp, or a line.
    fn heard(self, peer: int, value: any) {
        const kind = value["kind"];
        const at = vec2(float(value.get("x", 0.0)) catch 0.0, float(value.get("y", 0.0)) catch 0.0);
        if (kind == "pointer") self.pointers[peer] = at;
        if (kind == "stamp") self.stamp(at, peer);
        if (kind == "line") self.write(f"{peer}: {value["text"]}");
    }

    fn stamp(self, at: vec2, peer: int) {
        self.stamps.append(at);
        self.stamp_peers.append(peer);
        if (self.stamps.len > 60) {
            _ = self.stamps.remove(0);
            _ = self.stamp_peers.remove(0);
        }
    }

    fn update(self, dt: float) {
        if (app.keyJustPressed(.h)) {
            net.host(port, 8, "Fluxion samples", "a shared board") catch |e| {
                self.write(f"not hosting: {e.name}");
                return;
            };
            self.write(f"hosting on port {net.port()}");
        }
        if (app.keyJustPressed(.j)) self.join("127.0.0.1", port);
        if (app.keyJustPressed(.f)) {
            net.search(port) catch |e| self.write(f"not looking: {e.name}");
            self.write("looking for games on the LAN");
        }
        if (app.keyJustPressed(.e)) {
            const found = net.servers();
            if (found.len > 0) self.join(found[0]["address"], int(found[0]["port"]) catch port) else self.write("no game found yet");
        }
        if (app.keyJustPressed(.l)) {
            net.leave();
            self.write("left");
        }
        const pointer = app.pointerInWorld();
        const on_board = pointer.x > board_at.x and pointer.y > board_at.y and pointer.x < board_at.x + board_size.x and pointer.y < board_at.y + board_size.y;
        if (net.isOnline()) {
            if (on_board) _ = net.sendAll({"kind": "pointer", "x": pointer.x, "y": pointer.y}, .sequenced);
            if (app.keyJustPressed(.t)) {
                self.lines_said += 1;
                const text = f"hello, number {self.lines_said}";
                _ = net.sendAll({"kind": "line", "text": text});
                self.write(f"{net.id()} (me): {text}");
            }
        }
        if (on_board and app.mouseButtonJustPressed(.left)) {
            self.stamp(pointer, net.id());
            if (net.isOnline()) _ = net.sendAll({"kind": "stamp", "x": pointer.x, "y": pointer.y});
        }
        self.entity.queueRedraw();
    }

    fn join(self, address: string, at_port: int) {
        net.join(address, at_port, f"hello from {app.backendInUse().name()}") catch |e| {
            self.write(f"not joining: {e.name}");
            return;
        };
        self.write(f"joining {address}:{at_port}");
    }

    fn draw(self) {
        const e = self.entity;
        e.drawRect(board_at, board_size, color(0.12, 0.14, 0.18), true, 1.0);
        e.drawRect(board_at, board_size, color(0.36, 0.42, 0.55, 0.6), false, 1.0);
        for (self.stamps) |at, i| e.drawCircle(at, 9.0, hue(self.stamp_peers[i]).with_alpha(0.85), true, 1.0);
        for (self.pointers.keys()) |peer| {
            const at = self.pointers[peer];
            e.drawCircle(at, 7.0, hue(peer), false, 2.0);
            e.drawText(f"{peer}", at + vec2(10, -8), hue(peer), 13.0, font);
        }
        const mine = app.pointerInWorld();
        e.drawCircle(mine, 5.0, hue(net.id()), true, 1.0);

        // Who this is, and who else is on.
        const x = 190.0;
        e.drawText(f"{net.role().name()}  |  peer {net.id()}  |  {if (net.isOnline()) "online" else "alone"}", vec2(x, -170), ink, 15.0, font);
        var y = -140.0;
        for (net.peers()) |peer| {
            e.drawText(f"peer {peer}: {int(net.ping(peer) * 1000.0)} ms, {net.address(peer)}", vec2(x, y), hue(peer), 13.0, font);
            y += 20.0;
        }
        const found = net.servers();
        if (found.len > 0) {
            e.drawText("found on the LAN:", vec2(x, y + 6.0), faint, 13.0, font);
            for (found) |one| {
                y += 20.0;
                e.drawText(f"{one["name"]} at {one["address"]}:{one["port"]}, {one["players"]} of {one["max_players"]}", vec2(x, y + 6.0), ink, 12.0, font);
            }
        }
        for (self.lines) |line, i| e.drawText(line, vec2(x, 40.0 + float(i) * 19.0), faint, 12.0, font);
        e.drawText("H host  J join this machine  F find on the LAN, E join it  L leave  T say a line  click a stamp", vec2(-600, 290), faint, 14.0, font);
    }
}

/// A colour of its own for each peer.
fn hue(peer: int) color {
    const turn = float(peer) * 0.618;
    return color(0.55 + 0.45 * math.sin(turn * math.tau), 0.55 + 0.45 * math.sin((turn + 0.33) * math.tau), 0.55 + 0.45 * math.sin((turn + 0.66) * math.tau));
}
