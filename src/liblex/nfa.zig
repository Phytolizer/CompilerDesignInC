const std = @import("std");

const Allocator = std.mem.Allocator;

pub const Edge = union(enum) {
    Epsilon,
    Ccl,
    Empty,
    Char: u8,
};

pub const Anchor = enum(usize) {
    None = 0,
    Start = 0b01,
    End = 0b10,
    Both = 0b11,
};

pub const NFA = struct {
    const Set = std.StaticBitSet(std.math.maxInt(u8) + 1);

    edge: Edge = .Epsilon,
    bitset: Set = Set.initEmpty(),
    next: [2]?*NFA = .{ null, null },
    accept: ?[]const u8 = null,
    anchor: Anchor = .None,
};

pub const nfa_max = 768;
pub const str_max = 10 * 1024;

var nfa_states: []NFA = &.{};
var next_alloc: usize = 0;
const ssize = 32;
const Stack = struct {
    sstack: [ssize]*NFA = .{null} ** ssize,
    sp: usize = 0,

    const Self = @This();

    fn ok(self: *const Self) bool {
        return self.sp < ssize;
    }

    fn used(self: *const Self) usize {
        return self.sp;
    }

    fn clearStack(self: *Self) void {
        self.sp = 0;
    }

    fn push(self: *Self, x: *NFA) void {
        self.sstack[self.sp] = x;
        self.sp += 1;
    }

    fn pop(self: *Self) *NFA {
        self.sp -= 1;
        return self.sstack[self.sp];
    }
};

var stack = Stack{};

const mac_name_max = 34;
const mac_text_max = 80;

const Macro = struct {
    name: [mac_name_max]u8 = undefined,
    text: [mac_text_max]u8 = undefined,
};

var macros: std.StringHashMap(Macro) = undefined;

const Token = enum {
    Eos,
    Any,
    AtBol,
    AtEol,
    CclEnd,
    CclStart,
    CloseCurly,
    CloseParen,
    Closure,
    Dash,
    EndOfInput,
    L,
    OpenCurly,
    OpenParen,
    Optional,
    Or,
    PlusClose,
};

fn tokmap(c: u8) Token {
    return switch (c) {
        '$' => .AtEol,
        '(' => .OpenParen,
        ')' => .CloseParen,
        '*' => .Closure,
        '+' => .PlusClose,
        '-' => .Dash,
        '.' => .Any,
        '?' => .Optional,
        '[' => .CclStart,
        ']' => .CclEnd,
        '^' => .AtBol,
        '{' => .OpenCurly,
        '|' => .Or,
        '}' => .CloseCurly,
        else => .L,
    };
}

var input: usize = 0;
var s_input: []const u8 = &.{};
var current_tok: Token = .L;
var lexeme: u8 = 0;

fn match(t: Token) bool {
    return current_tok == t;
}

const Tracer = if (@import("builtin").mode == .Debug)
    struct {
        allocator: Allocator,
        lev: usize = 0,
        pub fn init(a: Allocator) @This() {
            return @This(){
                .allocator = a,
            };
        }
        pub fn enter(self: *@This(), f: []const u8) !void {
            const indent = try self.allocator.alloc(u8, self.lev * 4);
            defer self.allocator.free(indent);
            std.mem.set(u8, indent, ' ');
            std.debug.print("{s}enter {s} [{c}][{s:>10}]\n", .{ indent, f, lexeme, input });
            self.lev += 1;
        }
        pub fn leave(self: *@This(), f: []const u8) !void {
            const indent = try self.allocator.alloc(u8, self.lev * 4);
            defer self.allocator.free(indent);
            std.mem.set(u8, indent, ' ');
            std.debug.print("{s}leave {s} [{c}][{s:>10}]\n", .{ indent, f, lexeme, input });
            self.lev -= 1;
        }
    }
else
    struct {
        pub fn init(_: Allocator) @This() {
            return @This(){};
        }
        pub fn enter(_: *@This(), _: []const u8) !void {}
        pub fn leave(_: *@This(), _: []const u8) !void {}
    };

const Err = enum {
    Mem,
    BadExpr,
    Paren,
    Stack,
    Length,
    Bracket,
    Bol,
    Close,
    Strings,
    Newline,
    BadMac,
    NoMac,
    MacDepth,
};
fn errMsg(e: Err) []const u8 {
    return switch (e) {
        .Mem => "Not enough memory for NFA",
        .BadExpr => "Malformed regular expression",
        .Paren => "Missing close parenthesis",
        .Stack => "Internal error: Discard stack full",
        .Length => "Too many regular expressions or expression too long",
        .Bracket => "Missing [ in character class",
        .Bol => "^ must be at start of expression or after [",
        .Close => "+ ? or * must follow an expression or subexpression",
        .Strings => "Too many characters in accept actions",
        .Newline => "Newline in quoted string, use \\n to get newline into expression",
        .BadMac => "Missing } in macro expansion",
        .NoMac => "Macro doesn't exist",
        .MacDepth => "Macro expansions nested too deeply",
    };
}

const Warn = enum {
    StartDash,
    EndDash,
};
fn warnMsg(w: Warn) []const u8 {
    return switch (w) {
        .StartDash => "Treating dash in [-...] as a literal dash",
        .EndDash => "Treating dash in [...-] as a literal dash",
    };
}

fn warning(state: anytype, w: Warn) void {
    emitError(state, w, warnMsg, "WARNING");
}

fn parseErr(state: anytype, e: Err) noreturn {
    emitError(state, e, errMsg, "ERROR");
    std.process.exit(1);
}

fn emitError(state: anytype, t: anytype, table: fn (anytype) void, msg_type: []const u8) void {
    var stderr = std.io.getStdErr().writer();
    var bw = std.io.bufferedWriter(stderr);
    defer bw.flush() catch unreachable;
    var bww = bw.writer();
    bww.print("{s} (line {d}) {s}\n", .{
        msg_type,
        state.actual_lineno,
        table(t),
    }) catch unreachable;
    for (s_input[0..input]) |_| {
        bww.writeByte('-') catch unreachable;
    }
    bww.print("v\n{s}\n", .{s_input}) catch unreachable;
}

fn new(state: anytype) *NFA {
    _ = state;
}
