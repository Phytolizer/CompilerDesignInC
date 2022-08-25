const std = @import("std");
const globals = @import("globals.zig");

fn GetlineError(comptime T: type) type {
    return error{ StreamTooLong, EndOfFile } || T.Error;
}

fn lenOfMaybe(slice: ?[]u8) usize {
    return if (slice) |s| s.len else 0;
}

/// Gets a line of input. Gets at most stringp.len characters. Updates stringp.*
/// to point at the end of the string. Return the matched line. The '\n'
/// is not put into the string.
///
/// Return the matched line normally,
///       error.EndOfFile   at end of file,
///       error.LineTooLong if the line is too long.
fn getline(stringp: *[]u8, stream: anytype) GetlineError(@TypeOf(stream))![]u8 {
    const result = try stream.readUntilDelimiterOrEof(stringp.*, '\n');
    stringp.* = stringp.*[lenOfMaybe(result)..];
    return result orelse error.EndOfFile;
}

test "getline" {
    const test_str = "Hello\nWorld";
    var stream = std.io.fixedBufferStream(test_str);
    var reader = stream.reader();
    var str = try std.testing.allocator.dupe(u8, test_str);
    defer std.testing.allocator.free(str);
    const first_line = try getline(&str, reader);
    try std.testing.expectEqualStrings("Hello", first_line);
    const second_line = try getline(&str, reader);
    try std.testing.expectEqualStrings("World", second_line);
    try std.testing.expectError(error.EndOfFile, getline(&str, reader));
}

fn lookahead(state: anytype) !?u8 {
    return lookaheadImpl(@TypeOf(state.ifile.unbuffered_reader), state);
}

fn lookaheadImpl(comptime Reader: type, state: *globals.State(Reader)) !?u8 {
    var buf = [_]u8{0};
    const nread = try state.ifile.reader().readAll(&buf);
    try state.ifile.putBackByte(buf[0]);
    return if (nread == 0) null else buf[0];
}

pub fn getExpr(state: anytype) !?[]u8 {
    return getExprImpl(@TypeOf(state.ifile.unbuffered_reader), state);
}

fn getExprImpl(comptime Reader: type, state: *globals.State(Reader)) !?[]u8 {
    var i: usize = 0;
    var p: []u8 = &state.input_buf;
    if (state.verbosity > 1) {
        std.debug.print("b{d}: ", .{state.actual_lineno});
    }
    if (try lookahead(state) == @as(u8, '%')) {
        return null;
    }
    state.lineno = state.actual_lineno;
    while (true) {
        const line = try getline(&p, state.ifile.reader());
        i += line.len;
        if (try lookahead(state) == null) {
            return error.RuleTooLong;
        }
        state.actual_lineno += 1;
        if (line.len == 0) {
            continue;
        }
        if (!std.ascii.isSpace(try lookahead(state) orelse break)) {
            break;
        }
        p[0] = '\n';
        p = p[1..];
    }
    const expr = if (try lookahead(state) != null)
        state.input_buf[0..i]
    else
        null;
    if (state.verbosity > 1) {
        std.debug.print("{s}\n", .{expr orelse "--EOF--"});
    }
    return expr;
}

test "getExpr" {
    const test_str = "\n\nHello\nWorld\n% comment";
    var stream = std.io.fixedBufferStream(test_str);
    var reader = stream.reader();
    var state = globals.State(@TypeOf(reader)){
        .ifile = std.io.peekStream(1, reader),
    };
    const first = try getExpr(&state);
    try std.testing.expectEqualStrings("Hello", first.?);
    const second = try getExpr(&state);
    try std.testing.expectEqualStrings("World", second.?);
    try std.testing.expect(try getExpr(&state) == null);
}
