// flux_tour.flux
const json = @import("json");
const math = @import("math");

/// Something that can be hurt, and says so: what `extends` and signals are
/// tried with.
struct Actor {
    var name: string = "actor";
    var hp: int = 10;
    signal hurt(amount: int);
    signal died(by: string);

    fn damage(self, amount: int, by: string) {
        self.hp -= amount;
        self.hurt.emit(amount);
        if (self.hp <= 0) self.died.emit(by);
    }

    fn describe(self) string {
        return f"{self.name} ({self.hp})";
    }
}

/// A boss takes half of what is dealt it.
struct Boss extends Actor {
    var phase: int = 1;

    fn damage(self, amount: int, by: string) {
        self.hp -= amount / 2;
        if (self.hp < 5) self.phase = 2;
    }
}

enum Weather {
    sun,
    rain,
    storm = 10,

    fn wet(self) bool {
        return switch (self) {
            .sun => false,
            .rain, .storm => true,
        };
    }
}

/// A port from words, or why not.
fn parsePort(text: string) !int {
    const n = try int(text);
    if (n < 1 or n > 65535) return error.OutOfRange(f"{n} is not a port");
    return n;
}

/// What was wrong with a port, in words; empty for none.
fn portProblem(text: string) string {
    _ = parsePort(text) catch |e| return e.message orelse e.name;
    return "";
}

/// The name of what is wrong with some JSON; empty for none.
fn jsonProblem(text: string) string {
    _ = json.parse(text) catch |e| return e.name;
    return "";
}

fn find(items: [string], wanted: string) ?int {
    for (items) |item, i| {
        if (item == wanted) return i;
    }
    return null;
}

fn counter() fn() int {
    var count = 0;
    return fn () int {
        count += 1;
        return count;
    };
}

fn fib(n: int) int {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

fn doubledLater(n: int) int {
    await wait(0.25);
    return n * 2;
}

/// The language, each part of it tried and checked as the scene starts - and
/// the parts that take time, a task awaited and a signal heard, once they
/// have - written out under the part they belong to, passed in green and
/// failed in red. A clock under them counts the seconds with `await`.
struct FluxTour {
    var groups: [string];
    var results: [string: [string]] = {};
    var passed: int = 0;
    var failed: int = 0;
    var seconds: int = 0;

    fn check(self, group: string, what: string, ok: bool) {
        if (!(group in self.results)) {
            self.groups.append(group);
            self.results[group] = [];
        }
        const mark = if (ok) "{color=#7ED99A|pass}" else "{color=#FF7A7A|FAIL}";
        self.results[group].append(f"{mark}  {what}");
        if (ok) self.passed += 1 else self.failed += 1;
        self.show();
    }

    fn ready(self) {
        self.values();
        self.collections();
        self.text();
        self.structs();
        self.enums();
        self.optionals();
        self.errors();
        self.functions();
        self.signals();
        self.vectors();
        self.data();
        self.later();
        self.tick();
    }

    fn values(self) {
        const g = "Values";
        self.check(g, "integers divide whole: 7 / 2 == 3", 7 / 2 == 3);
        self.check(g, "a float keeps its fraction: 7.0 / 2 == 3.5", 7.0 / 2 == 3.5);
        self.check(g, "% keeps the left side's sign: -7 % 3 == -1", -7 % 3 == -1);
        self.check(g, "int(\"42\") reads a number", (int("42") catch 0) == 42);
        self.check(g, "booleans: and, or, not", (true and !false) or false);
    }

    fn collections(self) {
        const g = "Lists and maps";
        var xs = [5, 3, 8, 1];
        xs.push(4);
        xs.sort();
        self.check(g, "push and sort: [1, 3, 4, 5, 8]", xs == [1, 3, 4, 5, 8]);
        self.check(g, "map, filter and reduce", xs.map(|x| x * 10)[0] == 10 and xs.filter(|x| x % 2 == 0) == [4, 8] and xs.reduce(|a, x| a + x, 0) == 21);
        self.check(g, "slices and negative indices", xs[1..3] == [3, 4] and xs[-1] == 8);
        self.check(g, "any, all, contains", xs.any(|x| x > 7) and xs.all(|x| x > 0) and xs.contains(4));
        var m: [string: int] = {};
        m["hp"] = 10;
        m["hp"] += 1;
        self.check(g, "a map's keys, get with a default, in", m["hp"] == 11 and m.get("xp", 0) == 0 and "hp" in m);
        self.check(g, "range, min, max, clamp", range(3) == [0, 1, 2] and min(3, 1, 2) == 1 and max([4, 9, 2]) == 9 and clamp(15, 0, 10) == 10);
    }

    fn text(self) {
        const g = "Text";
        self.check(g, "f-strings: {1 + 2} is 3", f"{1 + 2}" == "3");
        self.check(g, "split and join", "a,b,c".split(",").join("-") == "a-b-c");
        self.check(g, "upper, repeat, replace, trim", "hi".upper() == "HI" and "x".repeat(3) == "xxx" and "hello".replace("l", "L") == "heLLo" and " pad ".trim() == "pad");
        self.check(g, "characters, not bytes: \"héllo\" has 5", "héllo".chars().len == 5);
        self.check(g, "pad_start lines numbers up", "7".pad_start(3, "0") == "007");
    }

    fn structs(self) {
        const g = "Structs";
        const a = Actor{ .name = "goblin" };
        const b = Boss{ .name = "dragon", .hp = 20 };
        a.damage(3, "test");
        b.damage(30, "test");
        self.check(g, "a method changes its own fields", a.hp == 7);
        self.check(g, "extends: a boss's own damage, its parent's describe", b.hp == 5 and b.describe() == "dragon (5)");
        self.check(g, "fields left out take their defaults", b.phase == 1 and Actor{}.name == "actor");
        // The type left out where it is known from where the value goes.
        const c: Actor = .{ .name = "orc", .hp = 4 };
        self.check(g, ".{ ... } takes its type from where it goes", c.name == "orc" and c.hp == 4);
    }

    fn enums(self) {
        const g = "Enums and switch";
        const w: Weather = .rain;
        self.check(g, "a method of an enum, switching on itself", w.wet() and !Weather.sun.wet());
        self.check(g, "explicit values carry on: storm is 10", int(Weather.storm) == 10);
        self.check(g, "a member's name", w.name() == "rain");
        // A name that is not one as written - digits, a keyword - quoted.
        const @"while" = 3;
        self.check(g, "a quoted name: @\"while\" and .@\"1\"", @"while" == 3 and Key.@"1".name() == "1");
    }

    fn optionals(self) {
        const g = "Optionals";
        const list = ["a", "b", "c"];
        self.check(g, "a function that finds, or gives null", find(list, "b") == 1 and find(list, "z") == null);
        self.check(g, "orelse fills in", (find(list, "z") orelse -1) == -1);
        var seen = -1;
        if (find(list, "c")) |at| seen = at;
        self.check(g, "if (x) |value| unwraps", seen == 2);
    }

    fn errors(self) {
        const g = "Errors";
        self.check(g, "try passes a value through", (parsePort("8080") catch 0) == 8080);
        self.check(g, "an error of the runtime: InvalidInt", (parsePort("abc") catch |e| if (e.name == "InvalidInt") 1 else 2) == 1);
        self.check(g, "an error of our own, with a message", portProblem("70000") == "70000 is not a port");
        self.check(g, "no error, no message", portProblem("80") == "");
    }

    fn functions(self) {
        const g = "Functions";
        const next = counter();
        _ = next();
        _ = next();
        self.check(g, "a closure keeps what it closed over", next() == 3);
        const double = |x: int| x * 2;
        self.check(g, "a lambda", double(21) == 42);
        self.check(g, "recursion: fib(20) is 6765", fib(20) == 6765);
    }

    fn signals(self) {
        const g = "Signals";
        const p = Actor{ .hp = 3 };
        var hits = 0;
        var killer = "";
        p.hurt.connect(|amount| {
            hits += amount;
        });
        p.died.once(|by| {
            killer = by;
        });
        p.damage(1, "rat");
        p.damage(2, "wolf");
        p.damage(1, "bat");
        self.check(g, "connect hears every emit", hits == 4);
        self.check(g, "once hears the first and lets go", killer == "wolf" and p.died.connections() == 0);
    }

    fn vectors(self) {
        const g = "Vectors and colours";
        var pos = vec2(1, 2);
        pos += vec2(3, 4) * 2.0;
        self.check(g, "vec2 arithmetic: (7, 10)", pos == vec2(7, 10));
        self.check(g, "length, normalized, dot", vec2(3, 4).length() == 5.0 and vec2(3, 4).normalized().distance_to(vec2(0.6, 0.8)) < 0.0001 and vec2(3, 4).dot(vec2(1, 0)) == 3.0);
        const r = vec2(1, 0).rotated(math.pi / 2);
        self.check(g, "rotated a quarter turn", math.approx_eq(r.x, 0.0) and math.approx_eq(r.y, 1.0));
        self.check(g, "vec3 cross", vec3(1, 2, 3).cross(vec3(0, 0, 1)) == vec3(2, -1, 0));
        self.check(g, "colours mix", color(1, 0, 0).lerp(color(0, 0, 1), 0.5) == color(0.5, 0, 0.5));
    }

    fn data(self) {
        const g = "JSON";
        const text = "{\"name\": \"Ada\", \"level\": 3, \"tags\": [\"a\", \"b\"]}";
        const parsed: ?any = json.parse(text) catch null;
        self.check(g, "parse reads objects and lists", parsed != null and parsed.?["name"] == "Ada" and parsed.?["tags"][1] == "b");
        self.check(g, "stringify writes a map", json.stringify({"ok": true}) == "{\"ok\":true}");
        const back: ?any = json.parse(json.stringify(Actor{ .name = "saved" })) catch null;
        self.check(g, "a struct goes out and comes back as a map", back != null and back.?["name"] == "saved");
        self.check(g, "bad JSON is an error, not a crash", jsonProblem("{\"a\": }") != "" and jsonProblem("[1]") == "");
    }

    /// What takes time: a task's value, awaited.
    fn later(self) {
        const value = await doubledLater(21);
        self.check("Tasks", "await gives a task's value: 42, a quarter of a second later", value == 42);
        const both = [doubledLater(1), doubledLater(2)];
        var sum = 0;
        for (both) |task| sum += await task;
        self.check("Tasks", "two tasks at once, each awaited", sum == 6);
    }

    /// A clock counting the seconds with `await wait`.
    fn tick(self) {
        while (true) {
            await wait(1.0);
            self.seconds += 1;
            self.show();
        }
    }

    fn show(self) {
        var left = "";
        var right = "";
        for (self.groups) |group, i| {
            var part = f"{{b|{group}}}\n";
            for (self.results[group]) |line| part += f"{line}\n";
            part += "\n";
            if (i % 2 == 0) left += part else right += part;
        }
        app.find("Left").?.get(RichText).text = left;
        app.find("Right").?.get(RichText).text = right;
        const verdict = if (self.failed == 0) "{color=#7ED99A|every check passed}" else f"{{color=#FF7A7A|{self.failed} failed}}";
        app.find("Summary").?.get(RichText).text = f"{self.passed} passed, {verdict}    -    a clock of `await wait(1.0)`: {self.seconds} s";
    }
}
