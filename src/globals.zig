const std = @import("std");

pub var verbosity: usize = 0;
pub var no_lines = false;
pub var unix = false;
pub var public = false;
pub var template = "lex.par";
pub var actualLineNo: usize = 1;
pub var lineNo: usize = 1;
pub var inputBuf: [2048]u8 = undefined;
pub var inputFileName: []const u8 = "";
pub var iFile: ?*std.fs.File = null;
pub var oFile: ?*std.fs.File = null;
