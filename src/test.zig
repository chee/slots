const std = @import("std");

pub fn main() void {
    std.log.info("{u}", .{"🔥"[0]});
}
