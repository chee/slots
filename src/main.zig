const std = @import("std");
const fruit: [6][]const u8 = .{ "🍒", "🍑", "🍐", "\u{001b}[2m7", "🍇", "🍋" };
const slotfmt = "┣ {s} {s} {s} ┫";
const machine_len = "┣    ┫".len;
const stderr = std.io.getStdErr();
var buffer: [100]u8 = undefined;
const rando = std.crypto.random;

// assuming we can always write
fn print(bytes: []const u8) usize {
    return stderr.write(bytes) catch unreachable;
}

// gulp gulp gulp
fn write(buf: []u8, comptime fmt: []const u8, args: anytype) void {
    _ = std.fmt.bufPrint(buf, fmt, args) catch unreachable;
}

fn clear(chars: usize) void {
    const len: usize = if (chars > 9) 5 else 6;
    write(buffer[0..len], "\x1b[{d}D", .{chars + 1});
    _ = print(buffer[0..len]);
    _ = print("\x1b[0K");
}

fn print_fruit(one: usize, two: usize, three: usize) usize {
    const fone: []const u8 = fruit[one];
    const ftwo: []const u8 = fruit[two];
    const fthree: []const u8 = fruit[three];
    const len: usize = fone.len + ftwo.len + fthree.len + machine_len;
    write(buffer[0..len], slotfmt, .{ fone, ftwo, fthree });
    _ = print(buffer[0..len]);
    return len;
}

fn random_fruit() usize {
    return rando.uintLessThan(usize, fruit.len);
}

fn print_random_fruit() usize {
    return print_fruit(random_fruit(), random_fruit(), random_fruit());
}

pub fn main() !void {
    var i: usize = 40;
    while (i > 0) : (i -= 1) {
        const len = print_random_fruit();
        const delay: usize = switch (i) {
            5...1000 => 50,
            4 => 100,
            3 => 200,
            2 => 300,
            1 => 600,
            else => unreachable,
        };
        std.time.sleep(delay * std.time.ns_per_ms);
        clear(len);
    }
    const one = random_fruit();
    const two = random_fruit();
    const three = random_fruit();
    _ = print_fruit(one, two, three);
    _ = print("\n");

    if (one == two and two == three) {
        _ = print("\u{001b}[5;3;1;2m✨ WINNER !! ✨\n");
        std.process.exit(0);
    } else if (one == two or two == three or one == three) {
        _ = print("\u{001b}[5;3;1;2;m yay 🪙\n");
        std.process.exit(0);
    }

    // c/o jakechampion, fail if there is no win
    std.process.exit(7);
}
