const std = @import("std");

fn GetlineError(comptime T: type) type {
    return error{ StreamTooLong, EndOfFile } || T.Error;
}

/// Gets a line of input. Gets at most stringp.len characters. Updates stringp.*
/// to point at the end of the string. Return the matched line. The '\n'
/// is not put into the string.
///
/// Return the character following the \n normally,
///        error.EndOfFile                at end of file,
///        error.LineTooLong              if the line is too long.
pub fn getline(stringp: *[]u8, stream: anytype) GetlineError(@TypeOf(stream))![]u8 {
    const result = try stream.readUntilDelimiterOrEof(stringp.*, '\n');
    stringp.* = stringp.*[(result orelse &[_]u8{}).len..];
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
