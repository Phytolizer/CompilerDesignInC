const std = @import("std");

pub fn main() !void {}

test {
    const liblex = @import("liblex.zig");
    _ = liblex.input;
    _ = liblex.nfa;
}
