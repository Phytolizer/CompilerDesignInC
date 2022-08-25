const std = @import("std");

pub fn State(comptime Reader: type) type {
    return struct {
        allocator: std.mem.Allocator,
        verbosity: usize = 0,
        no_lines: bool = false,
        unix: bool = false,
        public: bool = false,
        template: []const u8 = "lex.par",
        actual_lineno: usize = 1,
        lineno: usize = 1,
        input_buf: [2048]u8 = undefined,
        input_file_name: []const u8 = "",
        ifile: std.io.PeekStream(.{ .Static = 1 }, Reader) = undefined,
        ofile: std.fs.File.Writer = undefined,
    };
}
